BASE	= zpu-elf
CC      = $(BASE)-gcc
LD      = $(BASE)-gcc
AS      = $(BASE)-as
CP      = $(BASE)-objcopy
DUMP    = $(BASE)-objdump
MKDIR	= mkdir
VHDLCR	= tools/create_rom.pl

# we use mincrt0.s from here
STARTUP_DIR = .

# we fetch ROM prologue / epilogue from here
RTL_DIR = $(ZPUFLEXDIR)/RTL/


BUILD_DIR=zpu_obj

REVERSE_U16_DIR = reverse_u16

REVERSE_U16_BUILD_DIR = $(BUILD_DIR)/$(REVERSE_U16_DIR)

#MINSTARTUP_SRC = mincrt0.s
MINSTARTUP_SRC = mycrt0.s
MINSTARTUP_OBJ = $(patsubst $(STARTUP_DIR)/%.s,$(BUILD_DIR)/%.o,$(MINSTARTUP_SRC))

CORE_SRC = cartridge.c fileutils.c fileselector.c pokey/uart.c hexdump.c common/utils.c printf/printf.c 
FAT_SRC = fat/pff_file.c fat/pff.c 
COMMON_SRC = ${FAT_SRC} ${CORE_SRC}
SDCARD_SRC = sd_direct/diskio_mmc.c sd_direct/spi.c sd_direct/mmc2.c
A800_SRC_LIGHT = a800/freeze.c  a800/mainmenu.c atari_drive_emulator.c libgcc_divmod.c
A800_SRC = ${A800_SRC_LIGHT} a800/joystick.c 
5200_SRC_LIGHT = 5200/freeze.c  5200/mainmenu.c
5200_SRC = ${5200_SRC_LIGHT} 5200/joystick.c

REVERSE_U16_PRJ = reverse_u16
REVERSE_U16_SRC = $(COMMON_SRC) $(SDCARD_SRC) $(A800_SRC) reverse_u16/dirs.c
REVERSE_U16_OBJ = $(patsubst %.c,$(REVERSE_U16_BUILD_DIR)/%.o,$(REVERSE_U16_SRC))

LINKMAP  = ./standalone_simple.ld
LINKMAP_LARGE  = ./standalone_simple_large.ld

# Commandline options for each tool.

#ZPUOPTS= -mno-poppcrel -mno-pushspadd -mno-callpcrel -mno-shortop -mno-neg # No-neg requires bugfixed toolchain
#Include everything -> need to include emulation rom...
ZPUOPTS =
CFLAGS  = -I. -Isd_direct -Iprintf -Ifat -Icommon -Isdram_common -c -g -Os $(ZPUOPTS) -DDISABLE_UART_RX -DMAX_RAM_SELECT=6

LFLAGS  = -nostartfiles -nostdlib -Wl,--relax -g -Os -Wl,-Map=out.map
LFLAGS_5200  = -nostartfiles -Wl,--relax -g -Os -Wl,-Map=out.map
#LFLAGS  = -nostartfiles -Os

CFLAGS_5200 = $(CFLAGS) -DFIRMWARE_5200

# Our target.
all: zpu_rom.vhdl

install:
	cd ../common/romgen && ./createall && cd ../../firmware

reverse_u16: $(BUILD_DIR) $(REVERSE_U16_PRJ).bin $(REVERSE_U16_PRJ).rpt

clean:
	rm -rf $(BUILD_DIR)/* *.hex *.elf *.map *.lst *.srec *.bin *.rpt 

# Convert ELF binary to bin file.
%.bin: %.elf
	$(CP) -O binary $< $@

%.rpt: %.elf
	echo >$@ -n "End of code:\t"
	$(DUMP) -x $< | grep >>$@ _romend
	echo >>$@ -n "Start of BSS:\t"
	$(DUMP) -x $< | grep  >>$@ __bss_start__
	echo >>$@ -n "End of BSS:\t"
	$(DUMP) -x $< | grep >>$@ __bss_end__
	cat $@

# Link - this produces an ELF binary.

$(REVERSE_U16_PRJ).elf: $(MINSTARTUP_OBJ) $(REVERSE_U16_OBJ)
	$(LD) $(LFLAGS) -T $(LINKMAP) -o $@ $+ $(LIBS)

$(REVERSE_U16_BUILD_DIR)/%.o: %.c Makefile
	-$(MKDIR) -p $(dir $@)
	$(CC) -I$(REVERSE_U16_DIR) $(CFLAGS)  -o $@ -c $<

$(BUILD_DIR)/%.o: %.s
	$(AS) -o $@ $<

$(BUILD_DIR)/%.o: $(STARTUP_DIR)/%.s
	$(AS) -o $@ $<

$(BUILD_DIR):
	$(MKDIR) $(BUILD_DIR)

zpu_rom.vhdl: $(REVERSE_U16_PRJ).bin
	$(VHDLCR) 4 $< zpu_rom 12 > $@
