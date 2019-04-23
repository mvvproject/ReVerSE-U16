; ------------------------------------------------------------------[24.06.2018]
; ReVerSE-U16 NES Loader By MVV <mvvproject@gmail.com>
; -----------------------------------------------------------------------------

	DEVICE	ZXSPECTRUM48

osd_buffer	equ #FF00	; OSD buffer start address
osd_buffer_size	equ 256
stack_top	equ #17FE
rom_max		equ 24

port_00		equ #00		; sc spi port w/r
port_01		equ #01		; data spi port	w/r
port_02		equ #02		; status spi port r
port_03		equ #03		; buttons
port_04		equ #04		; joy0
port_05		equ #05		; data downloader port w/r
port_06		equ #06		; SD data out
port_0f		equ #0f		; joy1

sc_flash	equ %11111110
sc_sd		equ %11111101
download_on	equ %11111011

	org #0000
startprog:
	di
	ld sp,stack_top
	ld d,0
	call spi_end
	call cls		; очистка OSD буфера

	ld hl,menu
	call print_str		; печать в OSD буфер

; ID read
	ld a,30			; x
	ld (pos_x),a
	ld a,1			; y
	ld (pos_y),a

	ld d,sc_flash
	call spi_start
	ld d,%10101011		; command ID read
	call spi_w
	call spi_r
	call spi_r
	call spi_r
	call spi_r

	call print_hex
	ld d,sc_flash
	call spi_end

;	call sd_loader
;	jp key1

	jp n10
	
n11
	ld a,(rom_index)
	ld (index),a
	ld b,a
	call set_index
n12
	in a,(port_03)
	rrca
	jr nc,n12
n1
	ld a,4
	ld (pos_y),a
	ld a,14
	ld (pos_x),a
	in a,(port_04)
	call print_hex

	in a,(port_03)
	rrca
	jr nc,n11

	in a,(port_04)
	bit 2,a			; Down
	jr nz,pad_down
	bit 3,a			; Up
	jr nz,pad_up
	bit 6,a			; Fire
	jr z,n1

n2
	in a,(port_04)
	bit 6,a
	jr nz,n2
	in a,(port_03)
	rrca
	jr nc,n1
n10
	ld a,(index)
n7	
	ld (rom_index),a
	ld b,a
	call set_index
	ld hl,ldr
	call print_str
	call rom_loader
	call print_header
	jr n1

pad_up
	in a,(port_04)
	bit 3,a
	jr nz,pad_up
	in a,(port_03)
	rrca
	jr nc,n1

	ld a,(index)
	dec a
	jr nz,n6
	ld a,rom_max
n6	
	ld (index),a
	ld b,a
	call set_index
	jr n1

pad_down
	in a,(port_04)
	bit 2,a
	jr nz,pad_down
	in a,(port_03)
	rrca
	jr nc,n1

	ld a,(index)
	cp rom_max
	jr c,n8
	xor a
n8	
	inc a
	jr n6








; b=rom index
set_index
	ld hl,rom
n3
	ld a,(hl)
	inc hl
	or a
	jr nz,n3
	djnz n3

	ld a,(hl)		; start address
	ld (addr1),a
	inc hl
	ld a,(hl)
	ld (addr2),a
	inc hl
	ld a,(hl)
	ld (addr3),a
	inc hl

	xor a
	ld (pos_x),a
	ld a,#06
	ld (pos_y),a
	call print_str

	ld a,(hl)		; end address
	ld (addr4),a
	inc hl
	ld a,(hl)
	ld (addr5),a
	inc hl
	ld a,(hl)
	ld (addr6),a
	ret

; -----------------------------------------------------------------------------	
; SPI 
; -----------------------------------------------------------------------------
; Ports:

; Data Buffer (write/read)
;	bit 7-0	= Stores SPI read/write data

; Status Register (read):
; 	bit 7	= 1:BUSY	(Currently transmitting data)
;	bit 6-0	= Reserved
spi_start
	db #3e			; ld a,n вместо ld a,(spi_sc)
spi_sc	db #ff
	and d
	out (port_00),a		; CS
	ld (spi_sc),a
	ret
spi_end
	ld a,d
	cpl
	ld d,a
	ld a,(spi_sc)
	or d
	out (port_00),a
	ld (spi_sc),a
	ret
spi_w
	in a,(port_02)		; Status Register
	rlca
	jr c,spi_w
	ld a,d
	out (port_01),a		; Data Buffer
	ret
spi_r
	ld d,#ff
spi_wr
	call spi_w
spi_r1	
	in a,(port_02)		; Status Register
	rlca
	jr c,spi_r1
	in a,(port_01)		; Data Buffer
	ret

; -----------------------------------------------------------------------------
; clear OSD buffer
; -----------------------------------------------------------------------------
cls
	ld hl,osd_buffer
	xor a
	ld b,a
cls1
	ld (hl),a
	inc hl
	djnz cls1
	ret

; -----------------------------------------------------------------------------
; print string i: hl - pointer to string zero-terminated
; -----------------------------------------------------------------------------
print_str
	ld a,(hl)
	cp 23
	jr z,print_pos_xy
	cp 24
	jr z,print_pos_x
	cp 25
	jr z,print_pos_y
	inc hl
	or a
	ret z
	call print_char
	jr print_str
print_pos_xy
	inc hl
	ld a,(hl)
	ld (pos_x),a		; x-coord
	inc hl
	ld a,(hl)
	ld (pos_y),a		; y-coord
	inc hl
	jr print_str
print_pos_x
	inc hl
	ld a,(hl)
	ld (pos_x),a		; x-coord
	inc hl
	jr print_str
print_pos_y
	inc hl
	ld a,(hl)
	ld (pos_y),a		; y-coord
	inc hl
	jr print_str

; -----------------------------------------------------------------------------
; print character i: a - ansi char
; -----------------------------------------------------------------------------
print_char
	push hl
	push bc
	cp 13
	jr z,pchar2
	sub 32
	ld c,a			; временно сохранить в с
	ld a,#00
	org $-1
pos_y	db #00
	rrca
	rrca
	rrca
	or #00
	org $-1
pos_x	db #00
	ld h,high osd_buffer	; osd_buffer
	ld l,a
	ld (hl),c
	ld a,(pos_x)		; x
	inc a
	cp 32
	jr c,pchar1
pchar2
	ld a,(pos_y)		; y
	inc a
	cp 8
	jr c,pchar0
	xor a
pchar0
	ld (pos_y),a
	xor a
pchar1
	ld (pos_x),a
	pop bc
	pop hl
	ret

; -----------------------------------------------------------------------------
; print hexadecimal i: a - 8 bit number
; -----------------------------------------------------------------------------
print_hex
	ld c,a
	and $f0
	rrca
	rrca
	rrca
	rrca
	call hex2
	ld a,c
	and $0f
hex2
	cp 10
	jr nc,hex1
	add 48
	jp print_char
hex1
	add 55
	jp print_char

; -----------------------------------------------------------------------------
; print decimal i: l,d,e - 24 bit number , e - low byte
; -----------------------------------------------------------------------------
print_dec
	ld ix,dectb_w
	ld b,8
	ld h,0
lp_pdw1
	ld c,"0"-1
lp_pdw2
	inc c
	ld a,e
	sub (ix+0)
	ld e,a
	ld a,d
	sbc (ix+1)
	ld d,a
	ld a,l
	sbc (ix+2)
	ld l,a
	jr nc,lp_pdw2
	ld a,e
	add (ix+0)
	ld e,a
	ld a,d
	adc (ix+1)
	ld d,a
	ld a,l
	adc (ix+2)
	ld l,a
	inc ix
	inc ix
	inc ix
	ld a,h
	or a
	jr nz,prd3
	ld a,c
	cp "0"
	ld a," "
	jr z,prd4
prd3
	ld a,c
	ld h,1
prd4
	call print_char
	djnz lp_pdw1
	ret
dectb_w
	db #80,#96,#98		; 10000000 decimal
	db #40,#42,#0f		; 1000000
	db #a0,#86,#01		; 100000
	db #10,#27,0		; 10000
	db #e8,#03,0		; 1000
	db 100,0,0		; 100
	db 10,0,0		; 10
	db 1,0,0		; 1

; SPI loader
; -----------------------------------------------------------------------------
rom_loader
	ld d,download_on
	call spi_start
	ld d,sc_flash
	call spi_start
	ld d,#03		; command = read
	call spi_w
	;ld d,n
	db #16			; set address
addr1	db #00
	ld e,d
	call spi_w
	db #16
addr2	db #00
	ld h,d
	call spi_w
	db #16
addr3	db #00
	ld l,d
	call spi_w
	
; checksum = #000000
	xor a
	ld (checksum_32),a
	ld (checksum_24),a
	ld (checksum_16),a
	ld (checksum_08),a
	ld (header_cnt),a
	ld ix,header

spi_loader1
 	call spi_r		; a <= spiflash byte
 	out (port_05),a		; a => sdram
 
; checksum 32bit
	ld c,a
	ld b,#00
	ld a,(checksum_08)
	add a,c
	ld (checksum_08),a
	ld a,(checksum_16)
	adc a,b
	ld (checksum_16),a
	ld a,(checksum_24)
	adc a,b
	ld (checksum_24),a
	ld a,(checksum_32)
	adc a,b
	ld (checksum_32),a

 	ld a,(header_cnt)	; =0? End
	cp 8
 	jr nc,loop2
	inc a
 	ld (header_cnt),a
	ld (ix+0),c		; c => (header)
	inc ix
;-----------	

loop2 	ld c,#01
 	add hl,bc
 	ld a,e
 	adc a,b
 	ld e,a

 	db #3e
addr4	db #00
 	cp e
 	jr nz,spi_loader1
	db #3e
addr5	db #00
 	cp h
 	jr nz,spi_loader1
	db #3e
addr6	db #00
 	cp l
 	jr nz,spi_loader1
;-----------	

; 	in a,(port_05)
; 	rlca
; 	jr nc,spi_loader1

	ld d,download_on
	call spi_end
	ld d,sc_flash
	call spi_end

	ld a,24			; x
	ld (pos_x),a
	ld a,7			; y
	ld (pos_y),a
	ld a,(checksum_32)
	call print_hex
	ld a,(checksum_24)
	call print_hex
	ld a,(checksum_16)
	call print_hex
	ld a,(checksum_08)
	call print_hex
	ret
;----------------------------------
print_header
	ld hl,hdr
	call print_str
	ld a,4			; x
	ld (pos_x),a
	ld a,7			; y
	ld (pos_y),a
	ld ix,header
	ld a,(ix+4)
	call print_hex
	ld a,11			;x
	ld (pos_x),a
	ld a,(ix+5)
	call print_hex
	ld a,18			;x
	ld (pos_x),a
	ld a,(ix+6)
	and %11110000
	rrca
	rrca
	rrca
	rrca
	ld c,a
	ld a,(ix+7)
	and %11110000
	or c
	call print_hex
	ret

; -----------------------------------------------------------------------------
; sd_loader	
; 	ld d,download_on
; 	call spi_start
; ; INIT SD CARD
; 	ld a,#00		;STREAM: SD_INIT
; 	call FAT_DRV
; 	jr nz,ERR		;INIT - FAILED
; ; Find DIR entry
; 	ld hl,FES1
; 	ld a,#01		;find DIR entry
; 	call FAT_DRV
; 	jr nz,ERR		;dir not found
; 	ld a,#02		;SET CURR DIR - ACTIVE
; 	call FAT_DRV
; ; Find File entry
; 	ld hl,FES2
; 	ld a,#01		;find File entry
; 	call FAT_DRV
; 	jr nz,ERR		;file not found


; 	ld c,81			;1942.NES = 40976 bytes / 512 = 81 block
; fat32_loader
; 	ld de,sector		;offset in PAGE: 
; 	ld b,#01		;1 block = 512 Byte
; 	ld a,#03		;LOAD512(TSFAT.ASM)
; 	call FAT_DRV		;return CDE - Address
; 	jr nz,ERR

; 	ld hl,sector
; 	ld b,0
; fat32_loader1
; 	out (port_05),a		; a => sdram
; 	djnz fat32_loader1
; fat32_loader2
; 	out (port_05),a		; a => sdram
; 	djnz fat32_loader2

; 	dec c
; 	jr nz,fat32_loader

; 	ld d,download_on
; 	call spi_end
; ERR
; 	ret

; -----------------------------------------------------------------------------
; управляющие коды
; 13 (0x0d)		- след строка
; 23 (0x17),x,y		- изменить позицию на координаты x,y
; 24 (0x18),x		- изменить позицию по x
; 25 (0x19),y		- изменить позицию по y
; 0			- конец строки

; x(0-31),y(0-7)

;	   "01234567890123456789012345678901"
menu
	db "NES (build 20180624) By MVV     "
	db "Board:ReVerSE-U16c    FlashID:  "
	db "Reset[Esc] OSD[Win] ROM[Up/Down]"
	db "DJOY1-2: USB1-2 Keyboard/GamePad"
	db "Start[Enter ]      Select[Space]"
	db "D-Pad[Cursor] B[LShift] A[LCtrl]"
	db "                                "
hdr	db 23,0,7,"PRG:   CHR:   MPR:   CS:",0
ldr	db 23,0,7,"Loading...                      ",0

; Name of ROMs files
; FES1     	db #10			;flag (#00 - file, #10 - dir)
; 		db "NES",0		;DIR name

; FES2     	db #00			;flag (#00 - file, #10 - dir)
; 		db "1942.NES",0		;file name

;BLOCK					START ADDRESS	END ADDRESS
;Page_0					0x00000000	0x000AF6E8
;Super_Mario_Bros.hex			0x000AF6E9	0x000B96F8
;Gradius.hex				0x000B96F9	0x000C9708
;Tank1990.hex				0x000C9709	0x000D3718
;Chip_'n_Dale_Rescue_Rangers.hex	0x000D3719	0x00113728
;Contra.hex				0x00113729	0x00133738
;Lode_Runner.hex			0x00133739	0x00139748
;Darkwing_Duck.hex			0x00139749	0x00179758
;Castlevania_III.hex			0x00179759	0x001D9768
;Teenage_Mutant_Ninja_Turtles_III.hex	0x001D9769	0x00259778
;Tiny_Toon_Adventures.hex		0x00259779	0x00299788
;battletoads.hex			0x00299789	0x002D9798
;Prince_of_Persia.hex			0x002D9799	0x002F97A8
;1943.hex				0x002F97A9	0x003197B8
;kirbysadventure.hex			0x003197B9	0x003D97C8
;Aladdin (Unl).hex			0x003D97C9	0x00459768
;Battletoads_&_Double_Dragon.hex	0x00459769	0x00499778
;Super C (U).hex			0x00499779	0x004D9788
;ferrari-grand-prix-challenge.hex	0x004D9789	0x00519798
;lifeforce-(e)-[!].hex			0x00519799	0x005397A8
;road-fighter-(e)-[!].hex		0x005397A9	0x0053F7B8
;RoboCop_2.hex				0x0053F7B9	0x0057F848
;smb3.hex				0x0057F849	0x005DF858
;snow-bros-(u).hex			0x005DF859	0x0061F868
;tetris-2.hex				0x0061F869	0x0062B878

rom	db 0
	db #0A,#F6,#E9,"Super Mario Bros                ",0
	db #0B,#96,#F9,"Gradius                         ",0
	db #0C,#97,#09,"Tank1990                        ",0
	db #0D,#37,#19,"Chip'n Dale Rescue Rangers      ",0
	db #11,#37,#29,"Contra                          ",0
	db #13,#37,#39,"Lode Runner                     ",0
	db #13,#97,#49,"Darkwing Duck                   ",0
	db #17,#97,#59,"Castlevania 3                   ",0
	db #1D,#97,#69,"Teenage Mutant Ninja Turtles 3  ",0
	db #25,#97,#79,"Tiny Toon Adventures            ",0
	db #29,#97,#89,"Battletoads                     ",0
	db #2D,#97,#99,"Prince of Persia                ",0
	db #2F,#97,#A9,"1943                            ",0
	db #31,#97,#B9,"Kirby's Adventure               ",0
	db #3D,#97,#C9,"Aladdin                         ",0
	db #45,#97,#69,"Battletoads & Double Dragon     ",0
	db #49,#97,#79,"Super C                         ",0
	db #4D,#97,#89,"Ferrari Grand Prix Challenge    ",0	
	db #51,#97,#99,"Lifeforce                       ",0	
	db #53,#97,#A9,"Road Fighter                    ",0	
	db #53,#F7,#B9,"RoboCop 2                       ",0	
	db #57,#F8,#49,"Super Mario Bros 3              ",0	
	db #5D,#F8,#59,"Snow Bros                       ",0	
	db #61,#F8,#69,"Tetris 2                        ",0	
	db #62,#B8,#79


	; End

rom_index	db #01
index		db #01

checksum_32	db #00
checksum_24	db #00
checksum_16	db #00
checksum_08	db #00

header_cnt	db #00
header		db #0000,#0000,#0000,#0000

; sector		ds 512
; -----------------------------------------------------------------------------

	display "Code start: ",/a, startprog, " end: ",/a, $-1
	display "OSD buffer start: ",/a, osd_buffer, " end: ",/a, osd_buffer + osd_buffer_size - 1
;	INCLUDE "TSFAT.ASM"
	savebin "loader.bin",startprog, 8192

;