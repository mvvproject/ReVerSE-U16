 		DEVICE	ZXSPECTRUM48
; -----------------------------------------------------------------[26.06.2016]
; ReVerSE-U16 Loader By MVV
; -----------------------------------------------------------------------------

system_port	equ #0001	; bit2 = (0:Loader ON, 1:Loader OFF); bit1 = (NC); bit0 = (0:M25P16, 1:ENC424J600)
setup_start	equ #5b00	; Setup 8K (#5B00-#7AFF)


	org #0000
startprog:
	di
	ld sp,#7ffe
	call cls	; Очистка экрана
	xor a		; bit2 = (0:Loader ON, 1:Loader OFF); bit1 = (NC); bit0 = (0:M25P16, 1:ENC424J600)
	ld bc,system_port
	out (c),a
	ld a,#04
	out (#fe),a
; -----------------------------------------------------------------------------
; SPI autoloader
; -----------------------------------------------------------------------------
	call spi_start
	ld d,%00000011	; command = read
	call spi_w

	ld d,#0b	; address = #0B0000
	call spi_w
	ld d,#00
	call spi_w
	ld d,#00
	call spi_w
		
	ld hl,setup_start	; Setup start address = #5B00
spi_loader1
	call spi_r
	ld (hl),a
	inc hl
	ld a,h
	cp #7b
	jr nz,spi_loader1
	call spi_end
	xor a
	out (#fe),a
	jp setup_start

; -----------------------------------------------------------------------------	
; Clear screen
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

	display "Size of ROM is: ",/a, $
	savebin "loader.bin",startprog, 128
