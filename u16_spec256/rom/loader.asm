 		DEVICE	ZXSPECTRUM48
; -----------------------------------------------------------------[19.08.2016]
; ReVerSE-U16 Spec256 Loader
; -----------------------------------------------------------------------------
; Engineer: MVV <mvvproject@gmail.com>

; Port #xx00 - bit0=0:loader on, 1:loader off; bit1=0:LDR #0000-#03FF write disable, 1:LDR #0000-#0100 write enable
; Port #xx01 - #0000-#FFFF loader exit address
; Port #xx02 - SPI data
; Port #xx03 - SPI status: bit7=1:bysy
; Port #xx04 - bit7..0=1:disable memory write for CPU7..0; 0:enable


;#0000-#07FF LRAM

;#0000-#3FFF rom82 16K
;#4000-#FFFF *.sna 48K	
;#4000-#FFFF *.gfx 384K
pr_param	equ #5AF0

	org #0000
startprog:
	di

; -----------------------------------------------------------------------------
; Palitte
; -----------------------------------------------------------------------------
; 	ld hl,#4000
; n1	ld a,%11111110
; 	out (#04),a
; 	ld (hl),%01010101

; 	ld a,%11111101
; 	out (#04),a
; 	ld (hl),%00110011

; 	ld a,%11111011
; 	out (#04),a
; 	ld (hl),%00001111

; 	ld a,%11110111
; 	out (#04),a
; 	xor a
; 	bit 0,l
; 	jr z,n2
; 	cpl
; n2	ld (hl),a

; 	ld a,%11101111
; 	out (#04),a
; 	xor a
; 	bit 1,l
; 	jr z,n3
; 	cpl
; n3	ld (hl),a

; 	ld a,%11011111
; 	out (#04),a
; 	xor a
; 	bit 2,l
; 	jr z,n4
; 	cpl
; n4	ld (hl),a

; 	ld a,%10111111
; 	out (#04),a
; 	xor a
; 	bit 3,l
; 	jr z,n5
; 	cpl
; n5	ld (hl),a

; 	ld a,%01111111
; 	out (#04),a
; 	xor a
; 	bit 4,l
; 	jr z,n6
; 	cpl
; n6	ld (hl),a

; 	inc hl
; 	ld a,h
; 	cp #64
; 	jr c,n1

; 	xor a
; 	out (#04),a

	ld sp,#5AFE

; -----------------------------------------------------------------------------
; SPI autoloader
; -----------------------------------------------------------------------------
	call spi_end
	call cls	; очистка экрана
	call spi_start
	ld d,%00000011	; command = read
	call spi_w

	ld d,#0b	; address = #0B0000
	call spi_w
	ld d,#00
	call spi_w
	ld d,#00
	call spi_w

; load #0000-#3FFF rom82 16K		
	ld hl,#0000	; start address
spi_loader1
	call spi_r
	ld (hl),a
	inc hl
	ld a,h
	cp #40
	jr nz,spi_loader1
	call spi_end

;Page_0			0x00000000	0x000AF6E8
;82.hex			0x000B0000	0x000B3FFF

;PROFANAT_SNA.hex	0x000B4000	0x000C001A
;PROFANAT_GFX.hex	0x000C001B	0x0012001A

;ARMYMOV1_SNA.hex	0x0012001B	0x0012C035
;ARMYMOV1_GFX.hex	0x0012C036	0x0018C035

;ARMYMOV2_SNA.hex	0x0018C036	0x00198050
;ARMYMOV2_GFX.hex	0x00198051	0x001F8050

;CYBERNOI_SNA.hex	0x001F8051	0x0020406B
;CYBERNOI_GFX.hex	0x0020406C	0x0026406B

;GAMEOV1_SNA.hex	0x0026406C	0x00270086
;GAMEOV1_GFX.hex	0x00270087	0x002D0086

;GAMEOV2_SNA.hex	0x002D0087	0x002DC0A1
;GAMEOV2_GFX.hex	0x002DC0A2	0x0033C0A1

;JETPAC_SNA.hex		0x0033C0A2	0x003480BC
;JETPAC_GFX.hex		0x003480BD	0x003A80BC
;ROM0_GFX.hex		0x003A80BD	0x003C80BC

;KNLORE_SNA.hex		0x003C80BD	0x003D40D7
;KNLORE_GFX.hex		0x003D40D8	0x004340D7

;PHANTIS1_SNA.hex	0x004340D8	0x004400F2
;PHANTIS1_GFX.hex	0x004400F3	0x004A00F2

;SABREW_SNA.hex		0x004A00F3	0x004AC10D
;SABREW_GFX.hex		0x004AC10E	0x0050C10D
;ROM0_GFX.hex		0x0050C10E	0x0052C10D

;ScoobyDoo256_SNA.hex	0x0052C10E	0x00538128
;ScoobyDoo256_GFX.hex	0x00538129	0x00598128

;SOLOMONS_SNA.hex	0x00598129	0x005A4143
;SOLOMONS_GFX.hex	0x005A4144	0x00604143

;UNDERW_SNA..hex	0x00604144	0x0061015E
;UNDERW_GFX.hex		0x0061015F	0x0067015E

	ld hl,str	; выводим меню
	call print_str
keypress
	ld a,#f7	; опрашиваем клавиши 5,4,3,2,1
	in a,(#fe)
	rrca
	ld e,#0B
	ld bc,#4000
	jr nc,loader	; клавиша 1?
	rrca
	ld e,#12
	ld bc,#001B
	jr nc,loader	; клавиша 2?
	rrca
	ld e,#18
	ld bc,#C036
	jr nc,loader	; клавиша 3?
	rrca
	ld e,#1F
	ld bc,#8051
	jr nc,loader	; клавиша 4?
	rrca
	ld e,#26
	ld bc,#406C
	jr nc,loader	; клавиша 5?

	ld a,#ef	; опрашиваем клавиши 6,7,8,9,0
	in a,(#fe)
	rrca
	ld e,#4A
	ld bc,#00F3
	jr nc,loader	; клавиша 0?
	rrca
	ld e,#43
	ld bc,#40D8
	jr nc,loader	; клавиша 9?
	rrca
	ld e,#3C
	ld bc,#80BD
	jr nc,loader	; клавиша 8?
	rrca
	ld e,#33
	ld bc,#C0A2
	jr nc,loader	; клавиша 7?
	rrca
	ld e,#2D
	ld bc,#0087
	jr nc,loader	; клавиша 6?

	ld a,#fb	; опрашиваем клавиши Q,W,E
	in a,(#fe)
	rrca
	ld e,#52
	ld bc,#C10E
	jr nc,loader	; клавиша Q?
	rrca
	ld e,#59
	ld bc,#8129
	jr nc,loader	; клавиша W?
	rrca
	ld e,#60
	ld bc,#4144
	jr c,keypress	; клавиша E?

loader
	ld a,%00000010	; LDR #0000-#03FF write enable
	out (#00),a

	ld sp,#07FE

; -----------------------------------------------------------------------------	
; load #4000-#FFFF *.sna 48K
; -----------------------------------------------------------------------------	
	ld hl,#4000

; Смещение Размер   Описание
; ---------------------------
; 0        1        Регистр I.
; 1        2        Регистровая пара HL'.
; 3        2        Регистровая пара DE'.
; 5        2        Регистровая пара BC'.
; 7        2        Регистровая пара AF'.
; 9        2        Регистровая пара HL.
; 11       2        Регистровая пара DE.
; 13       2        Регистровая пара BC.
; 15       2        Регистровая пара IY.
; 17       2        Регистровая пара IX.
; 19       1        Состояние прерываний. Бит 2 содержит состояние
;                   триггера IFF2, бит 1 - IFF1 (0=DI, 1=EI).
; 20       1        Регистр R.
; 21       2        Регистровая пара AF.
; 23       2        Указатель на вершину стэка (SP).
; 25       1        Режим прерываний: 0=IM0, 1=IM1, 2=IM2.
; 26       1        Цвет бордюра, 0-7.
; 27       49152    Содержимое памяти с адреса 16384 (4000h).

	call spi_start
	ld d,%00000011	; command = read
	call spi_w

	ld d,e		; address
	call spi_w
	ld d,b
	call spi_w
	ld d,c
	call spi_w

	call spi_r
	ld i,a			; i
	call spi_r
	ld (index1+1),a		; hl'
	call spi_r
	ld (index1+2),a
	call spi_r
	ld (index3+1),a		; de'
	call spi_r
	ld (index3+2),a
	call spi_r
	ld (index5+1),a		; bc'
	call spi_r
	ld (index5+2),a
	call spi_r
	ld (index7+1),a		; af'
	call spi_r
	ld (index7+2),a
index7	ld bc,#0000
	push bc
	pop af
	ex af,af'
	call spi_r
	ld (index9+1),a		; hl
	call spi_r
	ld (index9+2),a
	call spi_r
	ld (index11+1),a	; de
	call spi_r
	ld (index11+2),a
	call spi_r
	ld (index13+1),a	; bc
	call spi_r
	ld (index13+2),a
	call spi_r
	ld (index15+2),a	; iy
	call spi_r
	ld (index15+3),a
	call spi_r
	ld (index17+2),a	; ix
	call spi_r
	ld (index17+3),a
	call spi_r
	bit 1,a
	ld a,#f3		; di
	jr z,r0
	ld a,#fb		; ei
r0
	ld (index19),a		; iff
	call spi_r
	ld (index20+1),a	; r
	call spi_r
	ld (index21+1),a	; af
	call spi_r
	ld (index21+2),a
	call spi_r
	ld (index23+1),a	; sp
	call spi_r
	ld (index23+2),a
	call spi_r
	cp #00
	im 0
	jr z,spi_loader3
	cp #01
	im 1
	jr z,spi_loader3
	im 2	
spi_loader3
	call spi_r
	ld (index24+1),a	; border

spi_loader2
	call spi_r
	ld (hl),a
	inc hl
	ld a,h
	or l
	jr nz,spi_loader2

;	jp init_cpu



	
; -----------------------------------------------------------------------------	
; load #4000-#FFFF *.gfx 384K
; -----------------------------------------------------------------------------	
	ld hl,#4000
load_gfx
	ld ix,buffer
spi_loader5
	ld a,%00000010		; LDR #0000-#03FF write enable
	out (#00),a

	call spi_r
	ld (ix+7),a		; bit 7
	call spi_r
	ld (ix+6),a
	call spi_r
	ld (ix+5),a
	call spi_r
	ld (ix+4),a
	call spi_r
	ld (ix+3),a
	call spi_r
	ld (ix+2),a
	call spi_r
	ld (ix+1),a
	call spi_r
	ld (ix+0),a		; bit 0

	or (ix+1)
	or (ix+2)
	or (ix+3)
	or (ix+4)
	or (ix+5)
	or (ix+6)
	or (ix+7)
	jp z,spi_loader4	; #00 = Not modified byte

	ld b,#ff
	ld a,(ix+7)		; #FF = Not modified byte
	cp b
	jp z,spi_loader4
	ld a,(ix+6)
	cp b
	jp z,spi_loader4
	ld a,(ix+5)
	cp b
	jp z,spi_loader4
	ld a,(ix+4)
	cp b
	jp z,spi_loader4
	ld a,(ix+3)
	cp b
	jp z,spi_loader4
	ld a,(ix+2)
	cp b
	jp z,spi_loader4
	ld a,(ix+1)
	cp b
	jp z,spi_loader4
	ld a,(ix+0)
	cp b
	jp z,spi_loader4

	ld b,8
	ld de,buffer1
spi_loader6
	rlc (ix+0)
	rla
	rlc (ix+1)
	rla
	rlc (ix+2)
	rla
	rlc (ix+3)
	rla
	rlc (ix+4)
	rla
	rlc (ix+5)
	rla
	rlc (ix+6)
	rla
	rlc (ix+7)
	rla
	ld (de),a
	inc de
	djnz spi_loader6

	xor a			; LDR #0000-#03FF write disable
	out (#00),a

	ld a,%11111110		; cpu0
	out (#04),a
	ld a,(ix+15)
	ld (hl),a

	ld a,%11111101		; cpu1
	out (#04),a
	ld a,(ix+14)
	ld (hl),a

	ld a,%11111011		; cpu2
	out (#04),a
	ld a,(ix+13)
	ld (hl),a

	ld a,%11110111		; cpu3
	out (#04),a
	ld a,(ix+12)
	ld (hl),a

	ld a,%11101111		; cpu4
	out (#04),a
	ld a,(ix+11)
	ld (hl),a

	ld a,%11011111		; cpu5
	out (#04),a
	ld a,(ix+10)
	ld (hl),a

	ld a,%10111111		; cpu6
	out (#04),a
	ld a,(ix+9)
	ld (hl),a

	ld a,%01111111		; cpu7
	out (#04),a
	ld a,(ix+8)
	ld (hl),a

	xor a			; cpu all
	out (#04),a

spi_loader4
	ld a,l
	and %00000111
	out (#fe),a		; полосы на бордюре иметирующие загрузку

	inc hl
	ld a,l
	or h
	jp nz,spi_loader5

;	ret

; -----------------------------------------------------------------------------	
; Инициализация CPU
; -----------------------------------------------------------------------------	
init_cpu
	ld a,%00000001		; spi end
	out (#03),a

	xor a			; LDR #0000-#03FF write disable
	out (#00),a

index1	ld hl,#0000
index3	ld de,#0000
index5	ld bc,#0000
	exx
index23	ld sp,#0000
	pop de
	ld b,d
;	ld a,%00000010		; LDR #0000-#03FF write enable
;	out (#00),a
;	ld (index27+1),de
;	xor a			; LDR #0000-#03FF write disable
;	out (#00),a
	ld c,#01
	out (c),e
index13	ld bc,#0000
index15	ld iy,#0000
index17	ld ix,#0000
	ld a,#01
	out (#00),a		; loader off
index20	ld a,#00
	ld r,a
index24 ld a,#00
	out (#fe),a
index21	ld hl,#0000
	push hl
	pop af
index9	ld hl,#0000
	push de
index11	ld de,#0000
index19	ei
;index27	jp #0000
	ret

; -----------------------------------------------------------------------------	
; print string i: hl - pointer to string zero-terminated
; -----------------------------------------------------------------------------	
print_str
	ld a,(hl)
;	cp 17
;	jr z,print_color	
	cp 23
	jr z,print_pos_xy
	or a
	ret z
	inc hl
	call print_char
	jr print_str
print_pos_xy
	inc hl
	ld a,(hl)
	ld (pr_param),a		; x-coord
	inc hl
	ld a,(hl)
	ld (pr_param+1),a	; y-coord
	inc hl
	jr print_str
;print_color
;	inc hl
;	ld a,(hl)
;	ld (pr_param+2),a	; color
;	inc hl
;	jr print_str

; -----------------------------------------------------------------------------	
; print character i: a - ansi char
; -----------------------------------------------------------------------------	
print_char
	push hl
	push de
	push bc
	cp 13
	jr z,pchar2
	sub 32
	ld c,a			; временно сохранить в с
	ld hl,(pr_param)	; hl=yx
	;координаты -> scr adr
	;in: H - Y координата, L - X координата
	;out:hl - screen adress
	ld a,h
	and 7
	rrca
	rrca
	rrca
	or l
	ld e,a
	ld a,h
        and 24
	or 64
	ld d,a
	ld l,c			; l= символ
	ld h,0
	add hl,hl
	add hl,hl
	add hl,hl
	ld bc,#3d00
	add hl,bc
	ld b,8
	ld a,(pr_param+1)
	rlca
	rlca
	rlca
	ld c,a
pchar3	
	ld a,(hl)
	ex af,af'
	ld a,c
	out (#04),a
	inc c
	ex af,af'
	ld (de),a
	xor a			; cpu all
	out (#04),a
	inc d
	inc hl
	djnz pchar3

	ld a,(pr_param)		; x
	inc a
	cp 32
	jr c,pchar1
pchar2
	ld a,(pr_param+1)	; y
	inc a
	cp 24
	jr c,pchar0
	jr pchar00
pchar0
	ld (pr_param+1),a
pchar00
	xor a
pchar1
	ld (pr_param),a
	pop bc
	pop de
	pop hl
	ret

; -----------------------------------------------------------------------------	
; Очистка экрана
; -----------------------------------------------------------------------------	
cls
 	ld de,#4001
 	ld bc,#1800
 	ld h,d
 	ld l,c
	ld a,c
	out (#fe),a
 	out (#04),a		; A = %00000000 одновременно доступ к памяти CPU7..0
 	ld (hl),c
 	ldir
 	ret

; -----------------------------------------------------------------------------	
; SPI Driver
; -----------------------------------------------------------------------------
; Ports:
; #02: Data Buffer (write/read)
;	bit 7-0	= Stores SPI read/write data
; #03: Command/Status Register (write)
;	bit 7-1	= Reserved
;	bit 0	= 1:END   	(Deselect device after transfer/or immediately if START = '0')
; #03: Command/Status Register (read):
; 	bit 7	= 1:BUSY	(Currently transmitting data)
;	bit 6-0	= Reserved

spi_end
	ld a,%00000001	; config = end
	out (#03),a
	ret
spi_start
	xor a
	out (#03),a
	ret
spi_w
	in a,(#03)
	rlca
	jr c,spi_w
	ld a,d
	out (#02),a
	ret
spi_r
	ld d,#ff
	call spi_w
spi_r1	
	in a,(#03)
	rlca
	jr c,spi_r1
	in a,(#02)
	ret

str	db 23,0,0
	db "ReVerSE-U16 DevBoard",13
	db "https://github.com/mvvproject",13,13
	db "FPGA SoftCore - SPEC256",13
	db "(build 20160819) By MVV",13,13
	db "Select Game:",13,13
 	db "1 Abu Simbel Profanation",13
	db "2 Army Moves",13
	db "3 Army Moves 2",13
	db "4 Cybernoid",13
	db "5 Game Over",13
	db "6 Game Over 2",13
	db "7 JetPac",13
	db "8 Knight Lore",13
	db "9 Phantis",13
	db "0 Sabre Wulf",13
	db "Q Scooby Doo",13
	db "W Solomon's Key",13
	db "E Underwurlde",13,13,13
	db "F4: Reset, F5: Menu",0

buffer		db #00,#00,#00,#00,#00,#00,#00,#00
buffer1		db #00,#00,#00,#00,#00,#00,#00,#00
; -----------------------------------------------------------------------------

	display "End: ",/a, $

	savebin "loader.bin",startprog, 2048
