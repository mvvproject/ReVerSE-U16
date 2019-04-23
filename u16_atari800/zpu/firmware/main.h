#include <alloca.h>
#include <sys/types.h>
#include "integer.h"
#include "regs.h"
#include "pause.h"
#include "printf.h"
#include "joystick.h"
#include "freeze.h"

#include "simpledir.h"
#include "simplefile.h"
#include "fileselector.h"
#include "cartridge.h"

#ifdef LINUX_BUILD
#include "curses_screen.h"
#define after_set_reg_hook() display_out_regs()
#else
#define after_set_reg_hook() do { } while(0)
#endif

#include "memory.h"

extern char ROM_DIR[];
extern unsigned char freezer_rom_present;

void mainmenu();

// TODO - needs serious cleanup!

// FUNCTIONS in here
// i) pff init - NOT USED EVERYWHERE
// ii) file selector - kind of crap, no fine scrolling - NOT USED EVERYWHERE
// iii) cold reset atari (clears base ram...)
// iv) start atari (begins paused)
// v) freeze/resume atari - NOT USED EVERYWHERE!
// vi) menu for various options - NOT USED EVERYWHERE!
// vii) pause - TODO - base this on pokey clock...

// standard ZPU IN/OUT use...
// OUT1 - 6502 settings (pause,reset,speed)
// pause_n: bit 0 
// reset_n: bit 1
// turbo: bit 2-4: meaning... 0=1.79Mhz,1=3.58MHz,2=7.16MHz,3=14.32MHz,4=28.64MHz,5=57.28MHz,etc.
// ram_select: bit 5-7: 
//   		RAM_SELECT : in std_logic_vector(2 downto 0); -- 64K,128K,320KB Compy, 320KB Rambo, 576K Compy, 576K Rambo, 1088K, 4MB

#define BIT_REG(op,mask,shift,name,reg) \
int get_ ## name() \
{ \
	int val = *reg; \
	return op((val>>shift)&mask); \
} \
void set_ ## name(int param) \
{ \
	int val = *reg; \
	 \
	val = (val&~(mask<<shift)); \
	val |= op(param)<<shift; \
	 \
	*reg = val; \
	after_set_reg_hook(); \
}

#define BIT_REG_RO(op,mask,shift,name,reg) \
int get_ ## name() \
{ \
	int val = *reg; \
	return op((val>>shift)&mask); \
}

BIT_REG(,0x1,0,pause_6502,zpu_out1)
BIT_REG(,0x1,1,reset_6502,zpu_out1)
BIT_REG(,0x3f,2,turbo_6502,zpu_out1)
BIT_REG(,0x7,8,ram_select,zpu_out1)
//BIT_REG(,0x3f,11,rom_select,zpu_out1)
BIT_REG(,0x3f,17,cart_select,zpu_out1)
// reserve 2 bits for extending cart_select
BIT_REG(,0x01,25,freezer_enable,zpu_out1)

BIT_REG_RO(,0x1,8,hotkey_softboot,zpu_in1)
BIT_REG_RO(,0x1,9,hotkey_coldboot,zpu_in1)
BIT_REG_RO(,0x1,10,hotkey_fileselect,zpu_in1)
BIT_REG_RO(,0x1,11,hotkey_settings,zpu_in1)

BIT_REG_RO(,0x3f,12,controls,zpu_in1) // (esc)FLRDU


void
wait_us(int unsigned num)
{
	// pause counter runs at pokey frequency - should be 1.79MHz
	int unsigned cycles = (num*230)>>7;
	*zpu_pause = cycles;
#ifdef LINUX_BUILD
	usleep(num);
#endif
#ifdef SOCKIT
	usleep(num);
#endif
}

void memset8(void * address, int value, int length)
{
	char * mem = address;
	while (length--)
		*mem++=value;
}

void memset32(void * address, int value, int length)
{
	int * mem = address;
	while (length--)
		*mem++=value;
}

void clear_main_ram()
{
	memset8(SRAM_BASE, 0, main_ram_size); // SRAM, if present (TODO)
	memset32(SDRAM_BASE, 0, main_ram_size/4);
}

void
reboot(int cold)
{
	set_pause_6502(1);
	if (cold)
	{
		set_freezer_enable(0);
		clear_main_ram();
		set_freezer_enable(freezer_rom_present);
	}
	set_reset_6502(1);
	// Do nothing in here - this resets the memory controller!
	set_reset_6502(0);
	set_pause_6502(0);
}

unsigned char toatarichar(int val)
{
	int inv = val>=128;
	if (inv)
	{
		val-=128;
	}
	if (val>='A' && val<='Z')
	{
		val+=-'A'+33;
	}
	else if (val>='a' && val<='z')
	{
		val+=-'a'+33+64;
	}
	else if (val>='0' && val<='9')
	{
		val+=-'0'+16;	
	}
	else if (val>=32 && val<=47)
	{
		val+=-32;
	}
	else if (val == ':')
	{
		val = 26;
	}
	else
	{
		val = 0;
	}
	if (inv)
	{
		val+=128;
	}
	return val;
}

int debug_pos;
int debug_adjust;
unsigned char volatile * baseaddr;

#ifdef LINUX_BUILD
void char_out(void* p, char c)
{
	// get rid of unused parameter p warning
	(void)(p);
	int x, y;
	x = debug_pos % 40;
	y = debug_pos / 40;
	display_char(x, y, c, debug_adjust == 128);
	debug_pos++;
}

#else
void clearscreen()
{
	unsigned volatile char * screen;
	for (screen=(unsigned volatile char *)(screen_address+atari_regbase); screen!=(unsigned volatile char *)(atari_regbase+screen_address+1024); ++screen)
		*screen = 0x00;
}

void char_out ( void* p, char c)
{
	unsigned char val = toatarichar(c);
	if (debug_pos>=0)
	{
		*(baseaddr+debug_pos) = val|debug_adjust;
		++debug_pos;
	}
}
#endif

#define NUM_FILES 7
struct SimpleFile * files[NUM_FILES];

void loadromfile(struct SimpleFile * file, int size, size_t ram_address)
{
	void* absolute_ram_address = SDRAM_BASE + ram_address;
	int read = 0;
	file_read(file, absolute_ram_address, size, &read);
}

void loadrom(char const * path, int size, size_t ram_address)
{
	if (SimpleFile_OK == file_open_name(path, files[5]))
	{
		loadromfile(files[5], size, ram_address);
	}
}

void loadrom_indir(struct SimpleDirEntry * entries, char const * filename, int size, size_t ram_address)
{
	if (SimpleFile_OK == file_open_name_in_dir(entries, filename, files[5]))
	{
		loadromfile(files[5], size, ram_address);
	}
}

#ifdef LINUX_BUILD
int zpu_main(void)
#else
int main(void)
#endif
{
	INIT_MEM

	fil_type_rom = "ROM";
	fil_type_bin = "BIN";
	fil_type_car = "CAR";
	fil_type_mem = "MEM";

	int i;
	for (i=0; i!=NUM_FILES; ++i)
	{
		files[i] = (struct SimpleFile *)alloca(file_struct_size());
		file_init(files[i]);
	}

	freeze_init((void*)FREEZE_MEM); // 128k

	debug_pos = -1;
	debug_adjust = 0;
	baseaddr = (unsigned char volatile *)(screen_address + atari_regbase);
	set_pause_6502(1);
	set_reset_6502(1);
	set_reset_6502(0);
	set_turbo_6502(1);
	set_ram_select(2);
	set_cart_select(0);
	set_freezer_enable(0);

	init_printf(0, char_out);

	mainmenu();
	return 0;
}

