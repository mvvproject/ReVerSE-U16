.DATA

.WEAK	"%eax"
.WEAK	"%ebx"
.WEAK	"%ecx"
.WEAK	"%r0"
.WEAK	"%r1"
.WEAK	"%r2"
.WEAK	"%r3"
ReportID_MS	.DB	40	?
.GLOBAL	  DO_NOT_EXPORT "ReportID_MS"
hid_parser	.DB	256	?
.GLOBAL	  DO_NOT_EXPORT "hid_parser"
ReportID_tbl	.DB	40	?
.GLOBAL	  DO_NOT_EXPORT "ReportID_tbl"
max_ReportID	.DB	1	?
.GLOBAL	  DO_NOT_EXPORT "max_ReportID"
hc_iocb_class	.DB	3	?
.GLOBAL	  DO_NOT_EXPORT "hc_iocb_class"
buf	.DB	128	?
.GLOBAL	  DO_NOT_EXPORT "buf"
pDATA	.DW	1	?
.GLOBAL	  DO_NOT_EXPORT "pDATA"
hUsb	.DW	2	?
.GLOBAL	  DO_NOT_EXPORT "hUsb"
hid_parce_data	.DB	71	?
.GLOBAL	  DO_NOT_EXPORT "hid_parce_data"
MS_OK	.DB	1	?
.GLOBAL	  DO_NOT_EXPORT "MS_OK"
hUART	.DW	1	?
.GLOBAL	  DO_NOT_EXPORT "hUART"
Xpos	.DD	1	?
.GLOBAL	  DO_NOT_EXPORT "Xpos"
Ypos	.DD	1	?
.GLOBAL	  DO_NOT_EXPORT "Ypos"
PS2_KB	.DB	42	?
.GLOBAL	  DO_NOT_EXPORT "PS2_KB"
PS2_MS	.DB	14	?
.GLOBAL	  DO_NOT_EXPORT "PS2_MS"
pPS2_KB	.DW	1	?
.GLOBAL	  DO_NOT_EXPORT "pPS2_KB"
ifInfo	.DB	7	?
.GLOBAL	  DO_NOT_EXPORT "ifInfo"
pParser	.DW	1	?
.GLOBAL	  DO_NOT_EXPORT "pParser"
hUSBHOST_1	.DW	1	?
.GLOBAL	  DO_NOT_EXPORT "hUSBHOST_1"
hUSBHOST_2	.DW	1	?
.GLOBAL	  DO_NOT_EXPORT "hUSBHOST_2"
hid_data	.DB	71	?
.GLOBAL	  DO_NOT_EXPORT "hid_data"
hid_path	.DB	41	?
.GLOBAL	  DO_NOT_EXPORT "hid_path"
sem_list	.DW	1	?
.GLOBAL	  DO_NOT_EXPORT "sem_list"
hid_Bdata	.DB	71	?
.GLOBAL	  DO_NOT_EXPORT "hid_Bdata"
hid_Wdata	.DB	71	?
.GLOBAL	  DO_NOT_EXPORT "hid_Wdata"
hid_Xdata	.DB	71	?
.GLOBAL	  DO_NOT_EXPORT "hid_Xdata"
hid_Ydata	.DB	71	?
.GLOBAL	  DO_NOT_EXPORT "hid_Ydata"
tcbFIRMWARE	.DW	1	?
.GLOBAL	  DO_NOT_EXPORT "tcbFIRMWARE"
phid_data	.DW	1	?
.GLOBAL	  DO_NOT_EXPORT "phid_data"
hGPIO_PORT_A	.DW	1	?
.GLOBAL	  DO_NOT_EXPORT "hGPIO_PORT_A"
phid_Bdata	.DW	1	?
.GLOBAL	  DO_NOT_EXPORT "phid_Bdata"
phid_Wdata	.DW	1	?
.GLOBAL	  DO_NOT_EXPORT "phid_Wdata"
phid_Xdata	.DW	1	?
.GLOBAL	  DO_NOT_EXPORT "phid_Xdata"
phid_Ydata	.DW	1	?
.GLOBAL	  DO_NOT_EXPORT "phid_Ydata"
Str@0	.ASCIIZ	"USB_thread"
Str@1	.ASCIIZ	"PS2_MSthread"
Str@2	.ASCIIZ	"\r\n"
Str@3	.ASCIIZ	"Starting...\r\n"
Str@4	.ASCIIZ	"Enumeration complete Port "
Str@5	.ASCIIZ	"No Device Found - code "
Str@6	.ASCIIZ	"No Control Endpoint Found - code "
Str@7	.ASCIIZ	"No interrupt Endpoint Found - code "
Str@8	.ASCIIZ	"Interrupt Endpoint Info Not Found - code "
Str@9	.ASCIIZ	"CONFIGURATION Descriptor failed - code "
Str@10	.ASCIIZ	"Report Descriptor : "
Str@11	.ASCIIZ	"Max Report ID : "
Str@12	.ASCIIZ	"Mouse Button was found "
Str@13	.ASCIIZ	"Bit offset: "
Str@14	.ASCIIZ	"Sise(bit): "
Str@15	.ASCIIZ	"Mouse Xpos was found "
Str@16	.ASCIIZ	"Bit offset: "
Str@17	.ASCIIZ	"Sise(bit): "
Str@18	.ASCIIZ	"Mouse Ypos was found "
Str@19	.ASCIIZ	"Bit offset: "
Str@20	.ASCIIZ	"Sise(bit): "
Str@21	.ASCIIZ	"Mouse Wheel was found "
Str@22	.ASCIIZ	"Bit offset: "
Str@23	.ASCIIZ	"Sise(bit): "
Str@24	.ASCIIZ	"Init complete Port "
Str@25	.ASCIIZ	"Port 00 Read Failed - code "
Str@26	.ASCIIZ	"Port 01 Read Failed - code "
Str@27	.ASCIIZ	"Port "
Str@28	.ASCIIZ	" Data: "
Str@29	.ASCIIZ	"Mouse Button: "
Str@30	.ASCIIZ	"Mouse Xpos: "
Str@31	.ASCIIZ	"Mouse Ypos: "
Str@32	.ASCIIZ	"Mouse Wheel: "




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

.WEAK	"fat_dirTableFindFirst"

.WEAK	"vos_signal_semaphore"

.WEAK	"fat_fileMod"

.WEAK	"vos_gpio_wait_on_int"

.WEAK	"ResetParser"

.WEAK	"stdinAttach"

.WEAK	"stdioAttach"

.WEAK	"vos_dma_get_fifo_data"

.WEAK	"fatdrv_init"

.WEAK	"PS2dev_write"

.WEAK	"vos_iocell_get_config"

.WEAK	"vos_iomux_define_bidi"

.WEAK	"vos_gpio_set_all_mode"

.WEAK	"vos_iocell_set_config"

.WEAK	"fat_fileRead"

.WEAK	"vos_gpio_set_pin_mode"

.WEAK	"MS_wr_packet"

.WEAK	"iomux_setup"

.WEAK	"fat_fileSeek"

.WEAK	"fat_dirEntryIsReadOnly"

.WEAK	"vos_get_chip_revision"

.WEAK	"fat_fileTell"

.WEAK	"vos_wait_semaphore_ex"

.WEAK	"fat_fileOpen"

.WEAK	"fat_fileCopy"

.WEAK	"vos_enable_interrupts"

.WEAK	"fat_capacity"

.WEAK	"stderrAttach"

.WEAK	"FindMouse_XYW"

.WEAK	"vos_dev_read"

.WEAK	"stdoutAttach"

.WEAK	"PS2dev_unlock"

.WEAK	"vos_dev_open"

.WEAK	"vos_halt_cpu"

.WEAK	"vos_dev_init"

.WEAK	"vos_dma_get_fifo_count"

.WEAK	"fat_getFSType"

.WEAK	"usbhost_init"

.WEAK	"vos_reset_kernel_clock"

.WEAK	"fat_freeSpace"

.WEAK	"fat_fileClose"

.WEAK	"fat_dirIsRoot"

.WEAK	"vos_gpio_set_port_mode"

.WEAK	"fat_fileFlush"

.WEAK	"vos_iomux_define_input"

.WEAK	"fat_fileWrite"

.WEAK	"vos_disable_interrupts"

.WEAK	"fat_dirEntryIsDirectory"

.WEAK	"PS2dev_write_c"

.WEAK	"vos_get_idle_thread_tcb"

.WEAK	"vos_dma_reset"

.WEAK	"vos_dev_close"

.WEAK	"vos_wdt_clear"

.WEAK	"vos_heap_size"

.WEAK	"PS2_mouse_init"

.WEAK	"vos_dev_ioctl"

.WEAK	"vos_dev_write"

.WEAK	"fat_fileDelete"

.WEAK	"fat_fileRename"

.WEAK	"vos_get_clock_frequency"

.WEAK	"fat_fileSetPos"

.WEAK	"vos_set_clock_frequency"

.WEAK	"feof"

.WEAK	"fat_fileRewind"

.WEAK	"vos_dma_enable"

.WEAK	"vos_reset_vnc2"

.WEAK	"vos_heap_space"

.WEAK	"vos_iomux_define_output"

.WEAK	"vos_wdt_enable"

.WEAK	"ReportID_Offset"

.WEAK	"LED_ON"

.WEAK	"PS2dev_host_req"

.WEAK	"fat_getVolumeID"

.WEAK	"vos_dma_wait_on_complete"

.WEAK	"vos_lock_mutex"

.WEAK	"vos_power_down"

.WEAK	"vos_init_mutex"

.WEAK	"fat_dirEntryIsVolumeLabel"

.WEAK	"fread"

.WEAK	"GetReportOffset"

.WEAK	"vos_gpio_wait_on_any_int"

.WEAK	"fgetc"

.WEAK	"fseek"

.WEAK	"LED_OFF"

.WEAK	"vos_get_priority_ceiling"

.WEAK	"ftell"

.WEAK	"fopen"

.WEAK	"fgets"

.WEAK	"vos_dma_disable"

.WEAK	"USB_PS2"

.WEAK	"vos_set_priority_ceiling"

.WEAK	"fputc"

.WEAK	"vos_dma_release"

.WEAK	"vos_iomux_disable_output"

.WEAK	"fputs"

.WEAK	"vos_dma_acquire"

.WEAK	"MS_cmd"

.WEAK	"fat_dirChangeDir"

.WEAK	"vos_delay_msecs"

.WEAK	"vos_stack_usage"

.WEAK	"fat_dirTableFind"

.WEAK	"fat_getDevHandle"

.WEAK	"vos_get_profile"

.WEAK	"fat_dirCreateDir"

.WEAK	"vos_gpio_wait_on_all_ints"

.WEAK	"fat_dirEntryName"

.WEAK	"rename"

.WEAK	"fat_dirEntryTime"

.WEAK	"fclose"

.WEAK	"fat_fileTruncate"

.WEAK	"fat_dirEntrySize"

.WEAK	"KBParse"

.WEAK	"fflush"

.WEAK	"rewind"

.WEAK	"memset"

.WEAK	"memcpy"

.WEAK	"vos_delay_cancel"

.WEAK	"FindReport_max_ID"

.WEAK	"remove"

.WEAK	"strcat"

.WEAK	"fwrite"

.WEAK	"printf"

.WEAK	"PS2_keyboard_init"

.WEAK	"strlen"

.WEAK	"strcmp"

.WEAK	"CHECK_BIT"

.WEAK	"strcpy"

.WEAK	"vos_dma_retained_configure"

.WEAK	"fat_dirDirIsEmpty"

.WEAK	"HIDParse"

.WEAK	"vos_unlock_mutex"

.WEAK	"FindMouse_Buttons"

.WEAK	"getchar"

.WEAK	"putchar"

.WEAK	"fgetpos"

.WEAK	"fprintf"

.WEAK	"vos_gpio_read_all"

.WEAK	"vos_create_thread"

.WEAK	"fsetpos"

.WEAK	"sprintf"

.WEAK	"strncmp"

.WEAK	"vos_gpio_read_pin"

.WEAK	"vos_dma_configure"

.WEAK	"strncpy"

.WEAK	"vos_init_cond_var"

.WEAK	"vos_wait_cond_var"

.WEAK	"GetValue"

.WEAK	"fat_dirEntryIsFile"

.WEAK	"SetValue"

.WEAK	"fsAttach"

.WEAK	"fat_getVolumeLabel"

.WEAK	"vos_stop_profiler"

.WEAK	"ReportID_DataLength"

.WEAK	"fat_time"

.WEAK	"fat_open"

.WEAK	"fat_init"

.WEAK	"vos_trylock_mutex"

.WEAK	"fat_bytesPerSector"

.WEAK	"vos_free"

.WEAK	"vos_init"

.WEAK	"vos_gpio_read_port"

.WEAK	"vos_gpio_write_all"

.WEAK	"vos_set_idle_thread_tcb_size"

.WEAK	"vos_init_semaphore"

.WEAK	"vos_wait_semaphore"

.WEAK	"vos_gpio_write_pin"

.WEAK	"fat_dirEntryIsValid"

.WEAK	"vos_start_profiler"

.WEAK	"fat_close"

.WEAK	"gpio_init"

.WEAK	"fat_bytesPerCluster"

.WEAK	"GetValueXY"

.WEAK	"uart_init"

.WEAK	"vos_gpio_enable_int"

.WEAK	"FindObject"

.WEAK	"vos_signal_cond_var"

.WEAK	"fat_dirTableFindNext"

.WEAK	"PS2KB_write"

main:	
.GLOBAL	 DO_NOT_EXPORT  "main"

.FUNCTION	"main"	
PUSH32	%r0
PUSH32	%r1
SP_DEC	$13
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
LD16	%r0	$PS2_MS
PUSH16	%r0
CALL	PS2_mouse_init
SP_INC	$2
LD16	%r0	$PS2_KB
PUSH16	%r0
CALL	PS2_keyboard_init
SP_INC	$2
CPY16	pPS2_KB	%r0
SP_STORE	%r0
CPY16	%r1	%r0
LD8	(%r1)	$64
PUSH16	%r0
PUSH8	$2
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
PUSH8	$3
SP_DEC	$1
CALL	gpio_init
POP8	%eax
SP_WR8	%eax	$6
SP_INC	$3
SP_STORE	%r0
INC16	%r0	$4
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
PUSH8	$1
PUSH8	$0
SP_DEC	$1
CALL	usbhost_init
POP8	%eax
SP_WR8	%eax	$12
SP_INC	$4
LD32	%r0	$USB_thread
LD32	%r1	$Str@0
PUSH16	$0
PUSH16	%r1
PUSH32	%r0
PUSH16	$4096
PUSH8	$20
SP_DEC	$2
CALL	vos_create_thread_ex
POP16	%eax
SP_WR16	%eax	$20
SP_INC	$11
SP_RD16	tcbFIRMWARE	$9
LD32	%r0	$PS2_MSthread
LD32	%r1	$Str@1
PUSH16	$0
PUSH16	%r1
PUSH32	%r0
PUSH16	$2048
PUSH8	$20
SP_DEC	$2
CALL	vos_create_thread_ex
POP16	%eax
SP_WR16	%eax	$22
SP_INC	$11
SP_RD16	tcbFIRMWARE	$11
CALL	vos_start_scheduler
@fl1main_loop:	
JUMP	@fl1main_loop
SP_INC	$13
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
SP_STORE	%ecx
CMP8	(%ecx)	$1
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

open_drivers:	
.GLOBAL	 DO_NOT_EXPORT  "open_drivers"

.FUNCTION	"open_drivers"	
SP_DEC	$8
PUSH8	$0
SP_DEC	$2
CALL	vos_dev_open
POP16	%eax
SP_WR16	%eax	$1
SP_INC	$1
SP_RD16	hUSBHOST_1	$0
PUSH8	$1
SP_DEC	$2
CALL	vos_dev_open
POP16	%eax
SP_WR16	%eax	$3
SP_INC	$1
SP_RD16	hUSBHOST_2	$2
PUSH8	$2
SP_DEC	$2
CALL	vos_dev_open
POP16	%eax
SP_WR16	%eax	$5
SP_INC	$1
SP_RD16	hUART	$4
PUSH8	$3
SP_DEC	$2
CALL	vos_dev_open
POP16	%eax
SP_WR16	%eax	$7
SP_INC	$1
SP_RD16	hGPIO_PORT_A	$6
SP_INC	$8
RTS	
.FUNC_END	"open_drivers"

attach_drivers:	
.GLOBAL	 DO_NOT_EXPORT  "attach_drivers"

.FUNCTION	"attach_drivers"	
RTS	
.FUNC_END	"attach_drivers"

close_drivers:	
.GLOBAL	 DO_NOT_EXPORT  "close_drivers"

.FUNCTION	"close_drivers"	
PUSH16	hUSBHOST_1
CALL	vos_dev_close
SP_INC	$2
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

message:	
.GLOBAL	 DO_NOT_EXPORT  "message"

.FUNCTION	"message"	
RTS	
.FUNC_END	"message"

number:	
.GLOBAL	 DO_NOT_EXPORT  "number"

.FUNCTION	"number"	
RTS	
.FUNC_END	"number"

D_number:	
.GLOBAL	 DO_NOT_EXPORT  "D_number"

.FUNCTION	"D_number"	
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
.FUNC_END	"D_number"

USB_thread:	
.GLOBAL	 DO_NOT_EXPORT  "USB_thread"

.FUNCTION	"USB_thread"	
PUSH32	%r0
PUSH32	%r1
PUSH32	%r2
PUSH32	%r3
SP_DEC	$255
SP_DEC	$70
LD32	%r0	$Str@2
SP_STORE	%ecx
CPY16	(%ecx)	%r0
LD16	%r0	$hid_parser
LD16	%r1	$137
ADD16	%r1	%r0
LD16	%r2	$hid_parce_data
CPY16	(%r1)	%r2
CPY16	pParser	%r0
LD16	%r0	$hid_data
CPY16	phid_data	%r0
LD16	%r0	$hid_Bdata
CPY16	phid_Bdata	%r0
LD16	%r0	$hid_Xdata
CPY16	phid_Xdata	%r0
LD16	%r0	$hid_Ydata
CPY16	phid_Ydata	%r0
LD16	%r0	$hid_Wdata
CPY16	phid_Wdata	%r0
SP_STORE	%r0
INC16	%r0	$2
LD32	(%r0)	$0
SP_STORE	%r1
INC16	%r1	$10
LD32	(%r1)	$0
INC16	%r0	$4
LD32	(%r0)	$0
LD16	%r0	$4
ADD16	%r0	%r1
LD32	(%r0)	$0
SP_STORE	%r0
INC16	%r0	$18
LD16	%r1	$0
ADD16	%r1	%r0
LD8	(%r1)	$0
INC16	%r0	$1
LD8	(%r0)	$0
SP_STORE	%r0
INC16	%r0	$20
LD16	%r1	$0
ADD16	%r1	%r0
LD8	(%r1)	$0
INC16	%r0	$1
LD8	(%r0)	$0
SP_STORE	%r0
INC16	%r0	$22
LD16	%r1	$0
ADD16	%r1	%r0
LD8	(%r1)	$0
INC16	%r0	$1
LD8	(%r0)	$0
SP_STORE	%r0
INC16	%r0	$24
LD16	%r1	$0
ADD16	%r1	%r0
LD8	(%r1)	$0
INC16	%r0	$1
LD8	(%r0)	$0
SP_STORE	%r0
INC16	%r0	$26
LD16	%r1	$0
ADD16	%r1	%r0
LD8	(%r1)	$0
INC16	%r0	$1
LD8	(%r0)	$0
SP_STORE	%r0
INC16	%r0	$28
PUSH16	$128
PUSH32	$0
PUSH16	%r0
SP_DEC	$2
CALL	memset
POP16	%eax
SP_WR16	%eax	$164
SP_INC	$8
CALL	open_drivers
CALL	PS2dev_init
CALL	PS2dev_unlock
LD16	%r0	$hUsb
CPY16	(%r0)	hUSBHOST_2
INC16	%r0	$2
CPY16	(%r0)	hUSBHOST_1
SP_STORE	%r0
INC16	%r0	$158
CPY16	%r1	%r0
LD8	(%r1)	$4
LD16	%r1	$1
ADD16	%r1	%r0
CPY16	%r2	%r1
CPY16	%r3	%r2
LD8	(%r3)	$0
PUSH16	%r0
PUSH16	hUART
SP_DEC	$1
CALL	vos_dev_ioctl
POP8	%eax
SP_WR8	%eax	$171
SP_INC	$4
CPY16	%r3	%r0
LD8	(%r3)	$34
CPY16	%r3	%r2
LD32	(%r3)	$9600
PUSH16	%r0
PUSH16	hUART
SP_DEC	$1
CALL	vos_dev_ioctl
POP8	%eax
SP_WR8	%eax	$172
SP_INC	$4
CPY16	%r3	%r0
LD8	(%r3)	$35
CPY16	%r2	%r2
LD8	(%r2)	$1
PUSH16	%r0
PUSH16	hUART
SP_DEC	$1
CALL	vos_dev_ioctl
POP8	%eax
SP_WR8	%eax	$173
SP_INC	$4
CPY16	%r2	%r0
LD8	(%r2)	$36
CPY16	%r2	%r1
LD8	(%r2)	$1
PUSH16	%r0
PUSH16	hUART
SP_DEC	$1
CALL	vos_dev_ioctl
POP8	%eax
SP_WR8	%eax	$174
SP_INC	$4
CPY16	%r2	%r0
LD8	(%r2)	$37
CPY16	%r2	%r1
LD8	(%r2)	$0
PUSH16	%r0
PUSH16	hUART
SP_DEC	$1
CALL	vos_dev_ioctl
POP8	%eax
SP_WR8	%eax	$175
SP_INC	$4
CPY16	%r2	%r0
LD8	(%r2)	$38
CPY16	%r1	%r1
LD8	(%r1)	$0
PUSH16	%r0
PUSH16	hUART
SP_DEC	$1
CALL	vos_dev_ioctl
POP8	%eax
SP_WR8	%eax	$176
SP_INC	$4
LD32	%r0	$Str@3
PUSH16	%r0
CALL	message
SP_INC	$2
@ICO2:	
@IC7:	
PUSH16	$1000
SP_DEC	$1
CALL	vos_delay_msecs
POP8	%eax
SP_WR8	%eax	$175
SP_INC	$2
LD16	%r0	$PS2_MS
CPY16	%r0	%r0
LD8	(%r0)	$0
LD8	%ecx	$0
SP_WR8	%ecx	$174
@IC10:	
SP_STORE	%ecx
INC16	%ecx	$174
CMP8	(%ecx)	$2
JGE	@IC11
@IC12:	
SP_RD8	%eax	$174
AND32	%eax	$255
LD32	%ebx	$2
SHL32	%r0	%eax	%ebx
SP_STORE	%r1
INC16	%r1	$10
ADD16	%r0	%r1	%r0
CPY32	%r0	(%r0)
CMP32	%r0	$0
JNZ	@IC16
@IC17:	
SP_RD8	%eax	$174
AND32	%eax	$255
LD32	%ebx	$1
SHL32	%r0	%eax	%ebx
LD16	%r1	$hUsb
ADD16	%r0	%r1
CPY16	%r0	(%r0)
PUSH16	%r0
SP_DEC	$1
CALL	usbhost_connect_state
POP8	%eax
SP_WR8	%eax	$177
SP_INC	$2
SP_STORE	%ecx
INC16	%ecx	$175
CMP8	(%ecx)	$17
JNZ	@IC20
@IC21:	
LD32	%r0	$Str@4
PUSH16	%r0
CALL	message
SP_INC	$2
SP_RD16	%eax	$174
PUSH8	%eax
CALL	number
SP_INC	$1
SP_STORE	%eax
PUSH16	(%eax)
CALL	message
SP_INC	$2
SP_STORE	%r0
INC16	%r0	$176
CPY16	%r1	%r0
LD8	(%r1)	$33
LD16	%r1	$2
ADD16	%r1	%r0
CPY16	%r1	%r1
LD32	(%r1)	$0
LD16	%r1	$6
ADD16	%r1	%r0
SP_STORE	%r2
INC16	%r2	$186
CPY16	(%r1)	%r2
SP_RD8	%eax	$174
AND32	%eax	$255
LD32	%ebx	$1
SHL32	%r1	%eax	%ebx
LD16	%r2	$hUsb
ADD16	%r1	%r2	%r1
CPY16	%r1	(%r1)
PUSH16	%r0
PUSH16	%r1
SP_DEC	$1
CALL	vos_dev_ioctl
POP8	%eax
SP_WR8	%eax	$194
SP_INC	$4
SP_RD8	%ecx	$190
SP_WR8	%ecx	$191
SP_STORE	%ecx
INC16	%ecx	$190
CMP8	(%ecx)	$0
JZ	@IC24
@IC25:	
LD32	%r0	$Str@5
PUSH16	%r0
CALL	message
SP_INC	$2
SP_RD16	%eax	$191
PUSH8	%eax
CALL	number
SP_INC	$1
SP_STORE	%eax
PUSH16	(%eax)
CALL	message
SP_INC	$2
JUMP	@IC11
@IC24:	
SP_STORE	%r0
INC16	%r0	$176
CPY16	%r1	%r0
LD8	(%r1)	$48
LD16	%r1	$2
ADD16	%r1	%r0
CPY16	%r1	%r1
SP_STORE	%eax
INC16	%eax	$186
CPY32	(%r1)	(%eax)
LD16	%r1	$6
ADD16	%r1	%r0
SP_RD8	%eax	$174
AND32	%eax	$255
LD32	%ebx	$2
SHL32	%r2	%eax	%ebx
SP_STORE	%r3
INC16	%r3	$10
ADD16	%r2	%r3	%r2
CPY16	(%r1)	%r2
SP_RD8	%eax	$174
AND32	%eax	$255
LD32	%ebx	$1
SHL32	%r1	%eax	%ebx
LD16	%r2	$hUsb
ADD16	%r1	%r2
CPY16	%r1	(%r1)
PUSH16	%r0
PUSH16	%r1
SP_DEC	$1
CALL	vos_dev_ioctl
POP8	%eax
SP_WR8	%eax	$196
SP_INC	$4
SP_RD8	%ecx	$192
SP_WR8	%ecx	$191
SP_STORE	%ecx
INC16	%ecx	$192
CMP8	(%ecx)	$0
JZ	@IC28
@IC29:	
LD32	%r0	$Str@6
PUSH16	%r0
CALL	message
SP_INC	$2
SP_RD16	%eax	$191
PUSH8	%eax
CALL	number
SP_INC	$1
SP_STORE	%eax
PUSH16	(%eax)
CALL	message
SP_INC	$2
JUMP	@IC11
@IC28:	
SP_STORE	%r0
INC16	%r0	$176
CPY16	%r1	%r0
LD8	(%r1)	$51
LD16	%r1	$2
ADD16	%r1	%r0
CPY16	%r1	%r1
SP_STORE	%eax
INC16	%eax	$186
CPY32	(%r1)	(%eax)
LD16	%r1	$6
ADD16	%r1	%r0
SP_RD8	%eax	$174
AND32	%eax	$255
LD32	%ebx	$2
SHL32	%r2	%eax	%ebx
SP_STORE	%r3
INC16	%r3	$2
ADD16	%r2	%r3	%r2
CPY16	(%r1)	%r2
SP_RD8	%eax	$174
AND32	%eax	$255
LD32	%ebx	$1
SHL32	%r1	%eax	%ebx
LD16	%r2	$hUsb
ADD16	%r1	%r2
CPY16	%r1	(%r1)
PUSH16	%r0
PUSH16	%r1
SP_DEC	$1
CALL	vos_dev_ioctl
POP8	%eax
SP_WR8	%eax	$197
SP_INC	$4
SP_RD8	%ecx	$193
SP_WR8	%ecx	$191
SP_STORE	%ecx
INC16	%ecx	$193
CMP8	(%ecx)	$0
JZ	@IC32
@IC33:	
LD32	%r0	$Str@7
PUSH16	%r0
CALL	message
SP_INC	$2
SP_RD16	%eax	$191
PUSH8	%eax
CALL	number
SP_INC	$1
SP_STORE	%eax
PUSH16	(%eax)
CALL	message
SP_INC	$2
JUMP	@IC11
@IC32:	
SP_STORE	%r0
INC16	%r0	$176
CPY16	%r1	%r0
LD8	(%r1)	$56
LD16	%r1	$2
ADD16	%r1	%r0
CPY16	%r1	%r1
SP_RD8	%eax	$174
AND32	%eax	$255
LD32	%ebx	$2
SHL32	%r2	%eax	%ebx
SP_STORE	%r3
INC16	%r3	$2
ADD16	%r2	%r3	%r2
CPY32	%r2	(%r2)
CPY32	(%r1)	%r2
LD16	%r1	$6
ADD16	%r1	%r0
SP_STORE	%r2
INC16	%r2	$194
CPY16	(%r1)	%r2
SP_RD8	%eax	$174
AND32	%eax	$255
LD32	%ebx	$1
SHL32	%r1	%eax	%ebx
LD16	%r2	$hUsb
ADD16	%r1	%r2	%r1
CPY16	%r1	(%r1)
PUSH16	%r0
PUSH16	%r1
SP_DEC	$1
CALL	vos_dev_ioctl
POP8	%eax
SP_WR8	%eax	$202
SP_INC	$4
SP_RD8	%ecx	$198
SP_WR8	%ecx	$191
SP_STORE	%ecx
INC16	%ecx	$198
CMP8	(%ecx)	$0
JZ	@IC36
@IC37:	
LD32	%r0	$Str@8
PUSH16	%r0
CALL	message
SP_INC	$2
SP_RD16	%eax	$191
PUSH8	%eax
CALL	number
SP_INC	$1
SP_STORE	%eax
PUSH16	(%eax)
CALL	message
SP_INC	$2
JUMP	@IC11
@IC36:	
SP_RD8	%eax	$174
AND32	%eax	$255
CPY32	%r0	%eax
SP_STORE	%r1
INC16	%r1	$199
ADD16	%r0	%r1
SP_STORE	%r1
INC16	%r1	$194
INC16	%r1	$1
CPY16	%r1	(%r1)
CPY8	(%r0)	%r1
SP_STORE	%r0
INC16	%r0	$201
CPY16	%r1	%r0
LD8	(%r1)	$129
LD16	%r1	$1
ADD16	%r1	%r0
LD8	(%r1)	$6
LD16	%r1	$2
ADD16	%r1	%r0
LD16	(%r1)	$8704
LD16	%r1	$4
ADD16	%r1	%r0
LD16	(%r1)	$0
LD16	%r1	$6
ADD16	%r1	%r0
LD16	(%r1)	$255
SP_STORE	%r1
INC16	%r1	$176
CPY16	%r2	%r1
LD8	(%r2)	$80
LD16	%r2	$2
ADD16	%r2	%r1
CPY16	%r2	%r2
SP_RD8	%eax	$174
AND32	%eax	$255
LD32	%ebx	$2
SHL32	%r3	%eax	%ebx
SP_STORE	%ecx
INC16	%ecx	$209
SP_STORE	%eax
INC16	%eax	$10
CPY16	(%ecx)	%eax
SP_RD16	%eax	$209
ADD16	%r3	%eax
CPY32	%r3	(%r3)
CPY32	(%r2)	%r3
LD16	%r2	$8
ADD16	%r2	%r1
CPY16	(%r2)	%r0
LD16	%r0	$6
ADD16	%r0	%r1
LD16	%r2	$pParser
CPY16	%r3	(%r2)
CPY16	%r3	%r3
CPY16	(%r0)	%r3
CPY16	%r0	(%r2)
CPY16	%r0	%r0
PUSH16	$128
PUSH32	$0
PUSH16	%r0
SP_DEC	$2
CALL	memset
POP16	%eax
SP_WR16	%eax	$219
SP_INC	$8
SP_RD8	%eax	$174
AND32	%eax	$255
LD32	%ebx	$1
SHL32	%r0	%eax	%ebx
LD16	%r2	$hUsb
ADD16	%r0	%r2
CPY16	%r0	(%r0)
PUSH16	%r1
PUSH16	%r0
SP_DEC	$1
CALL	vos_dev_ioctl
POP8	%eax
SP_WR8	%eax	$217
SP_INC	$4
SP_RD8	%ecx	$213
SP_WR8	%ecx	$191
SP_STORE	%ecx
INC16	%ecx	$213
CMP8	(%ecx)	$0
JZ	@IC40
@IC41:	
LD32	%r0	$Str@9
PUSH16	%r0
CALL	message
SP_INC	$2
SP_RD16	%eax	$191
PUSH8	%eax
CALL	number
SP_INC	$1
SP_STORE	%eax
PUSH16	(%eax)
CALL	message
SP_INC	$2
JUMP	@IC11
@IC40:	
LD32	%r0	$Str@10
PUSH16	%r0
CALL	message
SP_INC	$2
PUSH8	$0
CALL	number
SP_INC	$1
SP_STORE	%eax
PUSH16	(%eax)
CALL	message
SP_INC	$2
LD8	%ecx	$0
SP_WR8	%ecx	$214
@IC44:	
SP_STORE	%ecx
INC16	%ecx	$214
CMP8	(%ecx)	$128
JGE	@IC45
@IC46:	
LD16	%r0	$pParser
CPY16	%r0	(%r0)
CPY16	%r0	%r0
SP_RD8	%eax	$214
AND32	%eax	$255
CPY32	%r1	%eax
ADD16	%r0	%r1
CPY8	%r0	(%r0)
PUSH8	%r0
CALL	number
SP_INC	$1
SP_STORE	%ecx
INC16	%ecx	$214
CMP8	(%ecx)	$15
JNZ	@IC50
@IC51:	
SP_RD16	%eax	$0
PUSH16	%eax
CALL	message
SP_INC	$2
@IC50:	
SP_STORE	%ecx
INC16	%ecx	$214
CMP8	(%ecx)	$31
JNZ	@IC54
@IC55:	
SP_RD16	%eax	$0
PUSH16	%eax
CALL	message
SP_INC	$2
@IC54:	
SP_STORE	%ecx
INC16	%ecx	$214
CMP8	(%ecx)	$47
JNZ	@IC58
@IC59:	
SP_RD16	%eax	$0
PUSH16	%eax
CALL	message
SP_INC	$2
@IC58:	
SP_STORE	%ecx
INC16	%ecx	$214
CMP8	(%ecx)	$63
JNZ	@IC62
@IC63:	
SP_RD16	%eax	$0
PUSH16	%eax
CALL	message
SP_INC	$2
@IC62:	
SP_STORE	%ecx
INC16	%ecx	$214
CMP8	(%ecx)	$79
JNZ	@IC66
@IC67:	
SP_RD16	%eax	$0
PUSH16	%eax
CALL	message
SP_INC	$2
@IC66:	
SP_STORE	%ecx
INC16	%ecx	$214
CMP8	(%ecx)	$95
JNZ	@IC70
@IC71:	
SP_RD16	%eax	$0
PUSH16	%eax
CALL	message
SP_INC	$2
@IC70:	
SP_STORE	%ecx
INC16	%ecx	$214
CMP8	(%ecx)	$111
JNZ	@IC74
@IC75:	
SP_RD16	%eax	$0
PUSH16	%eax
CALL	message
SP_INC	$2
@IC74:	
SP_STORE	%ecx
INC16	%ecx	$214
CMP8	(%ecx)	$127
JNZ	@IC78
@IC79:	
SP_RD16	%eax	$0
PUSH16	%eax
CALL	message
SP_INC	$2
@IC78:	
@IC47:	
SP_STORE	%eax
INC16	%eax	$214
INC8	(%eax)	$1
JUMP	@IC44
@IC45:	
PUSH16	pParser
CALL	ResetParser
SP_INC	$2
LD16	%r0	$pParser
CPY16	%r0	(%r0)
INC16	%r0	$128
LD16	(%r0)	$128
PUSH16	pParser
SP_DEC	$1
CALL	FindReport_max_ID
POP8	%eax
SP_WR8	%eax	$217
SP_INC	$2
SP_RD8	max_ReportID	$215
LD8	%ecx	$0
SP_WR8	%ecx	$216
@IC82:	
CPY8	%eax	max_ReportID
AND32	%eax	$255
LD32	%r0	$1
ADD32	%r0	%eax
SP_RD32	%ecx	$216
CMP8	%ecx	%r0
JGES	@IC83
@IC84:	
SP_RD8	%eax	$216
AND32	%eax	$255
LD32	%ebx	$2
SHL32	%r0	%eax	%ebx
LD16	%r1	$ReportID_tbl
ADD16	%r0	%r1
SP_RD8	%r1	$216
PUSH8	%r1
PUSH16	pParser
SP_DEC	$4
CALL	ReportID_Offset
POP32	%eax
SP_WR32	%eax	$220
SP_INC	$3
SP_STORE	%eax
INC16	%eax	$217
CPY16	(%r0)	(%eax)
INC16	%r0	$2
SP_RD8	%r1	$216
PUSH8	%r1
PUSH16	pParser
SP_DEC	$4
CALL	ReportID_DataLength
POP32	%eax
SP_WR32	%eax	$224
SP_INC	$3
SP_STORE	%eax
INC16	%eax	$221
CPY16	(%r0)	(%eax)
@IC85:	
SP_STORE	%eax
INC16	%eax	$216
INC8	(%eax)	$1
JUMP	@IC82
@IC83:	
LD32	%r0	$Str@11
PUSH16	%r0
CALL	message
SP_INC	$2
PUSH8	max_ReportID
CALL	number
SP_INC	$1
SP_STORE	%eax
PUSH16	(%eax)
CALL	message
SP_INC	$2
LD8	%ecx	$0
SP_WR8	%ecx	$216
@IC88:	
SP_STORE	%ecx
INC16	%ecx	$216
CMP8	(%ecx)	$10
JGE	@IC89
@IC90:	
LD16	%r0	$phid_data
CPY16	%r1	(%r0)
INC16	%r1	$5
SP_RD8	%eax	$216
AND32	%eax	$255
LD32	%ebx	$2
SHL32	%r2	%eax	%ebx
ADD16	%r1	%r2
LD16	(%r1)	$0
CPY16	%r0	(%r0)
INC16	%r0	$5
ADD16	%r0	%r2
INC16	%r0	$2
LD16	(%r0)	$0
@IC91:	
SP_STORE	%eax
INC16	%eax	$216
INC8	(%eax)	$1
JUMP	@IC88
@IC89:	
LD16	%r0	$phid_data
CPY16	%r0	(%r0)
INC16	%r0	$4
LD8	(%r0)	$10
SP_RD8	%eax	$174
AND32	%eax	$255
CPY32	%r0	%eax
SP_STORE	%r1
INC16	%r1	$18
ADD16	%r0	%r1
PUSH16	phid_data
PUSH16	pParser
SP_DEC	$4
CALL	FindMouse_Buttons
POP32	%eax
SP_WR32	%eax	$229
SP_INC	$4
SP_STORE	%eax
INC16	%eax	$225
CPY8	(%r0)	(%eax)
SP_RD8	%eax	$174
AND32	%eax	$255
CPY32	%r0	%eax
ADD16	%r0	%r1
CPY8	%r0	(%r0)
CMP8	%r0	$0
JZ	@IC94
@IC95:	
LD16	%r0	$PS2_MS
CPY16	%r0	%r0
LD8	(%r0)	$1
LD16	%r0	$ReportID_MS
LD16	%r1	$ReportID_tbl
PUSH16	$40
PUSH16	%r1
PUSH16	%r0
SP_DEC	$2
CALL	memcpy
POP16	%eax
SP_WR16	%eax	$235
SP_INC	$6
SP_RD8	%eax	$174
AND32	%eax	$255
CPY32	%r0	%eax
SP_STORE	%r1
INC16	%r1	$20
ADD16	%r0	%r1
PUSH16	phid_Bdata
PUSH16	pParser
SP_DEC	$4
CALL	FindMouse_Buttons
POP32	%eax
SP_WR32	%eax	$235
SP_INC	$4
SP_STORE	%eax
INC16	%eax	$231
CPY8	(%r0)	(%eax)
SP_RD8	%eax	$174
AND32	%eax	$255
CPY32	%r0	%eax
SP_STORE	%r1
INC16	%r1	$22
ADD16	%r0	%r1
PUSH16	$48
PUSH16	phid_Xdata
PUSH16	pParser
SP_DEC	$4
CALL	FindMouse_XYW
POP32	%eax
SP_WR32	%eax	$241
SP_INC	$6
SP_STORE	%eax
INC16	%eax	$235
CPY8	(%r0)	(%eax)
SP_RD8	%eax	$174
AND32	%eax	$255
CPY32	%r0	%eax
SP_STORE	%r1
INC16	%r1	$24
ADD16	%r0	%r1
PUSH16	$49
PUSH16	phid_Ydata
PUSH16	pParser
SP_DEC	$4
CALL	FindMouse_XYW
POP32	%eax
SP_WR32	%eax	$245
SP_INC	$6
SP_STORE	%eax
INC16	%eax	$239
CPY8	(%r0)	(%eax)
SP_RD8	%eax	$174
AND32	%eax	$255
CPY32	%r0	%eax
SP_STORE	%r1
INC16	%r1	$26
ADD16	%r0	%r1
PUSH16	$56
PUSH16	phid_Wdata
PUSH16	pParser
SP_DEC	$4
CALL	FindMouse_XYW
POP32	%eax
SP_WR32	%eax	$249
SP_INC	$6
SP_STORE	%eax
INC16	%eax	$243
CPY8	(%r0)	(%eax)
@IC94:	
SP_STORE	%eax
PUSH16	(%eax)
CALL	message
SP_INC	$2
SP_RD8	%eax	$174
AND32	%eax	$255
CPY32	%r0	%eax
SP_STORE	%r1
INC16	%r1	$20
ADD16	%r0	%r1
CPY8	%r0	(%r0)
CMP8	%r0	$0
JZ	@IC96
@IC97:	
LD32	%r0	$Str@12
PUSH16	%r0
CALL	message
SP_INC	$2
SP_STORE	%eax
PUSH16	(%eax)
CALL	message
SP_INC	$2
LD32	%r0	$Str@13
PUSH16	%r0
CALL	message
SP_INC	$2
LD16	%r0	$phid_Bdata
CPY16	%r1	(%r0)
INC16	%r1	$46
CPY8	%r1	(%r1)
PUSH8	%r1
CALL	number
SP_INC	$1
SP_STORE	%eax
PUSH16	(%eax)
CALL	message
SP_INC	$2
LD32	%r1	$Str@14
PUSH16	%r1
CALL	message
SP_INC	$2
CPY16	%r0	(%r0)
INC16	%r0	$47
CPY8	%r0	(%r0)
PUSH8	%r0
CALL	number
SP_INC	$1
SP_STORE	%eax
PUSH16	(%eax)
CALL	message
SP_INC	$2
@IC96:	
SP_RD8	%eax	$174
AND32	%eax	$255
CPY32	%r0	%eax
SP_STORE	%r1
INC16	%r1	$22
ADD16	%r0	%r1
CPY8	%r0	(%r0)
CMP8	%r0	$0
JZ	@IC98
@IC99:	
LD32	%r0	$Str@15
PUSH16	%r0
CALL	message
SP_INC	$2
SP_STORE	%eax
PUSH16	(%eax)
CALL	message
SP_INC	$2
LD32	%r0	$Str@16
PUSH16	%r0
CALL	message
SP_INC	$2
LD16	%r0	$phid_Xdata
CPY16	%r1	(%r0)
INC16	%r1	$46
CPY8	%r1	(%r1)
PUSH8	%r1
CALL	number
SP_INC	$1
SP_STORE	%eax
PUSH16	(%eax)
CALL	message
SP_INC	$2
LD32	%r1	$Str@17
PUSH16	%r1
CALL	message
SP_INC	$2
CPY16	%r0	(%r0)
INC16	%r0	$47
CPY8	%r0	(%r0)
PUSH8	%r0
CALL	number
SP_INC	$1
SP_STORE	%eax
PUSH16	(%eax)
CALL	message
SP_INC	$2
@IC98:	
SP_RD8	%eax	$174
AND32	%eax	$255
CPY32	%r0	%eax
SP_STORE	%r1
INC16	%r1	$24
ADD16	%r0	%r1
CPY8	%r0	(%r0)
CMP8	%r0	$0
JZ	@IC100
@IC101:	
LD32	%r0	$Str@18
PUSH16	%r0
CALL	message
SP_INC	$2
SP_STORE	%eax
PUSH16	(%eax)
CALL	message
SP_INC	$2
LD32	%r0	$Str@19
PUSH16	%r0
CALL	message
SP_INC	$2
LD16	%r0	$phid_Ydata
CPY16	%r1	(%r0)
INC16	%r1	$46
CPY8	%r1	(%r1)
PUSH8	%r1
CALL	number
SP_INC	$1
SP_STORE	%eax
PUSH16	(%eax)
CALL	message
SP_INC	$2
LD32	%r1	$Str@20
PUSH16	%r1
CALL	message
SP_INC	$2
CPY16	%r0	(%r0)
INC16	%r0	$47
CPY8	%r0	(%r0)
PUSH8	%r0
CALL	number
SP_INC	$1
SP_STORE	%eax
PUSH16	(%eax)
CALL	message
SP_INC	$2
@IC100:	
SP_RD8	%eax	$174
AND32	%eax	$255
CPY32	%r0	%eax
SP_STORE	%r1
INC16	%r1	$26
ADD16	%r0	%r1
CPY8	%r0	(%r0)
CMP8	%r0	$0
JZ	@IC102
@IC103:	
LD32	%r0	$Str@21
PUSH16	%r0
CALL	message
SP_INC	$2
SP_STORE	%eax
PUSH16	(%eax)
CALL	message
SP_INC	$2
LD32	%r0	$Str@22
PUSH16	%r0
CALL	message
SP_INC	$2
LD16	%r0	$phid_Wdata
CPY16	%r1	(%r0)
INC16	%r1	$46
CPY8	%r1	(%r1)
PUSH8	%r1
CALL	number
SP_INC	$1
SP_STORE	%eax
PUSH16	(%eax)
CALL	message
SP_INC	$2
LD32	%r1	$Str@23
PUSH16	%r1
CALL	message
SP_INC	$2
CPY16	%r0	(%r0)
INC16	%r0	$47
CPY8	%r0	(%r0)
PUSH8	%r0
CALL	number
SP_INC	$1
SP_STORE	%eax
PUSH16	(%eax)
CALL	message
SP_INC	$2
@IC102:	
SP_STORE	%r0
INC16	%r0	$201
CPY16	%r1	%r0
LD8	(%r1)	$33
LD16	%r1	$1
ADD16	%r1	%r0
LD8	(%r1)	$10
LD16	%r1	$2
ADD16	%r1	%r0
LD16	(%r1)	$0
LD16	%r1	$4
ADD16	%r1	%r0
LD16	(%r1)	$0
LD16	%r1	$6
ADD16	%r1	%r0
LD16	(%r1)	$0
SP_STORE	%r1
INC16	%r1	$176
CPY16	%r2	%r1
LD8	(%r2)	$80
LD16	%r2	$2
ADD16	%r2	%r1
CPY16	%r2	%r2
SP_RD8	%eax	$174
AND32	%eax	$255
LD32	%ebx	$2
SHL32	%r3	%eax	%ebx
SP_STORE	%ecx
INC16	%ecx	$247
SP_STORE	%eax
INC16	%eax	$10
CPY16	(%ecx)	%eax
SP_RD16	%eax	$247
ADD16	%r3	%eax
CPY32	%r3	(%r3)
CPY32	(%r2)	%r3
LD16	%r2	$8
ADD16	%r2	%r1
CPY16	(%r2)	%r0
SP_RD8	%eax	$174
AND32	%eax	$255
LD32	%ebx	$1
SHL32	%r0	%eax	%ebx
LD16	%r2	$hUsb
ADD16	%r0	%r2	%r0
CPY16	%r0	(%r0)
PUSH16	%r1
PUSH16	%r0
SP_DEC	$1
CALL	vos_dev_ioctl
POP8	%eax
SP_WR8	%eax	$253
SP_INC	$4
LD32	%r0	$Str@24
PUSH16	%r0
CALL	message
SP_INC	$2
SP_RD16	%eax	$174
PUSH8	%eax
CALL	number
SP_INC	$1
SP_STORE	%eax
PUSH16	(%eax)
CALL	message
SP_INC	$2
@IC20:	
@IC16:	
@IC13:	
SP_STORE	%eax
INC16	%eax	$174
INC8	(%eax)	$1
JUMP	@IC10
@IC11:	
SP_STORE	%r0
INC16	%r0	$10
CPY32	%r0	(%r0)
CMP32	%r0	$0
JZ	@IC104
@IC105:	
CALL	LED_ON
PUSH16	$9
SP_DEC	$2
CALL	vos_malloc
POP16	%eax
SP_WR16	%eax	$252
SP_INC	$2
SP_RD16	%r0	$250
CPY16	sem_list	%r0
LD16	%r0	$sem_list
CPY16	%r1	(%r0)
LD16	(%r1)	$0
CPY16	%r1	(%r0)
INC16	%r1	$2
LD8	(%r1)	$2
CPY16	%r0	(%r0)
INC16	%r0	$3
LD8	(%r0)	$0
SP_STORE	%r0
INC16	%r0	$252
PUSH16	$0
PUSH16	%r0
CALL	vos_init_semaphore
SP_INC	$4
SP_STORE	%ecx
ADD16	%ecx	$262
LD16	%ebx	$5
ADD16	(%ecx)	%r0	%ebx
PUSH16	$0
SP_STORE	%eax
ADD16	%eax	$264
PUSH16	(%eax)
CALL	vos_init_semaphore
SP_INC	$4
SP_STORE	%r1
ADD16	%r1	$264
PUSH16	$28
PUSH32	$0
PUSH16	%r1
SP_DEC	$2
CALL	memset
SP_STORE	%eax
ADD16	%eax	$302
POP16	(%eax)
SP_INC	$8
CPY16	%r2	%r1
CPY16	%r2	%r2
INC16	%r2	$11
LD8	(%r2)	$96
LD16	%r3	$7
ADD16	%r3	%r1
SP_STORE	%r2
INC16	%r2	$28
CPY16	(%r3)	%r2
CPY16	%r3	%r1
CPY16	%r3	%r3
CPY16	%r3	%r3
SP_STORE	%ecx
ADD16	%ecx	$294
SP_STORE	%eax
ADD16	%eax	$2
CPY16	(%ecx)	%eax
SP_STORE	%ecx
ADD16	%ecx	$296
SP_STORE	%eax
ADD16	%eax	$294
CPY16	%eax	(%eax)
CPY32	(%ecx)	(%eax)
SP_STORE	%eax
ADD16	%eax	$296
CPY32	(%r3)	(%eax)
LD16	%r3	$4
ADD16	%r3	%r1
CPY16	(%r3)	%r0
CPY16	%r0	%r1
INC16	%r0	$14
INC16	%r0	$11
LD8	(%r0)	$96
LD16	%r0	$14
ADD16	%r0	%r1
LD16	%r3	$7
ADD16	%r3	%r0
CPY16	(%r3)	%r2
CPY16	%r1	%r1
INC16	%r1	$14
CPY16	%r1	%r1
SP_STORE	%eax
ADD16	%eax	$294
LD16	%ebx	$4
ADD16	%r2	(%eax)	%ebx
CPY32	%r2	(%r2)
CPY32	(%r1)	%r2
INC16	%r0	$4
SP_STORE	%eax
ADD16	%eax	$262
CPY16	(%r0)	(%eax)
LD8	%ecx	$255
SP_WR8	%ecx	$174
@IC106:	
LD8	%ecx	$1
CMP8	%ecx	$0
JZ	@IC107
@IC108:	
SP_STORE	%ecx
ADD16	%ecx	$174
CMP8	(%ecx)	$1
JZ	@IC109
@IC111:	
SP_STORE	%r0
INC16	%r0	$10
CPY32	%r0	(%r0)
CMP32	%r0	$0
JZ	@IC109
@IC110:	
LD16	%r0	$sem_list
CPY16	%r0	(%r0)
INC16	%r0	$5
SP_STORE	%r1
INC16	%r1	$252
CPY16	(%r0)	%r1
SP_STORE	%r0
ADD16	%r0	$264
LD16	%r1	$9
ADD16	%r1	%r0
SP_STORE	%r2
INC16	%r2	$199
INC16	%r2	$0
CPY8	%r2	(%r2)
CPY8	%eax	%r2
AND16	%eax	$255
CPY16	(%r1)	%eax
CPY16	%r1	%r0
CPY16	%r1	%r1
INC16	%r1	$6
LD8	(%r1)	$15
LD16	%r1	$hUsb
CPY16	%r1	(%r1)
CPY16	%r0	%r0
PUSH16	$0
PUSH16	$14
PUSH16	%r0
PUSH16	%r1
SP_DEC	$1
CALL	vos_dev_read
SP_STORE	%eax
ADD16	%eax	$309
POP8	(%eax)
SP_INC	$8
SP_STORE	%eax
ADD16	%eax	$300
CPY8	%ecx	(%eax)
SP_WR8	%ecx	$191
SP_STORE	%ecx
ADD16	%ecx	$300
CMP8	(%ecx)	$0
JZ	@IC114
@IC115:	
LD32	%r0	$Str@25
PUSH16	%r0
CALL	message
SP_INC	$2
SP_RD16	%eax	$191
PUSH8	%eax
CALL	number
SP_INC	$1
SP_STORE	%eax
PUSH16	(%eax)
CALL	message
SP_INC	$2
SP_STORE	%r0
INC16	%r0	$10
LD32	(%r0)	$0
CALL	LED_OFF
JUMP	@IC107
@IC114:	
@IC109:	
SP_STORE	%ecx
INC16	%ecx	$174
CMP8	(%ecx)	$0
JZ	@IC118
@IC120:	
SP_STORE	%r0
INC16	%r0	$10
INC16	%r0	$4
CPY32	%r0	(%r0)
CMP32	%r0	$0
JZ	@IC118
@IC119:	
LD16	%r0	$sem_list
CPY16	%r0	(%r0)
INC16	%r0	$5
INC16	%r0	$2
SP_STORE	%r1
INC16	%r1	$252
INC16	%r1	$5
CPY16	(%r0)	%r1
SP_STORE	%r0
ADD16	%r0	$264
LD16	%r1	$14
ADD16	%r1	%r0
LD16	%r2	$9
ADD16	%r2	%r1
SP_STORE	%r3
INC16	%r3	$199
INC16	%r3	$1
CPY8	%r3	(%r3)
CPY8	%eax	%r3
AND16	%eax	$255
CPY16	(%r2)	%eax
CPY16	%r0	%r0
INC16	%r0	$14
INC16	%r0	$6
LD8	(%r0)	$15
LD16	%r0	$hUsb
INC16	%r0	$2
CPY16	%r0	(%r0)
CPY16	%r1	%r1
PUSH16	$0
PUSH16	$14
PUSH16	%r1
PUSH16	%r0
SP_DEC	$1
CALL	vos_dev_read
SP_STORE	%eax
ADD16	%eax	$310
POP8	(%eax)
SP_INC	$8
SP_STORE	%eax
ADD16	%eax	$301
CPY8	%ecx	(%eax)
SP_WR8	%ecx	$191
SP_STORE	%ecx
ADD16	%ecx	$301
CMP8	(%ecx)	$0
JZ	@IC123
@IC124:	
LD32	%r0	$Str@26
PUSH16	%r0
CALL	message
SP_INC	$2
SP_RD16	%eax	$191
PUSH8	%eax
CALL	number
SP_INC	$1
SP_STORE	%eax
PUSH16	(%eax)
CALL	message
SP_INC	$2
SP_STORE	%r0
INC16	%r0	$10
INC16	%r0	$4
LD32	(%r0)	$0
JUMP	@IC107
@IC123:	
@IC118:	
PUSH16	sem_list
SP_DEC	$1
CALL	vos_wait_semaphore_ex
SP_STORE	%eax
ADD16	%eax	$305
POP8	(%eax)
SP_INC	$2
SP_STORE	%eax
ADD16	%eax	$302
CPY8	%ecx	(%eax)
SP_WR8	%ecx	$174
LD32	%r0	$Str@27
PUSH16	%r0
CALL	message
SP_INC	$2
SP_STORE	%eax
ADD16	%eax	$302
PUSH8	(%eax)
CALL	number
SP_INC	$1
LD32	%r0	$Str@28
PUSH16	%r0
CALL	message
SP_INC	$2
SP_STORE	%ecx
ADD16	%ecx	$302
CMP8	(%ecx)	$0
JNZ	@IC128
@IC129:	
LD8	%ecx	$0
SP_WR8	%ecx	$216
@ICO0:	
@IC132:	
SP_STORE	%r0
ADD16	%r0	$264
INC16	%r0	$9
CPY16	%r0	(%r0)
SP_RD32	%ecx	$216
CMP8	%ecx	%r0
JGE	@IC133
@IC134:	
SP_RD8	%eax	$216
AND32	%eax	$255
CPY32	%r0	%eax
SP_STORE	%r1
ADD16	%r1	$28
ADD16	%r0	%r1
CPY8	%r0	(%r0)
PUSH8	%r0
CALL	number
SP_INC	$1
@IC135:	
SP_STORE	%eax
INC16	%eax	$216
INC8	(%eax)	$1
JUMP	@IC132
@IC133:	
SP_STORE	%eax
PUSH16	(%eax)
CALL	message
SP_INC	$2
JUMP	@IC127
@IC128:	
SP_STORE	%ecx
INC16	%ecx	$174
CMP8	(%ecx)	$1
JNZ	@IC138
@IC139:	
LD8	%ecx	$0
SP_WR8	%ecx	$216
@ICO1:	
@IC142:	
SP_STORE	%r0
ADD16	%r0	$264
INC16	%r0	$14
INC16	%r0	$9
CPY16	%r0	(%r0)
SP_RD32	%ecx	$216
CMP8	%ecx	%r0
JGE	@IC143
@IC144:	
SP_RD8	%eax	$216
AND32	%eax	$255
CPY32	%r0	%eax
SP_STORE	%r1
ADD16	%r1	$28
ADD16	%r0	%r1
CPY8	%r0	(%r0)
PUSH8	%r0
CALL	number
SP_INC	$1
@IC145:	
SP_STORE	%eax
INC16	%eax	$216
INC8	(%eax)	$1
JUMP	@IC142
@IC143:	
SP_STORE	%eax
PUSH16	(%eax)
CALL	message
SP_INC	$2
@IC138:	
@IC127:	
SP_RD8	%eax	$174
AND32	%eax	$255
CPY32	%r0	%eax
SP_STORE	%r1
INC16	%r1	$20
ADD16	%r0	%r1
CPY8	%r0	(%r0)
CMP8	%r0	$0
JZ	@IC148
@IC149:	
SP_STORE	%r0
INC16	%r0	$28
LD16	%r1	$ReportID_MS
PUSH16	%r1
PUSH16	phid_Bdata
PUSH16	%r0
CALL	GetValue
SP_INC	$6
LD16	%r0	$PS2_MS
INC16	%r0	$2
LD16	%r1	$phid_Bdata
CPY16	%r1	(%r1)
CPY32	%r1	(%r1)
CPY8	(%r0)	%r1
LD32	%r1	$Str@29
PUSH16	%r1
CALL	message
SP_INC	$2
CPY8	%r0	(%r0)
PUSH8	%r0
CALL	number
SP_INC	$1
SP_RD16	%eax	$0
PUSH16	%eax
CALL	message
SP_INC	$2
@IC148:	
SP_RD8	%eax	$174
AND32	%eax	$255
CPY32	%r0	%eax
SP_STORE	%r1
INC16	%r1	$22
ADD16	%r0	%r1
CPY8	%r0	(%r0)
CMP8	%r0	$0
JZ	@IC150
@IC151:	
SP_STORE	%r0
INC16	%r0	$28
LD16	%r1	$ReportID_MS
PUSH16	%r1
PUSH16	phid_Xdata
PUSH16	%r0
CALL	GetValueXY
SP_INC	$6
LD16	%r0	$PS2_MS
INC16	%r0	$3
LD16	%r1	$phid_Xdata
CPY16	%r1	(%r1)
CPY32	%r1	(%r1)
CPY16	(%r0)	%r1
CPY16	%r0	%r0
CPY16	pDATA	%r0
LD32	%r0	$Str@30
PUSH16	%r0
CALL	message
SP_INC	$2
INC16	pDATA	$1
CPY8	%r0	(pDATA)
PUSH8	%r0
CALL	number
SP_INC	$1
DEC16	pDATA	$1
CPY8	%r0	(pDATA)
PUSH8	%r0
CALL	number
SP_INC	$1
SP_RD16	%eax	$0
PUSH16	%eax
CALL	message
SP_INC	$2
@IC150:	
SP_RD8	%eax	$174
AND32	%eax	$255
CPY32	%r0	%eax
SP_STORE	%r1
INC16	%r1	$24
ADD16	%r0	%r1
CPY8	%r0	(%r0)
CMP8	%r0	$0
JZ	@IC152
@IC153:	
SP_STORE	%r0
INC16	%r0	$28
LD16	%r1	$ReportID_MS
PUSH16	%r1
PUSH16	phid_Ydata
PUSH16	%r0
CALL	GetValueXY
SP_INC	$6
LD16	%r0	$PS2_MS
INC16	%r0	$5
LD16	%r1	$phid_Ydata
CPY16	%r1	(%r1)
CPY32	%r1	(%r1)
CPY16	(%r0)	%r1
CPY16	%r0	%r0
CPY16	pDATA	%r0
LD32	%r0	$Str@31
PUSH16	%r0
CALL	message
SP_INC	$2
INC16	pDATA	$1
CPY8	%r0	(pDATA)
PUSH8	%r0
CALL	number
SP_INC	$1
DEC16	pDATA	$1
CPY8	%r0	(pDATA)
PUSH8	%r0
CALL	number
SP_INC	$1
SP_RD16	%eax	$0
PUSH16	%eax
CALL	message
SP_INC	$2
@IC152:	
SP_RD8	%eax	$174
AND32	%eax	$255
CPY32	%r0	%eax
SP_STORE	%r1
INC16	%r1	$26
ADD16	%r0	%r1
CPY8	%r0	(%r0)
CMP8	%r0	$0
JZ	@IC154
@IC155:	
SP_STORE	%r0
INC16	%r0	$28
LD16	%r1	$ReportID_MS
PUSH16	%r1
PUSH16	phid_Wdata
PUSH16	%r0
CALL	GetValue
SP_INC	$6
LD16	%r0	$PS2_MS
INC16	%r0	$7
LD16	%r1	$phid_Wdata
CPY16	%r1	(%r1)
CPY32	%r1	(%r1)
CPY16	(%r0)	%r1
CPY16	%r0	%r0
CPY16	pDATA	%r0
LD32	%r0	$Str@32
PUSH16	%r0
CALL	message
SP_INC	$2
INC16	pDATA	$1
CPY8	%r0	(pDATA)
PUSH8	%r0
CALL	number
SP_INC	$1
DEC16	pDATA	$1
CPY8	%r0	(pDATA)
PUSH8	%r0
CALL	number
SP_INC	$1
SP_RD16	%eax	$0
PUSH16	%eax
CALL	message
SP_INC	$2
@IC154:	
SP_RD8	%eax	$174
AND32	%eax	$255
CPY32	%r0	%eax
SP_STORE	%r1
INC16	%r1	$20
ADD16	%r0	%r1
CPY8	%r0	(%r0)
CMP8	%r0	$0
JNZ	@IC158
@IC161:	
SP_RD8	%eax	$174
AND32	%eax	$255
CPY32	%r0	%eax
SP_STORE	%r1
INC16	%r1	$22
ADD16	%r0	%r1
CPY8	%r0	(%r0)
CMP8	%r0	$0
JNZ	@IC158
@IC160:	
SP_RD8	%eax	$174
AND32	%eax	$255
CPY32	%r0	%eax
SP_STORE	%r1
INC16	%r1	$24
ADD16	%r0	%r1
CPY8	%r0	(%r0)
CMP8	%r0	$0
JNZ	@IC158
@IC159:	
SP_RD8	%eax	$174
AND32	%eax	$255
CPY32	%r0	%eax
SP_STORE	%r1
INC16	%r1	$26
ADD16	%r0	%r1
CPY8	%r0	(%r0)
CMP8	%r0	$0
JZ	@IC157
@IC158:	
LD16	%r0	$PS2_MS
INC16	%r0	$1
LD8	(%r0)	$1
JUMP	@IC156
@IC157:	
LD8	%ecx	$0
SP_WR8	%ecx	$216
@IC162:	
SP_STORE	%ecx
INC16	%ecx	$216
CMP8	(%ecx)	$8
JGE	@IC163
@IC164:	
SP_RD8	%eax	$216
AND32	%eax	$255
CPY32	%r1	%eax
SP_STORE	%r0
INC16	%r0	$28
ADD16	%r1	%r0
CPY8	%r1	(%r1)
PUSH8	%r1
CALL	D_number
SP_INC	$1
LD16	%r1	$PS2_KB
INC16	%r1	$1
SP_RD8	%eax	$216
AND32	%eax	$255
CPY32	%r2	%eax
ADD16	%r1	%r2
SP_RD8	%eax	$216
AND32	%eax	$255
CPY32	%r2	%eax
ADD16	%r0	%r2
CPY8	%r0	(%r0)
CPY8	(%r1)	%r0
@IC165:	
SP_STORE	%eax
INC16	%eax	$216
INC8	(%eax)	$1
JUMP	@IC162
@IC163:	
LD16	%r0	$PS2_KB
CPY16	%r0	%r0
LD8	(%r0)	$0
PUSH16	pPS2_KB
SP_DEC	$4
CALL	KBParse
SP_STORE	%eax
ADD16	%eax	$309
POP32	(%eax)
SP_INC	$2
LD16	%r0	$pPS2_KB
CPY16	%r0	(%r0)
INC16	%r0	$9
CPY8	%r0	(%r0)
CMP8	%r0	$0
JNZ	@IC169
@IC170:	
LD16	%r0	$pPS2_KB
CPY16	%r1	(%r0)
INC16	%r1	$10
SP_STORE	%ecx
ADD16	%ecx	$307
CPY16	(%ecx)	%r1
CPY16	%r0	(%r0)
INC16	%r0	$24
SP_STORE	%ecx
ADD16	%ecx	$309
CPY16	(%ecx)	%r0
JUMP	@IC168
@IC169:	
LD16	%r0	$pPS2_KB
CPY16	%r1	(%r0)
INC16	%r1	$24
SP_STORE	%ecx
ADD16	%ecx	$307
CPY16	(%ecx)	%r1
CPY16	%r0	(%r0)
INC16	%r0	$10
SP_STORE	%ecx
ADD16	%ecx	$309
CPY16	(%ecx)	%r0
@IC168:	
LD8	%ecx	$0
SP_WR8	%ecx	$216
@IC173:	
SP_STORE	%ecx
INC16	%ecx	$216
CMP8	(%ecx)	$14
JGE	@IC174
@IC175:	
LD16	%r0	$pPS2_KB
CPY16	%r0	(%r0)
INC16	%r0	$40
CPY16	%r0	(%r0)
SP_RD16	%eax	$216
PUSH8	%eax
PUSH16	%r0
SP_DEC	$1
CALL	CHECK_BIT
SP_STORE	%eax
ADD16	%eax	$315
POP8	(%eax)
SP_INC	$3
SP_STORE	%ecx
ADD16	%ecx	$311
CMP8	(%ecx)	$0
JZ	@IC179
@IC180:	
SP_RD8	%eax	$216
AND32	%eax	$255
CPY32	%r0	%eax
SP_STORE	%eax
ADD16	%eax	$309
ADD16	%r0	(%eax)	%r0
CPY8	%r0	(%r0)
AND32	%r0	$255
PUSH8	%r0
SP_DEC	$1
CALL	USB_PS2
SP_STORE	%eax
ADD16	%eax	$314
POP8	(%eax)
SP_INC	$1
SP_STORE	%ecx
ADD16	%ecx	$313
SP_STORE	%eax
ADD16	%eax	$312
CPY8	(%ecx)	(%eax)
SP_STORE	%ecx
ADD16	%ecx	$313
CMP8	(%ecx)	$128
JLE	@IC181
@IC182:	
PUSH8	$224
SP_DEC	$1
CALL	PS2KB_write
SP_STORE	%eax
ADD16	%eax	$316
POP8	(%eax)
SP_INC	$1
PUSH8	$240
SP_DEC	$1
CALL	PS2KB_write
SP_STORE	%eax
ADD16	%eax	$317
POP8	(%eax)
SP_INC	$1
SP_STORE	%eax
ADD16	%eax	$313
CPY8	%eax	(%eax)
AND32	%eax	$255
LD32	%ebx	$128
SUB32	%r0	%eax	%ebx
PUSH8	%r0
SP_DEC	$1
CALL	PS2KB_write
SP_STORE	%eax
ADD16	%eax	$318
POP8	(%eax)
SP_INC	$1
@IC181:	
SP_STORE	%ecx
ADD16	%ecx	$313
CMP8	(%ecx)	$127
JGE	@IC185
@IC186:	
PUSH8	$240
SP_DEC	$1
CALL	PS2KB_write
SP_STORE	%eax
ADD16	%eax	$319
POP8	(%eax)
SP_INC	$1
SP_STORE	%eax
ADD16	%eax	$313
PUSH8	(%eax)
SP_DEC	$1
CALL	PS2KB_write
SP_STORE	%eax
ADD16	%eax	$320
POP8	(%eax)
SP_INC	$1
@IC185:	
@IC179:	
@IC176:	
SP_STORE	%eax
INC16	%eax	$216
INC8	(%eax)	$1
JUMP	@IC173
@IC174:	
LD8	%ecx	$0
SP_WR8	%ecx	$216
@IC189:	
SP_STORE	%ecx
INC16	%ecx	$216
CMP8	(%ecx)	$14
JGE	@IC190
@IC191:	
LD16	%r0	$pPS2_KB
CPY16	%r0	(%r0)
INC16	%r0	$38
CPY16	%r0	(%r0)
SP_RD16	%eax	$216
PUSH8	%eax
PUSH16	%r0
SP_DEC	$1
CALL	CHECK_BIT
SP_STORE	%eax
ADD16	%eax	$323
POP8	(%eax)
SP_INC	$3
SP_STORE	%ecx
ADD16	%ecx	$319
CMP8	(%ecx)	$0
JZ	@IC195
@IC196:	
SP_RD8	%eax	$216
AND32	%eax	$255
CPY32	%r0	%eax
SP_STORE	%eax
ADD16	%eax	$307
ADD16	%r0	(%eax)	%r0
CPY8	%r0	(%r0)
AND32	%r0	$255
PUSH8	%r0
SP_DEC	$1
CALL	USB_PS2
SP_STORE	%eax
ADD16	%eax	$322
POP8	(%eax)
SP_INC	$1
SP_STORE	%ecx
ADD16	%ecx	$313
SP_STORE	%eax
ADD16	%eax	$320
CPY8	(%ecx)	(%eax)
SP_STORE	%ecx
ADD16	%ecx	$313
CMP8	(%ecx)	$128
JLE	@IC197
@IC198:	
PUSH8	$224
SP_DEC	$1
CALL	PS2KB_write
SP_STORE	%eax
ADD16	%eax	$323
POP8	(%eax)
SP_INC	$1
SP_STORE	%eax
ADD16	%eax	$313
CPY8	%eax	(%eax)
AND32	%eax	$255
LD32	%ebx	$128
SUB32	%r0	%eax	%ebx
PUSH8	%r0
SP_DEC	$1
CALL	PS2KB_write
SP_STORE	%eax
ADD16	%eax	$324
POP8	(%eax)
SP_INC	$1
@IC197:	
SP_STORE	%ecx
ADD16	%ecx	$313
CMP8	(%ecx)	$128
JNZ	@IC201
@IC202:	
PUSH8	$252
SP_DEC	$1
CALL	PS2KB_write
SP_STORE	%eax
ADD16	%eax	$325
POP8	(%eax)
SP_INC	$1
@IC201:	
SP_STORE	%ecx
ADD16	%ecx	$313
CMP8	(%ecx)	$127
JGE	@IC205
@IC206:	
SP_STORE	%eax
ADD16	%eax	$313
PUSH8	(%eax)
SP_DEC	$1
CALL	PS2KB_write
SP_STORE	%eax
ADD16	%eax	$326
POP8	(%eax)
SP_INC	$1
@IC205:	
@IC195:	
@IC192:	
SP_STORE	%eax
INC16	%eax	$216
INC8	(%eax)	$1
JUMP	@IC189
@IC190:	
@IC156:	
SP_STORE	%eax
PUSH16	(%eax)
CALL	message
SP_INC	$2
JUMP	@IC106
@IC107:	
@IC104:	
@IC8:	
LD8	%ecx	$1
CMP8	%ecx	$0
JNZ	@IC7
@IC9:	
SP_INC	$255
SP_INC	$70
POP32	%r3
POP32	%r2
POP32	%r1
POP32	%r0
RTS	
.FUNC_END	"USB_thread"

PS2_MSthread:	
.GLOBAL	 DO_NOT_EXPORT  "PS2_MSthread"

.FUNCTION	"PS2_MSthread"	
PUSH32	%r0
PUSH32	%r1
SP_DEC	$4
LD32	%r0	$0
@IC209:	
SP_DEC	$1
CALL	PS2dev_host_req
POP8	%eax
SP_WR8	%eax	$0
SP_STORE	%eax
CPY8	%r1	(%eax)
CMP8	%r1	$0
JZ	@IC213
@IC215:	
LD16	%r1	$PS2_MS
CPY8	%r1	(%r1)
CMP8	%r1	$0
JZ	@IC213
@IC214:	
@IC216:	
SP_STORE	%r1
INC16	%r1	$1
PUSH16	%r1
SP_DEC	$1
CALL	PS2dev_read
POP8	%eax
SP_WR8	%eax	$4
SP_INC	$2
SP_STORE	%ecx
INC16	%ecx	$2
CMP8	(%ecx)	$0
JZ	@IC217
@IC218:	
JUMP	@IC216
@IC217:	
LD16	%r1	$PS2_MS
PUSH16	%r1
SP_RD16	%eax	$3
PUSH8	%eax
CALL	MS_cmd
SP_INC	$3
LD32	%r0	$50000
JUMP	@IC212
@IC213:	
LD16	%r1	$PS2_MS
INC16	%r1	$9
CPY8	%r1	(%r1)
CMP8	%r1	$0
JZ	@IC219
@IC223:	
LD16	%r1	$PS2_MS
INC16	%r1	$10
CPY8	%r1	(%r1)
CMP8	%r1	$0
JZ	@IC219
@IC222:	
LD16	%r1	$PS2_MS
INC16	%r1	$1
CPY8	%r1	(%r1)
CMP8	%r1	$0
JZ	@IC219
@IC221:	
CMP32	%r0	$0
JNZ	@IC219
@IC220:	
LD16	%r1	$PS2_MS
PUSH16	%r1
SP_DEC	$1
CALL	MS_wr_packet
POP8	%eax
SP_WR8	%eax	$5
SP_INC	$2
INC16	%r1	$1
LD8	(%r1)	$0
@IC219:	
CMP32	%r0	$0
JLE	@IC226
@IC227:	
DEC32	%r0	$1
@IC226:	
@IC212:	
@IC210:	
LD8	%ecx	$1
CMP8	%ecx	$0
JNZ	@IC209
@IC211:	
SP_INC	$4
POP32	%r1
POP32	%r0
RTS	
.FUNC_END	"PS2_MSthread"

PS2_KBthread:	
.GLOBAL	 DO_NOT_EXPORT  "PS2_KBthread"

.FUNCTION	"PS2_KBthread"	
RTS	
.FUNC_END	"PS2_KBthread"

