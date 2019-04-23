 		DEVICE	ZXSPECTRUM48
; -----------------------------------------------------------------------------
; LOADER(FAT32) 
; -----------------------------------------------------------------------------
;-----CONST-----
TOTAL_PAGE     	EQU   33         ; 31(512kB ROM) + 2 (32kB) GS ROM
Start      	EQU   #0000      ; BANK0 (ROM)
;================== LOADER EXEC CODE ==========================================
		ORG Start    ; Exec code - Bank0:
		JP  StartProg
		;- LOADER ID -------------------------
		;DB "LOADER(FAT32) V1.0/2014.08.14 | "
		;DB "LOADED FILES:"
		;- Name of ROMs files-----------------
FES1     	DB #10 ;flag (#00 - file, #10 - dir)
		DB "_ROM"	          ;DIR name
		DB 0
		;------
FES2     	DB #00 ;flag (#00 - file, #10 - dir)
		DB "ZXEVO.ROM"    ;file name //"TEST128.ROM"
		DB 0
		;-------------------------------------
		;ORG #F0
		;DB "Start Prog 0x100"
;=======================================================================
		;ORG #100         ; Reserve 512byte  
StartProg
		DI               ; DISABLE INT                   (PAGE2)
		LD SP,PWA        ; STACK_ADDR = BUFZZ+#4000;    0xC000-x 
		LD BC,SYC,A,DEFREQ:OUT(C), A ;SET DEFREQ:%00000010-14MHz
		; перед испоьзованием STACK - преназначаем номер страницы
		;---PAGE3
		LD B,PW3/256 : IN A,(C)      ;READ PAGE3 //PW3:#13AF
		LD (PGR3),A                  ;(PGR3) <- SAVE orig PAGE3
		;---PAGE2
		LD B,PW2/256 : IN A,(C)      ;READ PAGE2 //PW2:#12AF 
		LD E,PG0: OUT (C),E          ;SET PAGE2=0xF7
		LD (PGR),A                   ;(PGR) <- SAVE orig PAGE2		
		;=======================================================
		
;=============== SD_LOADER========================================
SD_LOADER	
		;step_1	======== INIT SD CARD =======	
		LD A, #00 	;STREAM: SD_INIT, HDD
		CALL FAT_DRV
		JR NZ,ERR	;INIT - FAILED
		;step_2 ======= find DIR entry ======	
		LD HL,FES1
		LD A, #01 	;find DIR entry
		CALL FAT_DRV
		JR NZ,ERR	;dir not found
		;-----------------------------------
		LD A, #02     ;SET CURR DIR - ACTIVE
		CALL FAT_DRV
		;step_3 ======= find File entry ====
		LD HL,FES2
		LD A, #01 	;find File entry
		CALL FAT_DRV
		JR NZ,ERR	;file not  found
		;--------------------------------
		;JP RESET_LOADER
		JP FAT32_LOADER
;========================================================================================
FAT32_LOADER
		;----------- Open 1st Page = ROM ========================================
 		 LD A, #0     ;download in page #0
		 LD (block_16kB_cnt), A ; RESET block_16kB_cnt = 0
 		 ;-------------------------------
		 LD C, A	     ;page Number
		 LD DE,#0000  ;offset in PAGE: 
		 LD B, 32     ;1block-512Byte/16-8kB
		 LD A, #3     ;LOAD512(TSFAT.ASM) c
		 CALL FAT_DRV ;return CDE - Address 
;-------------------------------------------------------------------------------------		
LOAD_16kb
;-------------------------------------------------------------------------------------	
		;------------------------- II ----------------------------------------
		;----------- Open 2snd Page = ROM 
		 LD A,(block_16kB_cnt)	; загружаем ячейку счетчика страниц в A
		 INC A			; block_16kB_cnt+1  увеличиваем значение на 1 
		 LD (block_16kB_cnt), A	; сохраняем новое значение 
		 ;-----------
		 LD C, A	    ;page 
		 LD DE,#0000        ;offset in Win3: 
		 LD B,32	    ;1 block-512Byte // 32- 16kB
		 ;-load data from opened file-------
		 LD A, #3       	;LOAD512(TSFAT.ASM) 
		 CALL FAT_DRV           ; читаем вторые 16kB
		 JR NZ,RESET_LOADER	;EOF -EXIT
		 ;-----------CHECK CNT------------------------------------------
		 LD A,(block_16kB_cnt); загружаем ячейку счетчика страниц в A
		 SUB TOTAL_PAGE       ; проверяем это был последний блок или нет
		 JR NZ,LOAD_16kb      ; если да то выход, если нет то возврат на 
				      ; LOAD_16kb
		;===============================================================
		;---------------
		; JP VS_INIT
		 JP RESET_LOADER
;------------------------------------------------------------------------------		
ERR
;------------------------------------------------------------------------------
		 LD A,#02	; ERROR: BORDER -RED!!!!!!!!!!!!!!!!!!!!!!!!!!!		
		 OUT (#FE),A    ; 
		 HALT
;==============================================================================		
;------------------------------------------------------------------------------
;                VS1053 Init
;------------------------------------------------------------------------------
;VS_INIT	
;		LD A,%00000000          ; XCS=0 XDCS=0
;		OUT (#05),A
;		LD HL,TABLE
;		LD B,44
;VS_INIT1 	LD D,(HL)
;		CALL VS_RW              ; WR D ==>
;		INC HL
;		DJNZ VS_INIT1
;		LD A,%00100000          ; XCS=0 XDCS=1
;		OUT (#05),A
;==============================================================================

;----------------RESTART-------------------------------------------------------
RESET_LOADER
		;---ESTORE PAGE3
		LD BC,PW3,A,(PGR3):OUT (C),A
		;---ESTORE PAGE2
		LD BC,PW2,A,(PGR) :OUT (C),A
		;--------------------------------------------------
		LD A,%00000100	; Bit2 = 0:Loader ON, 1:Loader OFF;
		LD BC,#0001 
		OUT (C),A       ; RESET LOADER
		LD SP,#FFFF
		JP #0000	; RESTART SYSTEM 
		;// только после перехода на адрес 0x0000, LOADER OFF !!!!!!!!!		
;================================ DRIVER ======================================	
		;========TS-Labs==================================
		INCLUDE "tsfat/TSFAT.ASM" ;
;---------------BANK2----------------------
PGR3 		EQU   STRMED+1   ; 
block_16kB_cnt  EQU   STRMED+2   ; 

;------------------------------------------------------------------------------
; VS1053
;------------------------------------------------------------------------------
;VS_RW   	
;		IN A,(#05)
;		RLCA 
;		JR C,VS_RW
;		RLCA 
;		JR NC,VS_RW
;		LD A,D
;		OUT (#04), A ; WR DATA
;				
;VS_RW1  	IN A,(#05)
;		RLCA 
;		JR C,VS_RW1
;		RLCA 
;		JR NC,VS_RW1
;		IN A,(#04)
;		RET 
;
;TABLE   	DB #52,#49,#46,#46,#FF,#FF,#FF,#FF      ;REFF....
;		DB #57,#41,#56,#45,#66,#6D,#74,#20      ;WAVEfmt
;		DB #10
;		DB #00,#00,#00,#01,#00,#02,#00
;
;		DB #80,#BB,#00,#00      ;48kHz
;		DB #00,#EE,#02,#00

;		DB #04,#00
;		DB #10,#00
;		DB #64,#61,#74,#61                      ;data
;		DB #FF,#FF,#FF,#FF

		savebin "loader.bin",Start, 8192
		;savebin "loader.bin",Start, 2048    ;-2K


