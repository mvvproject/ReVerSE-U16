                         EXTRN  _print_bios_banner      :proc      ; Print the BIOS Banner message
;;------------------------------------------------------------------------------------------------------------------------------------------
;;------------------------------------------------------------------------------------------------------------------------------------------                         
 startofrom              equ     0F800h
;;------------------------------------------------------------------------------------------------------------------------------------------
;;------------------------------------------------------------------------------------------------------------------------------------------
                        .Model  Tiny    ;; this forces it to nears on code and data
                        .8086           ;; this forces it to use 80186 and lower
_BIOSSEG                SEGMENT 'CODE'
                        assume  cs:_BIOSSEG
bootrom:                org     0000h           ;; start of ROM, get placed at 0E000h ====>0xFE000 -START PROGRAM !!!!!!!!!!!!!!!!!!!!!!!!
;------------------------------------------------------------------------------------------------------------------------------------------
;;------------------------------------------------------------------------------------------------------------------------------------------
                        org     (0F800h - startofrom)                                                   ;; ===========> 0xFE05B RUN  CODE FROM HERE!!!!
post:                   ;; xor     ax, ax          ; clear ax register
                        mov  dx, 0f102h;    ;; LED ADDR
                        mov  ax, 0010h;     ;; 1sr RED LED - ON
                        out    dx, ax             ;; send data
                        nop;
                        nop;
                        call    _print_bios_banner       ;; Print the openning banner
                        ;===========================================
                        mov  dx, 0f102h;    ;; LED ADDR
                        mov  ax, 0030h;     ;; 2nd RED LED - ON
                        out    dx, ax             ;; send data
                        hlt;                                                                                               ;; ============> HALT!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
                        
                        
                        
                        
                        
;;------------------------------------------------------------------------------------------------------------------------------------------
;; EXECUTABLE ROM CODE HERE !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
;;------------------------------------------------------------------------------------------------------------------------------------------
                        org     (0ff00h - startofrom)  ; =============================> COPY ROM to RAN !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
;BIOS_COPYRIGHT_STRING equ     "Zet Bios 1.1 (C) 2010 Zeus Gomez Marmolejo, Donna Polehn"
;MSG1:                   db      BIOS_COPYRIGHT_STRING
;                       db      0
START_ROM: 
                        mov  dx, 0f102h;    ;; LED ADDR
                        mov  ax, 0001h;     ;; 1sr RED LED - ON
                        out    dx, ax             ;; send data                                                                   ;;==============> 1st RED LED ON!!!!!!!!!!!
                       ; jmp     far ptr LED2 ;
;;--------------------------------------------------------------------------
;; First we have to prepare DRAM for use:
;;--------------------------------------------------------------------------
SDRAM_POST:             xor     ax, ax          ; Clear AX register
                        cli                     ; Disable interupt for startup
                        mov     dx, 0f200h      ; CSR_HPDMC_SYSTEM = HPDMC_SYSTEM_BYPASS|HPDMC_SYSTEM_RESET|HPDMC_SYSTEM_CKE;
                        mov     ax, 7           ; Bring CKE high
                        out     dx, ax          ; Initialize the SDRAM controller
                        mov     dx, 0f202h      ; Precharge All
                        
                        mov     ax, 0400bh      ; CSR_HPDMC_BYPASS = 0x400B;
                        out     dx, ax          ; Output the word of data to the SDRAM Controller
                        mov     ax, 0000dh      ; CSR_HPDMC_BYPASS = 0xD;
                        out     dx, ax          ; Auto refresh
                        
                        mov     ax, 0000dh      ; CSR_HPDMC_BYPASS = 0xD;
                        out     dx, ax          ; Auto refresh
                        mov     ax, 023fh       ; CSR_HPDMC_BYPASS = 0x23F;
                        out     dx, ax          ; Load Mode Register, Enable DLL
                        mov     cx, 50          ; Wait about 200 cycles
a_delay:         loop    a_delay         ; Loop until 50 goes to zero
                        mov     dx, 0f200h      ; CSR_HPDMC_SYSTEM = HPDMC_SYSTEM_CKE;
                        mov     ax, 4           ; Leave Bypass mode and bring up hardware controller
                        out     dx, ax          ; Output the word of data to the SDRAM Controller
                       ; jmp     far ptr LED3 ;
 ;==================================================================================================================================
LED2:             mov  dx, 0f102h;    ;; LED ADDR
                        mov  ax, 0003h;     ;; 2- RED LED - ON
                        out    dx, ax             ;; send data                                                          ;;==============> 2nd RED LED ON!!!!!!!!!!!
 ;;                     hlt;                                  
                        ;========================================================================================================================
 STACKP:      mov     ax, 0E3FEh      ; We are done with the controller, we can use the memory now  // clname DATA segment _DATA    segaddr=0xf000 offset=0xe400 &
                        mov     sp, ax                ; set the stack pointer to fffe (top)
                        mov     ax, 00000h   ;    // 0f000h 
                        mov     ds, ax           ; set data segment to  0xF0000
                        mov     ss, ax           ; set stack segment to 0xF0000
 ;==================================================================================================================================
 ;==================================================================================================================================
LED3:             mov  dx, 0f102h;    ;; LED ADDR
                        mov  ax, 0007h;     ;; 3- RED LED - ON
                        out    dx, ax             ;; send data                                                          ;;==============> 2nd RED LED ON!!!!!!!!!!!
 ;;                     hlt;
 ;;==========================================          
;;============================================
;;--------------------------------------------------------------------------
;; Copy Shadow BIOS from Flash into SDRAM after SDRAM has been initialized
;;---------------------------------------------------------------------------
FLASH_PORT              equ     0x0238                   ;; Flash RAM port            === FIX do noit change
ROMBIOSSEGMENT          equ     0xF000                   ;; ROM BIOS Segment   === FIX do noit change
ROMBIOSLENGTH           equ     0xDFF                    ;; Copy (4096 Words - 200 W stack) up to this ROM in Words
;;--------------------------------------------------------------------------
shadowcopy: mov     ax, ROMBIOSSEGMENT      ;; Load with the segment of the extra bios rom area
                        mov     es, ax                   ; BIOS area segment
                        mov     bp, 0E400h         ;  Bios(RAM for load) starts at offset address 0xE400 ==== !!!!!!!!!!!!
                        mov     cx, ROMBIOSLENGTH       ;; Bios is 64K long - Showdow rom len
                       ;--------------------- Load MSB  FLASH address ---------------------------
                        mov     dx, FLASH_PORT+2        ;; Set DX reg to FLASH IO port
                        mov     ax, 0x0000       ;; Load MSB  FLASH address
                        out       dx, ax                ;; Save MSB  FLASH address 
                         ;---------------------------------------------------------------------------------------
                        mov     bx, 0x200         ;; Bios starts at offset address in FLASH !!!!!!!!!!!!!!!!!!!!!!! 0x0200 x 2 !!!!!!!!!!!!!!!
                        call      biosloop           ;; Call bios IO loop (STACK is USED       !!!!!!!!!)
 ;;==========================================
 LED4:            mov  dx, 0f102h;    ;; LED ADDR
                        mov  ax, 000Fh;     ;; 4 RED LED - ON
                        out    dx, ax             ;; send data                                                                   ;;==============> 4 RED LED ON!!!!!!!!!!!                      
 ;;==========================================                       

                        jmp     far ptr post            ;; Continue with regular POST
;;--------------------------------------------------------------------------
biosloop:        mov     ax, bx                  ;; Put bx into ax // START - 0x0
                        mov     dx, FLASH_PORT          ;; Set DX reg to FLASH IO port
                        out     dx, ax                  ;; Save LSB address word
                        mov     dx, FLASH_PORT          ;; Set DX reg to FLASH IO port
                        in      ax, dx                  ;; Get input word into ax register    READ WORD FROM FLASH_PORT <===================
                        mov     word ptr es:[bp], ax    ;; Save that word to next place in RAM ===================> write to FE000 (first addr) 
                        inc     bp                      ;; Increment to next SRAM  address location 
                        inc     bp                      ;; Increment to next SRAM  address location - WORD
                        inc     bx                      ;; Increment to next FLASH address location ===========> READ WORDs!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
                        loop    biosloop                ;; Loop until bios is loaded up
                        ret                             ;; Return
;;--------------------------------------------------------------------------
;;------------------------------------------------------------------------------------------------------------------------------------------
;;------------------------------------------------------------------------------------------------------------------------------------------
;; MAIN BIOS Entry Point:  
;; on Reset - Processor starts at this location. This is the first instruction
                        org     (0fff0h - startofrom)        ;; Power-up Entry Point
                        jmp     far ptr START_ROM      ;; Boot up bios

                        org     (0fff5h - startofrom)   ;; ASCII Date ROM was built - 8 characters in MM/DD/YY
BIOS_BUILD_DATE         equ     "09/09/10\n"
MSG2:            db      BIOS_BUILD_DATE

                        org     (0fffeh -startofrom)    ;; Put the SYS_MODEL_ID
SYS_MODEL_ID               equ     0xFC
                        db      SYS_MODEL_ID            ;; here
                        db      0

_BIOSSEG                ends                    ;; End of code segment
                        end             bootrom ;; End of this program
