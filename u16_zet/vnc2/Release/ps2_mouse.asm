.DATA

.WEAK	"%eax"
.WEAK	"%ebx"
.WEAK	"%ecx"
.WEAK	"%r0"
.WEAK	"%r1"
.WEAK	"%r2"
.WEAK	"%r3"




.TEXT


.WEAK	"vos_dma_get_fifo_flow_control"

.WEAK	"vos_start_scheduler"

.WEAK	"PS2dev_read"

.WEAK	"vos_gpio_write_port"

.WEAK	"vos_signal_semaphore_from_isr"

.WEAK	"PS2dev_init"

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

.WEAK	"PS2dev_write"

.WEAK	"vos_iocell_get_config"

.WEAK	"vos_iomux_define_bidi"

.WEAK	"vos_gpio_set_all_mode"

.WEAK	"vos_iocell_set_config"

.WEAK	"vos_gpio_set_pin_mode"

.WEAK	"vos_get_chip_revision"

.WEAK	"vos_wait_semaphore_ex"

.WEAK	"vos_enable_interrupts"

.WEAK	"vos_dev_read"

.WEAK	"PS2dev_unlock"

.WEAK	"vos_dev_open"

.WEAK	"vos_halt_cpu"

.WEAK	"vos_dev_init"

.WEAK	"vos_dma_get_fifo_count"

.WEAK	"vos_reset_kernel_clock"

.WEAK	"vos_gpio_set_port_mode"

.WEAK	"vos_iomux_define_input"

.WEAK	"vos_disable_interrupts"

.WEAK	"PS2dev_write_c"

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

.WEAK	"LED_ON"

.WEAK	"PS2dev_host_req"

.WEAK	"vos_dma_wait_on_complete"

.WEAK	"vos_lock_mutex"

.WEAK	"vos_power_down"

.WEAK	"vos_init_mutex"

.WEAK	"vos_gpio_wait_on_any_int"

.WEAK	"LED_OFF"

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

.WEAK	"PS2KB_write"

PS2_mouse_init:	
.GLOBAL	 DO_NOT_EXPORT  "PS2_mouse_init"

.FUNCTION	"PS2_mouse_init"	
PUSH32	%r0
PUSH32	%r1
SP_STORE	%r0
INC16	%r0	$11
CPY16	%r1	(%r0)
CPY16	%r1	%r1
LD8	(%r1)	$0
CPY16	%r1	(%r0)
INC16	%r1	$2
LD8	(%r1)	$0
CPY16	%r1	(%r0)
INC16	%r1	$3
LD16	(%r1)	$0
CPY16	%r1	(%r0)
INC16	%r1	$5
LD16	(%r1)	$0
CPY16	%r1	(%r0)
INC16	%r1	$7
LD16	(%r1)	$0
CPY16	%r1	(%r0)
INC16	%r1	$9
LD8	(%r1)	$1
CPY16	%r1	(%r0)
INC16	%r1	$10
LD8	(%r1)	$0
CPY16	%r1	(%r0)
INC16	%r1	$1
LD8	(%r1)	$0
CPY16	%r1	(%r0)
INC16	%r1	$11
LD8	(%r1)	$0
CPY16	%r0	(%r0)
INC16	%r0	$12
LD8	(%r0)	$20
POP32	%r1
POP32	%r0
RTS	
.FUNC_END	"PS2_mouse_init"

ack:	
.GLOBAL	 DO_NOT_EXPORT  "ack"

.FUNCTION	"ack"	
SP_DEC	$1
@IC1:	
PUSH8	$250
SP_DEC	$1
CALL	PS2dev_write
POP8	%eax
SP_WR8	%eax	$1
SP_INC	$1
SP_RD8	%ecx	$0
CMP8	%ecx	$0
JZ	@IC2
@IC3:	
JUMP	@IC1
@IC2:	
SP_INC	$1
RTS	
.FUNC_END	"ack"

MS_wr_packet:	
.GLOBAL	 DO_NOT_EXPORT  "MS_wr_packet"

.FUNCTION	"MS_wr_packet"	
PUSH32	%r0
PUSH32	%r1
PUSH32	%r2
PUSH32	%r3
SP_DEC	$8
SP_STORE	%r0
INC16	%r0	$28
CPY16	%r1	(%r0)
INC16	%r1	$5
CPY16	%r2	(%r0)
INC16	%r2	$5
CPY16	%r2	(%r2)
INV16	%r2	%r2
CPY16	(%r1)	%r2
CPY16	%r1	(%r0)
INC16	%r1	$5
CPY16	%r1	(%r1)
INC16	%r1	$1
CPY16	%r2	(%r0)
INC16	%r2	$5
CPY16	(%r2)	%r1
SP_STORE	%r1
INC16	%r1	$0
SP_STORE	%ecx
INC16	%ecx	$3
LD16	%ebx	$0
ADD16	(%ecx)	%r1	%ebx
CPY16	%r2	(%r0)
INC16	%r2	$5
CPY16	%r2	(%r2)
CPY16	%eax	%r2
AND32	%eax	$65535
LD32	%r2	$256
AND32	%r2	%eax
LD32	%ebx	$8
SAR32	%r2	%r2	%ebx
AND32	%r2	$1
LD32	%ebx	$5
SHL32	%r2	%ebx
LD32	%eax	$0
OR32	%r2	%eax
CPY16	%r3	(%r0)
INC16	%r3	$3
CPY16	%r3	(%r3)
CPY16	%eax	%r3
AND32	%eax	$65535
LD32	%r3	$256
AND32	%r3	%eax
LD32	%ebx	$8
SAR32	%r3	%r3	%ebx
AND32	%r3	$1
LD32	%ebx	$4
SHL32	%r3	%ebx
OR32	%r2	%r3
LD32	%ebx	$8
OR32	%r2	%ebx
CPY16	%r3	(%r0)
INC16	%r3	$2
CPY8	%r3	(%r3)
CPY8	%eax	%r3
AND32	%eax	$255
LD32	%ebx	$2
SHR32	%r3	%eax	%ebx
AND32	%r3	$1
LD32	%ebx	$2
SHL32	%r3	%ebx
OR32	%r2	%r3
CPY16	%r3	(%r0)
INC16	%r3	$2
CPY8	%r3	(%r3)
CPY8	%eax	%r3
AND32	%eax	$255
LD32	%ebx	$1
SHR32	%r3	%eax	%ebx
AND32	%r3	$1
LD32	%ebx	$1
SHL32	%r3	%ebx
OR32	%r2	%r3
CPY16	%r3	(%r0)
INC16	%r3	$2
CPY8	%r3	(%r3)
CPY8	%eax	%r3
AND32	%eax	$255
CPY32	%r3	%eax
AND32	%r3	$1
OR32	%r2	%r3
SP_RD16	%ecx	$3
CPY8	(%ecx)	%r2
LD16	%r2	$1
ADD16	%r2	%r1
CPY16	%r3	(%r0)
INC16	%r3	$3
CPY16	%r3	(%r3)
CPY16	%eax	%r3
AND32	%eax	$65535
LD32	%r3	$255
AND32	%r3	%eax
CPY8	(%r2)	%r3
INC16	%r1	$2
CPY16	%r0	(%r0)
INC16	%r0	$5
CPY16	%r0	(%r0)
CPY16	%eax	%r0
AND32	%eax	$65535
LD32	%r0	$255
AND32	%r0	%eax
CPY8	(%r1)	%r0
SP_RD16	%eax	$3
CPY8	%r0	(%eax)
PUSH8	%r0
SP_DEC	$1
CALL	PS2dev_write_c
POP8	%eax
SP_WR8	%eax	$6
SP_INC	$1
SP_RD8	%ecx	$5
CMP8	%ecx	$0
JZ	@IC6
@IC7:	
LD8	%eax	$-1
SP_WR8	%eax	$27
SP_INC	$8
POP32	%r3
POP32	%r2
POP32	%r1
POP32	%r0
RTS	
@IC6:	
SP_STORE	%r0
INC16	%r0	$0
INC16	%r0	$1
CPY8	%r0	(%r0)
PUSH8	%r0
SP_DEC	$1
CALL	PS2dev_write_c
POP8	%eax
SP_WR8	%eax	$7
SP_INC	$1
SP_RD8	%ecx	$6
CMP8	%ecx	$0
JZ	@IC10
@IC11:	
LD8	%eax	$-1
SP_WR8	%eax	$27
SP_INC	$8
POP32	%r3
POP32	%r2
POP32	%r1
POP32	%r0
RTS	
@IC10:	
SP_STORE	%r0
INC16	%r0	$2
CPY8	%r0	(%r0)
PUSH8	%r0
SP_DEC	$1
CALL	PS2dev_write_c
POP8	%eax
SP_WR8	%eax	$8
SP_INC	$1
SP_RD8	%ecx	$7
CMP8	%ecx	$0
JZ	@IC14
@IC15:	
LD8	%eax	$-1
SP_WR8	%eax	$27
SP_INC	$8
POP32	%r3
POP32	%r2
POP32	%r1
POP32	%r0
RTS	
@IC14:	
LD8	%eax	$0
SP_WR8	%eax	$27
SP_INC	$8
POP32	%r3
POP32	%r2
POP32	%r1
POP32	%r0
RTS	
.FUNC_END	"MS_wr_packet"

MS_cmd:	
.GLOBAL	 DO_NOT_EXPORT  "MS_cmd"

.FUNCTION	"MS_cmd"	
PUSH32	%r0
PUSH32	%r1
SP_DEC	$10
SP_RD8	%r0	$21
SP_RD16	%ecx	$22
JUMP	@IC20
@IC19:	
CALL	ack
@IC55:	
PUSH8	$170
SP_DEC	$1
CALL	PS2dev_write
POP8	%eax
SP_WR8	%eax	$1
SP_INC	$1
SP_RD8	%ecx	$0
CMP8	%ecx	$0
JZ	@IC56
@IC57:	
JUMP	@IC55
@IC56:	
@IC60:	
PUSH8	$0
SP_DEC	$1
CALL	PS2dev_write
POP8	%eax
SP_WR8	%eax	$2
SP_INC	$1
SP_RD8	%ecx	$1
CMP8	%ecx	$0
JZ	@IC61
@IC62:	
JUMP	@IC60
@IC61:	
JUMP	@IC18
@IC21:	
SP_RD16	%r1	$22
INC16	%r1	$13
CPY8	%r1	(%r1)
SP_RD16	%eax	$22
PUSH16	%eax
PUSH8	%r1
CALL	MS_cmd
SP_INC	$3
JUMP	@IC18
@IC23:	
SP_RD16	%r1	$22
INC16	%r1	$9
LD8	(%r1)	$1
CALL	ack
JUMP	@IC18
@IC25:	
SP_RD16	%r1	$22
INC16	%r1	$10
LD8	(%r1)	$0
CALL	ack
JUMP	@IC18
@IC27:	
SP_RD16	%r1	$22
INC16	%r1	$10
LD8	(%r1)	$1
CALL	ack
JUMP	@IC18
@IC29:	
CALL	ack
SP_STORE	%r1
INC16	%r1	$2
PUSH16	%r1
SP_DEC	$1
CALL	PS2dev_read
POP8	%eax
SP_WR8	%eax	$5
SP_INC	$2
CALL	ack
SP_RD16	%r1	$22
INC16	%r1	$12
SP_STORE	%eax
INC16	%eax	$2
CPY8	(%r1)	(%eax)
JUMP	@IC18
@IC31:	
CALL	ack
@IC65:	
PUSH8	$0
SP_DEC	$1
CALL	PS2dev_write
POP8	%eax
SP_WR8	%eax	$5
SP_INC	$1
SP_RD8	%ecx	$4
CMP8	%ecx	$0
JZ	@IC66
@IC67:	
JUMP	@IC65
@IC66:	
JUMP	@IC18
@IC33:	
SP_RD16	%r1	$22
INC16	%r1	$9
LD8	(%r1)	$0
CALL	ack
JUMP	@IC18
@IC35:	
CALL	ack
JUMP	@IC18
@IC37:	
CALL	ack
JUMP	@IC18
@IC39:	
CALL	ack
SP_RD16	%eax	$22
PUSH16	%eax
SP_DEC	$1
CALL	MS_wr_packet
POP8	%eax
SP_WR8	%eax	$7
SP_INC	$2
JUMP	@IC18
@IC41:	
SP_RD16	%r1	$22
INC16	%r1	$9
LD8	(%r1)	$1
CALL	ack
JUMP	@IC18
@IC43:	
CALL	ack
@IC70:	
PUSH8	$230
SP_DEC	$1
CALL	PS2dev_write
POP8	%eax
SP_WR8	%eax	$7
SP_INC	$1
SP_RD8	%ecx	$6
CMP8	%ecx	$0
JZ	@IC71
@IC72:	
JUMP	@IC70
@IC71:	
@IC75:	
SP_RD16	%r1	$22
INC16	%r1	$11
CPY8	%r1	(%r1)
PUSH8	%r1
SP_DEC	$1
CALL	PS2dev_write
POP8	%eax
SP_WR8	%eax	$8
SP_INC	$1
SP_RD8	%ecx	$7
CMP8	%ecx	$0
JZ	@IC76
@IC77:	
JUMP	@IC75
@IC76:	
@IC80:	
SP_RD16	%r1	$22
INC16	%r1	$12
CPY8	%r1	(%r1)
PUSH8	%r1
SP_DEC	$1
CALL	PS2dev_write
POP8	%eax
SP_WR8	%eax	$9
SP_INC	$1
SP_RD8	%ecx	$8
CMP8	%ecx	$0
JZ	@IC81
@IC82:	
JUMP	@IC80
@IC81:	
JUMP	@IC18
@IC45:	
CALL	ack
SP_STORE	%r1
INC16	%r1	$2
PUSH16	%r1
SP_DEC	$1
CALL	PS2dev_read
POP8	%eax
SP_WR8	%eax	$11
SP_INC	$2
CALL	ack
SP_RD16	%r1	$22
INC16	%r1	$11
SP_STORE	%eax
INC16	%eax	$2
CPY8	(%r1)	(%eax)
JUMP	@IC18
@IC47:	
CALL	ack
JUMP	@IC18
@IC49:	
CALL	ack
JUMP	@IC18
@IC51:	
JUMP	@IC18
@IC53:	
CALL	ack
JUMP	@IC18
@IC20:	
CMP8	%r0	$255
JZ	@IC19
@IC22:	
CMP8	%r0	$254
JZ	@IC21
@IC24:	
CMP8	%r0	$246
JZ	@IC23
@IC26:	
CMP8	%r0	$245
JZ	@IC25
@IC28:	
CMP8	%r0	$244
JZ	@IC27
@IC30:	
CMP8	%r0	$243
JZ	@IC29
@IC32:	
CMP8	%r0	$242
JZ	@IC31
@IC34:	
CMP8	%r0	$240
JZ	@IC33
@IC36:	
CMP8	%r0	$238
JZ	@IC35
@IC38:	
CMP8	%r0	$236
JZ	@IC37
@IC40:	
CMP8	%r0	$235
JZ	@IC39
@IC42:	
CMP8	%r0	$234
JZ	@IC41
@IC44:	
CMP8	%r0	$233
JZ	@IC43
@IC46:	
CMP8	%r0	$232
JZ	@IC45
@IC48:	
CMP8	%r0	$231
JZ	@IC47
@IC50:	
CMP8	%r0	$230
JZ	@IC49
@IC52:	
CMP8	%r0	$0
JZ	@IC51
@IC54:	
JUMP	@IC53
@IC18:	
CMP8	%r0	$254
JZ	@IC85
@IC86:	
SP_RD16	%r1	$22
INC16	%r1	$13
CPY8	(%r1)	%r0
@IC85:	
SP_INC	$10
POP32	%r1
POP32	%r0
RTS	
.FUNC_END	"MS_cmd"

