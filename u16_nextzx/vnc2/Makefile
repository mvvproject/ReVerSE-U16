# main target
TARGET=ReverseU16_VNC2

# debugger module name
DEBUGGER='VII Debugger Module'

# can be redefined by command line
#CONFIG=debug
ifndef CONFIG
CONFIG=release
endif

# check debug word in CONFIG variable
ifndef DEBUG
  ifeq ($(findstring debug,$(CONFIG)),debug)
    DEBUG=1
  else ifeq ($(findstring Debug,$(CONFIG)),Debug)
    DEBUG=1
  else
    DEBUG=0
  endif
endif

REAL_ROOT=$(realpath .)

# Destination directory
DEST_DIR=$(REAL_ROOT)/build/$(CONFIG)

OBJECT_DIR=$(DEST_DIR)/objects

MD=$(REAL_ROOT)/tools/mkdir -p
RM=$(REAL_ROOT)/tools/rm -f

LIBS=$(REAL_ROOT)/lib/kernel.a $(REAL_ROOT)/lib/USBHost.a $(REAL_ROOT)/lib/UART.a $(REAL_ROOT)/lib/GPIO.a $(REAL_ROOT)/lib/USBHostHID.a 
                                                                                                                                            
CFLAGS= -c -d $(DEBUG) -I $(REAL_ROOT)/include/kernel -I $(REAL_ROOT)/include/drivers
AFLAGS= -d $(DEBUG)
LFLAGS= -d $(DEBUG) 

PATH:=$(PATH);$(REAL_ROOT)/tools

CC=$(REAL_ROOT)/tools/VinC.exe

LINK=$(REAL_ROOT)/tools/VinL.exe

ASM=$(REAL_ROOT)/tools/VinAsm.exe

PRG=$(REAL_ROOT)/tools/VinPrg.exe

all: $(DEST_DIR)/$(TARGET).rom

clean:
	@echo Cleaning project...
	@$(RM) -r $(REAL_ROOT)/build
	@echo done.

flash: $(DEST_DIR)/$(TARGET).rom
	@$(PRG) -d $(DEBUGGER) -c -r $<

$(DEST_DIR)/ReverseU16_VNC2.rom: $(OBJECT_DIR)/$(TARGET).obj
	@$(LINK) $(LFLAGS) -o $(DEST_DIR)/$(TARGET) $+ -U $(LIBS)

$(OBJECT_DIR)/$(TARGET).obj: $(OBJECT_DIR)/$(TARGET).asm
	@$(ASM) $(AFLAGS) -o $@ $+

$(OBJECT_DIR)/$(TARGET).asm: $(TARGET).c $(OBJECT_DIR) 
	@$(CC) $(CFLAGS) -o $@ $<

$(OBJECT_DIR): $(DEST_DIR)
	@echo Creating $@...
	@$(MD) $@

$(DEST_DIR):
	@echo Creating $@...
	@$(MD) $@


