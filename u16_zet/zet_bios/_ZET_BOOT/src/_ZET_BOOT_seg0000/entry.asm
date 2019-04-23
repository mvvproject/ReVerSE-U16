                         EXTRN  _print_bios_banner      :proc      ; Print the BIOS Banner message
;;------------------------------------------------------------------------------------------------------------------------------------------
;;------------------------------------------------------------------------------------------------------------------------------------------                         
 startofrom              equ     0FE00h
;;------------------------------------------------------------------------------------------------------------------------------------------
;;------------------------------------------------------------------------------------------------------------------------------------------
                        .Model  Tiny    ;; this forces it to nears on code and data
                        .8086           ;; this forces it to use 80186 and lower
_BIOSSEG                SEGMENT 'CODE'
                        assume  cs:_BIOSSEG
bootrom:                org     0000h           ;; start of ROM, get placed at 0E000h ====>0xFE000 -START PROGRAM !!!!!!!!!!!!!!!!!!!!!!!!
;------------------------------------------------------------------------------------------------------------------------------------------

;;------------------------------------------------------------------------------------------------------------------------------------------
                        org     (0FE00h - startofrom)                                                   ;; ===========> 0xFE05B RUN  CODE FROM HERE!!!!
post:                   ;; xor     ax, ax          ; clear ax register
                        mov  dx, 0f102h;    ;; LED ADDR
                        mov  ax, 0010h;     ;; 1sr RED LED - ON
                        out    dx, ax             ;; send data
                        nop;
                        nop;
                        ;;====================VGA BIOS =========================================================================
                        mov     cx, 0c000h             ;; init vga bios              DATA SEGMENT(VGA BIOS) = 0xC000h ;;  // VGABIOSLENGTH           equ     0x4000 
                        mov     ax, 0c780h             ;;  START ADDR =  0c000h, END  ADDR =  0c780h                                   
                        call    rom_scan                 ;; Scan ROM  
                        
                        ;--------------------------------------------------------------------------------------------------------------------------------------------------------------
                        call    _print_bios_banner       ;; Print the openning banner
                        ;===========================================
                        mov  dx, 0f102h;    ;; LED ADDR
                        mov  ax, 0030h;     ;; 2nd RED LED - ON
                        out    dx, ax             ;; send data
                        hlt;                                                                                               ;; ============> HALT!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
                        
;;--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;;--------------------------------------------------------------------------
;;  ROM Checksum calculation
;;--------------------------------------------------------------------------
;;--------------------------------------------------------------------------
rom_checksum:           
                        push    ax                      ;; Save registers
                        push    bx                      ;; Save registers
                        push    cx                      ;; Save registers
                        xor     ax, ax                  ;; Clear ax
                        xor     bx, bx                  ;; Clear bx
                        xor     cx, cx                  ;; Clear cx
                        mov     ch, BYTE PTR ds:[2]     ;; get 2nd byte pointerd to
                        shl     cx, 1                   ;; Shift left (mult by 2)
checksum_loop:          add     al, BYTE PTR ds:[bx]    ;; Add
                        inc     bx                      ;; increment bx++
                        loop    checksum_loop           ;; loop until done
                        and     al, 0ffh                ;; 
                        pop     cx
                        pop     bx
                        pop     ax
                        ret                             ;; return to caller
 ;;--------------------------------------------------------------------------
;;  We need a copy of this string, but we are not actually a PnP BIOS,
;;  so make sure it is *not* aligned, so OSes will not see it if they scan.
;;--------------------------------------------------------------------------
                        align 16
                        db      0
pnp_string:             DB      "$PnP"                        
                        
;;--------------------------------------------------------------------------
;;--------------------------------------------------------------------------
;; Scan for existence of valid expansion ROMS.
;;    Video ROM:   from 0xC0000..0xC7FFF in 2k increments
;;   General ROM: from 0xC8000..0xDFFFF in 2k increments
;;   System  ROM: only 0xE0000
;;
;; Header:
;;   Offset    Value ==========================
;;   0         055h
;;   1         0AAh
;;   2         ROM length in 512-byte blocks
;;   3         ROM initialization entry point (FAR CALL)
;;   -------------------------------------------------------------------
;;   rom_scan ( CX - START POINT;; AX -END POINT ;;
;;--------------------------------------------------------------------------
;;--------------------------------------------------------------------------
IPL_SEG                                     equ     09ff0h   ; 256 bytes at 0x9ff00 -- 0x9ffff is used for the IPL boot table.
IPL_COUNT_OFFSET              equ     0080h    ; u16: number of valid table entries
IPL_SEQUENCE_OFFSET     equ     0082h    ; u16: next boot device
IPL_BOOTFIRST_OFFSET      equ     0084h    ; u16: user selected device
IPL_TABLE_ENTRIES              equ     8        ; num Table entries
IPL_TYPE_BEV                         equ     080h        ;

rom_scan:
rom_scan_loop:          
                        push    ax                            ;; Save AX
                        mov     ds, cx                      ;;  CX - DATA SEGMENT
                        mov     ax, 0004h               ;; start with increment of 4 (512-byte) blocks = 2k
                        cmp     WORD PTR ds:[0], 0AA55h ;; look for signature
                        jne     rom_scan_increment    ;;  LOOP ==> (rom_scan_increment) ====>                           ^
                        call    rom_checksum              ;;                                                                                                     ||                                                      
                        jnz     rom_scan_increment     ;;  LOOP ==> (rom_scan_increment) ====> :rom_scan_loop 
                        mov     al, BYTE PTR ds:[2]     ;; change increment to ROM length in 512-byte blocks          ;; we found 
                        test    al, 003h                ;; We want our increment in 512-byte quantities, rounded to
                        jz      block_count_rounded     ;; the nearest 2k quantity, since we only scan at 2k intervals.
                        and     al, 0fch                ;; needs rounding up
                        add     al, 004h

block_count_rounded:    xor     bx, bx                  ;; Restore DS back to 0000:
                        mov     ds, bx
                        push    ax                      ;; Save AX
                        push    di                      ;; Save DI  Push addr of ROM entry point
                        push    cx                      ;; Push seg
                        mov     ax, 00003h              ;; Offset
                        push    ax                      ;; Put offset on stack            
                        mov     ax, 0F000h              ;; Point ES:DI at "$PnP", which tells the ROM that we are a PnP BIOS.
                        mov     es, ax                  ;; That should stop it grabbing INT 19h; we will use its BEV instead.
                        lea     di, pnp_string+startofrom
                        mov     bp, sp                          ;; Call ROM init routine using seg:off on stack
                        
                        call    DWORD PTR ss:[bp]           ;; should assemble to 0ff05eh 0 (and it does under tasm) ==========> CALL ROM INIT
                        cli                                 ;; In case expansion ROM BIOS turns IF on
                        add     sp, 2                       ;; Pop offset value
                        pop     cx                          ;; Pop seg value (restore CX)
                                                            ;; Look at the ROM's PnP Expansion header.  Properly, we're supposed
                                                            ;; to init all the ROMs and then go back and build an IPL table of
                                                            ;; all the bootable devices, but we can get away with one pass.
                        mov     ds, cx                      ;; ROM base
                        mov     bx, WORD PTR ds:01ah      ;; 0x1A is the offset into ROM header that contains...
                        mov     ax, [bx]                    ;; the offset of PnP expansion header, where...
                        cmp     ax, 05024h             ;; we look for signature "$PnP"
                        jne     no_bev
                        mov     ax, 2[bx]
                        cmp     ax, 0506eh
                        jne     no_bev
                        mov     ax, 01ah[bx]                ;; 0x1A is also the offset into the expansion header of...
                        cmp     ax, 00000h                  ;; the Bootstrap Entry Vector, or zero if there is none.
                        je      no_bev                      ;; Found a device that thinks it can boot the system.
                        
                        ;;================ Record its BEV and product name string==================
                        mov     di, 010h[bx]                ;; Pointer to the product name string or zero if none
                        mov     bx, IPL_SEG             ;; Go to the segment where the IPL table lives                        ;; // equ     09ff0h 
                        mov     ds, bx
                        mov     bx, WORD PTR ds:IPL_COUNT_OFFSET  ;; Read the number of entries so far ;; // equ     0080h
                        cmp     bx, IPL_TABLE_ENTRIES                                                                                           ;; // equ     8
                        je      no_bev                              ;; Get out if the table is full
                        push    cx
                        mov     cx, 04h                        ;; Zet: Needed to be compatible with 8086
                        shl     bx, cl                              ;; Turn count into offset (entries are 16 bytes)
                        pop     cx
                        mov     WORD PTR 0[bx], IPL_TYPE_BEV        ;; This entry is a BEV device            <=== equ     080h
                        mov     WORD PTR 6[bx], cx                  ;; Build a far pointer from the segment...
                        mov     WORD PTR 4[bx], ax                  ;; and the offset
                        cmp     di, 00000h
                        je      no_prod_str
                        mov     0Ah[bx], cx                  ;; Build a far pointer from the segment...
                        mov     8[bx], di                       ;; and the offset
no_prod_str:            
                        push    cx
                        mov     cx, 04h
                        shr     bx, cl                          ;; Turn the offset back into a count
                        pop     cx
                        inc     bx                               ;; We have one more entry now
                        mov     WORD PTR ds:IPL_COUNT_OFFSET, bx ;; Remember that.
no_bev:          pop     di                               ;; Restore DI
                        pop     ax                               ;; Restore AX
rom_scan_increment:    
                        push    cx                        ;; STACK: CX, AX
                        mov     cx, 5                    ;; convert 512-bytes blocks to 16-byte increments
                        shl     ax, cl                      ;; because the segment selector is shifted left 4 bits.
                        pop     cx                         ;; STACK: AX
                        add     cx, ax                   
                        pop     ax                          ;; Restore AX ==END OF SCAN //     (STACK == EMPTY)
                        cmp     cx, ax                   ;;  
                        jbe     rom_scan_loop    ;; This is a far jump ============================>> LOOP (SCAN AGAIN)
                        xor     ax, ax                     ;; Restore DS back to 0000:                        
                        mov   ds, ax                        
                        ret
                        
                        
;;------------------------------------------------------------------------------------------------------------------------------------------
;; EXECUTABLE ROM CODE HERE !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
;;------------------------------------------------------------------------------------------------------------------------------------------
                        org     (0ff00h - startofrom)  ; =============================> COPY ROM to RAN !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
;BIOS_COPYRIGHT_STRING equ     "Zet Bios 1.1 (C) 2010 Zeus Gomez Marmolejo, Donna Polehn"
;MSG1:                   db      BIOS_COPYRIGHT_STRING
;                       db      0
START_ROM: 
                        mov  dx, 0f102h;    ;; LED ADDR
                        mov  ax, 0001h;     ;; 1sr RED LED - ON
                        out    dx, ax             ;; send data                                                                   ;;==============> 1st RED LED ON!!!!!!!!!!!
                       ; jmp     far ptr LED2 ;
;;--------------------------------------------------------------------------
;; First we have to prepare DRAM for use:
;;--------------------------------------------------------------------------
SDRAM_POST:             xor     ax, ax          ; Clear AX register
                        cli                     ; Disable interupt for startup
                        mov     dx, 0f200h      ; CSR_HPDMC_SYSTEM = HPDMC_SYSTEM_BYPASS|HPDMC_SYSTEM_RESET|HPDMC_SYSTEM_CKE;
                        mov     ax, 7           ; Bring CKE high
                        out     dx, ax          ; Initialize the SDRAM controller
                        mov     dx, 0f202h      ; Precharge All
                        
                        mov     ax, 0400bh      ; CSR_HPDMC_BYPASS = 0x400B;
                        out     dx, ax          ; Output the word of data to the SDRAM Controller
                        mov     ax, 0000dh      ; CSR_HPDMC_BYPASS = 0xD;
                        out     dx, ax          ; Auto refresh
                        
                        mov     ax, 0000dh      ; CSR_HPDMC_BYPASS = 0xD;
                        out     dx, ax          ; Auto refresh
                        mov     ax, 023fh       ; CSR_HPDMC_BYPASS = 0x23F;
                        out     dx, ax          ; Load Mode Register, Enable DLL
                        mov     cx, 50          ; Wait about 200 cycles
a_delay:         loop    a_delay         ; Loop until 50 goes to zero
                        mov     dx, 0f200h      ; CSR_HPDMC_SYSTEM = HPDMC_SYSTEM_CKE;
                        mov     ax, 4           ; Leave Bypass mode and bring up hardware controller
                        out     dx, ax          ; Output the word of data to the SDRAM Controller
                       ; jmp     far ptr LED3 ;
 ;==================================================================================================================================                              
                        ;========================================================================================================================
 STACKP:      mov     ax, 0E3FEh      ; We are done with the controller, we can use the memory now  // clname DATA segment _DATA    segaddr=0xf000 offset=0xe400 &
                        mov     sp, ax                ; set the stack pointer to fffe (top)
                        mov     ax, 00000h   ;    // 0f000h 
                        mov     ds, ax           ; set data segment to  0xF0000
                        mov     ss, ax           ; set stack segment to 0xF0000
 ;==================================================================================================================================
 ;==================================================================================================================================
LED3:             mov  dx, 0f102h;    ;; LED ADDR
                        mov  ax, 0007h;     ;; 3- RED LED - ON
                        out    dx, ax             ;; send data                                                          ;;==============> 2nd RED LED ON!!!!!!!!!!!
 ;;                     hlt;
 ;;==========================================          
;;============================================
;;--------------------------------------------------------------------------
;; Copy Shadow BIOS from Flash into SDRAM after SDRAM has been initialized
;;---------------------------------------------------------------------------
FLASH_PORT              equ     0x0238                   ;; Flash RAM port            === FIX do noit change
;;///////
ROMBIOSSEGMENT			equ     0x0000                   ;; ROM BIOS Segment   === FIX do noit change
;;////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
ROMBIOS__START			equ     0xE400                   ;; 0xE400  +( 0xDFF *2 = 1BFF)   = 0xFFFF
ROMBIOSLENGTH           equ     0xDFF                    ;; Copy (4096 Words - 200 W stack) up to this ROM in Words  0xE400 
;;
;;--------------------------------------------------------------------------
shadowcopy: mov     ax, ROMBIOSSEGMENT					; Load with the segment of the extra bios rom area
                        mov     es, ax                  ; BIOS area segment
                        mov     bp, ROMBIOS__START      ;  Bios(RAM for load) starts at offset address 0xE400 ==== !!!!!!!!!!!!
                        mov     cx, ROMBIOSLENGTH       ;; Bios is 64K long - Showdow rom len
                       ;--------------------- Load MSB  FLASH address ---------------------------
                        mov     dx, FLASH_PORT+2        ;; Set DX reg to FLASH IO port
                        mov     ax, 0x0020				;; Load MSB  FLASH address                 0x20 0000 - Full adress
                        out     dx, ax					;; Save MSB  FLASH address 
                       ;---------------------------------------------------------------------------------------
                        mov     bx, 0x200				;; Bios starts at offset address in FLASH !!!!!!!!!!!!!!!!!!!!!!! 0x0200 x 2 !!!!!!!!!!!!!!!
                        call    biosloop				;; Call bios IO loop (STACK is USED       !!!!!!!!!)
;;=========================================================================================
VGABIOSSEGMENT         equ     0xC000                  ;; VGA BIOS Segment
VGABIOSLENGTH          equ     0x4000                  ;; Length of VGA Bios in Words
;;----------------------------------------------------------------------------
copy_vga_bios:            
                        mov     ax, VGABIOSSEGMENT      ;; Load with the segment of the vga bios rom area
                        mov     es, ax                  ;; BIOS area segment
                        xor     bp, bp                  ;; Bios starts at offset address 0
                        mov     cx, VGABIOSLENGTH       ;; VGA Bios is <32K long


                        mov     dx, FLASH_PORT+2        ;; Set DX reg to FLASH IO port
                        mov     ax, 0x0000                          ;; Load MSB address
                        out     dx, ax                  ;; Save MSB address word
                        mov     bx, 0x0000				;; Bios starts at offset address 0x0000 
                        call    biosloop				;; Call bios IO loop
                        nop
;;----------------------------------------------------------------------------
                   
 ;;==========================================                       

                        jmp     far ptr post            ;; Continue with regular POST ===============================================>>>>>>
;;--------------------------------------------------------------------------
biosloop:        mov     ax, bx							;; Put bx into ax // START - 0x0
                        mov     dx, FLASH_PORT          ;; Set DX reg to FLASH IO port
                        out     dx, ax                  ;; Save LSB address word
                        out     dx, ax                  ;; Save LSB address word                              ===============2 times !!!!!!!!!!!!!!!!!!!!!!!
                        mov     dx, FLASH_PORT          ;; Set DX reg to FLASH IO port
                        in      ax, dx                  ;; Get input word into ax register    READ WORD FROM FLASH_PORT <===================
                        mov     word ptr es:[bp], ax    ;; Save that word to next place in RAM ===================> write to FE400 (first addr) 
                        inc     bp                      ;; Increment to next SRAM  address location 
                        inc     bp                      ;; Increment to next SRAM  address location - WORD
                        inc     bx                      ;; Increment to next FLASH address location ===========> READ WORDs!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
                        loop    biosloop                ;; Loop until bios is loaded up
                        ret                             ;; Return
;;--------------------------------------------------------------------------
;;------------------------------------------------------------------------------------------------------------------------------------------
;;------------------------------------------------------------------------------------------------------------------------------------------
;; MAIN BIOS Entry Point:  
;; on Reset - Processor starts at this location. This is the first instruction
                        org     (0fff0h - startofrom)        ;; Power-up Entry Point
                        jmp     far ptr START_ROM      ;; Boot up bios

                        org     (0fff5h - startofrom)   ;; ASCII Date ROM was built - 8 characters in MM/DD/YY
BIOS_BUILD_DATE         equ     "09/09/10\n"
MSG2:            db      BIOS_BUILD_DATE

                        org     (0fffeh -startofrom)    ;; Put the SYS_MODEL_ID
SYS_MODEL_ID               equ     0xFC
                        db      SYS_MODEL_ID            ;; here
                        db      0

_BIOSSEG                ends                    ;; End of code segment
                        end             bootrom ;; End of this program
