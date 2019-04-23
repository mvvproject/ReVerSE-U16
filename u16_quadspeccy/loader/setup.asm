 		DEVICE	ZXSPECTRUM48
; -----------------------------------------------------------------[24.06.2018]
; ReVerSE-U16 Setup By MVV <mvvproject@gmail.com>
; -----------------------------------------------------------------------------

system_port	equ #0001	; bit2 = (0:Loader ON, 1:Loader OFF); bit1 = (NC); bit0 = (0:M25P16, 1:ENC424J600)
mask_port	equ #0000	; Маска порта EXT_MEM_PORT по AND
ext_mem_port	equ #dffd	; Порт памяти
pr_param	equ #7f00
cursor_pos	equ #7f05
buffer		equ #8000
time_pos_y	equ #08
time_pos_yx	equ #0800
setup_start	equ #5b00	; Setup

	org setup_start
startprog:
	di
	ld sp,#7ffe

	xor a		;bit2 = (0:Loader ON, 1:Loader OFF); bit1 = (NC); bit0 = (0:M25P16, 1:ENC424J600)
	ld bc,system_port
	out (c),a
	out (#fe),a
	call cls	; очистка экрана
	ld hl,str1
	call print_str

; ID read
	ld hl,str8
	call print_str

	call spi_start
	ld d,%10101011	; command ID read
	call spi_w
	call spi_r
	call spi_r
	call spi_r
	call spi_r
	call print_hex
	call spi_end

	ld hl,str5
	call print_str

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

	ld d,#0b	; address = #0b2000
	call spi_w
	ld d,#20
	call spi_w
	ld d,#00
	call spi_w
		
; 	ld hl,#5b00	; Setup
; spi_loader1
; 	call spi_r
; 	ld (hl),a
; 	inc hl
; 	ld a,l
; 	or h
; 	jr nz,spi_loader1
	
	ld bc,mask_port
	ld a,%11111111	; маска порта по and
	out (c),a
	ld a,%00100100
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

;----------------------------------------------
RTC_INIT
	xor a
	out (#fe),a

	ld hl,str3		;завершено
	call print_str
	
	ld hl,str4
	call print_str
	call rtc_read

	ld hl,str_absent	; отсутствует устройство
	jr z,spi_loader4
	ld hl,str3		; завершено
spi_loader4
	call print_str

	call rtc_data
	call ddc_read

	ld hl,str7
	call print_str
	call mac_read

	ld hl,str0	;any key
	call print_str

	call anykey
	call mc14818a_init	;инициализация MC14818A

	ld a,%00000100	; bit2 = (0:Loader ON, 1:Loader OFF); bit1 = (NC); bit0 = (0:M25P16, 1:ENC424J600)
	ld bc,system_port
	out (c),a

	ld sp,#ffff
	jp #0000	; запуск системы


; Ожидание клавиши
anykey1
	ld hl,str0
anykey5
	call print_str
anykey3
	ld bc,#0607
anykey2
	in a,(c)		; чтение сканкода клавиатуры
	or a
	djnz anykey2
	or a
	jr nz,anykey3
anykey
	ld hl,time_pos_yx	; координаты вывода даты и времени
	ld (pr_param),hl
	call rtc_read		; чтение даты и времени
	call rtc_data		; вывод
	ld bc,#0607
anykey4
	in a,(c)		; чтение сканкода клавиатуры
	cp #16			; <S> ?
	jp z,rtc_setup
	cp #28			; <ENTER> ?
	ret z
	djnz anykey4
	jr anykey

; -----------------------------------------------------------------------------
; ENC424J600 MAC read
; -----------------------------------------------------------------------------
mac_read
	ld a,%00000001
	ld bc,system_port
	out (c),a

	call spi_start
	ld d,#20		; RCRU
	call spi_w
	ld d,#60		; Address (#60 = MAAR3L .. #65 = MAAR1H)
	call spi_w
	ld b,#06
	ld hl,buffer
mac_read1
	call spi_r
	ld (hl),a
	inc hl
	djnz mac_read1
	call spi_end

mac_read3
	ld a,(buffer+4)
	call print_hex
	ld a,"-"
	call print_char
	ld a,(buffer+5)
	call print_hex
	ld a,"-"
	call print_char
	ld a,(buffer+2)
	call print_hex
	ld a,"-"
	call print_char
	ld a,(buffer+3)
	call print_hex
	ld a,"-"
	call print_char
	ld a,(buffer+0)
	call print_hex
	ld a,"-"
	call print_char
	ld a,(buffer+1)
	call print_hex
	ret	

; -----------------------------------------------------------------------------
; I2C DS1338 read
; -----------------------------------------------------------------------------
rtc_read
	ld bc,#3f00
	ld hl,buffer
	ld d,%11010001		; Device Address RTC DS1338 + read
	call i2c

	ld b,#3f
; проверка
; z=error, nz=ok
check_buffer
	ld hl,buffer
check_buffer1
	ld a,(hl)
	inc a
	ret nz
	ld (hl),a
	inc hl
	djnz check_buffer1
	ret
	
; -----------------------------------------------------------------------------
; инициализация MC14818A
; -----------------------------------------------------------------------------
mc14818a_init
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
	ld a,(buffer)		; 00h seconds
	and %01111111		; удаляем ch бит
	ld b,#bf
	out (c),a
; minutes		
	ld a,#02
	ld b,#df
	out (c),a
	ld a,(buffer+1)		; 01h minutes
	ld b,#bf
	out (c),a
; hours		
	ld a,#04
	ld b,#df
	out (c),a
	ld a,(buffer+2)		; 02h hours
	and #3f
	ld b,#bf
	out (c),a
; day of the week		
	ld a,#06
	ld b,#df
	out (c),a
	ld a,(buffer+3)		; 03h day
	ld b,#bf
	out (c),a
; date of the month
	ld a,#07
	ld b,#df
	out (c),a
	ld a,(buffer+4)		; 04h date
	ld b,#bf
	out (c),a
; month
	ld a,#08
	ld b,#df
	out (c),a
	ld a,(buffer+5)		; 05h month
	ld b,#bf
	out (c),a
; year
	ld a,#09
	ld b,#df
	out (c),a
	ld a,(buffer+6)
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
	ret

; -----------------------------------------------------------------------------
; Вывод даты и времени
; -----------------------------------------------------------------------------
rtc_data
	; вывод даты
	ld a,(buffer+3)
	dec a
	and %00000111
	add a,a
	add a,a
	ld hl,day		; день недели
	ld e,a
	ld d,0
	add hl,de
	call print_str
	ld a,","
	call print_char
	ld a,(buffer+4)		; число
	call print_hex
	ld a,"."
	call print_char
	ld a,(buffer+5)		; месяц
	call print_hex
	ld a,"."
	call print_char
	ld a,#20
	call print_hex
	ld a,(buffer+6)		; год
	call print_hex
	ld a," "
	call print_char
	; вывод времени
	ld a,(buffer+2)		; час
	and %00111111
	call print_hex
	ld a,":"
	call print_char
	ld a,(buffer+1)		; минуты
	call print_hex
	ld a,":"
	call print_char
	ld a,(buffer)		; секунды
	and %01111111
	jp print_hex

; -----------------------------------------------------------------------------
; I2C DDC loader
; -----------------------------------------------------------------------------
ddc_read
	ld hl,str2
	call print_str
	ld bc,#0000		; B = длина (0=256 байт), C = адрес
	ld hl,buffer		; адрес буфера = #8000
	ld d,#a1		; Device Address = 0xA0 DDC + read
	call i2c

	ld b,#00
	call check_buffer
	
	ld hl,str_absent	; отсутствует устройство
	jr z,ddc_read3
	ld hl,str3		; завершено
ddc_read3
	call print_str

	ld hl,buffer+#48	; Detailed Timing Description # 2 or Monitor Descriptor
ddc_read1	
	ld bc,#0011		
	ld a,(hl)
	inc hl
	or (hl)
	jr z,ddc_descriptor	; Flag = 0000h when block used as descriptor
ddc_read2
	add hl,bc		; следующий дескриптор
	bit 0,h
	ret nz			; выход, если поиск вне буфера #8000-#80FF
	jr ddc_read1

ddc_descriptor
	inc hl
	inc hl
	ld c,#0f
	ld a,(hl)		; Data Type Tag
	cp #fc			; FCh: Monitor name?
	jr nz,ddc_read2
	inc hl
	inc hl
	ld b,12
ddc_print1	
	ld a,(hl)
	cp #0a
	ret z
	call print_char
	inc hl
	djnz ddc_print1
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
; D = Device Address (bit0: 0=WR, 1=RD)

i2c	
	ld a,%11111101		; start
	out (#9c),a
	ld a,d			; slave address w
	and %11111110
	out (#8c),a
	call i2c_ack
	bit 0,d
	jr nz,i2c_4		; четение
	ld a,%11111100		; idle
	out (#9c),a
	ld a,c			; word address
	out (#8c),a
	call i2c_ack
	jr i2c_2
i2c_4
	ld a,%11111110		; nstart
	out (#9c),a
	ld a,c			; word address
	out (#8c),a
	call i2c_ack
	ld a,%11111101		; start
	out (#9c),a
	ld a,d			; slave address r/w
	out (#8c),a
	call i2c_ack
	ld a,%11111100		; idle
	out (#9c),a
i2c_2
	ld a,b
	dec a
	jr nz,i2c_1
	ld a,%11111111		; stop
	out (#9c),a
i2c_1
	ld a,(hl)
	out (#8c),a
	call i2c_ack
	bit 0,d
	jr z,i2c_3		; запись? да
	in a,(#8c)
	ld (hl),a
i2c_3	
	inc hl
	djnz i2c_2
	ret

; wait ack
i2c_ack
	in a,(#9c)
	rrca			; ack?
	jr c,i2c_ack
	rrca			; error?
	ret

; -----------------------------------------------------------------------------	
; clear screen
; -----------------------------------------------------------------------------	
cls
	xor a
	out (#fe),a
	ld hl,#5aff
cls1
	ld (hl),a
	or (hl)
	dec hl
	jr z,cls1
	ret

; -----------------------------------------------------------------------------	
; print string i: hl - pointer to string zero-terminated
; -----------------------------------------------------------------------------	
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
	ld (pr_param+2),a	; color
	inc hl
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
print_pos_x
	inc hl
	ld a,(hl)
	ld (pr_param),a		; x-coord
	inc hl
	jr print_str
print_pos_y
	inc hl
	ld a,(hl)
	ld (pr_param+1),a	; y-coord
	inc hl
	jr print_str

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
	jr c,pchar1
pchar2
	ld a,(pr_param+1)	; y
	inc a
	cp 24
	jr c,pchar0
	;сдвиг вверх на один символ
	call ssrl_up
	call asrl_up
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
; print hexadecimal i: a - 8 bit number
; -----------------------------------------------------------------------------	
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

; print decimal i: l,d,e - 24 bit number , e - low byte
; print_dec
; 	ld ix,dectb_w
; 	ld b,8
; 	ld h,0
; lp_pdw1
; 	ld c,"0"-1
; lp_pdw2
; 	inc c
; 	ld a,e
; 	sub (ix+0)
; 	ld e,a
; 	ld a,d
; 	sbc (ix+1)
; 	ld d,a
; 	ld a,l
; 	sbc (ix+2)
; 	ld l,a
; 	jr nc,lp_pdw2
; 	ld a,e
; 	add (ix+0)
; 	ld e,a
; 	ld a,d
; 	adc (ix+1)
; 	ld d,a
; 	ld a,l
; 	adc (ix+2)
; 	ld l,a
; 	inc ix
; 	inc ix
; 	inc ix
; 	ld a,h
; 	or a
; 	jr nz,prd3
; 	ld a,c
; 	cp "0"
; 	ld a," "
; 	jr z,prd4
; prd3
; 	ld a,c
; 	ld h,1
; prd4
; 	call print_char
; 	djnz lp_pdw1
; 	ret
; dectb_w
; 	db #80,#96,#98		; 10000000 decimal
; 	db #40,#42,#0f		; 1000000
; 	db #a0,#86,#01		; 100000
; 	db #10,#27,0		; 10000
; 	db #e8,#03,0		; 1000
; 	db 100,0,0		; 100
; 	db 10,0,0		; 10
; 	db 1,0,0		; 1

; -----------------------------------------------------------------------------	
; Сдвиг изображения вверх на один символ
; -----------------------------------------------------------------------------	
ssrl_up
        ld de,#4000     	; начало экранной области
lp_ssu1 
	push de           	; сохраняем адрес линии на стеке
        ld bc,#0020     	; в линии - 32 байта
        ld a,e          	; в регистре de находится адрес
        add a,c          	; верхней линии. в регистре
        ld l,a          	; hl необходимо получить адрес
        ld a,d          	; линии, лежащей ниже с шагом 8.
        jr nc,go_ssup   	; для этого к регистру e прибав-
        add a,#08        	; ляем 32 и заносим в l. если про-
go_ssup 
	ld h,a         		; изошло переполнение, то h=d+8
        ldir                 	; перенос одной линии (32 байта)
        pop de           	; восстанавливаем адрес начала линии
        ld a,h          	; проверяем: а не пора ли нам закру-
        cp #58          	; гляться? (перенесли все 23 ряда)
        jr nc,lp_ssu2   	; если да, то переход на очистку
        inc d            	; ---------------------------------
        ld a,d          	; down_de
        and #07          	; стандартная последовательность
        jr nz,lp_ssu1   	; команд для перехода на линию
        ld a,e         		; вниз в экранной области
        add a,#20        	; (для регистра de)
        ld e,a          	;
        jr c,lp_ssu1    	; на входе:  de - адрес линии
        ld a,d          	; на выходе: de - адрес линии ниже
        sub #08          	; используется аккумулятор
        ld d,a          	;
        jr lp_ssu1      	; ---------------------------------
lp_ssu2 
	xor a            	; очистка аккумулятора
lp_ssu3 
	ld (de),a       	; и с его помощью -
        inc e            	; очистка одной линии изображения
        jr nz,lp_ssu3   	; всего: 32 байта
        ld e,#e0        	; переход к следующей
        inc d            	; (нижней) линии изображения
        bit 3,d          	; заполнили весь последний ряд?
        jr z,lp_ssu2    	; если нет, то продолжаем заполнять
        ret                  	; выход из процедуры	

; -----------------------------------------------------------------------------	
; Сдвиг атрибутов вверх
; -----------------------------------------------------------------------------	
asrl_up
        ld hl,#5820     	; адрес второй линии атрибутов
        ld de,#5800     	; адрес первой линии атрибутов
        ld bc,#02e0     	; перемещать: 23 линии по 32 байта
        ldir                 	; сдвигаем 23 нижние линии вверх
        xor a   		; цвет для заполнения нижней линии
lp_asup 
	ld (de),a       	; устанавливаем новый атрибут
        inc e            	; если заполнили всю последнюю линию
        jr nz,lp_asup   	; (e=0), то прерываем цикл
        ret                  	; выход из процедуры

; -----------------------------------------------------------------------------	
; Расчет адреса атрибута
; -----------------------------------------------------------------------------
; e = y(0-23)		hl = адрес
; d = x(0-31)
attr_addr
	ld a,e
        rrca
        rrca
        rrca
        ld l,a
        and 31
        or 88
        ld h,a
        ld a,l
        and 252
        or d
        ld l,a
	ret

; -----------------------------------------------------------------------------	
; RTC Setup
; -----------------------------------------------------------------------------
; a = позиция		ix = адрес
get_cursor
	ld de,cursor_pos_data
	ld l,a
	ld h,0
	add hl,hl
	add hl,hl
	add hl,hl
	add hl,de
	push hl
	pop ix
	ret

; -----------------------------------------------------------------------------
; c = цвет
; a = позиция
print_cursor
	ld c,%01001111		; цвет курсора
print_cursor1
	call get_cursor
	ld d,(hl)		; координата х
	inc hl
	ld b,(hl)		; ширина курсора
	ld e,time_pos_y
	call attr_addr
print_cursor2	
	ld (hl),c
	inc hl
	djnz print_cursor2
	ret

; -----------------------------------------------------------------------------
rtc_setup
	ld hl,str6
	call print_str
	ld a,(buffer)
	and %01111111
	ld (buffer),a
	ld a,(buffer+2)
	and %00111111
	ld (buffer+2),a
	xor a
cursor1
	ld (cursor_pos),a	; курсор в начало
cursor2
	call print_cursor	; установить курсор
key_press3
	ld bc,#0607
	xor a
key_press2
	in l,(c)
	or l
	djnz key_press2
	or a
	jr nz,key_press3
key_press
	ld bc,#0607
key_press1
	in a,(c)		; чтение сканкода клавиатуры
	cp #28			; <ENTER> ?
	jr z,key_enter
	cp #52			; <UP> ?
	jr z,key_up
	cp #51			; <DOWN> ?
	jr z,key_down
	cp #50			; <LEFT> ?
	jr z,key_left
	cp #4f			; <RIGHT> ?
	jr z,key_right
	ld hl,str9
	cp #29			; <ESC>?
	jp z,anykey5
	djnz key_press1
	jr key_press
key_left
	ld a,(cursor_pos)
	or a			; первая позиция?
	jr z,key_press		; да, оставить без изменений
	ld c,%00000111
	call print_cursor1	; убрать курсор
	ld a,(cursor_pos)
	dec a
	jr cursor1

key_right
	ld a,(cursor_pos)
	cp 6			; последняя позиция?
	jr nc,key_press		; да, оставить без изменений
	ld c,%00000111
	call print_cursor1	; убрать курсор
	ld a,(cursor_pos)
	inc a
	jr cursor1

key_up
	ld d,(ix+4)
	ld e,(ix+5)
	ld a,(de)
	cp (ix+3)
	jr z,key_up2		; = max?
	add a,1			; арифметическое сложение
key_up1
	daa
	ld (de),a
key_up2
	ld hl,time_pos_yx	; координаты вывода даты и времени
	ld (pr_param),hl
	call rtc_data		; вывод
	ld a,(cursor_pos)
	jr cursor2

key_down
	ld d,(ix+4)
	ld e,(ix+5)
	ld a,(de)
	cp (ix+2)
	jr z,key_up2		; = min?
	sub 1			; арифметическое вычитание
	jr key_up1

key_enter
	ld hl,buffer
	set 7,(hl)
	ld hl,buffer
	ld bc,#0700
	ld d,%11010000		; Device Address RTC DS1338 + write
	call i2c

	ld hl,buffer
	res 7,(hl)
	ld bc,#0100
	ld d,%11010000		; Device Address RTC DS1338 + write
	call i2c
	ld hl,str9
	jp anykey5

/*DS_CH0_ADDRESS	equ #0050
DS_CH0_LENGTH	equ #0450
DS_CH0_TIMER	equ #0850
DS_CH0_VOLUME	equ #0A50
DS_CH_MIXING	equ #8050
DS_CH_LOOP	equ #8150
DS_CH_ENABLE	equ #8250

;Опрос наличия DMA-SOUND
Test		xor a			;запретить работу каналов 0-7
		ld bc,DS_CH_ENABLE	;порт DMASOUND_EN_CH
		out (c),a		;запись в порт
		in a,(c)		;чтение
		or a			;0?
		jr nz,Player		;DMA-SOUND отсутствует
noDMA		
		ret

;Проигрывание семпла
ch0_rate	equ 16			;частота выборки 16кГц
ch0_adr15to0	equ #0000		;линейный адрес, т.е.
ch0_adr23to16	equ #00			;0x000000-0x003FFF=стр.0 и т.д.
ch0_len15to0	equ #2000		;длина семпла 8кБ, т.е.
ch0_len23to16	equ #00			;0x002000
ch0_volume	equ #3F			;максимальная громкость
channel_enable	equ %00000001		;разрешаем канал 0

Player		ld a,ch0_adr23to16
		ld hl,ch0_adr15to0
		ld bc,DS_CH0_ADDRESS
		call Port_out
		ld a,ch0_len23to16
		ld hl,ch0_len15to0
		ld bc,DS_CH0_LENGTH
		call Port_out
		ld a,ch0_volume
		ld hl,3500/ch0_rate
		ld bc,DS_CH0_TIMER
		call Port_out
		ld a,channel_enable
		ld hl,#0101		;зацикливаем, будет слышан и слева
		ld bc,DS_CH0_TIMER
Port_out
		out (c),l
		inc b
		out (c),h
		inc b
		out (c),a
		ret*/

;управляющие коды
;13 (0x0d)		- след строка
;17 (0x11),color	- изменить цвет последующих символов
;23 (0x17),x,y		- изменить позицию на координаты x,y
;24 (0x18),x		- изменить позицию по x
;25 (0x19),y		- изменить позицию по y
;0			- конец строки
	
str1	
;          "                                "
	db 23,0,0,17,#4f,"ReVerSE-U16                     ",17,7
	db 13,"FPGA SoftCore - Quad Speccy"
	db 13,"(build 20180624) By MVV",0
str5	
	db "Copying data from FLASH...",0
str8
	db 13,13,"ASP configuration device ID 0x",0	; EPCS1	0x10 (1 Mb), EPCS4 0x12 (4 Mb), EPCS16 0x14 (16 Mb), EPCS64 0x16 (64 Mb)
str3
	db 17,4," Done",17,7,13,0
str4
	db "RTC data read...",0
str2
	db 13,"DDC data read...",0
str6
	db 23,0,22,"<>:Select Item   ENTER:Save&Exit"
	db "^",127,  ":Change Values   ESC:Abort   ",0
str_absent
	db 17,2," Error",17,7,13,0
str7
	db 13,"MAC address ",0
str0
;	db 13,"Quad Z80CPU@3.5MHz, Memory 16MB"
	db 13,13,"F1..F4: Window Select",13
	db "    F5: NMI Button",13
	db "    F6: DivMMC 512KB/ZController"
	db "    F7: SounDrive On/Off",13
	db "    F9: Sound in Window/All",13
	db "   F12: Reset",13
	db "PrtScr: Hard Reset",13
	db " Pause: Hard Reset All",13
str9
	db 23,0,22,"Press ENTER to continue...      "
	db	   "S: RTC Setup  Win: Full Window",0
; Fri,05.09.2014 23:53:29
; 0-7 1-31 1-12 0-99 0-23 0-59 0-59
cursor_pos_data
	db 0,3,#01,#07,#80,#03,#00,#00		; х, ширина, min, max, адрес переменной
	db 4,2,#01,#31,#80,#04,#00,#00
	db 7,2,#01,#12,#80,#05,#00,#00
	db 10,4,#00,#99,#80,#06,#00,#00
	db 15,2,#00,#23,#80,#02,#00,#00
	db 18,2,#00,#59,#80,#01,#00,#00
	db 21,2,#00,#59,#80,#00,#00,#00
day
	db "Sun",0,"Mon",0,"Tue",0,"Wed",0,"Thu",0,"Fri",0,"Sat",0,"Err",0
font	
	INCBIN "font.bin"

	display "Size of ROM is: ",/a, $-setup_start
	
	savebin "setup.bin",startprog, 8192