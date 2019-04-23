	DEVICE	ZXSPECTRUM48

; ReVerSE-U16 POST v1.0 (build 20140726)

; Карта памяти
; A15 A14 A13
; 0   0   0	0000-1fff ( 8192) ROM
; 0   0   1	2000-32bf ( 4800) текстовый буфер (символ, цвет, символ...)
; 0   0   1	32c0-3fff ( 3392) RAM
; 0   1   x	4000-7fff (16384) не используется
; 1   x   x	8000-ffff (32768) SDRAM страница (0..2047)

; Порта в/в
; #00	R/W	b7..0 = номер страницы b7..0 SDRAM, подключенной с адреса 8000-ffff
; #01	W	b2..0 = номер страницы b10..8 SDRAM, подключенной с адреса 8000-ffff

vram			= $2000
ram			= $32c0
ramtop			= $3fff
VARIABLES		EQU #32c0	; Адрес начала переменных
port_sdram_page		EQU #00

; Переменные
pr_param		EQU VARIABLES+0
sdram_page		EQU VARIABLES+3
print_addr		EQU VARIABLES+5


;--------------------------------------
; Reset
		ORG #0000
StartProg:
		di
		jp Test

;--------------------------------------
; INT
		ORG #0038
Int
		reti
;--------------------------------------
; NMI
		ORG #0066
Nmi
		retn
;--------------------------------------

		ORG #0100
Test
		ld sp,ramtop-1
test1		call cls
		ld hl,str1
		call print_str
;		jr test1
		halt
		
; --------------------------------------
; Тест памяти
; TestSram	ld de,str02
		; ld hl,video_ram+160*3
		; call PrintStr

		; xor a
		; ld hl,video_ram+160*3+38*2

; testSramNext	ld (port_page),a
		; ld (sram_page),a
		; ld (print_addr),hl

		; ld hl,#8000
		; ld b,h
		; ld c,l

		; call TestMem
		; jr nz,testSramError

		; ld hl,(print_addr)
		; ld (hl),219
		; inc hl
		; inc hl

		; ld a,(sram_page)
		; inc a
		; cp 16
		; jr nz,testSramNext

		; ld de,str05		"OK."
		; ld hl,video_ram+160*3+56*2
		; call PrintStr

		; jr TestMult
; --------------------------------------
; testSramError	ld d,a
		; push de
		; push hl

		; ld de,str15		"Error."
		; ld hl,video_ram+160*3+56*2
		; call PrintStr

		; ld de,str04		"ERROR:"
		; ld hl,video_ram+160*4
		; call PrintStr

		; pop de
		; ld c,0
		; ld a,(sram_page)
		; srl a
		; rr c
		; ld hl,video_ram+160*4+15*2
		; call ByteToHexStr
		; ld a,d
		; and %01111111
		; or c
		; call ByteToHexStr
		; ld a,e
		; call ByteToHexStr

		; pop de
		; ld a,d
		; ld hl,video_ram+160*4+32*2
		; call ByteToBitStr
		; ld a,e
		; ld hl,video_ram+160*4+48*2
		; call ByteToBitStr







; ;--------------------------------------
; ; Тест памяти
; ;--------------------------------------
; TestMem		xor a
		; ld (hl),a
		; nop
		; ld e,(hl)
		; cp e
		; ret nz
		; cpl
		; ld (hl),a
		; nop
		; ld e,(hl)
		; cp e
		; ret nz
		; ld a,%01010101
		; ld (hl),a
		; nop
		; ld e,(hl)
		; cp e
		; ret nz
		; cpl
		; ld (hl),a
		; nop
		; ld e,(hl)
		; cp e
		; ret nz
; testMemNext	inc hl
		; dec bc
		; ld a,b
		; or c
		; jr nz,TestMem
		; ret




		
;Print driver v1.02 by shurik-ua
;управляющие коды
;13 (0x0d)		- след строка
;17 (0x11),color	- изменить цвет последующих символов
;23 (0x17),x,y		- изменить позицию на координаты x,y
;24 (0x18),x		- изменить позицию по x
;25 (0x19),y		- изменить позицию по y
;0			- конец строки
;пример -
;	db	23,0,1,17,7,"Z80 instruction exerciser for ",17,$46,"Reverse",17,7," u16 board",13,13,0
;выведет в позиции 0,1 белым "Z80 instruction exerciser for ", затем ярким жёлтым "Reverse",
;и далее белым " u16 board" и сместит позицию печати на 0,3
;
;row - позиция по y до которой будет вертикальный скролл по достижении конца экрана
;

row	=	2

;========================
;clear screen
cls
	ld hl,vram
	ld de,vram+1
	ld bc,31*160-1
	ld (hl),0
	ldir
	ret

;========================
;print string i: hl - pointer to string zero-terminated
print_str
	ld a,(hl)
	cp 17
	jr z,print_color
	cp 23
	jr z,print_pos_xy
	cp 24
	jr z,print_pos_x
	cp 25
	jr z,print_pos_y
	or a
	ret z
	inc hl
	call print_char
	jr print_str
print_color
	inc hl
	ld a,(hl)
	ld (pr_param+2),a		;color
	inc hl
	jr print_str
print_pos_xy
	inc hl
	ld a,(hl)
	ld (pr_param),a			;x-coord
	inc hl
	ld a,(hl)
	ld (pr_param+1),a		;y-coord
	inc hl
	jr print_str
print_pos_x
	inc hl
	ld a,(hl)
	ld (pr_param),a			;x-coord
	inc hl
	jr print_str
print_pos_y
	inc hl
	ld a,(hl)
	ld (pr_param+1),a		;y-coord
	inc hl
	jr print_str

;========================
;print character i: a - ansi char
print_char
	push hl
	push de
	push bc
	cp 13
	jr z,pchar2
	ld c,a
	ld a,(pr_param+1)
	call mult
	ld de,vram
	add hl,de
	ld a,(pr_param)
	sla a
	ld e,a
	ld d,0
	add hl,de
	ld a,(pr_param+2)
	ld (hl),c
	inc hl
	ld (hl),a
	ld a,(pr_param)
	inc a
	cp 80
	jr nz,pchar1
pchar2
	ld a,(pr_param+1)
	inc a
	cp 30
	jr nz,pchar0
	ld de,vram+row*160
	ld hl,vram+(row+1)*160
	ld bc,(30-row)*160
	ldir
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

;========================
;print hexadecimal i: a - 8 bit number
print_hex
	ld b,a
	and $f0
	rrca
	rrca
	rrca
	rrca
	call hex2
	ld a,b
	and $0f
hex2
	cp 10
	jr nc,hex1
	add 48
	jp print_char
hex1
	add 55
	jp print_char

;========================
;print decimal i: l,d,e - 24 bit number , e - low byte
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
	db #80,#96,#98	;10000000 decimal
	db #40,#42,#0f	;1000000
	db #a0,#86,#01	;100000
	db #10,#27,0	;10000
	db #e8,#03,0	;1000
	db 100,0,0	;100
	db 10,0,0	;10
	db 1,0,0	;1

;========================
; Byte to HEX string
; A  = byte, HL = buffer
ByteToHexStr
	ld b,a
	rrca
	rrca
	rrca
	rrca
	and #0f
	add a,#90
	daa
	adc a,#40
	daa
	ld (hl),a
	inc hl
	ld a,b
	and #0f
	add a,#90
	daa
	adc a,#40
	daa
	ld (hl),a
	inc hl
	ret
	
;========================
; Byte to BIN string
; A  = byte, HL = vram (8 bytes)
ByteToBitStr
	ld b,8
byteToBitStr2
	rlca
	jr nc,byteToBitStr1
	ld (hl),#31
	inc hl
	inc hl
	djnz byteToBitStr2
	ret
byteToBitStr1
	ld (hl),#30
	inc hl
	inc hl
	djnz byteToBitStr2
	ret
	
;========================
; Multiple
; a = number; hl = result (a * 160 )
mult
	ld de,160
	ld h,d
	ld l,d
mult1
	or a
	ret z
	add hl,de
	dec a
	jr mult1
;---------------------------------------------------------------
	
	
	
;управляющие коды
;13 (0x0d)		- след строка
;17 (0x11),color	- изменить цвет последующих символов
;23 (0x17),x,y		- изменить позицию на координаты x,y
;24 (0x18),x		- изменить позицию по x
;25 (0x19),y		- изменить позицию по y
;0			- конец строки

bRGB_bRGB
;00000000001111111111222222222233333333334444444444555555555566666666667777777777
;01234567890123456789012345678901234567890123456789012345678901234567890123456789
;0123456789ABCDEF                                                FEDCBA9876543210
str1	db 23,0,0,17,%00010111,"ReVerSE-U16 Power-On-Self-Test v1.0 (build 20140726) By MVV",13,13
	db 17,%00000111,"SoftCore CPU NZ80v1 @ 50 MHz",13,13
;	db "Test SDRAM 32MB ",0
;7=Bright Paper, 6..4=Paper(RGB), 3=Bright Ink, 2..0=Ink(RGB)
pal	db 17,7,"Ink:",13
	db 17,#00,#db,#db,#db,17,#01,#db,#db,#db,17,#02,#db,#db,#db,17,#03,#db,#db,#db,17,#04,#db,#db,#db,17,#05,#db,#db,#db,17,#06,#db,#db,#db,17,#07,#db,#db,#db,13
	db 17,#08,#db,#db,#db,17,#09,#db,#db,#db,17,#0a,#db,#db,#db,17,#0b,#db,#db,#db,17,#0c,#db,#db,#db,17,#0d,#db,#db,#db,17,#0e,#db,#db,#db,17,#0f,#db,#db,#db,13,13
	db 17,7,"Paper:",13
	db 17,#00,"   ",17,#10,"   ",17,#20,"   ",17,#30,"   ",17,#40,"   ",17,#50,"   ",17,#60,"   ",17,#70,"   ",13
	db 17,#80,"   ",17,#90,"   ",17,#a0,"   ",17,#b0,"   ",17,#c0,"   ",17,#d0,"   ",17,#e0,"   ",17,#f0,"   ",13
	
	db 0
	savebin "test.bin",StartProg, 16384