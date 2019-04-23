 		DEVICE	ZXSPECTRUM48
; -----------------------------------------------------------------[09.08.2014]
; ReVerSE-U16 Loader Version 0.9.2 By MVV
; -----------------------------------------------------------------------------
; V0.1	 05.11.2011	первая версия
; V0.5	 09.11.2011	добавил SPI загрузчик и GS, VS1053
; V0.6	 14.01.2012	добавил расширение памяти KAY
; V0.7	 19.09.2012	по умолчанию режим память 4MB Profi, 96K ROM грузится из M25P40, wav 48kHz, FAT16 loader отключен
; V0.8	 19.03.2014	размер загрузчика 1К
; V0.9	 24.07.2014	одаптирован для U16 EP3C10
; V0.9.1 25.07.2014	одаптирован для U16 EP4CE22/EP3C25
; V0.9.2 09.08.2014	поддержка ENC424J600

system_port	equ #0001	; bit2 = (0:Loader ON, 1:Loader OFF); bit1 = (NC); bit0 = (0:M25P16, 1:ENC424J600)
mask_port	equ #0000	; Маска порта EXT_MEM_PORT по AND
ext_mem_port	equ #dffd	; Порт памяти
pr_param	equ #7f00



	org #0000
startprog:
	di
	ld sp,#7ffe

	xor a
	out (#fe),a
	call cls	; очистка экрана
	ld hl,str1
	call print_str


	xor a		;bit2 = (0:Loader ON, 1:Loader OFF); bit1 = (NC); bit0 = (0:M25P16, 1:ENC424J600)
	ld bc,system_port
	out (c),a
	

; 0B0000 GS 	32K
; 0B8000 GLUK	16K	0
; 0BC000 TR-DOS	16K	1
; 0C0000 OS'86	16K	2
; 0C4000 OS'82	16K	3
; 0C8000 divMMC	 8K	4

; -----------------------------------------------------------------------------
; SPI autoloader
; -----------------------------------------------------------------------------
	call spi_start
	ld d,%00000011	; command = read
	call spi_w

	ld d,#0b	; address = #0b0000
	call spi_w
	ld d,#00
	call spi_w
	ld d,#00
	call spi_w
		
	ld hl,#8000	; gs rom 32k
spi_loader1
	call spi_r
;	ld (hl),a
	inc hl
	ld a,l
	or h
	jr nz,spi_loader1
	
	ld bc,mask_port
	ld a,%11111111	; маска порта по and
	out (c),a
	ld a,%10000100
	ld bc,ext_mem_port
	out (c),a

	xor a		; открываем страницу озу
spi_loader3
	ld bc,#7ffd
	out (c),a
	ld hl,#c000
	ld e,a
spi_loader2
	call spi_r
	ld (hl),a
	out (#fe),a
	inc hl
	ld a,l
	or h
	jr nz,spi_loader2
	ld a,e
	inc a
	cp 5
	jr c,spi_loader3

	call spi_end
	xor a
	ld bc,#7ffd
	out (c),a
	ld bc,ext_mem_port
	out (c),a
	ld a,%00011111	; маска порта (разрешаем 4mb)
	ld bc,mask_port
	out (c),a

	xor a
	out (#fe),a

	ld hl,str3	;завершено
	call print_str

	ld hl,str4	;инициализация MC14818A
	call print_str

; -----------------------------------------------------------------------------
; I2C DS1338 to MC14818 loader
; -----------------------------------------------------------------------------
rtc_init
	ld bc,#3f00
	ld hl,#8000
	call i2c_get

	ld a,#80
	ld bc,#eff7
	out(c),a

; register b
	ld a,#0b
	ld b,#df
	out (c),a
	ld a,#82
	ld b,#bf
	out (c),a
; seconds
	ld a,#00
	ld b,#df
	out (c),a
	ld a,(#8000)	;00h seconds
	and %01111111	;удаляем ch бит
	ld b,#bf
	out (c),a
; minutes		
	ld a,#02
	ld b,#df
	out (c),a
	ld a,(#8001)	;01h minutes
	ld b,#bf
	out (c),a
; hours		
	ld a,#04
	ld b,#df
	out (c),a
	ld a,(#8002)	;02h hours
	and #1f
	ld b,#bf
	out (c),a
; day of the week		
	ld a,#06
	ld b,#df
	out (c),a
	ld a,(#8003)	;03h day
	ld b,#bf
	out (c),a
; date of the month
	ld a,#07
	ld b,#df
	out (c),a
	ld a,(#8004)	;04h date
	ld b,#bf
	out (c),a
; month
	ld a,#08
	ld b,#df
	out (c),a
	ld a,(#8005)	;05h month
	ld b,#bf
	out (c),a
; year
	ld a,#09
	ld b,#df
	out (c),a
	ld a,(#8005)
	; and #c0
	; rlca
	; rlca
	; ld hl,#8010	; ячейка для хранения года (8 бит)
	; add a,(hl)	; год из pcf + поправка из ячейки
	ld b,#bf
	out (c),a
; register b
	ld a,#0b
	ld b,#df
	out (c),a
	ld a,#02
	ld b,#bf
	out (c),a

	ld a,#00
	ld bc,#eff7
	out(c),a

	ld hl,str3	;завершено
	call print_str

	;вывод времени
	ld a,(#8002)	;час
	and #1f
	call print_hex
	ld a,":"
	call print_char
	ld a,(#8001)	;минуты
	call print_hex
	ld a,":"
	call print_char
	ld a,(#8000)	;секунды
	and #7F
	call print_hex

	;вывод даты
	ld a," "
	call print_char
	ld a,(#8004)	;число
	call print_hex
	ld a,"."
	call print_char
	ld a,(#8005)	;месец
	call print_hex
	ld a,"."
	call print_char
	ld a,(#8006)	;год
	call print_hex

	ld hl,str0	;any key
	call print_str

	call anykey

	ld a,%00000100	; bit2 = (0:Loader ON, 1:Loader OFF); bit1 = (NC); bit0 = (0:M25P16, 1:ENC424J600)
	ld bc,system_port
	out (c),a

	ld sp,#ffff
	jp #0000	; запуск системы













; -----------------------------------------------------------------------------	
; I2C 
; -----------------------------------------------------------------------------
; Ports:
; #8C: Data (write/read)
;	bit 7-0	= Stores I2C read/write data
; #8C: Address (write)
; 	bit 7-1	= Holds the first seven address bits of the I2C slave device
; 	bit 0	= I2C 1:read/0:write bit

; #9C: Command/Status Register (write)
;	bit 7-2	= Reserved
;	bit 1-0	= 00: IDLE; 01: START; 10: nSTART; 11: STOP
; #9C: Command/Status Register (read)
;	bit 7-2	= Reserved
;	bit 1 	= 1:ERROR 	(I2C transaction error)
;	bit 0 	= 1:BUSY 	(I2C bus busy)

; HL= адрес буфера
; B = длина (0=256 байт)
; C = адрес
i2c_get	
	ld a,%11111101	; start
	out (#9c),a
	ld a,%11010000	; slave address w
	out (#8c),a
	call i2c_ack
	ld a,%11111110	; nstart
	out (#9c),a
	ld a,c		; word address
	out (#8c),a
	call i2c_ack
	ld a,%11111101	; start
	out (#9c),a
	ld a,%11010001	; slave address r
	out (#8c),a
	call i2c_ack
	ld a,%11111100	; idle
	out (#9c),a
i2c_get2
	out (#8c),a
	call i2c_ack
	in a,(#8c)
	ld (hl),a
	inc hl
	ld a,b
	cp 2
	jr nz,i2c_get1
	ld a,%11111111	; stop
	out (#9c),a
i2c_get1
	djnz i2c_get2
	ret

; wait ack
i2c_ack
	in a,(#9c)
	rrca		; ack?
	jr c,i2c_ack
	rrca		; error?
	ret

; -----------------------------------------------------------------------------	
; SPI -- V0.2.1	(20130901)
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
	
;==============================================================================
; CMOS Setup Utility	
	

;clear screen
cls
	ld hl,#4000
	ld de,#4001
	ld bc,#1800
	ld (hl),l
	ldir
	ld b,#03
	ld (hl),#07
	ldir
	ret

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

;print character i: a - ansi char
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
	ld l,a
	ld a,h
        and 24
	or 64
	ld d,a
	;scr adr -> attr adr
	;in: hl - screen adress
	;out:hl - attr adress
	rrca
	rrca
	rrca
	and 3
	or #58
	ld h,a
	ld a,(pr_param+2)	; цвет
	ld (hl),a		; печать атрибута символа
	ld e,l
	ld l,c			; l= символ
	ld h,0
	add hl,hl
	add hl,hl
	add hl,hl
	ld bc,font
	add hl,bc
	ld b,8
pchar3	ld a,(hl)
	ld (de),a
	inc d
	inc hl
	djnz pchar3
	ld a,(pr_param)		; x
	inc a
	cp 32
	jr nz,pchar1
pchar2
	ld a,(pr_param+1)	; y
	inc a
	cp 24
	jr nz,pchar0
	;сдвиг вверх на один символ
	ld de,#4000		;откуда
	ld hl,#4020		;куда
	ld b,#17		;кол-во строк
pchar4
	push bc
	call scroll
	call ll693e		;служебные процедуры (на стр. вверх)
;	call ll6949		;служебные процедуры (на стр. вниз)
	pop bc
	djnz pchar4
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



;scroll screen
;	push bc
;	call scroll		;вызов проц.сдвига
;	call ll693e		;служебные процедуры (на стр. вверх)
;	call ll6949		;служебные процедуры (на стр. вниз)
;	pop bc
;	djnz main
;	ret
scroll	
	push hl
	push de
	ld a,d
	rrca
	rrca
	rrca
	and #03
	or #58
	ld d,a
	ld a,h
	rrca
	rrca
	rrca
	and #03
	or #58
	ld h,a
	dup 32
	ldi
	edup
	pop de
	pop hl
	ld bc,#00f8
	jp loop2
loop1
	inc h
	inc d
loop2	
	dup 31
	ldi
	edup
	ld a,(hl)
	ld (de),a
	inc h
	inc d
	dup 31
	ldd
	edup
	ld a,(hl)
	ld (de),a
	jp pe,loop1
	ret
	;служебные процедуры
ll692a
	ld a,l
	sub #20
	ld l,a
	ret nc
	ld a,h
	sub #08
	ld h,a
	ret
ll6934
	ld a,e
	sub #20
	ld e,a
	ret nc
	ld a,d
	sub #08
	ld d,a
	ret
ll693e	
	inc h
	ld a,l
	sub #e0
	ld l,a
	ret nc
	ld a,h
	sub #08
	ld h,a
	ret
ll6949 	
	inc d
	ld a,e
	sub #e0
	ld e,a
	ret nc
	ld a,d
	sub #08
	ld d,a
	ret
	
;Ожидание клавиши
anykey
	xor a			;все биты сброшены
	in a,(#fe)		;опрашиваем все полуряды
	cpl			;почти эквивалентно комбинации:
	and 31 			;AND 31:CP 31,  но короче
	jr z,anykey 		;пока не нажмут ANY KEY
	ret
	
	
;управляющие коды
;13 (0x0d)		- след строка
;17 (0x11),color	- изменить цвет последующих символов
;23 (0x17),x,y		- изменить позицию на координаты x,y
;24 (0x18),x		- изменить позицию по x
;25 (0x19),y		- изменить позицию по y
;0			- конец строки
	
	
str1	
;          "                                "
	db 23,0,0,17,47,"ReVerSE-U16 By MVV, 2014",13,13,13
	db 17,7,"FPGA SoftCore - Speccy v0.9.2",13
	db "(build 20140809)",13,13
	db "Copying data from FLASH...",0
str3
	db 17,4," done",17,7,13,0
str4
	db 13,"Initialization MC146818...",0
str0
	db 13,13,23,0,23,17,7,"Press ENTER to Resume",0

font	
	INCBIN "font.bin"

	savebin "loader.bin",startprog, 8192