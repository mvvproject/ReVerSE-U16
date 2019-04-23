.DATA

.WEAK	"%eax"
.WEAK	"%ebx"
.WEAK	"%ecx"
.WEAK	"%r0"
.WEAK	"%r1"
.WEAK	"%r2"
.WEAK	"%r3"
GPIO_Lock	.DB	6	?
.GLOBAL	  DO_NOT_EXPORT "GPIO_Lock"
port_data	.DB	1	?
.GLOBAL	  DO_NOT_EXPORT "port_data"
port_mode	.DB	1	?
.GLOBAL	  DO_NOT_EXPORT "port_mode"




.TEXT


.WEAK	"vos_dma_get_fifo_flow_control"

.WEAK	"vos_start_scheduler"

.WEAK	"vos_gpio_write_port"

.WEAK	"vos_signal_semaphore_from_isr"

.WEAK	"vos_malloc"

.WEAK	"vos_create_thread_ex"

.WEAK	"vos_memcpy"

.WEAK	"vos_memset"

.WEAK	"vos_get_kernel_clock"

.WEAK	"vos_gpio_disable_int"

.WEAK	"vos_get_package_type"

.WEAK	"vos_dma_get_fifo_data_register"

.WEAK	"vos_signal_semaphore"

.WEAK	"vos_gpio_wait_on_int"

.WEAK	"vos_dma_get_fifo_data"

.WEAK	"vos_iocell_get_config"

.WEAK	"vos_iomux_define_bidi"

.WEAK	"vos_gpio_set_all_mode"

.WEAK	"vos_iocell_set_config"

.WEAK	"vos_gpio_set_pin_mode"

.WEAK	"vos_get_chip_revision"

.WEAK	"vos_wait_semaphore_ex"

.WEAK	"vos_enable_interrupts"

.WEAK	"vos_dev_read"

.WEAK	"vos_dev_open"

.WEAK	"vos_halt_cpu"

.WEAK	"vos_dev_init"

.WEAK	"vos_dma_get_fifo_count"

.WEAK	"vos_reset_kernel_clock"

.WEAK	"vos_gpio_set_port_mode"

.WEAK	"vos_iomux_define_input"

.WEAK	"vos_disable_interrupts"

.WEAK	"vos_get_idle_thread_tcb"

.WEAK	"vos_dma_reset"

.WEAK	"vos_dev_close"

.WEAK	"vos_wdt_clear"

.WEAK	"vos_heap_size"

.WEAK	"vos_dev_ioctl"

.WEAK	"vos_dev_write"

.WEAK	"vos_get_clock_frequency"

.WEAK	"vos_set_clock_frequency"

.WEAK	"vos_dma_enable"

.WEAK	"vos_reset_vnc2"

.WEAK	"vos_heap_space"

.WEAK	"vos_iomux_define_output"

.WEAK	"vos_wdt_enable"

.WEAK	"vos_dma_wait_on_complete"

.WEAK	"vos_lock_mutex"

.WEAK	"vos_power_down"

.WEAK	"vos_init_mutex"

.WEAK	"vos_gpio_wait_on_any_int"

.WEAK	"vos_get_priority_ceiling"

.WEAK	"vos_dma_disable"

.WEAK	"vos_set_priority_ceiling"

.WEAK	"vos_dma_release"

.WEAK	"vos_iomux_disable_output"

.WEAK	"vos_dma_acquire"

.WEAK	"vos_delay_msecs"

.WEAK	"vos_stack_usage"

.WEAK	"vos_get_profile"

.WEAK	"vos_gpio_wait_on_all_ints"

.WEAK	"vos_delay_cancel"

.WEAK	"vos_dma_retained_configure"

.WEAK	"vos_unlock_mutex"

.WEAK	"vos_gpio_read_all"

.WEAK	"vos_create_thread"

.WEAK	"vos_gpio_read_pin"

.WEAK	"vos_dma_configure"

.WEAK	"vos_init_cond_var"

.WEAK	"vos_wait_cond_var"

.WEAK	"vos_stop_profiler"

.WEAK	"vos_trylock_mutex"

.WEAK	"vos_free"

.WEAK	"vos_init"

.WEAK	"vos_gpio_read_port"

.WEAK	"vos_gpio_write_all"

.WEAK	"vos_set_idle_thread_tcb_size"

.WEAK	"vos_init_semaphore"

.WEAK	"vos_wait_semaphore"

.WEAK	"vos_gpio_write_pin"

.WEAK	"vos_start_profiler"

.WEAK	"vos_gpio_enable_int"

.WEAK	"vos_signal_cond_var"

PS2dev_init:	
.GLOBAL	 DO_NOT_EXPORT  "PS2dev_init"

.FUNCTION	"PS2dev_init"	
PUSH32	%r0
SP_DEC	$2
LD8	port_mode	$4
LD8	port_data	$0
PUSH8	port_data
PUSH8	$0
SP_DEC	$1
CALL	vos_gpio_write_port
POP8	%eax
SP_WR8	%eax	$2
SP_INC	$2
PUSH8	port_mode
PUSH8	$0
SP_DEC	$1
CALL	vos_gpio_set_port_mode
POP8	%eax
SP_WR8	%eax	$3
SP_INC	$2
LD16	%r0	$GPIO_Lock
PUSH8	$1
PUSH16	%r0
CALL	vos_init_mutex
SP_INC	$3
SP_INC	$2
POP32	%r0
RTS	
.FUNC_END	"PS2dev_init"

PS2dev_unlock:	
.GLOBAL	 DO_NOT_EXPORT  "PS2dev_unlock"

.FUNCTION	"PS2dev_unlock"	
PUSH32	%r0
LD16	%r0	$GPIO_Lock
PUSH16	%r0
CALL	vos_unlock_mutex
SP_INC	$2
POP32	%r0
RTS	
.FUNC_END	"PS2dev_unlock"

LED_ON:	
.GLOBAL	 DO_NOT_EXPORT  "LED_ON"

.FUNCTION	"LED_ON"	
PUSH32	%r0
PUSH32	%r1
SP_DEC	$1
LD16	%r0	$GPIO_Lock
PUSH16	%r0
CALL	vos_lock_mutex
SP_INC	$2
CPY8	%eax	port_data
SHL32	%eax	$24
SAR32	%eax	$24
LD32	%r1	$4
OR32	%r1	%eax
CPY8	port_data	%r1
PUSH8	port_data
PUSH8	$0
SP_DEC	$1
CALL	vos_gpio_write_port
POP8	%eax
SP_WR8	%eax	$2
SP_INC	$2
PUSH16	%r0
CALL	vos_unlock_mutex
SP_INC	$2
SP_INC	$1
POP32	%r1
POP32	%r0
RTS	
.FUNC_END	"LED_ON"

LED_OFF:	
.GLOBAL	 DO_NOT_EXPORT  "LED_OFF"

.FUNCTION	"LED_OFF"	
PUSH32	%r0
PUSH32	%r1
SP_DEC	$1
LD16	%r0	$GPIO_Lock
PUSH16	%r0
CALL	vos_lock_mutex
SP_INC	$2
CPY8	%eax	port_data
SHL32	%eax	$24
SAR32	%eax	$24
LD32	%r1	$-5
AND32	%r1	%eax
CPY8	port_data	%r1
PUSH8	port_data
PUSH8	$0
SP_DEC	$1
CALL	vos_gpio_write_port
POP8	%eax
SP_WR8	%eax	$2
SP_INC	$2
PUSH16	%r0
CALL	vos_unlock_mutex
SP_INC	$2
SP_INC	$1
POP32	%r1
POP32	%r0
RTS	
.FUNC_END	"LED_OFF"

delayMicroseconds:	
.GLOBAL	 DO_NOT_EXPORT  "delayMicroseconds"

.FUNCTION	"delayMicroseconds"	
RTS	
.FUNC_END	"delayMicroseconds"

golo:	
.GLOBAL	 DO_NOT_EXPORT  "golo"

.FUNCTION	"golo"	
PUSH32	%r0
PUSH32	%r1
SP_DEC	$1
SP_RD32	%r1	$12
LD16	%r0	$GPIO_Lock
PUSH16	%r0
CALL	vos_lock_mutex
SP_INC	$2
LD32	%eax	$1
SHL32	%r1	%eax	%r1
CPY8	%eax	port_mode
SHL32	%eax	$24
SAR32	%eax	$24
OR32	%r1	%eax
CPY8	port_mode	%r1
PUSH8	port_mode
PUSH8	$0
SP_DEC	$1
CALL	vos_gpio_set_port_mode
POP8	%eax
SP_WR8	%eax	$2
SP_INC	$2
PUSH16	%r0
CALL	vos_unlock_mutex
SP_INC	$2
SP_INC	$1
POP32	%r1
POP32	%r0
RTS	
.FUNC_END	"golo"

gohi:	
.GLOBAL	 DO_NOT_EXPORT  "gohi"

.FUNCTION	"gohi"	
PUSH32	%r0
PUSH32	%r1
SP_DEC	$1
SP_RD32	%r1	$12
LD16	%r0	$GPIO_Lock
PUSH16	%r0
CALL	vos_lock_mutex
SP_INC	$2
LD32	%eax	$1
SHL32	%r1	%eax	%r1
INV32	%r1	%r1
CPY8	%eax	port_mode
SHL32	%eax	$24
SAR32	%eax	$24
AND32	%r1	%eax
CPY8	port_mode	%r1
PUSH8	port_mode
PUSH8	$0
SP_DEC	$1
CALL	vos_gpio_set_port_mode
POP8	%eax
SP_WR8	%eax	$2
SP_INC	$2
PUSH16	%r0
CALL	vos_unlock_mutex
SP_INC	$2
SP_INC	$1
POP32	%r1
POP32	%r0
RTS	
.FUNC_END	"gohi"

digitalRead:	
.GLOBAL	 DO_NOT_EXPORT  "digitalRead"

.FUNCTION	"digitalRead"	
PUSH32	%r0
PUSH32	%r1
PUSH32	%r2
SP_DEC	$2
SP_RD32	%r2	$18
LD16	%r0	$GPIO_Lock
PUSH16	%r0
CALL	vos_lock_mutex
SP_INC	$2
SP_STORE	%r1
PUSH16	%r1
PUSH8	$0
SP_DEC	$1
CALL	vos_gpio_read_port
POP8	%eax
SP_WR8	%eax	$4
SP_INC	$3
PUSH16	%r0
CALL	vos_unlock_mutex
SP_INC	$2
SP_RD8	%eax	$0
SHL32	%eax	$24
SAR32	%eax	$24
SAR32	%r0	%eax	%r2
AND32	%r0	$1
CPY8	%r0	%r0
SP_STORE	%eax
INC16	%eax	$17
CPY8	(%eax)	%r0
SP_INC	$2
POP32	%r2
POP32	%r1
POP32	%r0
RTS	
.FUNC_END	"digitalRead"

PS2dev_host_req:	
.GLOBAL	 DO_NOT_EXPORT  "PS2dev_host_req"

.FUNCTION	"PS2dev_host_req"	
SP_DEC	$2
PUSH32	$4
SP_DEC	$1
CALL	digitalRead
POP8	%eax
SP_WR8	%eax	$4
SP_INC	$4
SP_RD8	%ecx	$0
CMP8	%ecx	$0
JZ	@IC3
JNZ	@IC4
@IC4:	
PUSH32	$5
SP_DEC	$1
CALL	digitalRead
POP8	%eax
SP_WR8	%eax	$5
SP_INC	$4
SP_RD8	%ecx	$1
CMP8	%ecx	$0
JNZ	@IC2
@IC3:	
LD8	%eax	$1
SP_WR8	%eax	$5
SP_INC	$2
RTS	
JUMP	@IC1
@IC2:	
LD8	%eax	$0
SP_WR8	%eax	$5
SP_INC	$2
RTS	
@IC1:	
SP_INC	$2
RTS	
.FUNC_END	"PS2dev_host_req"

PS2dev_write:	
.GLOBAL	 DO_NOT_EXPORT  "PS2dev_write"

.FUNCTION	"PS2dev_write"	
PUSH32	%r0
PUSH32	%r1
PUSH32	%r2
PUSH32	%r3
SP_DEC	$6
SP_RD8	%r1	$26
LD8	%r0	$1
PUSH32	$4
SP_DEC	$1
CALL	digitalRead
POP8	%eax
SP_WR8	%eax	$4
SP_INC	$4
SP_RD8	%ecx	$0
CMP8	%ecx	$0
JNZ	@IC9
@IC10:	
LD8	%eax	$-1
SP_WR8	%eax	$25
SP_INC	$6
POP32	%r3
POP32	%r2
POP32	%r1
POP32	%r0
RTS	
@IC9:	
PUSH32	$5
SP_DEC	$1
CALL	digitalRead
POP8	%eax
SP_WR8	%eax	$5
SP_INC	$4
SP_RD8	%ecx	$1
CMP8	%ecx	$0
JNZ	@IC13
@IC14:	
LD8	%eax	$-2
SP_WR8	%eax	$25
SP_INC	$6
POP32	%r3
POP32	%r2
POP32	%r1
POP32	%r0
RTS	
@IC13:	
PUSH32	$5
CALL	golo
SP_INC	$4
PUSH32	$20
CALL	delayMicroseconds
SP_INC	$4
PUSH32	$4
SP_DEC	$1
CALL	digitalRead
POP8	%eax
SP_WR8	%eax	$6
SP_INC	$4
SP_RD8	%ecx	$2
CMP8	%ecx	$0
JNZ	@IC17
@IC18:	
@IC17:	
PUSH32	$4
CALL	golo
SP_INC	$4
PUSH32	$40
CALL	delayMicroseconds
SP_INC	$4
PUSH32	$4
CALL	gohi
SP_INC	$4
PUSH32	$20
CALL	delayMicroseconds
SP_INC	$4
LD8	%r2	$0
@IC21:	
CMP8	%r2	$8
JGE	@IC22
@IC23:	
CPY8	%eax	%r1
AND32	%eax	$255
LD32	%r3	$1
AND32	%r3	%eax
CMP32	%r3	$0
JZ	@IC28
@IC29:	
PUSH32	$5
CALL	gohi
SP_INC	$4
JUMP	@IC27
@IC28:	
PUSH32	$5
CALL	golo
SP_INC	$4
@IC27:	
PUSH32	$20
CALL	delayMicroseconds
SP_INC	$4
PUSH32	$4
SP_DEC	$1
CALL	digitalRead
POP8	%eax
SP_WR8	%eax	$7
SP_INC	$4
SP_RD8	%ecx	$3
CMP8	%ecx	$0
JNZ	@IC30
@IC31:	
@IC30:	
PUSH32	$4
CALL	golo
SP_INC	$4
PUSH32	$40
CALL	delayMicroseconds
SP_INC	$4
PUSH32	$4
CALL	gohi
SP_INC	$4
PUSH32	$20
CALL	delayMicroseconds
SP_INC	$4
CPY8	%eax	%r1
AND32	%eax	$255
LD32	%r3	$1
AND32	%r3	%eax
CPY8	%eax	%r0
AND32	%eax	$255
XOR32	%r3	%eax	%r3
CPY8	%r0	%r3
CPY8	%eax	%r1
AND32	%eax	$255
LD32	%ebx	$1
SHR32	%r3	%eax	%ebx
CPY8	%r1	%r3
@IC24:	
INC8	%r2	$1
JUMP	@IC21
@IC22:	
CMP8	%r0	$0
JZ	@IC35
@IC36:	
PUSH32	$5
CALL	gohi
SP_INC	$4
JUMP	@IC34
@IC35:	
PUSH32	$5
CALL	golo
SP_INC	$4
@IC34:	
PUSH32	$20
CALL	delayMicroseconds
SP_INC	$4
PUSH32	$4
SP_DEC	$1
CALL	digitalRead
POP8	%eax
SP_WR8	%eax	$8
SP_INC	$4
SP_RD8	%ecx	$4
CMP8	%ecx	$0
JNZ	@IC37
@IC38:	
@IC37:	
PUSH32	$4
CALL	golo
SP_INC	$4
PUSH32	$40
CALL	delayMicroseconds
SP_INC	$4
PUSH32	$4
CALL	gohi
SP_INC	$4
PUSH32	$20
CALL	delayMicroseconds
SP_INC	$4
PUSH32	$5
CALL	gohi
SP_INC	$4
PUSH32	$20
CALL	delayMicroseconds
SP_INC	$4
PUSH32	$4
SP_DEC	$1
CALL	digitalRead
POP8	%eax
SP_WR8	%eax	$9
SP_INC	$4
SP_RD8	%ecx	$5
CMP8	%ecx	$0
JNZ	@IC41
@IC42:	
@IC41:	
PUSH32	$4
CALL	golo
SP_INC	$4
PUSH32	$40
CALL	delayMicroseconds
SP_INC	$4
PUSH32	$4
CALL	gohi
SP_INC	$4
PUSH32	$20
CALL	delayMicroseconds
SP_INC	$4
PUSH32	$100
CALL	delayMicroseconds
SP_INC	$4
LD8	%eax	$0
SP_WR8	%eax	$25
SP_INC	$6
POP32	%r3
POP32	%r2
POP32	%r1
POP32	%r0
RTS	
.FUNC_END	"PS2dev_write"

PS2dev_write_c:	
.GLOBAL	 DO_NOT_EXPORT  "PS2dev_write_c"

.FUNCTION	"PS2dev_write_c"	
PUSH32	%r0
PUSH32	%r1
PUSH32	%r2
PUSH32	%r3
SP_DEC	$6
SP_RD8	%r1	$26
LD8	%r0	$1
PUSH32	$4
SP_DEC	$1
CALL	digitalRead
POP8	%eax
SP_WR8	%eax	$4
SP_INC	$4
SP_RD8	%ecx	$0
CMP8	%ecx	$0
JNZ	@IC45
@IC46:	
LD8	%eax	$-1
SP_WR8	%eax	$25
SP_INC	$6
POP32	%r3
POP32	%r2
POP32	%r1
POP32	%r0
RTS	
@IC45:	
PUSH32	$5
SP_DEC	$1
CALL	digitalRead
POP8	%eax
SP_WR8	%eax	$5
SP_INC	$4
SP_RD8	%ecx	$1
CMP8	%ecx	$0
JNZ	@IC49
@IC50:	
LD8	%eax	$-2
SP_WR8	%eax	$25
SP_INC	$6
POP32	%r3
POP32	%r2
POP32	%r1
POP32	%r0
RTS	
@IC49:	
PUSH32	$5
CALL	golo
SP_INC	$4
PUSH32	$20
CALL	delayMicroseconds
SP_INC	$4
PUSH32	$4
SP_DEC	$1
CALL	digitalRead
POP8	%eax
SP_WR8	%eax	$6
SP_INC	$4
SP_RD8	%ecx	$2
CMP8	%ecx	$0
JNZ	@IC53
@IC54:	
LD8	%eax	$-1
SP_WR8	%eax	$25
SP_INC	$6
POP32	%r3
POP32	%r2
POP32	%r1
POP32	%r0
RTS	
@IC53:	
PUSH32	$4
CALL	golo
SP_INC	$4
PUSH32	$40
CALL	delayMicroseconds
SP_INC	$4
PUSH32	$4
CALL	gohi
SP_INC	$4
PUSH32	$20
CALL	delayMicroseconds
SP_INC	$4
LD8	%r2	$0
@IC57:	
CMP8	%r2	$8
JGE	@IC58
@IC59:	
CPY8	%eax	%r1
AND32	%eax	$255
LD32	%r3	$1
AND32	%r3	%eax
CMP32	%r3	$0
JZ	@IC64
@IC65:	
PUSH32	$5
CALL	gohi
SP_INC	$4
JUMP	@IC63
@IC64:	
PUSH32	$5
CALL	golo
SP_INC	$4
@IC63:	
PUSH32	$20
CALL	delayMicroseconds
SP_INC	$4
PUSH32	$4
SP_DEC	$1
CALL	digitalRead
POP8	%eax
SP_WR8	%eax	$7
SP_INC	$4
SP_RD8	%ecx	$3
CMP8	%ecx	$0
JNZ	@IC66
@IC67:	
LD8	%eax	$-1
SP_WR8	%eax	$25
SP_INC	$6
POP32	%r3
POP32	%r2
POP32	%r1
POP32	%r0
RTS	
@IC66:	
PUSH32	$4
CALL	golo
SP_INC	$4
PUSH32	$40
CALL	delayMicroseconds
SP_INC	$4
PUSH32	$4
CALL	gohi
SP_INC	$4
PUSH32	$20
CALL	delayMicroseconds
SP_INC	$4
CPY8	%eax	%r1
AND32	%eax	$255
LD32	%r3	$1
AND32	%r3	%eax
CPY8	%eax	%r0
AND32	%eax	$255
XOR32	%r3	%eax
CPY8	%r0	%r3
CPY8	%eax	%r1
AND32	%eax	$255
LD32	%ebx	$1
SHR32	%r3	%eax	%ebx
CPY8	%r1	%r3
@IC60:	
INC8	%r2	$1
JUMP	@IC57
@IC58:	
CMP8	%r0	$0
JZ	@IC71
@IC72:	
PUSH32	$5
CALL	gohi
SP_INC	$4
JUMP	@IC70
@IC71:	
PUSH32	$5
CALL	golo
SP_INC	$4
@IC70:	
PUSH32	$20
CALL	delayMicroseconds
SP_INC	$4
PUSH32	$4
SP_DEC	$1
CALL	digitalRead
POP8	%eax
SP_WR8	%eax	$8
SP_INC	$4
SP_RD8	%ecx	$4
CMP8	%ecx	$0
JNZ	@IC73
@IC74:	
LD8	%eax	$-1
SP_WR8	%eax	$25
SP_INC	$6
POP32	%r3
POP32	%r2
POP32	%r1
POP32	%r0
RTS	
@IC73:	
PUSH32	$4
CALL	golo
SP_INC	$4
PUSH32	$40
CALL	delayMicroseconds
SP_INC	$4
PUSH32	$4
CALL	gohi
SP_INC	$4
PUSH32	$20
CALL	delayMicroseconds
SP_INC	$4
PUSH32	$5
CALL	gohi
SP_INC	$4
PUSH32	$20
CALL	delayMicroseconds
SP_INC	$4
PUSH32	$4
SP_DEC	$1
CALL	digitalRead
POP8	%eax
SP_WR8	%eax	$9
SP_INC	$4
SP_RD8	%ecx	$5
CMP8	%ecx	$0
JNZ	@IC77
@IC78:	
LD8	%eax	$-1
SP_WR8	%eax	$25
SP_INC	$6
POP32	%r3
POP32	%r2
POP32	%r1
POP32	%r0
RTS	
@IC77:	
PUSH32	$4
CALL	golo
SP_INC	$4
PUSH32	$40
CALL	delayMicroseconds
SP_INC	$4
PUSH32	$4
CALL	gohi
SP_INC	$4
PUSH32	$20
CALL	delayMicroseconds
SP_INC	$4
PUSH32	$100
CALL	delayMicroseconds
SP_INC	$4
LD8	%eax	$0
SP_WR8	%eax	$25
SP_INC	$6
POP32	%r3
POP32	%r2
POP32	%r1
POP32	%r0
RTS	
.FUNC_END	"PS2dev_write_c"

PS2dev_read:	
.GLOBAL	 DO_NOT_EXPORT  "PS2dev_read"

.FUNCTION	"PS2dev_read"	
PUSH32	%r0
PUSH32	%r1
PUSH32	%r2
PUSH32	%r3
SP_DEC	$4
LD8	%r3	$0
LD8	%r0	$1
@IC81:	
PUSH32	$5
SP_DEC	$1
CALL	digitalRead
POP8	%eax
SP_WR8	%eax	$4
SP_INC	$4
SP_RD8	%ecx	$0
CMP8	%ecx	$1
JNZ	@IC82
@IC83:	
PUSH32	$4
SP_DEC	$1
CALL	digitalRead
POP8	%eax
SP_WR8	%eax	$5
SP_INC	$4
SP_RD8	%ecx	$1
CMP8	%ecx	$1
JNZ	@IC86
@IC87:	
SP_RD16	%ecx	$24
LD8	(%ecx)	$0
LD8	%eax	$0
SP_WR8	%eax	$23
SP_INC	$4
POP32	%r3
POP32	%r2
POP32	%r1
POP32	%r0
RTS	
@IC86:	
JUMP	@IC81
@IC82:	
@IC90:	
PUSH32	$4
SP_DEC	$1
CALL	digitalRead
POP8	%eax
SP_WR8	%eax	$6
SP_INC	$4
SP_RD8	%ecx	$2
CMP8	%ecx	$0
JNZ	@IC91
@IC92:	
JUMP	@IC90
@IC91:	
PUSH32	$20
CALL	delayMicroseconds
SP_INC	$4
PUSH32	$4
CALL	golo
SP_INC	$4
PUSH32	$40
CALL	delayMicroseconds
SP_INC	$4
PUSH32	$4
CALL	gohi
SP_INC	$4
PUSH32	$20
CALL	delayMicroseconds
SP_INC	$4
LD8	%r1	$0
@IC95:	
CMP8	%r1	$8
JGE	@IC96
@IC97:	
PUSH32	$5
SP_DEC	$1
CALL	digitalRead
POP8	%eax
SP_WR8	%eax	$7
SP_INC	$4
SP_RD8	%ecx	$3
CMP8	%ecx	$1
JNZ	@IC102
@IC103:	
CPY8	%eax	%r3
CPY8	%ebx	%r0
AND32	%eax	$255
AND32	%ebx	$255
OR32	%r2	%eax	%ebx
CPY8	%r3	%r2
JUMP	@IC101
@IC102:	
@IC101:	
CPY8	%eax	%r0
AND32	%eax	$255
LD32	%ebx	$1
SHL32	%r2	%eax	%ebx
CPY8	%r0	%r2
PUSH32	$20
CALL	delayMicroseconds
SP_INC	$4
PUSH32	$4
CALL	golo
SP_INC	$4
PUSH32	$40
CALL	delayMicroseconds
SP_INC	$4
PUSH32	$4
CALL	gohi
SP_INC	$4
PUSH32	$20
CALL	delayMicroseconds
SP_INC	$4
@IC98:	
INC8	%r1	$1
JUMP	@IC95
@IC96:	
PUSH32	$20
CALL	delayMicroseconds
SP_INC	$4
PUSH32	$4
CALL	golo
SP_INC	$4
PUSH32	$40
CALL	delayMicroseconds
SP_INC	$4
PUSH32	$4
CALL	gohi
SP_INC	$4
PUSH32	$20
CALL	delayMicroseconds
SP_INC	$4
PUSH32	$20
CALL	delayMicroseconds
SP_INC	$4
PUSH32	$5
CALL	golo
SP_INC	$4
PUSH32	$4
CALL	golo
SP_INC	$4
PUSH32	$40
CALL	delayMicroseconds
SP_INC	$4
PUSH32	$4
CALL	gohi
SP_INC	$4
PUSH32	$20
CALL	delayMicroseconds
SP_INC	$4
PUSH32	$5
CALL	gohi
SP_INC	$4
PUSH32	$100
CALL	delayMicroseconds
SP_INC	$4
SP_RD16	%ecx	$24
CPY8	(%ecx)	%r3
LD8	%eax	$0
SP_WR8	%eax	$23
SP_INC	$4
POP32	%r3
POP32	%r2
POP32	%r1
POP32	%r0
RTS	
.FUNC_END	"PS2dev_read"

PS2KB_write:	
.GLOBAL	 DO_NOT_EXPORT  "PS2KB_write"

.FUNCTION	"PS2KB_write"	
PUSH32	%r0
PUSH32	%r1
PUSH32	%r2
PUSH32	%r3
SP_DEC	$2
SP_RD8	%r1	$22
LD8	%r0	$1
PUSH32	$6
SP_DEC	$1
CALL	digitalRead
POP8	%eax
SP_WR8	%eax	$4
SP_INC	$4
SP_RD8	%ecx	$0
CMP8	%ecx	$0
JNZ	@IC106
@IC107:	
LD8	%eax	$-1
SP_WR8	%eax	$21
SP_INC	$2
POP32	%r3
POP32	%r2
POP32	%r1
POP32	%r0
RTS	
@IC106:	
PUSH32	$7
SP_DEC	$1
CALL	digitalRead
POP8	%eax
SP_WR8	%eax	$5
SP_INC	$4
SP_RD8	%ecx	$1
CMP8	%ecx	$0
JNZ	@IC110
@IC111:	
LD8	%eax	$-2
SP_WR8	%eax	$21
SP_INC	$2
POP32	%r3
POP32	%r2
POP32	%r1
POP32	%r0
RTS	
@IC110:	
PUSH32	$7
CALL	golo
SP_INC	$4
PUSH32	$20
CALL	delayMicroseconds
SP_INC	$4
PUSH32	$6
CALL	golo
SP_INC	$4
PUSH32	$40
CALL	delayMicroseconds
SP_INC	$4
PUSH32	$6
CALL	gohi
SP_INC	$4
LD8	%r2	$0
@IC114:	
CMP8	%r2	$8
JGE	@IC115
@IC116:	
CPY8	%eax	%r1
AND32	%eax	$255
LD32	%r3	$1
AND32	%r3	%eax
CMP32	%r3	$0
JZ	@IC121
@IC122:	
PUSH32	$7
CALL	gohi
SP_INC	$4
JUMP	@IC120
@IC121:	
PUSH32	$7
CALL	golo
SP_INC	$4
@IC120:	
PUSH32	$6
CALL	golo
SP_INC	$4
PUSH32	$40
CALL	delayMicroseconds
SP_INC	$4
PUSH32	$6
CALL	gohi
SP_INC	$4
CPY8	%eax	%r1
AND32	%eax	$255
LD32	%r3	$1
AND32	%r3	%eax
CPY8	%eax	%r0
AND32	%eax	$255
XOR32	%r3	%eax
CPY8	%r0	%r3
CPY8	%eax	%r1
AND32	%eax	$255
LD32	%ebx	$1
SHR32	%r3	%eax	%ebx
CPY8	%r1	%r3
@IC117:	
INC8	%r2	$1
JUMP	@IC114
@IC115:	
CMP8	%r0	$0
JZ	@IC124
@IC125:	
PUSH32	$7
CALL	gohi
SP_INC	$4
JUMP	@IC123
@IC124:	
PUSH32	$7
CALL	golo
SP_INC	$4
@IC123:	
PUSH32	$20
CALL	delayMicroseconds
SP_INC	$4
PUSH32	$6
CALL	golo
SP_INC	$4
PUSH32	$40
CALL	delayMicroseconds
SP_INC	$4
PUSH32	$6
CALL	gohi
SP_INC	$4
PUSH32	$20
CALL	delayMicroseconds
SP_INC	$4
PUSH32	$7
CALL	gohi
SP_INC	$4
PUSH32	$20
CALL	delayMicroseconds
SP_INC	$4
PUSH32	$6
CALL	golo
SP_INC	$4
PUSH32	$40
CALL	delayMicroseconds
SP_INC	$4
PUSH32	$6
CALL	gohi
SP_INC	$4
PUSH32	$20
CALL	delayMicroseconds
SP_INC	$4
PUSH32	$100
CALL	delayMicroseconds
SP_INC	$4
LD8	%eax	$0
SP_WR8	%eax	$21
SP_INC	$2
POP32	%r3
POP32	%r2
POP32	%r1
POP32	%r0
RTS	
.FUNC_END	"PS2KB_write"

