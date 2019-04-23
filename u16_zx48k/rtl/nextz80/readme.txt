NZ80 FPGA processor features:
1 - All documented / un-documented instructions are implemented
2 - All documented / un-documented flags are implemented
4 - All (doc / un-doc) flags are changed accordingly by all (doc /un-doc) instructions. The block instructions (LDx,  CPx,  INx,  OUTx) have only the documented effects on flags. The Bit n, (IX/IY+d) and BIT n, (HL) undocumented flags XF and YF are implemented like the BIT n, r and not actually like on the real Z80 CPU.
5 - All interrupt modes implemented: NMI, IM0, IM1, IM2
6 - R register available
7 - Fast conditional jump/call/ret takes only 1 T state if not executed
8 - Fast block instructions: LDxR - 3 T states/byte, INxR/OTxR - 2 T states/byte, CPxR - 4 T states / byte
9 - Each CPU machine cycle takes (mainly) one clock T state. This makes this processor over 4 times faster than a Z80 at the same clock frequency (some instructions are up to 10 times faster). 
10 - Works at up to 50MHZ Cyclone III EP3C10 speed grade -8)
11 - Small size
13 - tested with ZEXDOC (fully compliant) and with ZEXALL (all OK except CPx(R),  LDx(R),  BIT n, (IX/IY+d),  BIT n, (HL) - fail because of the un-documented XF and YF flags).


Instruction CPU T states:
--------------------------- 8-Bit Load Group ------------------------------
Instruction			T States
LD r, r' 			1 (2-Xh..)
LD r, n				2 (3-Xh..)	
LD r, (HL)			2
LD r, (IX+d)		4
LD r, (IY+d) 		4
LD (HL), r 			2
LD (IX+d), r 		4
LD (IY+d), r 		4
LD (HL), n 			3
LD (IX+d), n 		5
LD (IY+d), n 		5
LD A, (BC) 			2
LD A, (DE) 			2
LD A, (nn) 			4
LD (BC), A 			2
LD (DE), A 			2
LD (nn), A 			4
LD A, I 			2
LD A, R 			2
LD I, A 			2
LD R, A 			2

------------------------------ 16-Bit Load Group -------------------------------
Instruction			T States
LD dd, nn 			3 (4-SP)
LD IX, nn 			4
LD IY, nn 			4
LD HL, (nn) 		5
LD dd, (nn) 		6 (7-SP)
LD IX, (nn) 		6
LD IY, (nn) 		6
LD (nn), HL 		5
LD (nn), dd 		6 (7-SP)
LD (nn), IX 		6
LD (nn), IY 		6
LD SP, HL 			2
LD SP, IX 			3
LD SP, IY 			3
PUSH qq				3
PUSH IX 			4
PUSH IY 			4
POP qq 				3
POP IX 				4
POP IY 				4

------------------------------ Exchange, Block Transfer, Search Group ------------
Instruction			T States
EX DE, HL			1
EX AF, AF'			1
EXX 				1
EX (SP), HL 		6
EX (SP), IX 		7
EX (SP), IY 		7
LDI 				5
LDIR 				2+3*n
LDD 				5
LDDR 				2+3*n
CPI 				6
CPIR 				2+4*n
CPD 				6
CPDR				2+4*n

------------------------------ 8-Bit Arithmetic and Logical Group ------------
Instruction			T States
ADD A, r 			1 (2 - Xh...)
ADD A, n 			2
ADD A, (HL) 		2
ADD A, (IX+d) 		4
ADD A, (IY+d) 		4
ADC A, x 			see ADD
SUB x 				see ADD
SBC A, x 			see ADD
AND x				see ADD
OR x				see ADD
XOR x				see ADD
CP x				see ADD
INC r				1 (2 - xh)
INC (HL) 			3
INC (IX+d) 			5
INC (IY+d) 			5
DEC x				see INC

------------------------------ General-Purpose Arithmetic and CPU Control Group ------------
Instruction			T States
DAA					1
CPL 				1
NEG					2
CCF					1
SCF					1
NOP					1
HALT				1
DI					1
EI					1
IM x				2

------------------------------ 16-Bit Arithmetic Group ------------
Instruction			T States
ADD HL, ss			2
ADC HL, ss			3
SBC HL, ss 			3
ADD IX, ss 			3
ADD IY, ss			3
INC ss				1 (2-SP)
INC IX 				2
INC IY 				2
DEC ss				1 (2-SP)
DEC IX				2
DEC IY				2

------------------------------ Rotate and Shift Group ------------
Instruction			T States
RLCA				1
RLA					1
RRCA				1
RRA					1
RLC r				2
RLC (HL)			4
RLC (IX+d)			6
RLC (IY+d) 			6
RLC (IX+d), r		6
RLC (IY+d), r		6
RL 					see RLC
RRC					see RLC
RR 					see RLC
SLA 				see RLC
SLL 				see RLC
SRA 				see RLC
SRL 				see RLC
RLD 				6
RRD 				6

------------------------------ Bit Set, Reset and Test Group ------------
Instruction			T States
BIT b, r 			2
BIT b, (HL) 		3
BIT b, (IX+d)		5
BIT b, (IY+d)		5
SET b, r 			2
SET b, (HL) 		4
SET b, (IX+d)		6
SET b, (IY+d) 		6
SET b, (IX+d), r 	6
SET b, (IY+d), r 	6
RES 				see SET

------------------------------ Jump Group ------------
Instruction			T States
JP nn				3
JP cc, nn 			3/1
JR e				2
JR cc, e			2/1
JP (HL) 			1
JP (IX)				2
JP (IY) 			2
DJNZ e 				2

------------------------------ Call and Return Group ------------
Instruction			T States
CALL nn				5
CALL cc, nn 		5/1
RET 				3
RET cc				3/1
RETI				4
RETN				4
RST p				3

------------------------------ Input and Output Group ------------
Instruction			T States
IN A, (n)			3
IN r, (C) 			3
IN F, (C) 			3
INI					4 
INIR 				2+2*n
IND					4
INDR				2+2*n
OUT (n), A			3
OUT (C), r			3
OUT (C), 0			3
OUTI				4
OTIR				2+2*n
OUTD				4
OTDR				2+2*n


------------------------------ RESET ------------
Reset request is accepted at each CLK pos edge (only when WAIT is 0). The processor exits from RESET state at the first CLK pos edge (WAIT 0), after RESET input becomes 0.
After RESET, the IR and PC are cleared. SP and AF are left unchanged.

------------------------------ WAIT ------------
Wait input is sampled on each CLK pos edge. This way a possible design can clock the processor at a higher than supported frequency, and slow it down with wait states.
This may be the case when fast synchronous SRAM is used. The CPU may be clocked at up to 3 x FMax, SRAM read may be done on the 2nd clock (because the CPU address lines are ready faster than the data output bus and the other internal signals), synchronous write on the 3rd clock and the CPU is waiting in 1st and 2nd clocks. The 1st clock may be used for other purpose RAM read (like video refresh), avoiding dual port RAM or slowing down the CPU.
When asynchronous read RAM is used, CPU may be clocked at up to FMax clock, with no need for wait states.

------------------------------ NMI ------------
NMI is sampled at the end of each instruction and during block instructions (as documented). It takes 4 T states until 0x66 code begins execution.

------------------------------ INT ------------
INT is sampled at the end of each instruction and during block instructions (as documented). It takes 1 T states (on IM0/IM1) and 6 T states (on IM2), until interrupt code begins execution.

------------------------------ HALT ------------
When halted, the HALT signal is 1, and the CPU waits for interrupts, without executing NOPs (as the original Z80), because the memory refresh is not necessary. The memory is not accessed during HALT state, and M1 is kept inactive.
