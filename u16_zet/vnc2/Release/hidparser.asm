.DATA

.WEAK	"%eax"
.WEAK	"%ebx"
.WEAK	"%ecx"
.WEAK	"%r0"
.WEAK	"%r1"
.WEAK	"%r2"
.WEAK	"%r3"
eol	.DB	2	str@eol
str@eol	.ASCIIZ	"\r\n"
.GLOBAL	  DO_NOT_EXPORT "eol"
ItemSize	.DB	4	0, 1, 2, 4
.GLOBAL	  DO_NOT_EXPORT "ItemSize"
Str@0	.ASCIIZ	"GetReportOffset: FATAL ERROR- Report count is out of space "




.TEXT


.WEAK	"number"

.WEAK	"memset"

.WEAK	"memcpy"

.WEAK	"strcat"

.WEAK	"strlen"

.WEAK	"strcmp"

.WEAK	"strcpy"

.WEAK	"message"

.WEAK	"strncmp"

.WEAK	"strncpy"

.WEAK	"SetValue"

.WEAK	"FindObject"

ResetParser:	
.GLOBAL	 DO_NOT_EXPORT  "ResetParser"

.FUNCTION	"ResetParser"	
PUSH32	%r0
PUSH32	%r1
SP_DEC	$12
SP_STORE	%r0
INC16	%r0	$23
CPY16	%r1	(%r0)
INC16	%r1	$137
CPY16	%r1	(%r1)
SP_STORE	%ecx
INC16	%ecx	$0
CPY16	(%ecx)	%r1
CPY16	%r1	(%r0)
INC16	%r1	$130
LD16	(%r1)	$0
CPY16	%r1	(%r0)
INC16	%r1	$170
LD8	(%r1)	$0
CPY16	%r1	(%r0)
INC16	%r1	$254
LD8	(%r1)	$0
CPY16	%r1	(%r0)
INC16	%r1	$255
LD8	(%r1)	$0
CPY16	%r1	(%r0)
INC16	%r1	$253
LD8	(%r1)	$0
CPY16	%r1	(%r0)
INC16	%r1	$173
PUSH16	$80
PUSH32	$0
PUSH16	%r1
SP_DEC	$2
CALL	memset
POP16	%eax
SP_WR16	%eax	$10
SP_INC	$8
CPY16	%r1	(%r0)
INC16	%r1	$139
PUSH16	$10
PUSH32	$0
PUSH16	%r1
SP_DEC	$2
CALL	memset
POP16	%eax
SP_WR16	%eax	$12
SP_INC	$8
CPY16	%r1	(%r0)
INC16	%r1	$149
PUSH16	$10
PUSH32	$0
PUSH16	%r1
SP_DEC	$2
CALL	memset
POP16	%eax
SP_WR16	%eax	$14
SP_INC	$8
CPY16	%r1	(%r0)
INC16	%r1	$159
PUSH16	$10
PUSH32	$0
PUSH16	%r1
SP_DEC	$2
CALL	memset
POP16	%eax
SP_WR16	%eax	$16
SP_INC	$8
CPY16	%r0	(%r0)
INC16	%r0	$137
CPY16	%r0	(%r0)
PUSH16	$71
PUSH32	$0
PUSH16	%r0
SP_DEC	$2
CALL	memset
POP16	%eax
SP_WR16	%eax	$18
SP_INC	$8
SP_RD16	%r0	$0
INC16	%r0	$45
LD8	(%r0)	$1
SP_INC	$12
POP32	%r1
POP32	%r0
RTS	
.FUNC_END	"ResetParser"

ResetLocalState:	
.LOCAL	"ResetLocalState"

.FUNCTION	"ResetLocalState"	
PUSH32	%r0
PUSH32	%r1
SP_DEC	$2
SP_STORE	%r0
INC16	%r0	$13
CPY16	%r1	(%r0)
INC16	%r1	$253
LD8	(%r1)	$0
CPY16	%r0	(%r0)
INC16	%r0	$173
PUSH16	$80
PUSH32	$0
PUSH16	%r0
SP_DEC	$2
CALL	memset
POP16	%eax
SP_WR16	%eax	$8
SP_INC	$8
SP_INC	$2
POP32	%r1
POP32	%r0
RTS	
.FUNC_END	"ResetLocalState"

GetReportOffset:	
.GLOBAL	 DO_NOT_EXPORT  "GetReportOffset"

.FUNCTION	"GetReportOffset"	
PUSH32	%r0
PUSH32	%r1
PUSH32	%r2
PUSH32	%r3
SP_RD8	%ecx	$24
SP_WR8	%ecx	$24
SP_RD8	%ecx	$23
SP_WR8	%ecx	$23
LD16	%r0	$0
@IC1:	
CMP16	%r0	$10
JGE	@IC2
@IC4:	
SP_RD16	%r1	$21
INC16	%r1	$139
CPY16	%eax	%r0
AND32	%eax	$65535
CPY32	%r2	%eax
ADD16	%r1	%r2
CPY8	%r1	(%r1)
CMP8	%r1	$0
JZ	@IC2
@IC3:	
SP_RD16	%r1	$21
INC16	%r1	$139
CPY16	%eax	%r0
AND32	%eax	$65535
CPY32	%r2	%eax
ADD16	%r1	%r2
CPY8	%r1	(%r1)
SP_STORE	%eax
INC16	%eax	$23
CMP8	%r1	(%eax)
JNZ	@IC9
@IC11:	
SP_RD16	%r1	$21
INC16	%r1	$149
CPY16	%eax	%r0
AND32	%eax	$65535
CPY32	%r2	%eax
ADD16	%r1	%r2
CPY8	%r1	(%r1)
SP_STORE	%eax
INC16	%eax	$24
CMP8	%r1	(%eax)
JNZ	@IC9
@IC10:	
SP_RD16	%r1	$21
INC16	%r1	$159
CPY16	%eax	%r0
AND32	%eax	$65535
CPY32	%r2	%eax
ADD16	%r1	%r2
SP_STORE	%eax
INC16	%eax	$19
CPY16	(%eax)	%r1
POP32	%r3
POP32	%r2
POP32	%r1
POP32	%r0
RTS	
@IC9:	
INC16	%r0	$1
JUMP	@IC1
@IC2:	
CMP16	%r0	$10
JGE	@IC16
@IC17:	
SP_STORE	%r1
INC16	%r1	$21
CPY16	%r2	(%r1)
INC16	%r2	$255
CPY8	%r2	(%r2)
INC8	%r2	$1
CPY16	%r3	(%r1)
INC16	%r3	$255
CPY8	(%r3)	%r2
CPY16	%r2	(%r1)
INC16	%r2	$139
CPY16	%eax	%r0
AND32	%eax	$65535
CPY32	%r3	%eax
ADD16	%r2	%r3
SP_STORE	%eax
INC16	%eax	$23
CPY8	(%r2)	(%eax)
CPY16	%r2	(%r1)
INC16	%r2	$149
CPY16	%eax	%r0
AND32	%eax	$65535
CPY32	%r3	%eax
ADD16	%r2	%r3
SP_STORE	%eax
INC16	%eax	$24
CPY8	(%r2)	(%eax)
CPY16	%r2	(%r1)
INC16	%r2	$159
CPY16	%eax	%r0
AND32	%eax	$65535
CPY32	%r3	%eax
ADD16	%r2	%r3
LD8	(%r2)	$0
CPY16	%r1	(%r1)
INC16	%r1	$159
CPY16	%eax	%r0
AND32	%eax	$65535
CPY32	%r2	%eax
ADD16	%r1	%r2
SP_STORE	%eax
INC16	%eax	$19
CPY16	(%eax)	%r1
POP32	%r3
POP32	%r2
POP32	%r1
POP32	%r0
RTS	
@IC16:	
LD32	%r1	$Str@0
PUSH16	%r1
CALL	message
SP_INC	$2
PUSH16	eol
CALL	message
SP_INC	$2
@IC20:	
LD8	%ecx	$1
CMP8	%ecx	$0
JZ	@IC21
@IC22:	
JUMP	@IC20
@IC21:	
LD16	%eax	$0
SP_WR16	%eax	$19
POP32	%r3
POP32	%r2
POP32	%r1
POP32	%r0
RTS	
.FUNC_END	"GetReportOffset"

FormatValue:	
.GLOBAL	 DO_NOT_EXPORT  "FormatValue"

.FUNCTION	"FormatValue"	
PUSH32	%r0
PUSH32	%r1
PUSH32	%r2
SP_RD32	%r0	$19
SP_RD8	%r1	$23
CMP8	%r1	$1
JNZ	@IC24
@IC25:	
CPY8	%r2	%r0
CPY8	%eax	%r2
SHL32	%eax	$24
SAR32	%eax	$24
CPY32	%r2	%eax
CPY32	%r0	%r2
JUMP	@IC23
@IC24:	
CMP8	%r1	$2
JNZ	@IC28
@IC29:	
CPY16	%r2	%r0
CPY16	%eax	%r2
SHL32	%eax	$16
SAR32	%eax	$16
CPY32	%r2	%eax
CPY32	%r0	%r2
@IC28:	
@IC23:	
SP_STORE	%eax
INC16	%eax	$15
CPY32	(%eax)	%r0
POP32	%r2
POP32	%r1
POP32	%r0
RTS	
.FUNC_END	"FormatValue"

HIDParse:	
.GLOBAL	 DO_NOT_EXPORT  "HIDParse"

.FUNCTION	"HIDParse"	
PUSH32	%r0
PUSH32	%r1
PUSH32	%r2
PUSH32	%r3
SP_DEC	$251
SP_STORE	%eax
ADD16	%eax	$276
CPY16	%r2	(%eax)
SP_STORE	%ecx
ADD16	%ecx	$274
SP_STORE	%eax
ADD16	%eax	$274
CPY16	(%ecx)	(%eax)
SP_STORE	%eax
ADD16	%eax	$274
CPY16	%r0	(%eax)
INC16	%r0	$137
CPY16	%r0	(%r0)
SP_STORE	%ecx
ADD16	%ecx	$0
CPY16	(%ecx)	%r0
LD32	%r3	$0
@IC32:	
CMP32	%r3	$0
JNZ	@IC33
@IC35:	
SP_STORE	%ecx
INC16	%ecx	$2
SP_STORE	%eax
ADD16	%eax	$274
CPY16	(%ecx)	%eax
SP_RD16	%eax	$2
CPY16	%r0	(%eax)
INC16	%r0	$130
SP_STORE	%ecx
ADD16	%ecx	$4
CPY16	(%ecx)	(%r0)
SP_RD16	%eax	$2
CPY16	%r0	(%eax)
INC16	%r0	$128
CPY16	%r0	(%r0)
SP_RD32	%ecx	$4
CMP16	%ecx	%r0
JGE	@IC33
@IC34:	
SP_STORE	%eax
ADD16	%eax	$274
CPY16	%r0	(%eax)
INC16	%r0	$170
CPY8	%r0	(%r0)
CMP8	%r0	$0
JNZ	@IC38
@IC39:	
SP_STORE	%ecx
ADD16	%ecx	$6
SP_STORE	%eax
ADD16	%eax	$274
CPY16	(%ecx)	%eax
SP_RD16	%eax	$6
CPY16	%r0	(%eax)
SP_STORE	%ecx
ADD16	%ecx	$8
LD16	%ebx	$132
ADD16	(%ecx)	%r0	%ebx
SP_RD16	%eax	$6
CPY16	%r0	(%eax)
SP_STORE	%ecx
INC16	%ecx	$10
CPY16	(%ecx)	%r0
SP_RD16	%eax	$6
CPY16	%r0	(%eax)
INC16	%r0	$130
CPY16	%r0	(%r0)
CPY16	%eax	%r0
AND32	%eax	$65535
CPY32	%r0	%eax
SP_RD16	%eax	$10
ADD16	%r0	%eax
SP_STORE	%ecx
INC16	%ecx	$12
CPY8	(%ecx)	(%r0)
SP_RD16	%eax	$6
CPY16	%r0	(%eax)
INC16	%r0	$130
SP_STORE	%ecx
INC16	%ecx	$13
CPY16	(%ecx)	(%r0)
SP_STORE	%eax
INC16	%eax	$13
INC16	(%eax)	$1
SP_RD16	%eax	$6
CPY16	%r0	(%eax)
INC16	%r0	$130
SP_STORE	%eax
INC16	%eax	$13
CPY16	(%r0)	(%eax)
SP_RD16	%ecx	$8
SP_STORE	%eax
INC16	%eax	$12
CPY8	(%ecx)	(%eax)
SP_RD16	%eax	$6
CPY16	%r0	(%eax)
INC16	%r0	$133
LD32	(%r0)	$0
SP_RD16	%eax	$6
CPY16	%r0	(%eax)
SP_STORE	%ecx
INC16	%ecx	$15
LD16	%ebx	$133
ADD16	(%ecx)	%r0	%ebx
SP_RD16	%eax	$6
CPY16	%r0	(%eax)
SP_STORE	%ecx
INC16	%ecx	$17
CPY16	(%ecx)	%r0
SP_RD16	%eax	$6
CPY16	%r0	(%eax)
INC16	%r0	$130
CPY16	%r0	(%r0)
CPY16	%eax	%r0
AND32	%eax	$65535
CPY32	%r0	%eax
SP_STORE	%ecx
INC16	%ecx	$19
SP_STORE	%eax
INC16	%eax	$17
ADD16	(%ecx)	(%eax)	%r0
SP_RD16	%eax	$6
CPY16	%r0	(%eax)
INC16	%r0	$132
CPY8	%r0	(%r0)
CPY8	%eax	%r0
AND32	%eax	$255
LD32	%r0	$3
AND32	%r0	%eax
SP_STORE	%ecx
INC16	%ecx	$21
LD16	(%ecx)	$ItemSize
SP_RD16	%eax	$21
ADD16	%r0	%eax
CPY8	%r0	(%r0)
AND16	%r0	$255
PUSH16	%r0
SP_RD16	%eax	$21
PUSH16	%eax
SP_RD16	%eax	$19
PUSH16	%eax
SP_DEC	$2
CALL	memcpy
POP16	%eax
SP_WR16	%eax	$29
SP_INC	$6
SP_RD16	%eax	$6
CPY16	%r0	(%eax)
SP_STORE	%ecx
INC16	%ecx	$25
LD16	%ebx	$130
ADD16	(%ecx)	%r0	%ebx
SP_RD16	%eax	$6
CPY16	%r0	(%eax)
INC16	%r0	$132
CPY8	%r0	(%r0)
CPY8	%eax	%r0
AND32	%eax	$255
LD32	%r0	$3
AND32	%r0	%eax
SP_RD16	%eax	$21
ADD16	%r0	%eax
CPY8	%r0	(%r0)
SP_STORE	%ecx
INC16	%ecx	$27
SP_RD16	%eax	$25
CPY16	(%ecx)	(%eax)
SP_STORE	%eax
INC16	%eax	$27
CPY8	%ebx	%r0
SHL16	%ebx	$8
SAR16	%ebx	$8
ADD16	%r0	(%eax)	%ebx
SP_RD16	%ecx	$25
CPY16	(%ecx)	%r0
@IC38:	
JUMP	@IC44
@IC43:	
SP_STORE	%r0
ADD16	%r0	$274
SP_STORE	%ecx
ADD16	%ecx	$29
CPY16	(%ecx)	(%r0)
SP_STORE	%ecx
INC16	%ecx	$31
SP_STORE	%eax
INC16	%eax	$29
LD16	%ebx	$171
ADD16	(%ecx)	(%eax)	%ebx
CPY16	%r0	(%r0)
INC16	%r0	$133
CPY32	%r0	(%r0)
CPY16	%r0	%r0
SP_RD16	%ecx	$31
CPY16	(%ecx)	%r0
JUMP	@IC32
@IC45:	
SP_STORE	%eax
ADD16	%eax	$274
CPY16	%r0	(%eax)
INC16	%r0	$132
CPY8	%r0	(%r0)
CPY8	%eax	%r0
AND32	%eax	$255
LD32	%r0	$3
AND32	%r0	%eax
CMP32	%r0	$2
JLE	@IC78
@IC79:	
SP_STORE	%ecx
ADD16	%ecx	$33
SP_STORE	%eax
ADD16	%eax	$274
CPY16	(%ecx)	%eax
SP_RD16	%eax	$33
CPY16	%r0	(%eax)
SP_STORE	%ecx
ADD16	%ecx	$35
LD16	%ebx	$173
ADD16	(%ecx)	%r0	%ebx
SP_RD16	%eax	$33
CPY16	%r0	(%eax)
INC16	%r0	$253
CPY8	%r0	(%r0)
CPY8	%eax	%r0
AND32	%eax	$255
LD32	%ebx	$2
SHL32	%r0	%eax	%ebx
SP_STORE	%ecx
INC16	%ecx	$37
SP_STORE	%eax
INC16	%eax	$35
ADD16	(%ecx)	(%eax)	%r0
SP_RD16	%eax	$33
CPY16	%r0	(%eax)
INC16	%r0	$133
CPY32	%r0	(%r0)
LD32	%ebx	$16
SAR32	%r0	%r0	%ebx
CPY16	%r0	%r0
SP_RD16	%ecx	$37
CPY16	(%ecx)	%r0
JUMP	@IC77
@IC78:	
SP_STORE	%ecx
INC16	%ecx	$39
SP_STORE	%eax
ADD16	%eax	$274
CPY16	(%ecx)	%eax
SP_RD16	%eax	$39
CPY16	%r0	(%eax)
SP_STORE	%ecx
ADD16	%ecx	$41
LD16	%ebx	$173
ADD16	(%ecx)	%r0	%ebx
SP_RD16	%eax	$39
CPY16	%r0	(%eax)
INC16	%r0	$253
CPY8	%r0	(%r0)
CPY8	%eax	%r0
AND32	%eax	$255
LD32	%ebx	$2
SHL32	%r0	%eax	%ebx
SP_STORE	%ecx
INC16	%ecx	$43
SP_STORE	%eax
INC16	%eax	$41
ADD16	(%ecx)	(%eax)	%r0
SP_RD16	%eax	$39
CPY16	%r0	(%eax)
INC16	%r0	$171
CPY16	%r0	(%r0)
SP_RD16	%ecx	$43
CPY16	(%ecx)	%r0
@IC77:	
SP_STORE	%ecx
INC16	%ecx	$45
SP_STORE	%eax
ADD16	%eax	$274
CPY16	(%ecx)	%eax
SP_RD16	%eax	$45
CPY16	%r0	(%eax)
SP_STORE	%ecx
ADD16	%ecx	$47
LD16	%ebx	$173
ADD16	(%ecx)	%r0	%ebx
SP_RD16	%eax	$45
CPY16	%r0	(%eax)
INC16	%r0	$253
CPY8	%r0	(%r0)
CPY8	%eax	%r0
AND32	%eax	$255
LD32	%ebx	$2
SHL32	%r0	%eax	%ebx
SP_RD16	%eax	$47
ADD16	%r0	%eax
SP_STORE	%ecx
INC16	%ecx	$49
LD16	%ebx	$2
ADD16	(%ecx)	%r0	%ebx
SP_RD16	%eax	$45
CPY16	%r0	(%eax)
INC16	%r0	$133
CPY32	%r0	(%r0)
AND32	%r0	$65535
CPY16	%r0	%r0
SP_RD16	%ecx	$49
CPY16	(%ecx)	%r0
SP_RD16	%eax	$45
CPY16	%r0	(%eax)
INC16	%r0	$253
SP_STORE	%ecx
INC16	%ecx	$51
CPY8	(%ecx)	(%r0)
SP_STORE	%eax
INC16	%eax	$51
INC8	(%eax)	$1
SP_RD16	%eax	$45
CPY16	%r0	(%eax)
INC16	%r0	$253
SP_STORE	%eax
INC16	%eax	$51
CPY8	(%r0)	(%eax)
JUMP	@IC32
@IC47:	
SP_STORE	%ecx
INC16	%ecx	$52
SP_STORE	%eax
CPY16	(%ecx)	%eax
SP_RD16	%eax	$52
CPY16	%r0	(%eax)
SP_STORE	%ecx
INC16	%ecx	$54
LD16	%ebx	$5
ADD16	(%ecx)	%r0	%ebx
SP_RD16	%eax	$52
CPY16	%r0	(%eax)
INC16	%r0	$4
CPY8	%r0	(%r0)
CPY8	%eax	%r0
AND32	%eax	$255
LD32	%ebx	$2
SHL32	%r0	%eax	%ebx
SP_STORE	%ecx
INC16	%ecx	$56
SP_STORE	%eax
INC16	%eax	$54
ADD16	(%ecx)	(%eax)	%r0
SP_STORE	%ecx
INC16	%ecx	$58
SP_STORE	%eax
ADD16	%eax	$274
CPY16	(%ecx)	%eax
SP_RD16	%eax	$58
CPY16	%r0	(%eax)
INC16	%r0	$173
CPY16	%r0	(%r0)
SP_RD16	%ecx	$56
CPY16	(%ecx)	%r0
SP_RD16	%eax	$52
CPY16	%r0	(%eax)
SP_STORE	%ecx
ADD16	%ecx	$60
LD16	%ebx	$5
ADD16	(%ecx)	%r0	%ebx
SP_RD16	%eax	$52
CPY16	%r0	(%eax)
INC16	%r0	$4
CPY8	%r0	(%r0)
CPY8	%eax	%r0
AND32	%eax	$255
LD32	%ebx	$2
SHL32	%r0	%eax	%ebx
SP_RD16	%eax	$60
ADD16	%r0	%eax
SP_STORE	%ecx
INC16	%ecx	$62
LD16	%ebx	$2
ADD16	(%ecx)	%r0	%ebx
SP_RD16	%eax	$58
CPY16	%r0	(%eax)
INC16	%r0	$173
INC16	%r0	$2
CPY16	%r0	(%r0)
SP_RD16	%ecx	$62
CPY16	(%ecx)	%r0
SP_RD16	%eax	$52
CPY16	%r0	(%eax)
INC16	%r0	$4
SP_STORE	%ecx
INC16	%ecx	$64
CPY8	(%ecx)	(%r0)
SP_STORE	%eax
INC16	%eax	$64
INC8	(%eax)	$1
SP_RD16	%eax	$52
CPY16	%r0	(%eax)
INC16	%r0	$4
SP_STORE	%eax
INC16	%eax	$64
CPY8	(%r0)	(%eax)
SP_RD16	%eax	$58
CPY16	%r0	(%eax)
INC16	%r0	$253
CPY8	%r0	(%r0)
CMP8	%r0	$0
JLE	@IC82
@IC83:	
LD8	%r1	$0
@ICO0:	
SP_STORE	%ecx
INC16	%ecx	$65
SP_STORE	%eax
ADD16	%eax	$274
CPY16	(%ecx)	%eax
@IC86:	
SP_RD16	%eax	$65
CPY16	%r0	(%eax)
INC16	%r0	$253
CPY8	%r0	(%r0)
CMP8	%r1	%r0
JGE	@IC87
@IC88:	
SP_STORE	%ecx
ADD16	%ecx	$67
SP_STORE	%eax
ADD16	%eax	$274
CPY16	(%ecx)	%eax
SP_RD16	%eax	$67
CPY16	%r0	(%eax)
INC16	%r0	$173
SP_STORE	%ecx
ADD16	%ecx	$69
CPY8	%eax	%r1
AND32	%eax	$255
LD32	%ebx	$2
SHL32	(%ecx)	%eax	%ebx
SP_STORE	%ebx
INC16	%ebx	$69
ADD16	%r0	(%ebx)
SP_STORE	%ecx
INC16	%ecx	$73
LD16	%ebx	$2
ADD16	(%ecx)	%r0	%ebx
SP_RD16	%eax	$67
CPY16	%r0	(%eax)
INC16	%r0	$173
SP_STORE	%ecx
INC16	%ecx	$75
CPY8	%eax	%r1
AND32	%eax	$255
LD32	%ebx	$1
ADD32	(%ecx)	%eax	%ebx
SP_RD32	%ecx	$75
SHL32	%ecx	$2
SP_WR32	%ecx	$79
SP_STORE	%ebx
INC16	%ebx	$79
ADD16	%r0	(%ebx)
INC16	%r0	$2
CPY16	%r0	(%r0)
SP_RD16	%ecx	$73
CPY16	(%ecx)	%r0
SP_RD16	%eax	$67
CPY16	%r0	(%eax)
INC16	%r0	$173
SP_RD16	%ebx	$69
ADD16	%ecx	%r0	%ebx
SP_WR16	%ecx	$83
SP_RD16	%eax	$67
CPY16	%r0	(%eax)
INC16	%r0	$173
SP_STORE	%ebx
INC16	%ebx	$79
ADD16	%r0	(%ebx)
CPY16	%r0	(%r0)
SP_RD16	%ecx	$83
CPY16	(%ecx)	%r0
INC8	%r1	$1
JUMP	@IC86
@IC87:	
SP_STORE	%ecx
INC16	%ecx	$85
SP_STORE	%eax
ADD16	%eax	$274
CPY16	(%ecx)	%eax
SP_RD16	%eax	$85
CPY16	%r0	(%eax)
INC16	%r0	$253
SP_STORE	%ecx
ADD16	%ecx	$87
CPY8	(%ecx)	(%r0)
SP_STORE	%eax
INC16	%eax	$87
DEC8	(%eax)	$1
SP_RD16	%eax	$85
CPY16	%r0	(%eax)
INC16	%r0	$253
SP_STORE	%eax
INC16	%eax	$87
CPY8	(%r0)	(%eax)
@IC82:	
SP_STORE	%eax
ADD16	%eax	$274
CPY16	%r0	(%eax)
INC16	%r0	$133
CPY32	%r0	(%r0)
CMP32	%r0	$128
JLTS	@IC91
@IC92:	
SP_STORE	%ecx
ADD16	%ecx	$88
SP_STORE	%eax
CPY16	(%ecx)	%eax
SP_RD16	%eax	$88
CPY16	%r0	(%eax)
SP_STORE	%ecx
INC16	%ecx	$90
LD16	%ebx	$5
ADD16	(%ecx)	%r0	%ebx
SP_RD16	%eax	$88
CPY16	%r0	(%eax)
INC16	%r0	$4
CPY8	%r0	(%r0)
CPY8	%eax	%r0
AND32	%eax	$255
LD32	%ebx	$2
SHL32	%r0	%eax	%ebx
SP_RD16	%eax	$90
ADD16	%r0	%eax
LD16	(%r0)	$255
SP_RD16	%eax	$88
CPY16	%r0	(%eax)
SP_STORE	%ecx
INC16	%ecx	$92
LD16	%ebx	$5
ADD16	(%ecx)	%r0	%ebx
SP_RD16	%eax	$88
CPY16	%r0	(%eax)
INC16	%r0	$4
CPY8	%r0	(%r0)
CPY8	%eax	%r0
AND32	%eax	$255
LD32	%ebx	$2
SHL32	%r0	%eax	%ebx
SP_RD16	%eax	$92
ADD16	%r0	%eax
SP_STORE	%ecx
INC16	%ecx	$94
LD16	%ebx	$2
ADD16	(%ecx)	%r0	%ebx
SP_STORE	%eax
ADD16	%eax	$274
CPY16	%r0	(%eax)
INC16	%r0	$133
CPY32	%r0	(%r0)
AND32	%r0	$127
SP_RD16	%ecx	$94
CPY16	(%ecx)	%r0
SP_RD16	%eax	$88
CPY16	%r0	(%eax)
INC16	%r0	$4
SP_STORE	%ecx
ADD16	%ecx	$96
CPY8	(%ecx)	(%r0)
SP_STORE	%eax
INC16	%eax	$96
INC8	(%eax)	$1
SP_RD16	%eax	$88
CPY16	%r0	(%eax)
INC16	%r0	$4
SP_STORE	%eax
INC16	%eax	$96
CPY8	(%r0)	(%eax)
@IC91:	
SP_STORE	%eax
ADD16	%eax	$274
PUSH16	(%eax)
CALL	ResetLocalState
SP_INC	$2
JUMP	@IC32
@IC49:	
SP_STORE	%ecx
ADD16	%ecx	$97
SP_STORE	%eax
CPY16	(%ecx)	%eax
SP_RD16	%eax	$97
CPY16	%r0	(%eax)
INC16	%r0	$4
SP_STORE	%ecx
INC16	%ecx	$99
CPY8	(%ecx)	(%r0)
SP_STORE	%eax
INC16	%eax	$99
DEC8	(%eax)	$1
SP_RD16	%eax	$97
CPY16	%r0	(%eax)
INC16	%r0	$4
SP_STORE	%eax
INC16	%eax	$99
CPY8	(%r0)	(%eax)
SP_RD16	%eax	$97
CPY16	%r0	(%eax)
SP_STORE	%ecx
INC16	%ecx	$100
LD16	%ebx	$5
ADD16	(%ecx)	%r0	%ebx
SP_RD16	%eax	$97
CPY16	%r0	(%eax)
INC16	%r0	$4
CPY8	%r0	(%r0)
CPY8	%eax	%r0
AND32	%eax	$255
LD32	%ebx	$2
SHL32	%r0	%eax	%ebx
SP_RD16	%eax	$100
ADD16	%r0	%eax
CPY16	%r0	(%r0)
CMP16	%r0	$255
JNZ	@IC95
@IC96:	
SP_STORE	%ecx
INC16	%ecx	$102
SP_STORE	%eax
CPY16	(%ecx)	%eax
SP_RD16	%eax	$102
CPY16	%r0	(%eax)
INC16	%r0	$4
SP_STORE	%ecx
INC16	%ecx	$104
CPY8	(%ecx)	(%r0)
SP_STORE	%eax
INC16	%eax	$104
DEC8	(%eax)	$1
SP_RD16	%eax	$102
CPY16	%r0	(%eax)
INC16	%r0	$4
SP_STORE	%eax
INC16	%eax	$104
CPY8	(%r0)	(%eax)
@IC95:	
SP_STORE	%eax
ADD16	%eax	$274
PUSH16	(%eax)
CALL	ResetLocalState
SP_INC	$2
JUMP	@IC32
@IC51:	
@IC53:	
@IC55:	
LD32	%r3	$1
SP_STORE	%ecx
ADD16	%ecx	$105
SP_STORE	%eax
ADD16	%eax	$274
CPY16	(%ecx)	%eax
SP_RD16	%eax	$105
CPY16	%r0	(%eax)
INC16	%r0	$254
SP_STORE	%ecx
ADD16	%ecx	$107
CPY8	(%ecx)	(%r0)
SP_STORE	%eax
INC16	%eax	$107
INC8	(%eax)	$1
SP_RD16	%eax	$105
CPY16	%r0	(%eax)
INC16	%r0	$254
SP_STORE	%eax
INC16	%eax	$107
CPY8	(%r0)	(%eax)
SP_RD16	%eax	$105
CPY16	%r0	(%eax)
INC16	%r0	$170
CPY8	%r0	(%r0)
CMP8	%r0	$0
JNZ	@IC99
@IC100:	
SP_STORE	%r0
ADD16	%r0	$274
SP_STORE	%ecx
ADD16	%ecx	$108
CPY16	(%ecx)	(%r0)
SP_STORE	%ecx
INC16	%ecx	$110
SP_STORE	%eax
INC16	%eax	$108
LD16	%ebx	$170
ADD16	(%ecx)	(%eax)	%ebx
CPY16	%r0	(%r0)
INC16	%r0	$169
CPY8	%r0	(%r0)
SP_RD16	%ecx	$110
CPY8	(%ecx)	%r0
@IC99:	
SP_STORE	%ecx
INC16	%ecx	$112
SP_STORE	%eax
INC16	%eax	$0
CPY16	(%ecx)	%eax
SP_RD16	%eax	$112
CPY16	%r0	(%eax)
SP_STORE	%ecx
INC16	%ecx	$114
LD16	%ebx	$5
ADD16	(%ecx)	%r0	%ebx
SP_RD16	%eax	$112
CPY16	%r0	(%eax)
INC16	%r0	$4
CPY8	%r0	(%r0)
CPY8	%eax	%r0
AND32	%eax	$255
LD32	%ebx	$2
SHL32	%r0	%eax	%ebx
SP_STORE	%ecx
INC16	%ecx	$116
SP_STORE	%eax
INC16	%eax	$114
ADD16	(%ecx)	(%eax)	%r0
SP_STORE	%ecx
INC16	%ecx	$118
SP_STORE	%eax
ADD16	%eax	$274
CPY16	(%ecx)	%eax
SP_RD16	%eax	$118
CPY16	%r0	(%eax)
INC16	%r0	$173
CPY16	%r0	(%r0)
SP_RD16	%ecx	$116
CPY16	(%ecx)	%r0
SP_RD16	%eax	$112
CPY16	%r0	(%eax)
SP_STORE	%ecx
ADD16	%ecx	$120
LD16	%ebx	$5
ADD16	(%ecx)	%r0	%ebx
SP_RD16	%eax	$112
CPY16	%r0	(%eax)
INC16	%r0	$4
CPY8	%r0	(%r0)
CPY8	%eax	%r0
AND32	%eax	$255
LD32	%ebx	$2
SHL32	%r0	%eax	%ebx
SP_RD16	%eax	$120
ADD16	%r0	%eax
SP_STORE	%ecx
INC16	%ecx	$122
LD16	%ebx	$2
ADD16	(%ecx)	%r0	%ebx
SP_RD16	%eax	$118
CPY16	%r0	(%eax)
INC16	%r0	$173
INC16	%r0	$2
CPY16	%r0	(%r0)
SP_RD16	%ecx	$122
CPY16	(%ecx)	%r0
SP_RD16	%eax	$112
CPY16	%r0	(%eax)
INC16	%r0	$4
SP_STORE	%ecx
INC16	%ecx	$124
CPY8	(%ecx)	(%r0)
SP_STORE	%eax
INC16	%eax	$124
INC8	(%eax)	$1
SP_RD16	%eax	$112
CPY16	%r0	(%eax)
INC16	%r0	$4
SP_STORE	%eax
INC16	%eax	$124
CPY8	(%r0)	(%eax)
SP_RD16	%eax	$118
CPY16	%r0	(%eax)
INC16	%r0	$253
CPY8	%r0	(%r0)
CMP8	%r0	$0
JLE	@IC103
@IC104:	
LD8	%r1	$0
@ICO1:	
SP_STORE	%ecx
INC16	%ecx	$125
SP_STORE	%eax
ADD16	%eax	$274
CPY16	(%ecx)	%eax
@IC107:	
SP_RD16	%eax	$125
CPY16	%r0	(%eax)
INC16	%r0	$253
CPY8	%r0	(%r0)
CMP8	%r1	%r0
JGE	@IC108
@IC109:	
SP_STORE	%ecx
ADD16	%ecx	$127
SP_STORE	%eax
ADD16	%eax	$274
CPY16	(%ecx)	%eax
SP_RD16	%eax	$127
CPY16	%r0	(%eax)
INC16	%r0	$173
SP_STORE	%ecx
ADD16	%ecx	$129
CPY8	%eax	%r1
AND32	%eax	$255
LD32	%ebx	$2
SHL32	(%ecx)	%eax	%ebx
SP_RD16	%ebx	$129
ADD16	%ecx	%r0	%ebx
SP_WR16	%ecx	$133
SP_RD16	%eax	$127
CPY16	%r0	(%eax)
INC16	%r0	$173
SP_STORE	%ecx
INC16	%ecx	$135
CPY8	%eax	%r1
AND32	%eax	$255
LD32	%ebx	$1
ADD32	(%ecx)	%eax	%ebx
SP_RD32	%ecx	$135
SHL32	%ecx	$2
SP_WR32	%ecx	$139
SP_STORE	%ebx
INC16	%ebx	$139
ADD16	%r0	(%ebx)
CPY16	%r0	(%r0)
SP_RD16	%ecx	$133
CPY16	(%ecx)	%r0
SP_RD16	%eax	$127
CPY16	%r0	(%eax)
INC16	%r0	$173
SP_STORE	%ebx
INC16	%ebx	$129
ADD16	%r0	(%ebx)
SP_STORE	%ecx
INC16	%ecx	$143
LD16	%ebx	$2
ADD16	(%ecx)	%r0	%ebx
SP_RD16	%eax	$127
CPY16	%r0	(%eax)
INC16	%r0	$173
SP_STORE	%ebx
INC16	%ebx	$139
ADD16	%r0	(%ebx)
INC16	%r0	$2
CPY16	%r0	(%r0)
SP_RD16	%ecx	$143
CPY16	(%ecx)	%r0
INC8	%r1	$1
JUMP	@IC107
@IC108:	
SP_STORE	%ecx
INC16	%ecx	$145
SP_STORE	%eax
ADD16	%eax	$274
CPY16	(%ecx)	%eax
SP_RD16	%eax	$145
CPY16	%r0	(%eax)
INC16	%r0	$253
SP_STORE	%ecx
ADD16	%ecx	$147
CPY8	(%ecx)	(%r0)
SP_STORE	%eax
INC16	%eax	$147
DEC8	(%eax)	$1
SP_RD16	%eax	$145
CPY16	%r0	(%eax)
INC16	%r0	$253
SP_STORE	%eax
INC16	%eax	$147
CPY8	(%r0)	(%eax)
@IC103:	
SP_STORE	%ecx
INC16	%ecx	$148
SP_STORE	%eax
CPY16	(%ecx)	%eax
SP_RD16	%eax	$148
CPY16	%r0	(%eax)
SP_STORE	%ecx
INC16	%ecx	$150
LD16	%ebx	$48
ADD16	(%ecx)	%r0	%ebx
SP_STORE	%ecx
INC16	%ecx	$152
SP_STORE	%eax
ADD16	%eax	$274
CPY16	(%ecx)	%eax
SP_RD16	%eax	$152
CPY16	%r0	(%eax)
INC16	%r0	$132
CPY8	%r0	(%r0)
CPY8	%eax	%r0
AND32	%eax	$255
LD32	%r0	$252
AND32	%r0	%eax
CPY8	%r0	%r0
SP_RD16	%ecx	$150
CPY8	(%ecx)	%r0
SP_RD16	%eax	$148
CPY16	%r0	(%eax)
SP_STORE	%ecx
ADD16	%ecx	$154
LD16	%ebx	$49
ADD16	(%ecx)	%r0	%ebx
SP_RD16	%eax	$152
CPY16	%r0	(%eax)
INC16	%r0	$133
CPY32	%r0	(%r0)
CPY8	%r0	%r0
SP_RD16	%ecx	$154
CPY8	(%ecx)	%r0
SP_RD16	%eax	$148
CPY16	%r0	(%eax)
SP_STORE	%ecx
INC16	%ecx	$156
LD16	%ebx	$46
ADD16	(%ecx)	%r0	%ebx
SP_RD16	%eax	$148
CPY16	%r0	(%eax)
INC16	%r0	$45
SP_STORE	%ecx
INC16	%ecx	$158
CPY8	(%ecx)	(%r0)
SP_RD16	%eax	$152
CPY16	%r0	(%eax)
INC16	%r0	$132
CPY8	%r0	(%r0)
CPY8	%eax	%r0
AND32	%eax	$255
LD32	%r0	$252
AND32	%r0	%eax
CPY8	%r0	%r0
PUSH8	%r0
SP_RD16	%eax	$159
PUSH8	%eax
SP_STORE	%eax
ADD16	%eax	$276
PUSH16	(%eax)
SP_DEC	$2
CALL	GetReportOffset
POP16	%eax
SP_WR16	%eax	$163
SP_INC	$4
SP_RD16	%eax	$159
CPY8	%r0	(%eax)
SP_RD16	%ecx	$156
CPY8	(%ecx)	%r0
PUSH16	$71
SP_RD16	%eax	$2
PUSH16	%eax
PUSH16	%r2
SP_DEC	$2
CALL	memcpy
POP16	%eax
SP_WR16	%eax	$167
SP_INC	$6
SP_RD16	%eax	$148
CPY16	%r0	(%eax)
INC16	%r0	$45
SP_STORE	%ecx
ADD16	%ecx	$163
CPY8	(%ecx)	(%r0)
SP_RD16	%eax	$152
CPY16	%r0	(%eax)
INC16	%r0	$132
CPY8	%r0	(%r0)
CPY8	%eax	%r0
AND32	%eax	$255
LD32	%r0	$252
AND32	%r0	%eax
CPY8	%r0	%r0
PUSH8	%r0
SP_RD16	%eax	$164
PUSH8	%eax
SP_STORE	%eax
ADD16	%eax	$276
PUSH16	(%eax)
SP_DEC	$2
CALL	GetReportOffset
POP16	%eax
SP_WR16	%eax	$168
SP_INC	$4
SP_RD16	%eax	$148
CPY16	%r0	(%eax)
INC16	%r0	$47
CPY8	%r0	(%r0)
SP_STORE	%ecx
ADD16	%ecx	$166
SP_RD16	%eax	$164
CPY8	(%ecx)	(%eax)
SP_RD8	%eax	$166
ADD8	%r0	%eax
SP_RD16	%ecx	$164
CPY8	(%ecx)	%r0
SP_RD16	%eax	$148
CPY16	%r0	(%eax)
INC16	%r0	$4
SP_STORE	%ecx
INC16	%ecx	$167
CPY8	(%ecx)	(%r0)
SP_STORE	%eax
INC16	%eax	$167
DEC8	(%eax)	$1
SP_RD16	%eax	$148
CPY16	%r0	(%eax)
INC16	%r0	$4
SP_STORE	%eax
INC16	%eax	$167
CPY8	(%r0)	(%eax)
SP_RD16	%eax	$152
CPY16	%r0	(%eax)
INC16	%r0	$170
SP_STORE	%ecx
INC16	%ecx	$168
CPY8	(%ecx)	(%r0)
SP_STORE	%eax
INC16	%eax	$168
DEC8	(%eax)	$1
SP_RD16	%eax	$152
CPY16	%r0	(%eax)
INC16	%r0	$170
SP_STORE	%eax
INC16	%eax	$168
CPY8	(%r0)	(%eax)
SP_RD16	%eax	$152
CPY16	%r0	(%eax)
INC16	%r0	$170
CPY8	%r0	(%r0)
CMP8	%r0	$0
JNZ	@IC112
@IC113:	
SP_STORE	%eax
ADD16	%eax	$274
PUSH16	(%eax)
CALL	ResetLocalState
SP_INC	$2
@IC112:	
JUMP	@IC32
@IC57:	
SP_RD16	%r0	$0
SP_STORE	%ecx
ADD16	%ecx	$169
LD16	%ebx	$45
ADD16	(%ecx)	%r0	%ebx
SP_STORE	%eax
ADD16	%eax	$274
CPY16	%r0	(%eax)
INC16	%r0	$133
CPY32	%r0	(%r0)
CPY8	%r0	%r0
SP_RD16	%ecx	$169
CPY8	(%ecx)	%r0
JUMP	@IC32
@IC59:	
SP_RD16	%r0	$0
SP_STORE	%ecx
ADD16	%ecx	$171
LD16	%ebx	$47
ADD16	(%ecx)	%r0	%ebx
SP_STORE	%eax
ADD16	%eax	$274
CPY16	%r0	(%eax)
INC16	%r0	$133
CPY32	%r0	(%r0)
CPY8	%r0	%r0
SP_RD16	%ecx	$171
CPY8	(%ecx)	%r0
JUMP	@IC32
@IC61:	
SP_STORE	%r0
ADD16	%r0	$274
SP_STORE	%ecx
INC16	%ecx	$173
CPY16	(%ecx)	(%r0)
SP_STORE	%ecx
INC16	%ecx	$175
SP_STORE	%eax
INC16	%eax	$173
LD16	%ebx	$169
ADD16	(%ecx)	(%eax)	%ebx
CPY16	%r0	(%r0)
INC16	%r0	$133
CPY32	%r0	(%r0)
CPY8	%r0	%r0
SP_RD16	%ecx	$175
CPY8	(%ecx)	%r0
JUMP	@IC32
@IC63:	
SP_STORE	%ecx
INC16	%ecx	$177
SP_STORE	%eax
INC16	%eax	$0
CPY16	(%ecx)	%eax
SP_RD16	%eax	$177
CPY16	%r0	(%eax)
SP_STORE	%ecx
INC16	%ecx	$179
LD16	%ebx	$54
ADD16	(%ecx)	%r0	%ebx
SP_STORE	%eax
ADD16	%eax	$274
CPY16	%r0	(%eax)
INC16	%r0	$133
CPY32	%r0	(%r0)
CPY8	%r0	%r0
SP_RD16	%ecx	$179
CPY8	(%ecx)	%r0
SP_RD16	%eax	$177
CPY16	%r0	(%eax)
INC16	%r0	$54
CPY8	%r0	(%r0)
CMP8	%r0	$7
JLES	@IC42
@IC117:	
SP_RD16	%r0	$0
SP_STORE	%ecx
ADD16	%ecx	$181
LD16	%ebx	$54
ADD16	(%ecx)	%r0	%ebx
SP_RD16	%eax	$181
CPY8	%r0	(%eax)
OR8	%r0	$240
SP_RD16	%ecx	$181
CPY8	(%ecx)	%r0
@IC116:	
JUMP	@IC32
@IC65:	
SP_RD16	%r0	$0
SP_STORE	%ecx
INC16	%ecx	$183
LD16	%ebx	$50
ADD16	(%ecx)	%r0	%ebx
SP_STORE	%eax
ADD16	%eax	$274
CPY16	%r0	(%eax)
INC16	%r0	$133
CPY32	%r0	(%r0)
SP_RD16	%ecx	$183
CPY32	(%ecx)	%r0
JUMP	@IC32
@IC67:	
SP_RD16	%r0	$0
SP_STORE	%ecx
ADD16	%ecx	$185
LD16	%ebx	$55
ADD16	(%ecx)	%r0	%ebx
SP_STORE	%ecx
INC16	%ecx	$187
SP_STORE	%eax
ADD16	%eax	$274
CPY16	(%ecx)	%eax
SP_RD16	%eax	$187
CPY16	%r0	(%eax)
INC16	%r0	$133
SP_STORE	%ecx
ADD16	%ecx	$189
CPY32	(%ecx)	(%r0)
SP_RD16	%eax	$187
CPY16	%r0	(%eax)
INC16	%r0	$132
CPY8	%r0	(%r0)
CPY8	%eax	%r0
AND32	%eax	$255
LD32	%r0	$3
AND32	%r0	%eax
SP_STORE	%ecx
INC16	%ecx	$193
LD16	(%ecx)	$ItemSize
SP_RD16	%eax	$193
ADD16	%r0	%eax
CPY8	%r0	(%r0)
PUSH8	%r0
SP_RD32	%eax	$190
PUSH32	%eax
SP_DEC	$4
CALL	FormatValue
POP32	%eax
SP_WR32	%eax	$200
SP_INC	$5
SP_RD16	%ecx	$185
SP_STORE	%eax
INC16	%eax	$195
CPY32	(%ecx)	(%eax)
JUMP	@IC32
@IC69:	
SP_RD16	%r0	$0
SP_STORE	%ecx
INC16	%ecx	$199
LD16	%ebx	$59
ADD16	(%ecx)	%r0	%ebx
SP_STORE	%ecx
INC16	%ecx	$201
SP_STORE	%eax
ADD16	%eax	$274
CPY16	(%ecx)	%eax
SP_RD16	%eax	$201
CPY16	%r0	(%eax)
INC16	%r0	$133
SP_STORE	%ecx
ADD16	%ecx	$203
CPY32	(%ecx)	(%r0)
SP_RD16	%eax	$201
CPY16	%r0	(%eax)
INC16	%r0	$132
CPY8	%r0	(%r0)
CPY8	%eax	%r0
AND32	%eax	$255
LD32	%r0	$3
AND32	%r0	%eax
SP_STORE	%ecx
INC16	%ecx	$207
LD16	(%ecx)	$ItemSize
SP_RD16	%eax	$207
ADD16	%r0	%eax
CPY8	%r0	(%r0)
PUSH8	%r0
SP_RD32	%eax	$204
PUSH32	%eax
SP_DEC	$4
CALL	FormatValue
POP32	%eax
SP_WR32	%eax	$214
SP_INC	$5
SP_RD16	%ecx	$199
SP_STORE	%eax
INC16	%eax	$209
CPY32	(%ecx)	(%eax)
JUMP	@IC32
@IC71:	
SP_RD16	%r0	$0
SP_STORE	%ecx
INC16	%ecx	$213
LD16	%ebx	$63
ADD16	(%ecx)	%r0	%ebx
SP_STORE	%ecx
INC16	%ecx	$215
SP_STORE	%eax
ADD16	%eax	$274
CPY16	(%ecx)	%eax
SP_RD16	%eax	$215
CPY16	%r0	(%eax)
INC16	%r0	$133
SP_STORE	%ecx
ADD16	%ecx	$217
CPY32	(%ecx)	(%r0)
SP_RD16	%eax	$215
CPY16	%r0	(%eax)
INC16	%r0	$132
CPY8	%r0	(%r0)
CPY8	%eax	%r0
AND32	%eax	$255
LD32	%r0	$3
AND32	%r0	%eax
SP_STORE	%ecx
INC16	%ecx	$221
LD16	(%ecx)	$ItemSize
SP_RD16	%eax	$221
ADD16	%r0	%eax
CPY8	%r0	(%r0)
PUSH8	%r0
SP_RD32	%eax	$218
PUSH32	%eax
SP_DEC	$4
CALL	FormatValue
POP32	%eax
SP_WR32	%eax	$228
SP_INC	$5
SP_RD16	%ecx	$213
SP_STORE	%eax
INC16	%eax	$223
CPY32	(%ecx)	(%eax)
JUMP	@IC32
@IC73:	
SP_RD16	%r0	$0
SP_STORE	%ecx
INC16	%ecx	$227
LD16	%ebx	$67
ADD16	(%ecx)	%r0	%ebx
SP_STORE	%ecx
INC16	%ecx	$229
SP_STORE	%eax
ADD16	%eax	$274
CPY16	(%ecx)	%eax
SP_RD16	%eax	$229
CPY16	%r0	(%eax)
INC16	%r0	$133
SP_STORE	%ecx
ADD16	%ecx	$231
CPY32	(%ecx)	(%r0)
SP_RD16	%eax	$229
CPY16	%r0	(%eax)
INC16	%r0	$132
CPY8	%r0	(%r0)
CPY8	%eax	%r0
AND32	%eax	$255
LD32	%r0	$3
AND32	%r0	%eax
SP_STORE	%ecx
INC16	%ecx	$235
LD16	(%ecx)	$ItemSize
SP_RD16	%eax	$235
ADD16	%r0	%eax
CPY8	%r0	(%r0)
PUSH8	%r0
SP_RD32	%eax	$232
PUSH32	%eax
SP_DEC	$4
CALL	FormatValue
POP32	%eax
SP_WR32	%eax	$242
SP_INC	$5
SP_RD16	%ecx	$227
SP_STORE	%eax
INC16	%eax	$237
CPY32	(%ecx)	(%eax)
JUMP	@IC32
@IC75:	
SP_STORE	%r0
ADD16	%r0	$274
SP_STORE	%ecx
ADD16	%ecx	$241
CPY16	(%ecx)	(%r0)
SP_STORE	%ecx
INC16	%ecx	$243
SP_STORE	%eax
INC16	%eax	$241
LD16	%ebx	$130
ADD16	(%ecx)	(%eax)	%ebx
CPY16	%r0	(%r0)
INC16	%r0	$133
CPY32	%r0	(%r0)
AND32	%r0	$255
CPY8	%r0	%r0
SP_STORE	%ecx
INC16	%ecx	$245
SP_RD16	%eax	$243
CPY16	(%ecx)	(%eax)
SP_STORE	%eax
INC16	%eax	$245
CPY8	%ebx	%r0
AND16	%ebx	$255
ADD16	%r0	(%eax)	%ebx
SP_RD16	%ecx	$243
CPY16	(%ecx)	%r0
JUMP	@IC32
@IC44:	
SP_STORE	%eax
ADD16	%eax	$274
CPY16	%r0	(%eax)
INC16	%r0	$132
CPY8	%r0	(%r0)
SP_STORE	%ecx
ADD16	%ecx	$247
CPY8	%eax	%r0
AND32	%eax	$255
LD32	%ebx	$252
AND32	(%ecx)	%eax	%ebx
SP_RD32	%ecx	$247
CMP32	%ecx	$4
JZ	@IC43
@IC46:	
SP_RD32	%ecx	$247
CMP32	%ecx	$8
JZ	@IC45
@IC48:	
SP_RD32	%ecx	$247
CMP32	%ecx	$160
JZ	@IC47
@IC50:	
SP_RD32	%ecx	$247
CMP32	%ecx	$192
JZ	@IC49
@IC52:	
SP_RD32	%ecx	$247
CMP32	%ecx	$176
JZ	@IC51
@IC54:	
SP_RD32	%ecx	$247
CMP32	%ecx	$128
JZ	@IC53
@IC56:	
SP_RD32	%ecx	$247
CMP32	%ecx	$144
JZ	@IC55
@IC58:	
SP_RD32	%ecx	$247
CMP32	%ecx	$132
JZ	@IC57
@IC60:	
SP_RD32	%ecx	$247
CMP32	%ecx	$116
JZ	@IC59
@IC62:	
SP_RD32	%ecx	$247
CMP32	%ecx	$148
JZ	@IC61
@IC64:	
SP_RD32	%ecx	$247
CMP32	%ecx	$84
JZ	@IC63
@IC66:	
SP_RD32	%ecx	$247
CMP32	%ecx	$100
JZ	@IC65
@IC68:	
SP_RD32	%ecx	$247
CMP32	%ecx	$20
JZ	@IC67
@IC70:	
SP_RD32	%ecx	$247
CMP32	%ecx	$36
JZ	@IC69
@IC72:	
SP_RD32	%ecx	$247
CMP32	%ecx	$52
JZ	@IC71
@IC74:	
SP_RD32	%ecx	$247
CMP32	%ecx	$68
JZ	@IC73
@IC76:	
SP_RD32	%ecx	$247
CMP32	%ecx	$252
JZ	@IC75
@IC42:	
JUMP	@IC32
@IC33:	
SP_STORE	%eax
ADD16	%eax	$270
CPY32	(%eax)	%r3
SP_INC	$251
POP32	%r3
POP32	%r2
POP32	%r1
POP32	%r0
RTS	
.FUNC_END	"HIDParse"

GetValue:	
.GLOBAL	 DO_NOT_EXPORT  "GetValue"

.FUNCTION	"GetValue"	
PUSH32	%r0
PUSH32	%r1
PUSH32	%r2
PUSH32	%r3
SP_DEC	$4
SP_RD16	%ecx	$23
SP_RD16	%r3	$27
SP_STORE	%r1
ADD16	%r1	$25
CPY16	%r2	(%r1)
INC16	%r2	$46
CPY8	%r2	(%r2)
SP_STORE	%ecx
INC16	%ecx	$0
CPY8	%eax	%r2
AND16	%eax	$255
CPY16	(%ecx)	%eax
LD16	%ecx	$0
SP_WR16	%ecx	$2
CPY16	%r2	(%r1)
CPY16	%r2	%r2
LD32	(%r2)	$0
CPY16	%r1	(%r1)
INC16	%r1	$45
CPY8	%r1	(%r1)
CPY8	%eax	%r1
AND32	%eax	$255
CPY32	%r1	%eax
LD32	%ebx	$2
SHL32	%r1	%ebx
ADD16	%r1	%r3
CPY16	%r1	(%r1)
SP_STORE	%eax
ADD16	%r1	(%eax)	%r1
SP_STORE	%ecx
CPY16	(%ecx)	%r1
@ICO2:	
SP_STORE	%r0
INC16	%r0	$25
@IC120:	
CPY16	%r1	(%r0)
INC16	%r1	$47
CPY8	%r1	(%r1)
SP_STORE	%ecx
INC16	%ecx	$2
CPY8	%eax	%r1
SHL16	%eax	$8
SHR16	%eax	$8
CMP16	(%ecx)	%eax
JGE	@IC121
@IC122:	
SP_RD16	%eax	$0
AND32	%eax	$65535
LD32	%ebx	$3
SHR32	%r1	%eax	%ebx
SP_RD16	%eax	$23
ADD16	%r1	%eax
CPY8	%r1	(%r1)
AND32	%r1	$255
SP_RD16	%eax	$0
AND32	%eax	$65535
LD32	%ebx	$8
REM32	%r2	%eax	%ebx
LD32	%eax	$1
SHL32	%r2	%eax	%r2
AND32	%r1	%r2
CMP32	%r1	$0
JZ	@IC125
@IC126:	
SP_RD16	%r1	$25
CPY16	%r1	%r1
SP_RD16	%ebx	$2
AND32	%ebx	$65535
LD32	%eax	$1
SHL32	%r2	%eax	%ebx
CPY32	%r3	(%r1)
ADD32	%r2	%r3
CPY32	(%r1)	%r2
@IC125:	
SP_STORE	%eax
INC16	%eax	$2
INC16	(%eax)	$1
SP_STORE	%eax
INC16	(%eax)	$1
JUMP	@IC120
@IC121:	
SP_INC	$4
POP32	%r3
POP32	%r2
POP32	%r1
POP32	%r0
RTS	
.FUNC_END	"GetValue"

GetValueXY:	
.GLOBAL	 DO_NOT_EXPORT  "GetValueXY"

.FUNCTION	"GetValueXY"	
PUSH32	%r0
PUSH32	%r1
PUSH32	%r2
PUSH32	%r3
SP_DEC	$12
SP_RD16	%ecx	$31
SP_RD16	%r3	$35
SP_STORE	%r1
INC16	%r1	$33
CPY16	%r2	(%r1)
INC16	%r2	$46
CPY8	%r2	(%r2)
SP_STORE	%ecx
INC16	%ecx	$0
CPY8	%eax	%r2
AND32	%eax	$255
CPY32	(%ecx)	%eax
LD32	%ecx	$0
SP_WR32	%ecx	$4
CPY16	%r2	(%r1)
CPY16	%r2	%r2
LD32	(%r2)	$0
CPY16	%r1	(%r1)
INC16	%r1	$45
CPY8	%r1	(%r1)
CPY8	%eax	%r1
AND32	%eax	$255
CPY32	%r1	%eax
LD32	%ebx	$2
SHL32	%r1	%ebx
ADD16	%r1	%r3
CPY16	%r1	(%r1)
SP_STORE	%eax
CPY16	%ebx	%r1
AND32	%ebx	$65535
ADD32	%r1	(%eax)	%ebx
SP_STORE	%ecx
CPY32	(%ecx)	%r1
@ICO3:	
SP_STORE	%r0
INC16	%r0	$33
@IC127:	
CPY16	%r1	(%r0)
INC16	%r1	$47
CPY8	%r1	(%r1)
SP_STORE	%ecx
INC16	%ecx	$4
CPY8	%eax	%r1
SHL32	%eax	$24
SAR32	%eax	$24
CMP32	(%ecx)	%eax
JGES	@IC128
@IC129:	
SP_STORE	%eax
LD32	%ebx	$3
SAR32	%r1	(%eax)	%ebx
SP_RD16	%eax	$31
ADD16	%r1	%eax
CPY8	%r1	(%r1)
AND32	%r1	$255
SP_STORE	%eax
LD32	%ebx	$8
REM32	%r2	(%eax)	%ebx
LD32	%eax	$1
SHL32	%r2	%eax	%r2
AND32	%r1	%r2
CMP32	%r1	$0
JZ	@IC132
@IC133:	
SP_RD16	%r1	$33
CPY16	%r1	%r1
SP_STORE	%ebx
INC16	%ebx	$4
LD32	%eax	$1
SHL32	%r2	%eax	(%ebx)
CPY32	%r3	(%r1)
ADD32	%r2	%r3
CPY32	(%r1)	%r2
@IC132:	
SP_STORE	%eax
INC16	%eax	$4
INC32	(%eax)	$1
SP_STORE	%eax
INC32	(%eax)	$1
JUMP	@IC127
@IC128:	
SP_STORE	%r1
INC16	%r1	$33
CPY16	%r2	(%r1)
CPY32	%r2	(%r2)
SP_STORE	%ecx
INC16	%ecx	$8
CPY32	(%ecx)	%r2
CPY16	%r1	(%r1)
INC16	%r1	$47
CPY8	%r1	(%r1)
CMP8	%r1	$8
JLE	@IC135
@IC136:	
SP_RD16	%r1	$33
INC16	%r1	$47
CPY8	%r1	(%r1)
CPY8	%eax	%r1
AND32	%eax	$255
LD32	%ebx	$9
SUB32	%r1	%eax	%ebx
CPY8	%r1	%r1
SP_STORE	%eax
INC16	%eax	$8
CPY8	%ebx	%r1
AND32	%ebx	$255
SAR32	%r1	(%eax)	%ebx
SP_STORE	%ecx
INC16	%ecx	$8
CPY32	(%ecx)	%r1
JUMP	@IC134
@IC135:	
SP_RD16	%r1	$33
INC16	%r1	$47
CPY8	%r1	(%r1)
CMP8	%r1	$8
JNZ	@IC139
@IC140:	
SP_RD32	%r1	$8
SHL32	%r1	$1
SP_STORE	%ecx
INC16	%ecx	$8
CPY32	(%ecx)	%r1
@IC139:	
@IC134:	
SP_STORE	%r1
INC16	%r1	$33
CPY16	%r2	(%r1)
CPY16	%r2	%r2
SP_STORE	%eax
INC16	%eax	$8
LD32	%ebx	$256
AND32	%r3	(%eax)	%ebx
CPY16	%r1	(%r1)
CPY32	%r1	(%r1)
AND32	%r1	$255
OR32	%r1	%r3
CPY32	(%r2)	%r1
SP_INC	$12
POP32	%r3
POP32	%r2
POP32	%r1
POP32	%r0
RTS	
.FUNC_END	"GetValueXY"

ReportID_DataLength:	
.GLOBAL	 DO_NOT_EXPORT  "ReportID_DataLength"

.FUNCTION	"ReportID_DataLength"	
PUSH32	%r0
PUSH32	%r1
PUSH32	%r2
PUSH32	%r3
SP_DEC	$75
SP_RD8	%r0	$100
SP_RD16	%r2	$98
LD32	%r1	$0
PUSH16	%r2
CALL	ResetParser
SP_INC	$2
@IC143:	
SP_STORE	%r3
INC16	%r3	$0
PUSH16	%r3
PUSH16	%r2
SP_DEC	$4
CALL	HIDParse
POP32	%eax
SP_WR32	%eax	$75
SP_INC	$4
SP_RD32	%ecx	$71
CMP32	%ecx	$0
JZ	@IC144
@IC145:	
SP_STORE	%r3
INC16	%r3	$0
INC16	%r3	$45
CPY8	%r3	(%r3)
CMP8	%r3	%r0
JNZ	@IC146
@IC147:	
SP_STORE	%r3
INC16	%r3	$47
CPY8	%r3	(%r3)
AND32	%r3	$255
ADD32	%r3	%r1
CPY32	%r1	%r3
@IC146:	
JUMP	@IC143
@IC144:	
SP_STORE	%eax
INC16	%eax	$94
CPY32	(%eax)	%r1
SP_INC	$75
POP32	%r3
POP32	%r2
POP32	%r1
POP32	%r0
RTS	
.FUNC_END	"ReportID_DataLength"

ReportID_Offset:	
.GLOBAL	 DO_NOT_EXPORT  "ReportID_Offset"

.FUNCTION	"ReportID_Offset"	
PUSH32	%r0
PUSH32	%r1
PUSH32	%r2
PUSH32	%r3
SP_DEC	$75
SP_RD8	%r0	$100
SP_RD16	%r2	$98
LD32	%r1	$0
PUSH16	%r2
CALL	ResetParser
SP_INC	$2
@IC150:	
SP_STORE	%r3
INC16	%r3	$0
PUSH16	%r3
PUSH16	%r2
SP_DEC	$4
CALL	HIDParse
POP32	%eax
SP_WR32	%eax	$75
SP_INC	$4
SP_RD32	%ecx	$71
CMP32	%ecx	$0
JZ	@IC151
@IC152:	
SP_STORE	%r3
INC16	%r3	$0
INC16	%r3	$45
CPY8	%r3	(%r3)
CMP8	%r3	%r0
JLE	@IC150
@IC154:	
SP_STORE	%r3
INC16	%r3	$47
CPY8	%r3	(%r3)
AND32	%r3	$255
ADD32	%r3	%r1
CPY32	%r1	%r3
@IC153:	
JUMP	@IC150
@IC151:	
SP_STORE	%eax
INC16	%eax	$94
CPY32	(%eax)	%r1
SP_INC	$75
POP32	%r3
POP32	%r2
POP32	%r1
POP32	%r0
RTS	
.FUNC_END	"ReportID_Offset"

FindReport_max_ID:	
.GLOBAL	 DO_NOT_EXPORT  "FindReport_max_ID"

.FUNCTION	"FindReport_max_ID"	
PUSH32	%r0
PUSH32	%r1
PUSH32	%r2
SP_DEC	$75
SP_RD16	%r1	$91
LD8	%r0	$0
PUSH16	%r1
CALL	ResetParser
SP_INC	$2
@IC157:	
SP_STORE	%r2
INC16	%r2	$0
PUSH16	%r2
PUSH16	%r1
SP_DEC	$4
CALL	HIDParse
POP32	%eax
SP_WR32	%eax	$75
SP_INC	$4
SP_RD32	%ecx	$71
CMP32	%ecx	$0
JZ	@IC158
@IC159:	
SP_STORE	%r2
INC16	%r2	$0
INC16	%r2	$45
CPY8	%r2	(%r2)
CMP8	%r2	%r0
JLE	@IC157
@IC161:	
SP_STORE	%r2
INC16	%r2	$45
CPY8	%r2	(%r2)
CPY8	%r0	%r2
@IC160:	
JUMP	@IC157
@IC158:	
SP_STORE	%eax
INC16	%eax	$90
CPY8	(%eax)	%r0
SP_INC	$75
POP32	%r2
POP32	%r1
POP32	%r0
RTS	
.FUNC_END	"FindReport_max_ID"

FindMouse_XYW:	
.GLOBAL	 DO_NOT_EXPORT  "FindMouse_XYW"

.FUNCTION	"FindMouse_XYW"	
PUSH32	%r0
PUSH32	%r1
PUSH32	%r2
PUSH32	%r3
SP_DEC	$77
SP_RD16	%r1	$102
SP_RD16	%r0	$104
SP_RD16	%r2	$100
PUSH16	%r2
CALL	ResetParser
SP_INC	$2
@IC164:	
SP_STORE	%r3
INC16	%r3	$0
PUSH16	%r3
PUSH16	%r2
SP_DEC	$4
CALL	HIDParse
POP32	%eax
SP_WR32	%eax	$75
SP_INC	$4
SP_RD32	%ecx	$71
CMP32	%ecx	$0
JZ	@IC165
@IC166:	
SP_STORE	%r3
INC16	%r3	$0
INC16	%r3	$5
INC16	%r3	$2
CPY16	%r3	(%r3)
CMP16	%r3	$2
JNZ	@IC167
@IC169:	
SP_STORE	%r3
INC16	%r3	$5
INC16	%r3	$8
INC16	%r3	$2
CPY16	%r3	(%r3)
CMP16	%r3	%r0
JNZ	@IC167
@IC168:	
SP_STORE	%r3
PUSH16	$71
PUSH16	%r3
PUSH16	%r1
SP_DEC	$2
CALL	memcpy
POP16	%eax
SP_WR16	%eax	$81
SP_INC	$6
LD32	%eax	$1
SP_WR32	%eax	$96
SP_INC	$77
POP32	%r3
POP32	%r2
POP32	%r1
POP32	%r0
RTS	
@IC167:	
JUMP	@IC164
@IC165:	
LD32	%eax	$0
SP_WR32	%eax	$96
SP_INC	$77
POP32	%r3
POP32	%r2
POP32	%r1
POP32	%r0
RTS	
.FUNC_END	"FindMouse_XYW"

FindMouse_Buttons:	
.GLOBAL	 DO_NOT_EXPORT  "FindMouse_Buttons"

.FUNCTION	"FindMouse_Buttons"	
PUSH32	%r0
PUSH32	%r1
PUSH32	%r2
SP_DEC	$77
SP_RD16	%ecx	$98
SP_RD16	%r0	$96
PUSH16	%r0
CALL	ResetParser
SP_INC	$2
@IC174:	
SP_STORE	%r1
PUSH16	%r1
PUSH16	%r0
SP_DEC	$4
CALL	HIDParse
POP32	%eax
SP_WR32	%eax	$75
SP_INC	$4
SP_RD32	%ecx	$71
CMP32	%ecx	$0
JZ	@IC175
@IC176:	
SP_STORE	%r1
INC16	%r1	$0
INC16	%r1	$5
INC16	%r1	$2
CPY16	%r1	(%r1)
CMP16	%r1	$2
JNZ	@IC177
@IC179:	
SP_STORE	%r1
INC16	%r1	$5
INC16	%r1	$4
INC16	%r1	$2
CPY16	%r1	(%r1)
CMP16	%r1	$1
JNZ	@IC177
@IC178:	
SP_STORE	%r1
PUSH16	$71
PUSH16	%r1
SP_RD16	%eax	$102
PUSH16	%eax
SP_DEC	$2
CALL	memcpy
POP16	%eax
SP_WR16	%eax	$81
SP_INC	$6
SP_STORE	%r1
INC16	%r1	$98
CPY16	%r2	(%r1)
INC16	%r2	$47
LD8	(%r2)	$3
CPY16	%r2	(%r1)
INC16	%r2	$67
LD32	(%r2)	$7
CPY16	%r2	(%r1)
INC16	%r2	$63
LD32	(%r2)	$0
CPY16	%r2	(%r1)
INC16	%r2	$59
LD32	(%r2)	$7
CPY16	%r1	(%r1)
INC16	%r1	$55
LD32	(%r1)	$0
LD32	%eax	$1
SP_WR32	%eax	$92
SP_INC	$77
POP32	%r2
POP32	%r1
POP32	%r0
RTS	
@IC177:	
JUMP	@IC174
@IC175:	
LD32	%eax	$0
SP_WR32	%eax	$92
SP_INC	$77
POP32	%r2
POP32	%r1
POP32	%r0
RTS	
.FUNC_END	"FindMouse_Buttons"

