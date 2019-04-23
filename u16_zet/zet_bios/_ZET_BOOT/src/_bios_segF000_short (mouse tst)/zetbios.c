//---------------------------------------------------------------------------
//---------------------------------------------------------------------------
//  ZET Bios C Helper functions:
//  This file contains various functions in C called fromt the zetbios.asm
//  module. This module provides support fuctions and special code specific
//  to the Zet computer, specifically, special video support and disk support
//  for the SD and Flash types of disks. 
//
//  This code is compatible with the Open Watcom C Compiler.
//  Originally modified from the Bochs bios by Zeus Gomez Marmolejo
//---------------------------------------------------------------------------
//---------------------------------------------------------------------------

#include "zetbios.h"
////////////////////////////////////////////////////////////////////////////////////////////////
//#define BIOSMEM_SEG                       0xF000
//#define BIOSMEM_CURSOR_POS    0xFF90 
//#define BIOSMEM_CURSOR_TYPE  0xFF92

#define BIOSMEM_SEG           0x40
#define BIOSMEM_CURSOR_POS    0xe402 
#define BIOSMEM_CURSOR_TYPE   0xe404

#define SCROLL_DOWN    0
#define SCROLL_UP           1
#define NO_ATTR                 2
#define WITH_ATTR             3
        
//////////////////////////////////////
#define MODE_MAX   15
#define TEXT       0x00
#define GRAPH      0x01

#define CTEXT      0x00
#define MTEXT      0x01
#define CGA        0x02
#define PLANAR1    0x03
#define PLANAR4    0x04
#define LINEAR8    0x05

// for SVGA
#define LINEAR15   0x10
#define LINEAR16   0x11
#define LINEAR24   0x12
#define LINEAR32   0x13


typedef struct
{
    Bit8u  svgamode;
    Bit8u  class;             // TEXT, GRAPH 
    Bit8u  memmodel;   //CTEXT,MTEXT,CGA,PL1,PL2,PL4,P8,P15,P16,P24,P32 
    Bit8u  pixbits;
    Bit16u sstart;
    Bit8u  pelmask;
    Bit8u  dacmodel;    // 0 1 2 3 
} VGAMODES;

static VGAMODES vga_modes[MODE_MAX+1] =
{
    //mode  class  model bits sstart  pelm  dac
    {0x00, TEXT,  CTEXT,   4, 0xB800, 0xFF, 0x02},
    {0x01, TEXT,  CTEXT,   4, 0xB800, 0xFF, 0x02},
    {0x02, TEXT,  CTEXT,   4, 0xB800, 0xFF, 0x02},
    {0x03, TEXT,  CTEXT,   4, 0xB800, 0xFF, 0x02},
    {0x04, GRAPH, CGA,     2, 0xB800, 0xFF, 0x01},
    {0x05, GRAPH, CGA,     2, 0xB800, 0xFF, 0x01},
    {0x06, GRAPH, CGA,     1, 0xB800, 0xFF, 0x01},
    {0x07, TEXT,  MTEXT,   4, 0xB000, 0xFF, 0x00},
    {0x0D, GRAPH, PLANAR4, 4, 0xA000, 0xFF, 0x01},
    {0x0E, GRAPH, PLANAR4, 4, 0xA000, 0xFF, 0x01},
    {0x0F, GRAPH, PLANAR1, 1, 0xA000, 0xFF, 0x00},
    {0x10, GRAPH, PLANAR4, 4, 0xA000, 0xFF, 0x02},
    {0x11, GRAPH, PLANAR1, 1, 0xA000, 0xFF, 0x02},
    {0x12, GRAPH, PLANAR4, 4, 0xA000, 0xFF, 0x02},
    {0x13, GRAPH, LINEAR8, 8, 0xA000, 0xFF, 0x03},
    {0x6A, GRAPH, PLANAR4, 4, 0xA000, 0xFF, 0x02}
};

//static void     biosfn_write_teletype(Bit8u car, Bit8u page, Bit8u attr, Bit8u flag);
static void     biosfn_prnt_char(Bit8u car);
static void     biosfn_set_cursor_pos(Bit8u page, Bit16u cursor);
static void     biosfn_get_cursor_pos(Bit8u page, Bit16u *shape, Bit16u *pos);
static Bit8u    find_vga_entry(Bit8u mode);
static void    wrchar(Bit8u character);
static void mem_test (Bit16u tested_segment, Bit16u start, Bit16u end, Bit8u pattern, Bit8u inc);
///////////////////////////////////////////////////////////////////////////////////////////////

//--------------------------------------------------------------------------
// Low level assembly functions
//--------------------------------------------------------------------------
#pragma aux LED =         \
"       mov  dx, 0f102h      " \
"       out    dx, ax              " \
parm [ax] ;

#pragma aux get_CS = "mov ax, cs" modify [ax];
#pragma aux get_SS = "mov ax, ss" modify [ax];

#pragma aux read_byte = \
"       push ds          " \
"       mov  ds, ax      " \
"       mov  al, ds:[bx] " \
"       pop  ds          " \
parm [ax] [bx] modify [al];

#pragma aux read_word = \
"       push ds          " \
"       mov  ds, ax      " \
"       mov  ax, ds:[bx] " \
"       pop  ds          " \
parm [ax] [bx] modify [ax];

#pragma aux write_byte = \
"       push ds          " \
"       mov  ds, ax      " \
"       mov  ds:[bx], dl " \
"       pop  ds          " \
parm [ax] [bx] [dl];

#pragma aux write_word = \
"       push ds          " \
"       mov  ds, ax      " \
"       mov  ds:[bx], dx " \
"       pop  ds          " \
parm [ax] [bx] [dx];

#pragma aux inb  = "in  al, dx" parm [dx] modify [al];
#pragma aux outb = "out dx, al" parm [dx] [al];
#pragma aux inw  = "in  ax, dx" parm [dx] modify [ax];
#pragma aux outw = "out dx, ax" parm [dx] [ax];

#pragma aux memsetb = \
"       push es          " \
"       mov  es, bx      " \
"       cld              " \
"       rep  stosb       " \
"       pop  es          " \
parm [bx] [di] [al] [cx] modify [di cx];

#pragma aux memcpyb = \
"       push ds          " \
"       push es          " \
"       mov  ds, ax      " \
"       mov  es, bx      " \
"       cld              " \
"       rep  movsb       " \
"       pop  es          " \
"       pop  ds          " \
parm [bx] [di] [ax] [si] [cx] modify [di si cx];

#pragma aux wrch = \
"       xor  bx, bx      " \
"       mov  ah, 0x0e    " \
"       int  0x10        " \
parm [al] modify [ah bx];

#pragma aux wrchar = \
"       xor  bx, bx      " \
"       mov  ah, 0x0e    " \
parm [al] modify [ah bx];

//--------------------------------------------------------------------------
void Delay (Bit16u a) { while (--a!=0); }

static void init_comport(void)
{
        outb(UART_LC, 0x83);    // set up uart
 //       outb(UART_TR, 0x01);    // set up uart for 115.2kbps
//        outb(UART_IE,  0x00);     // set up uart for 115.2kbps
        outb(UART_TR, 0x03);    // set up uart for 38.4 kbps
        outb(UART_IE,  0x00);     // set up uart for 38.4 kbps
        outb(UART_LC, 0x03);    // set up uart
}

static void wcomport(Bit8u c)            //////////////////////// 2013.06.18     Transmit buffer empty byte -? 
{
    Bit8u  ticks;
    ticks = read_byte(0x0040, 0x006C); // get current tick count

    while(! (inb(UART_LS) & 0x40)) {     // wait for transmitter buffer to empty
       /// if((ticks + 50) < read_byte(0x0040, 0x006C)) break;
    }
    /// while((ticks + 70) < read_byte(0x0040, 0x006C));
    //Delay(100); // CLK ==12 000k,  Rate==115k  = OK!!!!
    outb(UART,c);
}
//--------------------------------------------------------------------------
static void send(Bit16u action, Bit8u  c) //////////////////////// 2013.06.16
{
    if(action & BIOS_PRINTF_SCREEN) {
        // if(c == '\n') biosfn_prnt_char('\r');
        biosfn_prnt_char(c);
    }
    if(action & BIOS_PRINTF_COMPORT)
    {
         if(c == '\n')
         {
             wcomport(0xA);
             wcomport(0xD);      
         }
        wcomport(c);
    }    
}
//--------------------------------------------------------------------------
static void put_int(Bit16u action, short val, short width, bx_bool neg)
{
    short nval = val / 10;
    if(nval) put_int(action, nval, width - 1, neg);
    else {
        while(--width > 0) send(action, ' ');
        if(neg) send(action, '-');
    }
    send(action, val - (nval * 10) + '0');
}
//--------------------------------------------------------------------------
static void put_uint(Bit16u action, unsigned short val, short width, bx_bool neg)
{
    unsigned short nval = val / 10;
    if(nval) put_uint(action, nval, width - 1, neg);
    else {
        while(--width > 0) send(action, ' ');
        if(neg) send(action, '-');
    }
    send(action, val - (nval * 10) + '0');
}
//--------------------------------------------------------------------------
static void put_luint(Bit16u action, unsigned long val, short width, bx_bool neg)
{
    unsigned long nval = val / 10;
    if(nval) put_luint(action, nval, width - 1, neg);
    else {
        while(--width > 0) send(action, ' ');
        if(neg) send(action, '-');
    }
    send(action, val - (nval * 10) + '0');
}
//--------------------------------------------------------------------------
static void put_str(Bit16u action, Bit16u segment, Bit16u offset)
{
    Bit8u c;
    while(c = read_byte(segment, offset)) {
        send(action, c);
        offset++;
    }
}

//--------------------------------------------------------------------------
//--------------------------------------------------------------------------
// bios_printf()  A compact variable argument printf function.
//   Supports %[format_width][length]format
//   where format can be x,X,u,d,s,S,c
//   and the optional length modifier is l (ell)
//--------------------------------------------------------------------------
//--------------------------------------------------------------------------
static void bios_printf(Bit16u action, Bit8u *s, ...)
{
    Bit8u    c;
    bx_bool  in_format;
    short    i;
    Bit16u  *arg_ptr;
    Bit16u   arg_seg, arg, nibble, hibyte, format_width, hexadd;

    arg_ptr = (Bit16u  *)&s;
    arg_seg = get_SS();

    in_format = 0;
    format_width = 0;

    if((action & BIOS_PRINTF_DEBHALT) == BIOS_PRINTF_DEBHALT)
        bios_printf(BIOS_PRINTF_SCREEN, "FATAL: ");

    while(c = read_byte(get_CS(), (Bit16u)s)) {
        if( c == '%' ) {
            in_format = 1;
            format_width = 0;
        }
        else if(in_format) {
            if( (c >= '0') && (c <= '9') ) {
                format_width = (format_width * 10) + (c - '0');
            }
            else {
                arg_ptr++;              // increment to next arg
                arg = read_word(arg_seg, (Bit16u)arg_ptr);
                if(c == 'x' || c == 'X') {
                    if(format_width == 0) format_width = 4;
                    if(c == 'x') hexadd = 'a';
                    else         hexadd = 'A';
                    for(i = format_width-1; i >= 0; i--) {
                        nibble = (arg >> (4 * i)) & 0x000f;
                        send(action, (nibble<=9)? (nibble+'0') : (nibble-10+hexadd));
                    }
                }
                else if(c == 'u') {
                    put_uint(action, arg, format_width, 0);
                }
                else if(c == 'l') {
                    s++;
                    c = read_byte(get_CS(), (Bit16u)s);       // is it ld,lx,lu? 
                    arg_ptr++;                                // increment to next arg
                    hibyte = read_word(arg_seg, (Bit16u)arg_ptr);
                    if(c == 'd') {
                        if(hibyte & 0x8000) put_luint(action, 0L-(((Bit32u) hibyte << 16) | arg), format_width-1, 1);
                        else                put_luint(action, ((Bit32u) hibyte << 16) | arg, format_width, 0);
                    }
                    else if(c == 'u') {
                        put_luint(action, ((Bit32u) hibyte << 16) | arg, format_width, 0);
                    }
                    else if(c == 'x' || c == 'X') {
                        if(format_width == 0) format_width = 8;
                        if(c == 'x') hexadd = 'a';
                        else          hexadd = 'A';
                        for(i=format_width-1; i>=0; i--) {
                            nibble = ((((Bit32u) hibyte <<16) | arg) >> (4 * i)) & 0x000f;
                            send(action, (nibble<=9)? (nibble+'0') : (nibble-10+hexadd));
                        }
                    }
                }
                else if(c == 'd') {
                    if(arg & 0x8000) put_int(action, -arg, format_width - 1, 1);
                    else             put_int(action, arg, format_width, 0);
                }
                else if(c == 's') {
                    put_str(action, get_CS(), arg);
                }
                else if(c == 'S') {
                    hibyte = arg;
                    arg_ptr++;
                    arg = read_word(arg_seg, (Bit16u)arg_ptr);
                    put_str(action, hibyte, arg);
                }
                else if(c == 'c') {
                    send(action, arg);
                }
                else bios_printf(BIOS_PRINTF_DEBHALT,"bios_printf: unknown format\n");
                in_format = 0;
            }
        }
        else {
            send(action, c);
        }
        s ++;
    }

    if(action & BIOS_PRINTF_HALT) {  // freeze in a busy loop.
        __asm {
                        cli
            halt2_loop: hlt
                        jmp halt2_loop
        }
    }
}

//-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
void send_LED(Bit8u val)
{
    LED(val);
}


Bit8u Read_UART(void)
{
    while(! (inb(UART_LS) & 0x01));
    //=========================
    while(! (inb(UART_LS) & 0x40));
    //outb(UART, '\r'); //             Syn =>
    //=========================
    return  inb(UART);
}


//==========================================================================
//--------------------------------------------------------------------------
// Wait for data - waits for data to come in by checking control register.
// returns after either the data came in, or there was a time out
//--------------------------------------------------------------------------
static void wait_mouse_event(void)
{
    Bit8u  ticks;
    ticks = read_byte(0x0040, 0x006C); // get current tick count
    while((inb(MOUSE_CNTL) & 0x01) != 0x01) {
        if((ticks +10) < read_byte(0x0040, 0x006C)) {
            BX_INT15_DEBUG_PRINTF("wait mouse timeout\n");
            break; // time out
        }
    }
} 

//--------------------------------------------------------------------------
// Get Mouse Data
//--------------------------------------------------------------------------
static Bit8u get_mouse_data(void)
{
    Bit8u  data;
    wait_mouse_event();
    data = inb(MOUSE_PORT);
    return(data);
}

//--------------------------------------------------------------------------
// print_bios_banner -  displays a the bios version
//--------------------------------------------------------------------------
//--------------------------------------------------------------------------
#define BIOS_COPYRIGHT_STRING   "2015 05 09 Mouse Test \n"
void __cdecl print_bios_banner(void)
{
   Bit8u val, pattern, incr, readback, cmd;
   Bit16u val_w, addr, start, end, tested_segment, segment;
   //===========
    init_comport();
    bios_printf(BIOS_PRINTF_COMPORT, BIOS_COPYRIGHT_STRING);
    bios_printf(BIOS_PRINTF_COMPORT, "ZET COM 38400 \n");
    //====================================== 
   
    //========================================
    tested_segment = 0x0000;
    pattern =0x0;
    incr =1;
    start = 0x0000;
    end  = 0xFFFF;

   /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // write_byte(0xB800, 80*24*2, 0x53);  // =S
    while(1)
    {
		//bios_printf(BIOS_PRINTF_COMPORT,  "READY FOR COMMAND.... \n");
		//======= READ COMMAND

		//cmd = Read_UART();
		//switch(cmd) {
		
        //case 1:          //FIXME should beep
			bios_printf(BIOS_PRINTF_COMPORT,  "COMMAND - RD BYTE \n");
			//=======1 Read SEGMENT===============
			val = Read_UART();
			segment = Read_UART();
			segment =  (segment<<8) + val;
			bios_printf(BIOS_PRINTF_COMPORT,  "	Send(mouse) : %x \n", val);
			//===============================================================
			outb(MOUSE_CNTL, 0xD4);                    // Enable sending to mouse
			outb(MOUSE_PORT, val);                     // Send the byte to mouse
			val = get_mouse_data();             // if no mouse attached, it will return RESEND
			bios_printf(BIOS_PRINTF_COMPORT,  "	Read(mouse) : %x \n", val);
        //    break;

        //default:
		//	bios_printf(BIOS_PRINTF_COMPORT,  "COMMAND - not DEF \n");
		//}

    }
}

//---------------------------------------------------------------------------
//  End
//---------------------------------------------------------------------------
static void mem_test (Bit16u tested_segment, Bit16u start, Bit16u end, Bit8u pattern, Bit8u incr)
{
   Bit8u val, readback;
   Bit16u addr;
   
   bios_printf(BIOS_PRINTF_COMPORT, "TEST MEM seg: %x \n", tested_segment);
   bios_printf(BIOS_PRINTF_COMPORT, "TEST MEM start ADDR: %x \n", start);
   bios_printf(BIOS_PRINTF_COMPORT, "TEST MEM stop  ADDR: %x \n", end );
   bios_printf(BIOS_PRINTF_COMPORT, "START...\n");
   //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        for (addr=start,val=pattern; addr<end+1; addr++) {
            write_byte( tested_segment, addr , val);
            val  += incr;
            }
       for (addr=start,val=pattern; addr<end+1; addr++) {
            readback = read_byte( tested_segment, addr);
           if (readback != val) {
                //================ERROR===================================================
                bios_printf(BIOS_PRINTF_COMPORT, "TEST MEM ERR: addr - %x, data- %x \n", addr, readback);
               //==========================================================================
           }
           val += incr;
     }
     bios_printf(BIOS_PRINTF_COMPORT, "\n");
     bios_printf(BIOS_PRINTF_COMPORT, "TEST MEM - FINISH \n" );
}


static void biosfn_set_cursor_pos(Bit8u page, Bit16u cursor)
{
    Bit8u current;
    Bit16u crtc_addr;
    //if(page>7) return;  // Should not happen...
    
//write_word(BIOSMEM_SEG, BIOSMEM_CURSOR_POS+2*page, cursor); // Bios cursor pos
write_word(BIOSMEM_SEG, BIOSMEM_CURSOR_POS, cursor); // Bios cursor pos
/*
current=read_byte(BIOSMEM_SEG,BIOSMEM_CURRENT_PAGE); // Set the hardware cursor
    if(page==current) {     
        crtc_addr=read_word(BIOSMEM_SEG,BIOSMEM_CRTC_ADDRESS);  // CRTC regs 0x0e and 0x0f
        outb(crtc_addr,0x0e);
        outb(crtc_addr+1,(cursor&0xff00)>>8);
        outb(crtc_addr,0x0f);
        outb(crtc_addr+1,cursor&0x00ff);
    }
*/
}



static void biosfn_get_cursor_pos(Bit8u page, Bit16u *shape, Bit16u *pos)
{
    Bit16u ss = get_SS();

    write_word(ss, (Bit16u)shape, 0);       // Default
    write_word(ss, (Bit16u)pos,   0);

    if(page>7)return;              // FIXME should handle VGA 14/16 lines
    write_word(ss, (Bit16u)shape, read_word(BIOSMEM_SEG, BIOSMEM_CURSOR_TYPE));
    write_word(ss, (Bit16u)pos,   read_word(BIOSMEM_SEG,BIOSMEM_CURSOR_POS+page*2));
}

static Bit8u find_vga_entry(Bit8u mode)
{
    Bit8u i, line = 0xFF;
    for(i = 0; i <= MODE_MAX; i++)
        if(vga_modes[i].svgamode == mode) {
            line=i;
            break;
        }
    return line;
}

static void biosfn_prnt_char(Bit8u car)
{
    // flag = WITH_ATTR / NO_ATTR
    Bit8u  xcurs, ycurs, line;
    Bit16u nbcols, nbrows, address;
    Bit16u cursor;
    Bit8u  character;

   character =  car;
   // if(line==0xFF)return;
 
    // Get the cursor pos for the page
    // biosfn_get_cursor_pos(page, (Bit16u *)&dummy, (Bit16u *)&cursor);
   cursor = read_word(BIOSMEM_SEG,BIOSMEM_CURSOR_POS); 
   xcurs = cursor & 0x00ff; ycurs =(cursor&0xff00)>>8;

    // Get the dimensions
    nbrows = 25;
    nbcols  = 80;

    switch(car) {
        case 7:          //FIXME should beep
            break;
        case 8:
            if(xcurs>0)xcurs--;
        break;

        case '\r':
            xcurs=0;
            break;

        case '\n':
            ycurs++;
            xcurs=0;
            break;
       /*
        case '\t':
            do {
                biosfn_write_teletype(' ',page,attr,flag);
                //biosfn_get_cursor_pos(page, (Bit16u *)&dummy, (Bit16u *)&cursor);
                cursor = read_word(BIOSMEM_SEG,BIOSMEM_CURSOR_POS); 
                xcurs=cursor&0x00ff;ycurs=(cursor&0xff00)>>8;
            } while(xcurs%8==0);
            break;
      */
        default:
                address=(xcurs+ycurs*nbcols)*2;
                // Write the char
                write_byte(0xB800,address,character);
                xcurs++;
    }

    // Do we need to wrap ?
    if(xcurs==nbcols) {
        xcurs=0;
        ycurs++;
    }

    // Do we need to scroll ?
    /*
    if(ycurs==nbrows) {
        if(vga_modes[line].class==TEXT) {
            biosfn_scroll(0x01,0x07,0,0,nbrows-1,nbcols-1,page,SCROLL_UP);
        }
        ycurs-=1;
    }
    */

    // Set the cursor for the page
    cursor=ycurs; cursor<<=8; cursor+=xcurs;
   //biosfn_set_cursor_pos(page,cursor);
   write_word(BIOSMEM_SEG, BIOSMEM_CURSOR_POS, cursor);
} 







