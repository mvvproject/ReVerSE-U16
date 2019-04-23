# 1 u16_vnc2_firmware.c













# 1 "u16_vnc2_firmware.h" 1
















# 1 "C:\ProgramData\FTDI\Vinculum II Toolchain\Firmware\kernel\include\vos.h" 1


































typedef unsigned char (*PF)(unsigned char);
typedef void (*PF_OPEN)(void *);
typedef void (*PF_CLOSE)(void *);
typedef unsigned char (*PF_IOCTL)(unsigned char *);
typedef unsigned char (*PF_IO)(unsigned char *, unsigned short, unsigned short *);
typedef void (*PF_INT)(void);

typedef void (*fnVoidPtr)(void);









void vos_init(unsigned char quantum, unsigned short tick_cnt, unsigned char num_devices);
void vos_start_scheduler(void);












enum {
IDLE,
BLOCKED,
READY,
RUNNING,
DELAYED,
GONE
};


typedef struct _vos_tcb_t {
struct _vos_tcb_t *next;
unsigned char			  state;
unsigned char			  orig_priority;
unsigned char			  priority;
unsigned char			  quantum;
unsigned short			  delay;
unsigned short			  sp;
unsigned int			  eax;
unsigned int			  ebx;
unsigned int			  ecx;
unsigned int			  r0;
unsigned int			  r1;
unsigned int			  r2;
unsigned int			  r3;
void			  *system_data;
void			  *system_profiler;
unsigned short			  flags;
void			  *semaphore_list;
} vos_tcb_t;

vos_tcb_t *vos_create_thread(unsigned char priority, unsigned short stack, fnVoidPtr function, short arg_size, pack ...);
vos_tcb_t *vos_create_thread_ex(unsigned char priority, unsigned short stack, fnVoidPtr function, char *name, short arg_size, pack ...);

void vos_set_idle_thread_tcb_size(unsigned short tcb_size);
vos_tcb_t *vos_get_idle_thread_tcb(void);

unsigned char vos_delay_msecs(unsigned short ms);
void vos_delay_cancel(vos_tcb_t *tcb);















typedef struct _vos_mutex_t {
vos_tcb_t *threads;                
vos_tcb_t *owner;                  
unsigned char	  attr;                    
unsigned char	  ceiling;                 
} vos_mutex_t;





void vos_init_mutex(vos_mutex_t *m, unsigned char state);
void vos_lock_mutex(vos_mutex_t *m);
unsigned char vos_trylock_mutex(vos_mutex_t *m);
void vos_unlock_mutex(vos_mutex_t *m);
unsigned char vos_get_priority_ceiling(vos_mutex_t *m);
void vos_set_priority_ceiling(vos_mutex_t *m, unsigned char priority);






typedef struct _vos_semaphore_t {
short	  val;
vos_tcb_t *threads;
char	  usage_count;
} vos_semaphore_t;


typedef struct _vos_semaphore_list_t {
struct _vos_semaphore_list_t *next;
char						 siz;
unsigned char						 flags;
unsigned char						 result;
vos_semaphore_t				 *list[1];
} vos_semaphore_list_t;







void vos_init_semaphore(vos_semaphore_t *sem, short count);
void vos_wait_semaphore(vos_semaphore_t *s);
char vos_wait_semaphore_ex(vos_semaphore_list_t *l);
void vos_signal_semaphore(vos_semaphore_t *s);
void vos_signal_semaphore_from_isr(vos_semaphore_t *s);





typedef struct _vos_cond_var_t {
vos_tcb_t	*threads;
vos_mutex_t *lock;
unsigned char		state;
} vos_cond_var_t;

void vos_init_cond_var(vos_cond_var_t *cv);
void vos_wait_cond_var(vos_cond_var_t *cv, vos_mutex_t *m);
void vos_signal_cond_var(vos_cond_var_t *cv);





unsigned short vos_stack_usage(vos_tcb_t *tcb);
void vos_start_profiler(void);
void vos_stop_profiler(void);
unsigned int vos_get_profile(vos_tcb_t *tcb);

typedef struct _vos_system_data_area_t {
struct _vos_system_data_area_t *next;
vos_tcb_t					   *tcb;
unsigned int						   count;
char						   *name;
} vos_system_data_area_t;










void vos_set_clock_frequency(unsigned char frequency);
unsigned char vos_get_clock_frequency(void);






unsigned char vos_get_package_type(void);


unsigned char vos_get_chip_revision(void);








unsigned char vos_power_down(unsigned char wakeMask);


void vos_halt_cpu(void);


void vos_reset_vnc2(void);








unsigned char vos_wdt_enable(unsigned char bitPosition);
void vos_wdt_clear(void);


unsigned int vos_get_kernel_clock(void);
void vos_reset_kernel_clock(void);





# 1 "C:\ProgramData\FTDI\Vinculum II Toolchain\Firmware\kernel\include\devman.h" 1
























typedef struct _vos_driver_t {
PF_OPEN	 open;                     
PF_CLOSE close;                    
PF_IO	 read;                     
PF_IO	 write;                    
PF_IOCTL ioctl;                    
PF_INT	 interrupt;                
unsigned char	 flags;                    
} vos_driver_t;


typedef struct _vos_device_t {
vos_mutex_t	 mutex;                
vos_driver_t *driver;              
void		 *context;             
} vos_device_t;









void vos_dev_init(unsigned char dev_num, vos_driver_t *driver_cb, void *context);


unsigned short vos_dev_open(unsigned char dev_num);
unsigned char vos_dev_read(unsigned short h, unsigned char *buf, unsigned short num_to_read, unsigned short *num_read);
unsigned char vos_dev_write(unsigned short h, unsigned char *buf, unsigned short num_to_write, unsigned short *num_written);
unsigned char vos_dev_ioctl(unsigned short h, void *cb);
void vos_dev_close(unsigned short h);














void vos_enable_interrupts(unsigned int mask);
void vos_disable_interrupts(unsigned int mask);








# 256 "C:\ProgramData\FTDI\Vinculum II Toolchain\Firmware\kernel\include\vos.h" 2
# 1 "C:\ProgramData\FTDI\Vinculum II Toolchain\Firmware\kernel\include\dma.h" 1


























enum dma_status {
DMA_OK = 0,
DMA_INVALID_PARAMETER,
DMA_ACQUIRE_ERROR,
DMA_ENABLE_ERROR,
DMA_DISABLE_ERROR,
DMA_CONFIGURE_ERROR,
DMA_ERROR,
DMA_FIFO_ERROR
};


typedef struct _vos_dma_config_t {
union
{
unsigned short io_addr;
unsigned char  *mem_addr;
} src;
union
{
unsigned short io_addr;
unsigned char  *mem_addr;
}	   dest;
unsigned short bufsiz;
unsigned char  mode;
unsigned char  fifosize;
unsigned char  flow_control;
unsigned char  afull_trigger;
} vos_dma_config_t;


















unsigned short vos_dma_acquire(void);
void vos_dma_release(unsigned short h);
unsigned char vos_dma_reset(unsigned short h);
unsigned char vos_dma_configure(unsigned short h, vos_dma_config_t *cb);
unsigned char vos_dma_retained_configure(unsigned short h, unsigned char *mem_addr, unsigned short bufsiz);
unsigned char vos_dma_enable(unsigned short h);
unsigned char vos_dma_disable(unsigned short h);
void vos_dma_wait_on_complete(unsigned short h);
unsigned short vos_dma_get_fifo_data_register(unsigned short h);
unsigned char vos_dma_get_fifo_flow_control(unsigned short h);
unsigned short vos_dma_get_fifo_count(unsigned short h);
unsigned char vos_dma_get_fifo_data(unsigned short h, unsigned char *dat);


# 257 "C:\ProgramData\FTDI\Vinculum II Toolchain\Firmware\kernel\include\vos.h" 2
# 1 "C:\ProgramData\FTDI\Vinculum II Toolchain\Firmware\kernel\include\iomux.h" 1























enum IOMUX_SIGNALS {


IOMUX_IN_DEBUGGER = 0,

IOMUX_IN_UART_RXD,
IOMUX_IN_UART_CTS_N,
IOMUX_IN_UART_DSR_N,
IOMUX_IN_UART_DCD,
IOMUX_IN_UART_RI,

IOMUX_IN_FIFO_DATA_0,
IOMUX_IN_FIFO_DATA_1,
IOMUX_IN_FIFO_DATA_2,
IOMUX_IN_FIFO_DATA_3,
IOMUX_IN_FIFO_DATA_4,
IOMUX_IN_FIFO_DATA_5,
IOMUX_IN_FIFO_DATA_6,
IOMUX_IN_FIFO_DATA_7,
IOMUX_IN_FIFO_OE_N,
IOMUX_IN_FIFO_RD_N,
IOMUX_IN_FIFO_WR_N,

IOMUX_IN_SPI_SLAVE_0_CLK,
IOMUX_IN_SPI_SLAVE_0_MOSI,
IOMUX_IN_SPI_SLAVE_0_CS,

IOMUX_IN_SPI_SLAVE_1_CLK,
IOMUX_IN_SPI_SLAVE_1_MOSI,
IOMUX_IN_SPI_SLAVE_1_CS,

IOMUX_IN_SPI_MASTER_MISO,

IOMUX_IN_GPIO_PORT_A_0,            
IOMUX_IN_GPIO_PORT_A_1,            
IOMUX_IN_GPIO_PORT_A_2,            
IOMUX_IN_GPIO_PORT_A_3,            
IOMUX_IN_GPIO_PORT_A_4,            
IOMUX_IN_GPIO_PORT_A_5,            
IOMUX_IN_GPIO_PORT_A_6,            
IOMUX_IN_GPIO_PORT_A_7,            

IOMUX_IN_GPIO_PORT_B_0,            
IOMUX_IN_GPIO_PORT_B_1,            
IOMUX_IN_GPIO_PORT_B_2,            
IOMUX_IN_GPIO_PORT_B_3,            
IOMUX_IN_GPIO_PORT_B_4,            
IOMUX_IN_GPIO_PORT_B_5,            
IOMUX_IN_GPIO_PORT_B_6,            
IOMUX_IN_GPIO_PORT_B_7,            

IOMUX_IN_GPIO_PORT_C_0,            
IOMUX_IN_GPIO_PORT_C_1,            
IOMUX_IN_GPIO_PORT_C_2,            
IOMUX_IN_GPIO_PORT_C_3,            
IOMUX_IN_GPIO_PORT_C_4,            
IOMUX_IN_GPIO_PORT_C_5,            
IOMUX_IN_GPIO_PORT_C_6,            
IOMUX_IN_GPIO_PORT_C_7,            

IOMUX_IN_GPIO_PORT_D_0,            
IOMUX_IN_GPIO_PORT_D_1,            
IOMUX_IN_GPIO_PORT_D_2,            
IOMUX_IN_GPIO_PORT_D_3,            
IOMUX_IN_GPIO_PORT_D_4,            
IOMUX_IN_GPIO_PORT_D_5,            
IOMUX_IN_GPIO_PORT_D_6,            
IOMUX_IN_GPIO_PORT_D_7,            

IOMUX_IN_GPIO_PORT_E_0,            
IOMUX_IN_GPIO_PORT_E_1,            
IOMUX_IN_GPIO_PORT_E_2,            
IOMUX_IN_GPIO_PORT_E_3,            
IOMUX_IN_GPIO_PORT_E_4,            
IOMUX_IN_GPIO_PORT_E_5,            
IOMUX_IN_GPIO_PORT_E_6,            
IOMUX_IN_GPIO_PORT_E_7,            



IOMUX_OUT_DEBUGGER,

IOMUX_OUT_UART_TXD,
IOMUX_OUT_UART_RTS_N,
IOMUX_OUT_UART_DTR_N,
IOMUX_OUT_UART_TX_ACTIVE,

IOMUX_OUT_FIFO_DATA_0,
IOMUX_OUT_FIFO_DATA_1,
IOMUX_OUT_FIFO_DATA_2,
IOMUX_OUT_FIFO_DATA_3,
IOMUX_OUT_FIFO_DATA_4,
IOMUX_OUT_FIFO_DATA_5,
IOMUX_OUT_FIFO_DATA_6,
IOMUX_OUT_FIFO_DATA_7,
IOMUX_OUT_FIFO_RXF_N,
IOMUX_OUT_FIFO_TXE_N,

IOMUX_OUT_PWM_0,
IOMUX_OUT_PWM_1,
IOMUX_OUT_PWM_2,
IOMUX_OUT_PWM_3,
IOMUX_OUT_PWM_4,
IOMUX_OUT_PWM_5,
IOMUX_OUT_PWM_6,
IOMUX_OUT_PWM_7,

IOMUX_OUT_SPI_SLAVE_0_MOSI,
IOMUX_OUT_SPI_SLAVE_0_MISO,

IOMUX_OUT_SPI_SLAVE_1_MOSI,
IOMUX_OUT_SPI_SLAVE_1_MISO,

IOMUX_OUT_SPI_MASTER_CLK,
IOMUX_OUT_SPI_MASTER_MOSI,
IOMUX_OUT_SPI_MASTER_CS_0,
IOMUX_OUT_SPI_MASTER_CS_1,

IOMUX_OUT_FIFO_CLKOUT_245,

IOMUX_OUT_GPIO_PORT_A_0,           
IOMUX_OUT_GPIO_PORT_A_1,           
IOMUX_OUT_GPIO_PORT_A_2,           
IOMUX_OUT_GPIO_PORT_A_3,           
IOMUX_OUT_GPIO_PORT_A_4,           
IOMUX_OUT_GPIO_PORT_A_5,           
IOMUX_OUT_GPIO_PORT_A_6,           
IOMUX_OUT_GPIO_PORT_A_7,           

IOMUX_OUT_GPIO_PORT_B_0,           
IOMUX_OUT_GPIO_PORT_B_1,           
IOMUX_OUT_GPIO_PORT_B_2,           
IOMUX_OUT_GPIO_PORT_B_3,           
IOMUX_OUT_GPIO_PORT_B_4,           
IOMUX_OUT_GPIO_PORT_B_5,           
IOMUX_OUT_GPIO_PORT_B_6,           
IOMUX_OUT_GPIO_PORT_B_7,           

IOMUX_OUT_GPIO_PORT_C_0,           
IOMUX_OUT_GPIO_PORT_C_1,           
IOMUX_OUT_GPIO_PORT_C_2,           
IOMUX_OUT_GPIO_PORT_C_3,           
IOMUX_OUT_GPIO_PORT_C_4,           
IOMUX_OUT_GPIO_PORT_C_5,           
IOMUX_OUT_GPIO_PORT_C_6,           
IOMUX_OUT_GPIO_PORT_C_7,           

IOMUX_OUT_GPIO_PORT_D_0,           
IOMUX_OUT_GPIO_PORT_D_1,           
IOMUX_OUT_GPIO_PORT_D_2,           
IOMUX_OUT_GPIO_PORT_D_3,           
IOMUX_OUT_GPIO_PORT_D_4,           
IOMUX_OUT_GPIO_PORT_D_5,           
IOMUX_OUT_GPIO_PORT_D_6,           
IOMUX_OUT_GPIO_PORT_D_7,           

IOMUX_OUT_GPIO_PORT_E_0,           
IOMUX_OUT_GPIO_PORT_E_1,           
IOMUX_OUT_GPIO_PORT_E_2,           
IOMUX_OUT_GPIO_PORT_E_3,           
IOMUX_OUT_GPIO_PORT_E_4,           
IOMUX_OUT_GPIO_PORT_E_5,           
IOMUX_OUT_GPIO_PORT_E_6,           
IOMUX_OUT_GPIO_PORT_E_7            
};

enum IOMUX_STATUS {
IOMUX_OK = 0,
IOMUX_INVALID_SIGNAL,
IOMUX_INVALID_PIN_SELECTION,
IOMUX_UNABLE_TO_ROUTE_SIGNAL,
IOMUX_INVALID_IOCELL_DRIVE_CURRENT,
IOMUX_INVALID_IOCELL_TRIGGER,
IOMUX_INVALID_IOCELL_SLEW_RATE,
IOMUX_INVALID_IOCELL_PULL,
IOMUX_ERROR
};






















unsigned char vos_iomux_define_input(unsigned char pin, unsigned char signal);
unsigned char vos_iomux_define_output(unsigned char pin, unsigned char signal);
unsigned char vos_iomux_define_bidi(unsigned char pin, unsigned char input_signal, unsigned char output_signal);
unsigned char vos_iomux_disable_output(unsigned char pin);

unsigned char vos_iocell_get_config(unsigned char pin, unsigned char *drive_current, unsigned char *trigger, unsigned char *slew_rate, unsigned char *pull);
unsigned char vos_iocell_set_config(unsigned char pin, unsigned char drive_current, unsigned char trigger, unsigned char slew_rate, unsigned char pull);


# 258 "C:\ProgramData\FTDI\Vinculum II Toolchain\Firmware\kernel\include\vos.h" 2
# 1 "C:\ProgramData\FTDI\Vinculum II Toolchain\Firmware\kernel\include\memmgmt.h" 1























void *vos_malloc(unsigned short size);
void vos_free(void *ptrFree);
void *vos_memset(void *dstptr, int value, short num);
void *vos_memcpy(void *destination, const void *source, short num);

unsigned short vos_heap_size(void);
void vos_heap_space(unsigned short *hfree, unsigned short *hmax);


# 259 "C:\ProgramData\FTDI\Vinculum II Toolchain\Firmware\kernel\include\vos.h" 2
# 1 "C:\ProgramData\FTDI\Vinculum II Toolchain\Firmware\kernel\include\gpioctrl.h" 1

























enum gpioctrl_status {
GPIO_OK = 0,
GPIO_INVALID_PIN,
GPIO_INVALID_PORT,
GPIO_INVALID_PARAMETER,
GPIO_INVALID_INTERRUPT,
GPIO_INVALID_INTERRUPT_TYPE,
GPIO_INTERRUPT_NOT_ENABLED,
GPIO_ERROR
};





































































typedef struct _vos_gpio_t {
unsigned char gpio_port_a;
unsigned char gpio_port_b;
unsigned char gpio_port_c;
unsigned char gpio_port_d;
unsigned char gpio_port_e;
} vos_gpio_t;




unsigned char vos_gpio_set_pin_mode (unsigned char pinId, unsigned char mask);
unsigned char vos_gpio_set_port_mode (unsigned char portId, unsigned char mask);
unsigned char vos_gpio_set_all_mode (vos_gpio_t *masks);

unsigned char vos_gpio_read_pin(unsigned char pinId, unsigned char *val);
unsigned char vos_gpio_read_port(unsigned char portId, unsigned char *val);
unsigned char vos_gpio_read_all(vos_gpio_t *vals);

unsigned char vos_gpio_write_pin(unsigned char pinId, unsigned char val);
unsigned char vos_gpio_write_port(unsigned char portId, unsigned char val);
unsigned char vos_gpio_write_all(vos_gpio_t *vals);

unsigned char vos_gpio_enable_int(unsigned char intNum, unsigned char intType, unsigned char pinId);
unsigned char vos_gpio_disable_int(unsigned char intNum);
unsigned char vos_gpio_wait_on_int(unsigned char intNum);
unsigned char vos_gpio_wait_on_any_int(unsigned char *intNum);
unsigned char vos_gpio_wait_on_all_ints(void);



# 260 "C:\ProgramData\FTDI\Vinculum II Toolchain\Firmware\kernel\include\vos.h" 2



# 18 "u16_vnc2_firmware.h" 2


# 1 "C:\ProgramData\FTDI\Vinculum II Toolchain\Firmware\drivers\include\USB.h" 1





























































































































































typedef struct _usb_deviceRequest_t
{













unsigned char  bmRequestType;

unsigned char  bRequest;
unsigned short wValue;
unsigned short wIndex;
unsigned short wLength;
} usb_deviceRequest_t;


















































typedef struct _usb_deviceDescriptor_t
{
unsigned char  bLength;
unsigned char  bDescriptorType;
unsigned short bcdUSB;
unsigned char  bDeviceClass;
unsigned char  bDeviceSubclass;
unsigned char  bDeviceProtocol;
unsigned char  bMaxPacketSize0;
unsigned short idVendor;
unsigned short idProduct;
unsigned short bcdDevice;
unsigned char  iManufacturer;
unsigned char  iProduct;
unsigned char  iSerialNumber;
unsigned char  bNumConfigurations;
} usb_deviceDescriptor_t;


typedef struct _usb_deviceQualifierDescriptor_t
{
unsigned char  bLength;
unsigned char  bDescriptorType;
unsigned short bcdUSB;
unsigned char  bDeviceClass;
unsigned char  bDeviceSubclass;
unsigned char  bDeviceProtocol;
unsigned char  bMaxPacketSize0;
unsigned char  bNumConfigurations;
unsigned char  bReserved;
} usb_deviceQualifierDescriptor_t;


typedef struct _usb_deviceConfigurationDescriptor_t
{
unsigned char  bLength;
unsigned char  bDescriptorType;
unsigned short wTotalLength;
unsigned char  bNumInterfaces;
unsigned char  bConfigurationValue;
unsigned char  iConfiguration;
unsigned char  bmAttributes;
unsigned char  bMaxPower;
} usb_deviceConfigurationDescriptor_t;







typedef struct _usb_deviceInterfaceDescriptor_t
{
unsigned char bLength;
unsigned char bDescriptorType;
unsigned char bInterfaceNumber;
unsigned char bAlternateSetting;
unsigned char bNumEndpoints;
unsigned char bInterfaceClass;
unsigned char bInterfaceSubclass;
unsigned char bInterfaceProtocol;
unsigned char iInterface;
} usb_deviceInterfaceDescriptor_t;


typedef struct _usb_deviceEndpointDescriptor_t
{
unsigned char  bLength;
unsigned char  bDescriptorType;
unsigned char  bEndpointAddress;
unsigned char  bmAttributes;
unsigned short wMaxPacketSize;
unsigned char  bInterval;
} usb_deviceEndpointDescriptor_t;








typedef struct _usb_interfaceAssociationDescriptor_t
{
unsigned char  bLength;
unsigned char  bDescriptorType;
unsigned char  bFirstInterface;
unsigned char  bInterfaceCount;
unsigned char  bFunctionClass;
unsigned char  bFunctionSubClass;
unsigned char  bFunctionProtocol;
unsigned char  iFunction;
} usb_interfaceAssociationDescriptor_t;


typedef struct _usb_deviceStringDescriptorZero_t
{
unsigned char  bLength;
unsigned char  bDescriptorType;
unsigned short wLANGID0;



} usb_deviceStringDescriptorZero_t;


typedef struct _usb_deviceStringDescriptor_t
{
unsigned char bLength;
unsigned char bDescriptorType;
unsigned char bString;



} usb_deviceStringDescriptor_t;


typedef struct _usb_hubDescriptor_t
{
unsigned char  bLength;
unsigned char  bDescriptorType;
unsigned char  bNbrPorts;
unsigned short wHubCharacteristics;
unsigned char  bPwrOn2PwrGood;
unsigned char  bHubContrCurrent;


unsigned char  DeviceRemovable[16];
unsigned char  PortPwrCtrlMask[16];
} usb_hubDescriptor_t;

































typedef struct _usb_hubStatus_t
{

unsigned short localPowerSource : 1;
unsigned short overCurrent : 1;
unsigned short resv1 : 14;

unsigned short localPowerSourceChange : 1;
unsigned short overCurrentChange : 1;
unsigned short resv2 : 14;
} usb_hubStatus_t;


typedef struct _usb_hubPortStatus_t
{

unsigned short currentConnectStatus : 1;       
unsigned short portEnabled : 1;                
unsigned short portSuspend : 1;                
unsigned short portOverCurrent : 1;            
unsigned short portReset : 1;                  
unsigned short resv1 : 3;                      
unsigned short portPower : 1;                  
unsigned short portLowSpeed : 1;               
unsigned short portHighSpeed : 1;              
unsigned short portTest : 1;                   
unsigned short portIndicator : 1;              
unsigned short resv2 : 3;                      

unsigned short currentConnectStatusChange : 1; 
unsigned short portEnabledChange : 1;          
unsigned short portSuspendChange : 1;          
unsigned short portOverCurrentChange : 1;      
unsigned short portResetChange : 1;            
unsigned short resv3 : 3;                      
unsigned short portPowerChange : 1;            
unsigned short portLowSpeedChange : 1;         
unsigned short portHighSpeedChange : 1;        
unsigned short portTestChange : 1;             
unsigned short portIndicatorChange : 1;        
unsigned short resv4 : 3;                      
} usb_hubPortStatus_t;

typedef struct _usb_hub_selector_t {
unsigned char hub_port;
unsigned char selector;
} usb_hub_selector_t;


























































































































































# 21 "u16_vnc2_firmware.h" 2
# 1 "C:\ProgramData\FTDI\Vinculum II Toolchain\Firmware\drivers\include\USBHost.h" 1




























enum USBHOST_STATUS {
USBHOST_OK = 0,                    
USBHOST_NOT_FOUND,                 
USBHOST_PENDING,                   
USBHOST_INVALID_PARAMETER,         
USBHOST_INVALID_BUFFER,            
USBHOST_INCOMPLETE_ENUM,           
USBHOST_INVALID_CONFIGURATION,     
USBHOST_TD_FULL,                   
USBHOST_EP_FULL,                   
USBHOST_IF_FULL,                   
USBHOST_EP_HALTED,                 
USBHOST_EP_INVALID,                
USBHOST_INVALID_STATE,             
USBHOST_ERROR,                     
USBHOST_CC_ERROR = 0x10,           
USBHOST_FATAL_ERROR = 0xff,        
};

















































































typedef void *usbhost_device_handle;   
typedef int	 usbhost_device_handle_ex; 

typedef void *usbhost_ep_handle;       
typedef int	 usbhost_ep_handle_ex;     


typedef struct _usbhost_xfer_t {


usbhost_ep_handle_ex ep;


vos_semaphore_t		 *s;


unsigned char		 cond_code;


unsigned char		 *buf;


unsigned short		 len;


unsigned char		 flags;


unsigned char		 resv1;


unsigned char		 zero;
} usbhost_xfer_t;


typedef struct _usbhost_xfer_iso_t {


usbhost_ep_handle_ex ep;


vos_semaphore_t		 *s;


unsigned char		 cond_code;


unsigned char		 *buf;


unsigned short		 len;


unsigned char		 flags;


unsigned char		 resv1;



unsigned char		 count;


struct {
unsigned short size : 11;
unsigned short pad : 1;
unsigned short cond_code : 4;
}			   len_psw[8];


unsigned short frame;
} usbhost_xfer_iso_t;





















































































typedef struct _usbhost_ioctl_cb_t {
unsigned char ioctl_code;

unsigned char hub_port;
union
{


usbhost_ep_handle_ex	 ep;


usbhost_device_handle_ex dif;
}	 handle;

void *get;

void *set;
} usbhost_ioctl_cb_t;

typedef struct _usbhost_ioctl_cb_vid_pid_t {
unsigned short vid;
unsigned short pid;
} usbhost_ioctl_cb_vid_pid_t;

typedef struct _usbhost_ioctl_cb_class_t {
unsigned char dev_class;
unsigned char dev_subclass;
unsigned char dev_protocol;
} usbhost_ioctl_cb_class_t;

typedef struct _usbhost_ioctl_cb_dev_info_t {
unsigned char port_number;
unsigned char addr;

unsigned char interface_number;
unsigned char speed;

unsigned char alt;

unsigned char configuration;

unsigned char num_configurations;
} usbhost_ioctl_cb_dev_info_t;

typedef struct _usbhost_ioctl_cb_ep_info_t {
unsigned char  number;
unsigned short max_size;
unsigned char  speed;
} usbhost_ioctl_cb_ep_info_t;


typedef struct _usbhost_context_t {

unsigned char if_count;

unsigned char ep_count;

unsigned char xfer_count;

unsigned char iso_xfer_count;
} usbhost_context_t;


unsigned char usbhost_init(unsigned char devNum_1, unsigned char devNum_2, usbhost_context_t *context);


# 22 "u16_vnc2_firmware.h" 2
# 1 "C:\ProgramData\FTDI\Vinculum II Toolchain\Firmware\drivers\include\ioctl.h" 1

























































typedef struct _common_ioctl_cb_t {
unsigned char ioctl_code;
union
{
unsigned long uart_baud_rate;
unsigned long spi_master_sck_freq;
unsigned char param;
void		  *data;
} set;
union
{
unsigned long  spi_master_sck_freq;
unsigned short queue_stat;
unsigned char  param;
void		   *data;
} get;
} common_ioctl_cb_t;



# 23 "u16_vnc2_firmware.h" 2
# 1 "C:\ProgramData\FTDI\Vinculum II Toolchain\Firmware\drivers\include\UART.h" 1





















# 1 "C:\ProgramData\FTDI\Vinculum II Toolchain\Firmware\drivers\include\ioctl.h" 1













































































# 23 "C:\ProgramData\FTDI\Vinculum II Toolchain\Firmware\drivers\include\UART.h" 2













































































enum UART_STATUS {
UART_OK = 0,
UART_INVALID_PARAMETER,
UART_DMA_NOT_ENABLED,
UART_ERROR,
UART_FATAL_ERROR = 0xFF
};


typedef struct _uart_context_t {
unsigned char buffer_size;
} uart_context_t;


unsigned char uart_init(
    unsigned char devNum,
    uart_context_t *context
    );



# 24 "u16_vnc2_firmware.h" 2
# 1 "C:\ProgramData\FTDI\Vinculum II Toolchain\Firmware\drivers\include\SPIMaster.h" 1





















# 1 "C:\ProgramData\FTDI\Vinculum II Toolchain\Firmware\drivers\include\ioctl.h" 1













































































# 23 "C:\ProgramData\FTDI\Vinculum II Toolchain\Firmware\drivers\include\SPIMaster.h" 2


















































enum SPIMASTER_STATUS {
SPIMASTER_OK = 0,
SPIMASTER_INVALID_PARAMETER,
SPIMASTER_DMA_NOT_ENABLED,
SPIMASTER_ERROR,
SPIMASTER_FATAL_ERROR = 0xFF
};


typedef struct _spimaster_context_t {
unsigned char buffer_size;
} spimaster_context_t;


unsigned char spimaster_init(
    unsigned char devNum,
    spimaster_context_t *context
    );



# 25 "u16_vnc2_firmware.h" 2
# 1 "C:\ProgramData\FTDI\Vinculum II Toolchain\Firmware\drivers\include\GPIO.h" 1




































































enum GPIO_STATUS {
GPIO_OK = 0,
GPIO_INVALID_PORT_IDENTIFIER,
GPIO_INVALID_PARAMETER,
GPIO_INTERRUPT_NOT_ENABLED,
GPIO_ERROR,
GPIO_FATAL_ERROR = 0xFF
};


typedef struct _gpio_context_t {
unsigned char port_identifier;
} gpio_context_t;


typedef struct _gpio_ioctl_cb_t {
unsigned char ioctl_code;
unsigned char value;
} gpio_ioctl_cb_t;


unsigned char gpio_init(
    unsigned char devNum,
    void *context
    );



# 26 "u16_vnc2_firmware.h" 2
# 1 "C:\ProgramData\FTDI\Vinculum II Toolchain\Firmware\drivers\include\FAT.h" 1



























enum FAT_STATUS {
FAT_OK = 0,
FAT_NOT_FOUND,
FAT_READ_ONLY,
FAT_PENDING,
FAT_INVALID_PARAMETER,
FAT_INVALID_BUFFER,
FAT_INVALID_FILE_TYPE,
FAT_EXISTS,
FAT_BPB_INVALID,
FAT_NOT_OPEN,
FAT_EOF,
FAT_DIRECTORY_TABLE_FULL,
FAT_DISK_FULL,
FAT_ERROR,
FAT_MSI_ERROR = 0x80,
FAT_FATAL_ERROR = 0xff,
};


typedef void *fat_context;


typedef struct _file_context_t
{

unsigned char dirEntry[32];


unsigned char mode;

unsigned char context[34];
} file_context_t;





































unsigned char fatdrv_init(unsigned char vos_dev_num);

typedef struct _fat_ioctl_cb_t {
unsigned char  ioctl_code;

file_context_t *file_ctx;

unsigned char  *get;

unsigned char  *set;
} fat_ioctl_cb_t;

typedef struct _fatdrv_ioctl_cb_attach_t
{

unsigned short	  msi_handle;

unsigned char partition;
} fatdrv_ioctl_cb_attach_t;

typedef struct _fatdrv_ioctl_cb_fs_t
{

char		   fsType;

unsigned int   freeSpaceH;
unsigned int   freeSpaceL;

unsigned int   capacityH;
unsigned int   capacityL;

unsigned int   bytesPerCluster;

unsigned short bytesPerSector;

unsigned long  volID;
} fatdrv_ioctl_cb_fs_t;

typedef struct _fatdrv_ioctl_cb_file_t
{

char *filename;

int	 offset;

char mode;
} fatdrv_ioctl_cb_file_t;

typedef struct _fatdrv_ioctl_cb_dir_t
{
char *filename;
} fatdrv_ioctl_cb_dir_t;

typedef struct _fatdrv_ioctl_cb_time_t
{

unsigned short crtDate;
unsigned short crtTime;

unsigned short wrtDate;
unsigned short wrtTime;
unsigned short accDate;
} fatdrv_ioctl_cb_time_t;

typedef struct _fat_stream_t {

file_context_t *file_ctx;

unsigned char  *buf;


unsigned long  len;
unsigned long  actual;
} fat_stream_t;




































void fat_init(void);
fat_context *fat_open(unsigned short hMsi, unsigned char partition, unsigned char *status);
void fat_close(fat_context *fat_ctx);



unsigned char fat_freeSpace(fat_context *fat_ctx, unsigned long *bytes_h, unsigned long *bytes_l, unsigned char scan);
unsigned short fat_getDevHandle(fat_context *fat_ctx);
unsigned char fat_capacity(fat_context *fat_ctx, unsigned long *bytes_h, unsigned long *bytes_l);
unsigned char fat_bytesPerCluster(fat_context *fat_ctx, unsigned long *bytes);
unsigned char fat_bytesPerSector(fat_context *fat_ctx, unsigned short *bytes);
unsigned char fat_getFSType(fat_context *fat_ctx);
unsigned char fat_getVolumeID(fat_context *fat_ctx, unsigned long *volID);
unsigned char fat_getVolumeLabel(fat_context *fat_ctx, char *volLabel);


unsigned char fat_fileOpen(fat_context *fat_ctx, file_context_t *file_ctx, char *name, unsigned char mode);
unsigned char fat_fileClose(file_context_t *file_ctx);



unsigned char fat_fileSeek(file_context_t *file_ctx, long offset, unsigned char mode);
unsigned char fat_fileSetPos(file_context_t *file_ctx, unsigned long offset);
unsigned char fat_fileTell(file_context_t *file_ctx, unsigned long *offset);
unsigned char fat_fileRewind(file_context_t *file_ctx);
unsigned char fat_fileTruncate(file_context_t *file_ctx);
unsigned char fat_fileFlush(file_context_t *file_ctx);

unsigned char fat_fileRead(file_context_t *file_ctx, unsigned long length, char *buffer, unsigned short hOutput, unsigned long *bytes_read);
unsigned char fat_fileWrite(file_context_t *file_ctx, unsigned long length, char *buffer, unsigned short hOutput, unsigned long *bytes_written);



unsigned char fat_fileDelete(file_context_t *source_file_ctx);



unsigned char fat_fileCopy(file_context_t *source_file_ctx, file_context_t *dest_file_ctx);





unsigned char fat_fileRename(file_context_t *file_ctx, char *name);


unsigned char fat_fileMod(file_context_t *file_ctx, unsigned char attr);


unsigned char fat_time(unsigned long time);


unsigned char fat_dirTableFind(fat_context *fat_ctx, file_context_t *file_ctx, char *name);
unsigned char fat_dirTableFindFirst(fat_context *fat_ctx, file_context_t *file_ctx);
unsigned char fat_dirTableFindNext(fat_context *fat_ctx, file_context_t *file_ctx);

unsigned char fat_dirDirIsEmpty(file_context_t *file_ctx);
unsigned char fat_dirEntryIsValid(file_context_t *file_ctx);
unsigned char fat_dirEntryIsVolumeLabel(file_context_t *file_ctx);
unsigned char fat_dirEntryIsReadOnly(file_context_t *file_ctx);
unsigned char fat_dirEntryIsFile(file_context_t *file_ctx);
unsigned char fat_dirEntryIsDirectory(file_context_t *file_ctx);
unsigned long fat_dirEntrySize(file_context_t *file_ctx);





unsigned short fat_dirEntryTime(file_context_t *file_ctx, unsigned char offset);
unsigned char fat_dirEntryName(file_context_t *file_ctx, char *fileName);

unsigned char fat_dirChangeDir(fat_context *fat_ctx, unsigned char *name);
unsigned char fat_dirCreateDir(fat_context *fat_ctx, unsigned char *name);
unsigned char fat_dirIsRoot(fat_context *fat_ctx);


# 27 "u16_vnc2_firmware.h" 2
# 1 "C:\ProgramData\FTDI\Vinculum II Toolchain\Firmware\drivers\include\msi.h" 1



























enum MSI_STATUS {
MSI_OK = 0,
MSI_COMMAND_FAILED,
MSI_NOT_FOUND,
MSI_INVALID_PARAMETER,
MSI_INVALID_BUFFER,
MSI_NOT_ACCESSED,
MSI_ERROR,

MSI_RESERVED = 0x40,

MSI_TRANSPORT_ERROR = 0x80,
};

















typedef struct _msi_ioctl_cb_t {
unsigned char ioctl_code;

unsigned char *get;

unsigned char *set;
} msi_ioctl_cb_t;

typedef struct _msi_ioctl_cb_info_t
{

unsigned char  vendorId[8];
unsigned char  productId[16];
unsigned char  rev[4];
unsigned short vid;                
unsigned short pid;                
} msi_ioctl_cb_info_t;





typedef struct _msi_xfer_cb_t {

unsigned long	sector;


vos_semaphore_t *s;


unsigned char	*buf;

unsigned short	buf_len;


unsigned short	total_len;


unsigned char	do_phases;



unsigned char	status;



union
{

usbhost_xfer_t usb;
} transport;
} msi_xfer_cb_t;
















# 28 "u16_vnc2_firmware.h" 2
# 1 "C:\ProgramData\FTDI\Vinculum II Toolchain\Firmware\drivers\include\BOMS.h" 1























# 1 "C:\ProgramData\FTDI\Vinculum II Toolchain\Firmware\drivers\include\msi.h" 1





























































































































# 25 "C:\ProgramData\FTDI\Vinculum II Toolchain\Firmware\drivers\include\BOMS.h" 2

enum BOMS_STATUS {
BOMS_HC_CC_ERROR = MSI_RESERVED,
BOMS_CLEAR_HALT,
BOMS_FATAL_ERROR = 0xff,
}




unsigned char boms_init(unsigned char vos_dev_num);

typedef struct _boms_ioctl_cb_attach_t
{
unsigned short				 hc_handle;
usbhost_device_handle_ex ifDev;
} boms_ioctl_cb_attach_t;


# 29 "u16_vnc2_firmware.h" 2
# 1 "C:\ProgramData\FTDI\Vinculum II Toolchain\Firmware\drivers\include\SDCard.h" 1
























unsigned char sd_init(unsigned char devNum);




typedef struct _sdcard_ioctl_cb_attach_t
{
unsigned short	  spi_master_handle;
unsigned short	  gpio_handle;
unsigned char spi_master_dma_mode;
unsigned char WP_Bit;              
unsigned char CD_Bit;              
} sdcard_ioctl_cb_attach_t;


























enum SD_CARD_STATUS {
SD_OK = 0x00,
SD_INVALID_PARAMETER,
SD_INITIALIZATION_FAILED,
SD_INVALID_CARD,
SD_CMD_FAILED,
SD_READ_FAILED,
SD_WRITE_FAILED,
SD_FRAME_ERROR,
SD_WRITE_PROTECTED,
SD_FATAL_ERROR = 0xFF
};


# 30 "u16_vnc2_firmware.h" 2
# 1 "C:\ProgramData\FTDI\Vinculum II Toolchain\Firmware\C\include\stdio.h" 1




















# 1 "C:\ProgramData\FTDI\Vinculum II Toolchain\Firmware\kernel\include\vos.h" 1






































































































































































































































































# 22 "C:\ProgramData\FTDI\Vinculum II Toolchain\Firmware\C\include\stdio.h" 2
# 1 "C:\ProgramData\FTDI\Vinculum II Toolchain\Firmware\C\include\config.h" 1


















typedef short size_t;
typedef short addr_t;



# 23 "C:\ProgramData\FTDI\Vinculum II Toolchain\Firmware\C\include\stdio.h" 2
# 1 "C:\ProgramData\FTDI\Vinculum II Toolchain\Firmware\C\include\errno.h" 1

























# 24 "C:\ProgramData\FTDI\Vinculum II Toolchain\Firmware\C\include\stdio.h" 2
# 1 "C:\ProgramData\FTDI\Vinculum II Toolchain\Firmware\drivers\include\FAT.h" 1



























































































































































































































































































# 25 "C:\ProgramData\FTDI\Vinculum II Toolchain\Firmware\C\include\stdio.h" 2








typedef file_context_t FILE;







int stdioAttach(unsigned short);

int stdinAttach(unsigned short);
int stdoutAttach(unsigned short);
int stderrAttach(unsigned short);

int fsAttach(unsigned short);


int printf(const char *fmt, ...);


FILE *fopen(const char *, const char *);
int fclose(FILE *);
int feof(FILE *);
int ftell(FILE *);
int fseek(FILE *, long offset, int whence);
int fflush(FILE *);

int fprintf(FILE *, const char *fmt, ...);
size_t fread(void *, size_t, size_t, FILE *);
size_t fwrite(const void *, size_t, size_t, FILE *);
int remove(const char *);
int rename(const char *, const char *);
void rewind(FILE *);


int getchar();
int putchar(int);
int fgetc(FILE *);
int fputc(int, FILE *);





int sprintf(char *, const char *fmt, ...);


char *fgets(char *, int, FILE *);
int fputs(const char *, FILE *);
int fgetpos(FILE *, long *);
int fsetpos(FILE *, const long *);


# 31 "u16_vnc2_firmware.h" 2
# 1 "C:\ProgramData\FTDI\Vinculum II Toolchain\Firmware\C\include\errno.h" 1

























# 32 "u16_vnc2_firmware.h" 2
# 1 "C:\ProgramData\FTDI\Vinculum II Toolchain\Firmware\C\include\string.h" 1



















# 1 "C:\ProgramData\FTDI\Vinculum II Toolchain\Firmware\C\include\config.h" 1























# 21 "C:\ProgramData\FTDI\Vinculum II Toolchain\Firmware\C\include\string.h" 2
# 1 "C:\ProgramData\FTDI\Vinculum II Toolchain\Firmware\C\include\errno.h" 1

























# 22 "C:\ProgramData\FTDI\Vinculum II Toolchain\Firmware\C\include\string.h" 2

extern void *memcpy(void *destination, const void *source, size_t num);
extern void *memset(void *dstptr, int value, size_t num);
extern int strcmp(const char *str1, const char *str2);
extern int strncmp(const char *str1, const char *str2, size_t num);
extern char *strcpy(char *destination, const char *source);
extern char *strncpy(char *destination, const char *source, size_t num);
extern char *strcat(char *destination, const char *source);
extern size_t strlen(const char *str);



# 33 "u16_vnc2_firmware.h" 2





















# 15 "u16_vnc2_firmware.c" 2


vos_tcb_t *tcbFIRMWARE;

void firmware();



unsigned short hUSBHOST_1; 
unsigned short hUSBHOST_2; 
unsigned short hUART; 
unsigned short hSPI_MASTER; 
unsigned short hGPIO_PORT_A; 
unsigned short hFAT_FILE_SYSTEM_1; 
unsigned short hFAT_FILE_SYSTEM_2; 
unsigned short hBOMS_1; 
unsigned short hBOMS_2; 
unsigned short hSDCARD; 



void iomux_setup(void);


void main(void)
{
	

uart_context_t uartContext;

spimaster_context_t spimContext;

gpio_context_t gpioContextA;

usbhost_context_t usbhostContext;
	

	
vos_init(50, 1, 10);
vos_set_clock_frequency(0);
vos_set_idle_thread_tcb_size(512);
	

iomux_setup();

	

uartContext.buffer_size = 0x40;
uart_init(2,&uartContext);


spimContext.buffer_size = 0x40;
spimaster_init(3,&spimContext);


gpioContextA.port_identifier = 0;
gpio_init(4,&gpioContextA);


fatdrv_init(5);


fatdrv_init(6);


boms_init(7);


boms_init(8);


sd_init(9);




usbhostContext.if_count = 8;
usbhostContext.ep_count = 16;
usbhostContext.xfer_count = 2;
usbhostContext.iso_xfer_count = 2;
usbhost_init(0, 1, &usbhostContext);
	

	
tcbFIRMWARE = vos_create_thread_ex(20, 4096, firmware, "Application", 0);
	

vos_start_scheduler();

main_loop:
goto main_loop;
}



unsigned char usbhost_connect_state(unsigned short hUSB)
{
unsigned char connectstate = 0x00;
usbhost_ioctl_cb_t hc_iocb;

if (hUSB)
{
hc_iocb.ioctl_code = 0x10;
hc_iocb.get        = &connectstate;
vos_dev_ioctl(hUSB, &hc_iocb);


if (connectstate == 0x01)
{
vos_dev_ioctl(hUSB, &hc_iocb);
}
}
return connectstate;
}


unsigned short fat_attach(unsigned short hMSI, unsigned char devFAT)
{
fat_ioctl_cb_t           fat_ioctl;
fatdrv_ioctl_cb_attach_t fat_att;
unsigned short hFAT;



hFAT = vos_dev_open(devFAT);


fat_ioctl.ioctl_code = 0x01;
fat_ioctl.set = &fat_att;
fat_att.msi_handle = hMSI;
fat_att.partition = 0;

if (vos_dev_ioctl(hFAT, &fat_ioctl) != FAT_OK)
{

vos_dev_close(hFAT);
hFAT = 0;
}

return hFAT;
}

void fat_detach(unsigned short hFAT)
{
fat_ioctl_cb_t           fat_ioctl;

if (hFAT)
{
fat_ioctl.ioctl_code = 0x02;
fat_ioctl.set = 0;
fat_ioctl.get = 0;

vos_dev_ioctl(hFAT, &fat_ioctl);
vos_dev_close(hFAT);
}
}


unsigned short boms_attach(unsigned short hUSB, unsigned char devBOMS)
{
usbhost_device_handle_ex ifDisk = 0;
usbhost_ioctl_cb_t hc_iocb;
usbhost_ioctl_cb_class_t hc_iocb_class;
msi_ioctl_cb_t boms_iocb;
boms_ioctl_cb_attach_t boms_att;
unsigned short hBOMS;


hc_iocb_class.dev_class = 0x08;
hc_iocb_class.dev_subclass = 0x06;
hc_iocb_class.dev_protocol = 0x50;


hc_iocb.ioctl_code = 0x23;
hc_iocb.handle.dif = 0;
hc_iocb.set = &hc_iocb_class;
hc_iocb.get = &ifDisk;

if (vos_dev_ioctl(hUSB, &hc_iocb) != USBHOST_OK)
{
return 0;
}


hBOMS = vos_dev_open(devBOMS);


boms_att.hc_handle = hUSB;
boms_att.ifDev = ifDisk;

boms_iocb.ioctl_code = (0x20 + 0x01);
boms_iocb.set = &boms_att;
boms_iocb.get = 0;

if (vos_dev_ioctl(hBOMS, &boms_iocb) != MSI_OK)
{
vos_dev_close(hBOMS);
hBOMS = 0;
}

return hBOMS;
}

void boms_detach(unsigned short hBOMS)
{
msi_ioctl_cb_t boms_iocb;

if (hBOMS)
{
boms_iocb.ioctl_code = (0x20 + 0x02);
boms_iocb.set = 0;
boms_iocb.get = 0;

vos_dev_ioctl(hBOMS, &boms_iocb);
vos_dev_close(hBOMS);
}
}


unsigned short sdcard_attach(unsigned short hSPIMaster, unsigned char devSDCard)
{
unsigned short hSDCard;
msi_ioctl_cb_t msi_cb;
sdcard_ioctl_cb_attach_t sd_cb;
gpio_ioctl_cb_t gpio_iocb;


hSDCard = vos_dev_open(devSDCard);


sd_cb.spi_master_handle = hSpiMaster;
sd_cb.gpio_handle = 0; 
sd_cb.WP_Bit = 0; 
sd_cb.CD_Bit = 0; 

sd_cb.spi_master_dma_mode = 0x00;
msi_cb.ioctl_code = 0x01;
msi_cb.set = &sd_cb;

if (vos_dev_ioctl(hSDCard, &msi_cb) != SD_OK)
{
vos_dev_close(hSDCard);
hSDCard = 0;
}

	




return hSDCard;
}

void sdcard_detach(unsigned short hSDCard)
{
msi_ioctl_cb_t msi_cb

if (hSDCard)
{
msi_cb.ioctl_code = 0x07;
vos_dev_ioctl(hSDCard, &msi_cb);
vos_dev_close(hSDCard);
}
}



void open_drivers(void)
{
        
        
hUSBHOST_1 = vos_dev_open(0);
hUSBHOST_2 = vos_dev_open(1);
hUART = vos_dev_open(2);
hSPI_MASTER = vos_dev_open(3);
hGPIO_PORT_A = vos_dev_open(4);
        
hSDCARD = vos_dev_open(9);
}

void attach_drivers(void)
{
        
hBOMS_1 = boms_attach(hUSBHOST_1, 7);
hBOMS_2 = boms_attach(hUSBHOST_2, 8);
hSDCARD = sdcard_attach(hSPI_MASTER, 9);
hFAT_FILE_SYSTEM_1 = fat_attach(hBOMS_1, 5);
hFAT_FILE_SYSTEM_2 = fat_attach(hBOMS_2, 6);
hFAT_FILE_SYSTEM_3 = fat_attach(hSDCARD, VOS_DEV_FAT_FILE_SYSTEM_3);



        
}

void close_drivers(void)
{
        
vos_dev_close(hUSBHOST_1);
vos_dev_close(hUSBHOST_2);
vos_dev_close(hUART);
vos_dev_close(hSPI_MASTER);
vos_dev_close(hGPIO_PORT_A);
        
}



void firmware()
{
	


}

