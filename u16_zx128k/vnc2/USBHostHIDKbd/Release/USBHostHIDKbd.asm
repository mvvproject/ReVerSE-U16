.DATA

.WEAK	"%eax"
.WEAK	"%ebx"
.WEAK	"%ecx"
.WEAK	"%r0"
.WEAK	"%r1"
.WEAK	"%r2"
.WEAK	"%r3"
buf	.DB	64	?
.GLOBAL	  DO_NOT_EXPORT "buf"
hUART	.DW	1	?
.GLOBAL	  DO_NOT_EXPORT "hUART"
hUSBHOST_2	.DW	1	?
.GLOBAL	  DO_NOT_EXPORT "hUSBHOST_2"
tcbFIRMWARE	.DW	1	?
.GLOBAL	  DO_NOT_EXPORT "tcbFIRMWARE"
hUSBHOST_HID	.DW	1	?
.GLOBAL	  DO_NOT_EXPORT "hUSBHOST_HID"
hGPIO_PORT_A	.DW	1	?
.GLOBAL	  DO_NOT_EXPORT "hGPIO_PORT_A"
Str@0	.ASCIIZ	"Application"




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

.WEAK	"iomux_setup"

.WEAK	"vos_get_chip_revision"

.WEAK	"vos_wait_semaphore_ex"

.WEAK	"vos_enable_interrupts"

.WEAK	"vos_dev_read"

.WEAK	"vos_dev_open"

.WEAK	"vos_halt_cpu"

.WEAK	"vos_dev_init"

.WEAK	"vos_dma_get_fifo_count"

.WEAK	"usbhost_init"

.WEAK	"vos_reset_kernel_clock"

.WEAK	"vos_gpio_set_port_mode"

.WEAK	"vos_iomux_define_input"

.WEAK	"vos_disable_interrupts"

.WEAK	"vos_get_idle_thread_tcb"

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

.WEAK	"usbHostHID_init"

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

.WEAK	"gpio_init"

.WEAK	"uart_init"

.WEAK	"vos_gpio_enable_int"

.WEAK	"vos_signal_cond_var"

number:	
.GLOBAL	 DO_NOT_EXPORT  "number"

.FUNCTION	"number"	
PUSH32	%r0
SP_DEC	$1
SP_STORE	%r0
INC16	%r0	$8
PUSH16	$0
PUSH16	$1
PUSH16	%r0
PUSH16	hUART
SP_DEC	$1
CALL	vos_dev_write
POP8	%eax
SP_WR8	%eax	$8
SP_INC	$8
SP_INC	$1
POP32	%r0
RTS	
.FUNC_END	"number"

main:	
.GLOBAL	 DO_NOT_EXPORT  "main"

.FUNCTION	"main"	
PUSH32	%r0
PUSH32	%r1
SP_DEC	$12
PUSH8	$4
PUSH16	$1
PUSH8	$50
CALL	vos_init
SP_INC	$4
PUSH8	$0
CALL	vos_set_clock_frequency
SP_INC	$1
PUSH16	$512
CALL	vos_set_idle_thread_tcb_size
SP_INC	$2
CALL	iomux_setup
SP_STORE	%r0
CPY16	%r1	%r0
LD8	(%r1)	$64
PUSH16	%r0
PUSH8	$1
SP_DEC	$1
CALL	uart_init
POP8	%eax
SP_WR8	%eax	$4
SP_INC	$3
SP_STORE	%r0
INC16	%r0	$2
CPY16	%r1	%r0
LD8	(%r1)	$0
PUSH16	%r0
PUSH8	$2
SP_DEC	$1
CALL	gpio_init
POP8	%eax
SP_WR8	%eax	$6
SP_INC	$3
PUSH8	$3
SP_DEC	$1
CALL	usbHostHID_init
POP8	%eax
SP_WR8	%eax	$5
SP_INC	$1
SP_STORE	%r0
INC16	%r0	$5
CPY16	%r1	%r0
LD8	(%r1)	$8
LD16	%r1	$1
ADD16	%r1	%r0
LD8	(%r1)	$16
LD16	%r1	$2
ADD16	%r1	%r0
LD8	(%r1)	$2
LD16	%r1	$3
ADD16	%r1	%r0
LD8	(%r1)	$2
PUSH16	%r0
PUSH8	$0
PUSH8	$-1
SP_DEC	$1
CALL	usbhost_init
POP8	%eax
SP_WR8	%eax	$13
SP_INC	$4
LD32	%r0	$firmware
LD32	%r1	$Str@0
PUSH16	$0
PUSH16	%r1
PUSH32	%r0
PUSH16	$4096
PUSH8	$20
SP_DEC	$2
CALL	vos_create_thread_ex
POP16	%eax
SP_WR16	%eax	$21
SP_INC	$11
SP_RD16	tcbFIRMWARE	$10
CALL	vos_start_scheduler
@fl2main_loop:	
JUMP	@fl2main_loop
SP_INC	$12
POP32	%r1
POP32	%r0
RTS	
.FUNC_END	"main"

usbhost_connect_state:	
.GLOBAL	 DO_NOT_EXPORT  "usbhost_connect_state"

.FUNCTION	"usbhost_connect_state"	
PUSH32	%r0
PUSH32	%r1
PUSH32	%r2
PUSH32	%r3
SP_DEC	$13
SP_RD16	%r0	$33
LD8	%ecx	$0
SP_WR8	%ecx	$0
CMP16	%r0	$0
JZ	@IC1
@IC2:	
SP_STORE	%r1
INC16	%r1	$1
CPY16	%r2	%r1
LD8	(%r2)	$16
LD16	%r2	$6
ADD16	%r2	%r1
SP_STORE	%r3
CPY16	(%r2)	%r3
PUSH16	%r1
PUSH16	%r0
SP_DEC	$1
CALL	vos_dev_ioctl
POP8	%eax
SP_WR8	%eax	$15
SP_INC	$4
SP_RD8	%ecx	$0
CMP8	%ecx	$1
JNZ	@IC3
@IC4:	
SP_STORE	%r1
INC16	%r1	$1
PUSH16	%r1
PUSH16	%r0
SP_DEC	$1
CALL	vos_dev_ioctl
POP8	%eax
SP_WR8	%eax	$16
SP_INC	$4
@IC3:	
@IC1:	
SP_RD8	%eax	$0
SP_WR8	%eax	$32
SP_INC	$13
POP32	%r3
POP32	%r2
POP32	%r1
POP32	%r0
RTS	
.FUNC_END	"usbhost_connect_state"

hid_attach:	
.GLOBAL	 DO_NOT_EXPORT  "hid_attach"

.FUNCTION	"hid_attach"	
PUSH32	%r0
PUSH32	%r1
PUSH32	%r2
PUSH32	%r3
SP_DEC	$40
SP_RD8	%ecx	$63
SP_WR8	%ecx	$63
SP_RD16	%ecx	$61
LD32	%ecx	$0
SP_WR32	%ecx	$0
SP_STORE	%r0
INC16	%r0	$4
CPY16	%r1	%r0
LD8	(%r1)	$3
LD16	%r1	$1
ADD16	%r1	%r0
LD8	(%r1)	$255
LD16	%r1	$2
ADD16	%r1	%r0
LD8	(%r1)	$255
SP_STORE	%r1
INC16	%r1	$7
CPY16	%r2	%r1
LD8	(%r2)	$35
LD16	%r2	$2
ADD16	%r2	%r1
CPY16	%r2	%r2
LD32	(%r2)	$0
LD16	%r2	$8
ADD16	%r2	%r1
CPY16	(%r2)	%r0
LD16	%r0	$6
ADD16	%r0	%r1
SP_STORE	%r2
CPY16	(%r0)	%r2
PUSH16	%r1
SP_RD16	%eax	$63
PUSH16	%eax
SP_DEC	$1
CALL	vos_dev_ioctl
POP8	%eax
SP_WR8	%eax	$21
SP_INC	$4
SP_RD8	%ecx	$17
CMP8	%ecx	$0
JZ	@IC7
@IC8:	
LD16	%eax	$0
SP_WR16	%eax	$59
SP_INC	$40
POP32	%r3
POP32	%r2
POP32	%r1
POP32	%r0
RTS	
@IC7:	
SP_RD16	%eax	$63
PUSH8	%eax
SP_DEC	$2
CALL	vos_dev_open
POP16	%eax
SP_WR16	%eax	$19
SP_INC	$1
SP_RD16	%r3	$18
SP_STORE	%r0
INC16	%r0	$20
SP_STORE	%eax
INC16	%eax	$61
CPY16	(%r0)	(%eax)
LD16	%r1	$2
ADD16	%r1	%r0
SP_STORE	%eax
CPY32	(%r1)	(%eax)
SP_STORE	%r1
INC16	%r1	$26
CPY16	%r2	%r1
LD8	(%r2)	$1
LD16	%r2	$9
ADD16	%r2	%r1
CPY16	(%r2)	%r0
LD16	%r0	$11
ADD16	%r0	%r1
LD16	(%r0)	$0
PUSH16	%r1
SP_RD16	%eax	$20
PUSH16	%eax
SP_DEC	$1
CALL	vos_dev_ioctl
POP8	%eax
SP_WR8	%eax	$43
SP_INC	$4
SP_RD8	%ecx	$39
CMP8	%ecx	$0
JZ	@IC11
@IC12:	
PUSH16	%r3
CALL	vos_dev_close
SP_INC	$2
LD16	%r3	$0
@IC11:	
SP_WR16	%r3	$59
SP_INC	$40
POP32	%r3
POP32	%r2
POP32	%r1
POP32	%r0
RTS	
.FUNC_END	"hid_attach"

HID_detach:	
.GLOBAL	 DO_NOT_EXPORT  "HID_detach"

.FUNCTION	"HID_detach"	
PUSH32	%r0
PUSH32	%r1
PUSH32	%r2
SP_DEC	$14
SP_RD16	%r0	$29
CMP16	%r0	$0
JZ	@IC15
@IC16:	
SP_STORE	%r1
CPY16	%r2	%r1
LD8	(%r2)	$2
PUSH16	%r1
PUSH16	%r0
SP_DEC	$1
CALL	vos_dev_ioctl
POP8	%eax
SP_WR8	%eax	$17
SP_INC	$4
PUSH16	%r0
CALL	vos_dev_close
SP_INC	$2
@IC15:	
SP_INC	$14
POP32	%r2
POP32	%r1
POP32	%r0
RTS	
.FUNC_END	"HID_detach"

open_drivers:	
.GLOBAL	 DO_NOT_EXPORT  "open_drivers"

.FUNCTION	"open_drivers"	
SP_DEC	$6
PUSH8	$0
SP_DEC	$2
CALL	vos_dev_open
POP16	%eax
SP_WR16	%eax	$1
SP_INC	$1
SP_RD16	hUSBHOST_2	$0
PUSH8	$1
SP_DEC	$2
CALL	vos_dev_open
POP16	%eax
SP_WR16	%eax	$3
SP_INC	$1
SP_RD16	hUART	$2
PUSH8	$2
SP_DEC	$2
CALL	vos_dev_open
POP16	%eax
SP_WR16	%eax	$5
SP_INC	$1
SP_RD16	hGPIO_PORT_A	$4
SP_INC	$6
RTS	
.FUNC_END	"open_drivers"

attach_drivers:	
.GLOBAL	 DO_NOT_EXPORT  "attach_drivers"

.FUNCTION	"attach_drivers"	
SP_DEC	$2
PUSH8	$3
PUSH16	hUSBHOST_2
SP_DEC	$2
CALL	hid_attach
POP16	%eax
SP_WR16	%eax	$3
SP_INC	$3
SP_RD16	hUSBHOST_HID	$0
SP_INC	$2
RTS	
.FUNC_END	"attach_drivers"

close_drivers:	
.GLOBAL	 DO_NOT_EXPORT  "close_drivers"

.FUNCTION	"close_drivers"	
PUSH16	hUSBHOST_2
CALL	vos_dev_close
SP_INC	$2
PUSH16	hUART
CALL	vos_dev_close
SP_INC	$2
PUSH16	hGPIO_PORT_A
CALL	vos_dev_close
SP_INC	$2
RTS	
.FUNC_END	"close_drivers"

firmware:	
.GLOBAL	 DO_NOT_EXPORT  "firmware"

.FUNCTION	"firmware"	
PUSH32	%r0
PUSH32	%r1
PUSH32	%r2
PUSH32	%r3
SP_DEC	$25
@IC17:	
CALL	open_drivers
@IC20:	
PUSH16	$1000
SP_DEC	$1
CALL	vos_delay_msecs
POP8	%eax
SP_WR8	%eax	$2
SP_INC	$2
PUSH16	hUSBHOST_2
SP_DEC	$1
CALL	usbhost_connect_state
POP8	%eax
SP_WR8	%eax	$3
SP_INC	$2
SP_RD8	%ecx	$1
SP_WR8	%ecx	$2
@IC21:	
SP_RD8	%ecx	$2
CMP8	%ecx	$17
JNZ	@IC20
JZ	@IC22
@IC22:	
SP_RD8	%ecx	$2
CMP8	%ecx	$17
JNZ	@IC25
@IC26:	
PUSH8	$4
PUSH8	$0
SP_DEC	$1
CALL	vos_gpio_set_port_mode
POP8	%eax
SP_WR8	%eax	$5
SP_INC	$2
PUSH8	$4
PUSH8	$0
SP_DEC	$1
CALL	vos_gpio_write_port
POP8	%eax
SP_WR8	%eax	$6
SP_INC	$2
CALL	attach_drivers
CMP16	hUSBHOST_HID	$0
JNZ	@IC29
@IC30:	
JUMP	@IC19
@IC29:	
SP_STORE	%r1
INC16	%r1	$5
LD16	%r2	$1
ADD16	%r2	%r1
LD8	(%r2)	$34
LD16	%r2	$2
ADD16	%r2	%r1
LD8	(%r2)	$0
LD16	%r2	$7
ADD16	%r2	%r1
LD16	(%r2)	$64
LD16	%r2	$11
ADD16	%r2	%r1
CPY16	%r2	%r2
LD16	%r3	$buf
INC16	%r3	$0
CPY16	(%r2)	%r3
CPY16	%r2	%r1
LD8	(%r2)	$9
PUSH16	%r1
PUSH16	hUSBHOST_HID
SP_DEC	$1
CALL	vos_dev_ioctl
POP8	%eax
SP_WR8	%eax	$22
SP_INC	$4
SP_RD8	%ecx	$18
SP_WR8	%ecx	$2
SP_RD8	%ecx	$18
CMP8	%ecx	$0
JZ	@IC33
@IC34:	
JUMP	@IC19
@IC33:	
SP_STORE	%r1
INC16	%r1	$5
LD16	%r2	$6
ADD16	%r2	%r1
LD8	(%r2)	$0
LD16	%r2	$3
ADD16	%r2	%r1
LD8	(%r2)	$32
CPY16	%r2	%r1
LD8	(%r2)	$8
PUSH16	%r1
PUSH16	hUSBHOST_HID
SP_DEC	$1
CALL	vos_dev_ioctl
POP8	%eax
SP_WR8	%eax	$23
SP_INC	$4
SP_RD8	%ecx	$19
SP_WR8	%ecx	$2
SP_RD8	%ecx	$19
CMP8	%ecx	$0
JZ	@IC37
@IC38:	
JUMP	@IC19
@IC37:	
SP_STORE	%r1
INC16	%r1	$5
LD16	%r2	$6
ADD16	%r2	%r1
LD8	(%r2)	$0
LD16	%r2	$11
ADD16	%r2	%r1
CPY16	%r2	%r2
LD16	%r3	$buf
CPY16	(%r2)	%r3
CPY16	%r2	%r1
LD8	(%r2)	$7
PUSH16	%r1
PUSH16	hUSBHOST_HID
SP_DEC	$1
CALL	vos_dev_ioctl
POP8	%eax
SP_WR8	%eax	$24
SP_INC	$4
SP_RD8	%ecx	$20
SP_WR8	%ecx	$2
SP_RD8	%ecx	$20
CMP8	%ecx	$0
JZ	@IC41
@IC42:	
JUMP	@IC19
@IC41:	
SP_RD8	%ecx	$2
CMP8	%ecx	$0
JNZ	@IC45
@IC46:	
@IC49:	
LD8	%ecx	$1
CMP8	%ecx	$0
JZ	@IC50
@IC51:	
LD16	%r1	$buf
SP_STORE	%r2
INC16	%r2	$21
PUSH16	%r2
PUSH16	$8
PUSH16	%r1
PUSH16	hUSBHOST_HID
SP_DEC	$1
CALL	vos_dev_read
POP8	%eax
SP_WR8	%eax	$31
SP_INC	$8
SP_RD8	%ecx	$23
CMP8	%ecx	$0
JNZ	@IC53
@IC54:	
LD8	%r0	$0
@IC57:	
SP_STORE	%eax
INC16	%eax	$21
CMP8	%r0	(%eax)
JGE	@IC52
@IC59:	
CPY8	%eax	%r0
AND32	%eax	$255
CPY32	%r1	%eax
LD16	%r2	$buf
ADD16	%r1	%r2	%r1
CPY8	%r1	(%r1)
PUSH8	%r1
CALL	number
SP_INC	$1
@IC60:	
INC8	%r0	$1
JUMP	@IC57
@IC58:	
JUMP	@IC49
@IC53:	
JUMP	@IC50
@IC52:	
JUMP	@IC49
@IC50:	
@IC45:	
PUSH8	$0
PUSH8	$0
SP_DEC	$1
CALL	vos_gpio_write_port
POP8	%eax
SP_WR8	%eax	$26
SP_INC	$2
@IC25:	
PUSH16	hUSBHOST_HID
CALL	vos_dev_close
SP_INC	$2
CALL	close_drivers
@IC18:	
LD8	%ecx	$1
CMP8	%ecx	$0
JNZ	@IC17
@IC19:	
SP_INC	$25
POP32	%r3
POP32	%r2
POP32	%r1
POP32	%r0
RTS	
.FUNC_END	"firmware"

