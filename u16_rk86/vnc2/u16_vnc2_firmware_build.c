//---------------------------------------------------------------------------
//-- (c) 2015-2016 Alexey Spirkov
//-- I am happy for anyone to use this for non-commercial use.
//-- If my vhdl/c files are used commercially or otherwise sold,
//-- please contact me for explicit permission at me _at_ alsp.net.
//-- This applies for source and binary form and derived works.
//---------------------------------------------------------------------------


#include "vos.h"
#include "USB.h"
#include "USBHost.h"
#include "ioctl.h"
#include "UART.h"
#include "GPIO.h"
#include "USBHID.h"
#include "USBHostHID.h"

#define VOS_DEV_USBHOST_1 0
#define VOS_DEV_USBHOST_2 1
#define VOS_DEV_UART 2
#define VOS_DEV_GPIO_PORT_A 3
#define VOS_DEV_USBHOST_HID_1 4
#define VOS_DEV_USBHOST_HID_2 5

#define VOS_NUMBER_DEVICES 6

#ifdef _VDEBUG
#define DEBUG 1
#endif

#define ON 1
#define OFF 0
#define PKGSTARTPIN GPIO_A_1
#define LEDPIN GPIO_A_2
//#define NEWMODEPIN GPIO_A_3


void firmware(uint8 hostId, uint8 hidId);

VOS_HANDLE hUART; // UART Interface Driver
VOS_HANDLE hGPIO_PORT_A; // GPIO Port A Driver

#define MAX_STRING_LEN 255
uint8 buf[64];
uint8 buf2[64];

vos_mutex_t rxLock;
vos_mutex_t spiLock;
int connectedCount = 0;

#ifdef DEBUG

char *eol = "\r\n";

void message(char *str)
{
	int length = 0;
	char *tmp = str;

	while ((tmp[length] != '\0') && (length < MAX_STRING_LEN))
		length++;                           /*calculate string length*/

	vos_lock_mutex(&rxLock);		
	vos_dev_write(hUART, (uint8 *) str, (uint16) length, NULL);
	vos_unlock_mutex(&rxLock);
}
#endif		

void number(uint8 val)
{	
	vos_lock_mutex(&rxLock);

#ifdef DEBUG			
	{
		unsigned char nibble;

		
		nibble = (val >> 4) + '0';
		if (nibble > '9') nibble += ('A' - '9' - 1);

		vos_dev_write(hUART, &nibble, (uint16) 1, NULL);

		nibble = (val & 15) + '0';
		if (nibble > '9') nibble += ('A' - '9' - 1);

		vos_dev_write(hUART, &nibble, (uint16) 1, NULL);
	}
#else	
	vos_dev_write(hUART, &val, (uint8) 1, NULL);
#endif	
	vos_unlock_mutex(&rxLock);

}

void iomux_setup(void)
{	
		// Debugger to pin 11 as Bi-Directional.
		vos_iomux_define_bidi(11, IOMUX_IN_DEBUGGER, IOMUX_OUT_DEBUGGER);
		// GPIO_Port_A_1 to pin 12 as Output.
		vos_iomux_define_output(12, IOMUX_OUT_GPIO_PORT_A_1);
		vos_iocell_set_config(12, 0, 0, 0, 2);
		// GPIO_Port_A_2 to pin 14 as Output.
		vos_iomux_define_output(14, IOMUX_OUT_GPIO_PORT_A_2);
		vos_iocell_set_config(14, 3, 0, 0, 2);
		// GPIO_Port_A_3 to pin 15 as Output.
		vos_iomux_define_output(15, IOMUX_OUT_GPIO_PORT_A_3);
		vos_iocell_set_config(15, 0, 0, 0, 2);
		// UART_TXD to pin 23 as Output.
		vos_iomux_define_output(23, IOMUX_OUT_UART_TXD);
		// UART_RXD to pin 24 as Input.
		vos_iomux_define_input(24, IOMUX_IN_UART_RXD);
		// UART_RTS_N to pin 25 as Output.
		vos_iomux_define_output(25, IOMUX_OUT_UART_RTS_N);
		// UART_CTS_N to pin 26 as Input.
		vos_iomux_define_input(26, IOMUX_IN_UART_CTS_N);
		vos_iocell_set_config(26, 0, 0, 0, 1);
}

/* Main code - entry point to firmware */
void main(void)
{
	// UART Driver configuration context
	uart_context_t uartContext;
	common_ioctl_cb_t uart_iocb;

	// GPIO Port A configuration context
	gpio_context_t gpioContextA;

	// USB Host configuration context
	usbhost_context_t usbhostContext;
	
	// Kernel Initialisation
	vos_init(50, VOS_TICK_INTERVAL, VOS_NUMBER_DEVICES);
	vos_set_clock_frequency(VOS_48MHZ_CLOCK_FREQUENCY);
	vos_set_idle_thread_tcb_size(512);

	// MUX ports
	iomux_setup();

	// Initialise UART
	uartContext.buffer_size = VOS_BUFFER_SIZE_128_BYTES;
	uart_init(VOS_DEV_UART,&uartContext);
	hUART = vos_dev_open(VOS_DEV_UART);

	// enable DMA on UART
	uart_iocb.ioctl_code = VOS_IOCTL_COMMON_ENABLE_DMA;
	uart_iocb.set.param = DMA_ACQUIRE_AS_REQUIRED;
	vos_dev_ioctl(hUART, &uart_iocb);
	
	// UART set baud rate
	uart_iocb.ioctl_code = VOS_IOCTL_UART_SET_BAUD_RATE;
	uart_iocb.set.uart_baud_rate = 115200;
	vos_dev_ioctl(hUART, &uart_iocb);
	
	// Initialise GPIO A
	gpioContextA.port_identifier = GPIO_PORT_A;
	gpio_init(VOS_DEV_GPIO_PORT_A,&gpioContextA);
	hGPIO_PORT_A = vos_dev_open(VOS_DEV_GPIO_PORT_A);

	// Init GPIO pins
	vos_gpio_set_port_mode(GPIO_PORT_A, 0b00101110);	// PIN to output 
	vos_gpio_write_port(GPIO_PORT_A, 0x00);

	
	// Initialise USB HID Device
	usbHostHID_init(VOS_DEV_USBHOST_HID_1);
	
	// Initialise USB HID Device
	usbHostHID_init(VOS_DEV_USBHOST_HID_2);
	
	// Initialise USB Host
	usbhostContext.if_count = 8;
	usbhostContext.ep_count = 16;
	usbhostContext.xfer_count = 2;
	usbhostContext.iso_xfer_count = 2;
	usbhost_init(VOS_DEV_USBHOST_1, VOS_DEV_USBHOST_2, &usbhostContext);
	
	// init mutexes
	vos_init_mutex(&rxLock, 1);
	vos_unlock_mutex(&rxLock);

	iomux_setup();

	// start processes
	vos_create_thread_ex(20, 1024, firmware, "Port1", sizeof(uint8) * 2, (uint8)VOS_DEV_USBHOST_1, (uint8) VOS_DEV_USBHOST_HID_1);
	vos_create_thread_ex(20, 1024, firmware, "Port2", sizeof(uint8) * 2, (uint8)VOS_DEV_USBHOST_2, (uint8) VOS_DEV_USBHOST_HID_2);

	vos_start_scheduler();

main_loop:
	goto main_loop;
}

unsigned char usbhost_connect_state(VOS_HANDLE hUSB)
{
	unsigned char connectstate = PORT_STATE_DISCONNECTED;
	usbhost_ioctl_cb_t hc_iocb;

	if (hUSB)
	{
		hc_iocb.ioctl_code = VOS_IOCTL_USBHOST_GET_CONNECT_STATE;
		hc_iocb.get        = &connectstate;
		vos_dev_ioctl(hUSB, &hc_iocb);

    	// repeat if connected to see if we move to enumerated
		if (connectstate == PORT_STATE_CONNECTED)
		{
			vos_dev_ioctl(hUSB, &hc_iocb);
		}
	}
	return connectstate;
}


VOS_HANDLE hid_attach(VOS_HANDLE hUSB, unsigned char devHID)
{
	usbhost_device_handle_ex ifHID = 0;
	usbhost_ioctl_cb_t hc_iocb;
	usbhost_ioctl_cb_class_t hc_iocb_class;
	usbHostHID_ioctl_t hid_iocb;
	usbHostHID_ioctl_cb_attach_t hid_att;
	VOS_HANDLE hHID;

	// find HID class device
	hc_iocb_class.dev_class = USB_CLASS_HID;
	hc_iocb_class.dev_subclass = USB_SUBCLASS_ANY;
	hc_iocb_class.dev_protocol = USB_PROTOCOL_ANY;

	// user ioctl to find first hub device
	hc_iocb.ioctl_code = VOS_IOCTL_USBHOST_DEVICE_FIND_HANDLE_BY_CLASS;
	hc_iocb.handle.dif = NULL;
	hc_iocb.set = &hc_iocb_class;
	hc_iocb.get = &ifHID;

	if (vos_dev_ioctl(hUSB, &hc_iocb) != USBHOST_OK)
	{
		return NULL;
	}

	// now we have a device, intialise a HID driver with it
	hHID = vos_dev_open(devHID);

	// perform attach
	hid_att.hc_handle = hUSB;
	hid_att.ifDev = ifHID;

	hid_iocb.ioctl_code = VOS_IOCTL_USBHOSTHID_ATTACH;
	hid_iocb.set = &hid_att;
	hid_iocb.get = NULL;

	if (vos_dev_ioctl(hHID, &hid_iocb) != USBHOSTHID_OK)
	{
		vos_dev_close(hHID);
		hHID = NULL;
	}

	return hHID;
}

void HID_detach(VOS_HANDLE hHID)
{
	usbHostHID_ioctl_t hid_iocb;

	if (hHID)
	{
		hid_iocb.ioctl_code = VOS_IOCTL_USBHOSTHID_DETACH;

		vos_dev_ioctl(hHID, &hid_iocb);
		vos_dev_close(hHID);
	}
}


void led(uint8 on)
{
	vos_gpio_write_pin(LEDPIN, on);
}
		

void firmware(uint8 hostId, uint8 hidId)
{
	/* Thread code to be added here */

	usbHostHID_ioctl_t	hid_iocb;
	usbhost_device_handle ifDev; 			// device handle
	usbhost_ioctl_cb_t hc_iocb;				// Host Controller ioctl request block
	unsigned char byteCount,status;
	unsigned short num_read;
	uint8 reportLen;
	uint8 deviceType = 0;
	VOS_HANDLE hUSBHOST; 
	VOS_HANDLE hUSBHOST_HID;
	uint8 * localBuf = hostId == 0 ? &buf[0] : &buf2[0];

	do
	{
        hUSBHOST = vos_dev_open(hostId);

		do
		{				
			// wait for enumeration to complete
			vos_delay_msecs(250);
			if(!connectedCount)
				led(OFF);
			vos_delay_msecs(250);
			led(ON);
			
#ifdef DEBUG			
			message("Waiting for enumeration ");
			number(hostId);
			message(eol);
#endif		
			
				
			status = usbhost_connect_state(hUSBHOST);
			
		} while (status != PORT_STATE_ENUMERATED);

		if (status == PORT_STATE_ENUMERATED)
		{
#ifdef DEBUG			
			message("Enumeration complete ");
			number(hostId);
			message(eol);
#endif			
			
			hUSBHOST_HID = hid_attach(hUSBHOST, hidId);
			if (hUSBHOST_HID == NULL)
			{
#ifdef DEBUG			
				message("No HID device found - code ");
				number(status);
				message(eol);
#endif				
				continue;
			}


			// get report descriptor
			hid_iocb.descriptorType = USB_DESCRIPTOR_TYPE_REPORT;
			hid_iocb.descriptorIndex = USB_HID_DESCRIPTOR_INDEX_ZERO;
			hid_iocb.Length = 0x40;
			hid_iocb.get.data=localBuf;
			hid_iocb.ioctl_code = VOS_IOCTL_USBHOSTHID_GET_DESCRIPTOR;
			status = vos_dev_ioctl(hUSBHOST_HID, &hid_iocb);
			if (status != USBHOSTHID_OK)
			{
#ifdef DEBUG			
				message("Get report descriptor failed - code ");
				number(status);
				message(eol);
#endif				
				continue;
			}
#ifdef DEBUG			
			{
				int i;
				message("Report descriptor:\r");
				for(i = 0; i < 0x40; i++)
				{
					if (i==0x00 || i==0x08 || i==0x10 || i==0x18 || i==0x20 || i==0x28 || i==0x30 || i==0x38)
					{
						message(eol); number((unsigned char) i); message(": ");
					}
					number((unsigned char) localBuf[i]); message(" ");
				}
				message(eol);
			}
#endif		
			// check for Generic desktop and usage start
			if(localBuf[0] != 0x05 || localBuf[1] != 0x01 || localBuf[2] != 0x09)
			{
#ifdef DEBUG			
				message("Unrecognized device\r\n");				
#endif				
				continue;
			}
			deviceType = localBuf[3];

			// get report length (typically 8 but can be up to 64)
			hid_iocb.ioctl_code = VOS_IOCTL_USBHOSTHID_GET_IN_REPORT_SIZE;
			status = vos_dev_ioctl(hUSBHOST_HID, &hid_iocb);
			if (status != USBHOSTHID_OK)
			{
#ifdef DEBUG			
				message("Get Report Length failed - code ");
				number(status);
				message(eol);
#endif				
				continue;
			}
			reportLen = (uint8) hid_iocb.Length; 
						
			if (status == USBHOSTHID_OK)
			{
					connectedCount++;			
					led(ON);
					
					while (1)
					{
						if (vos_dev_read(hUSBHOST_HID, localBuf, (uint16)reportLen, &num_read) == USBHOSTHID_OK)
						{
							uint8 gpioval;
							
							// pkg start gpio
							vos_gpio_write_pin(PKGSTARTPIN, 1);
							
							// send port id in first bit and deviceType in remaining
							number(hostId << 7 | deviceType);								
							// number(reportLen);
						
							for (byteCount = 0; byteCount < num_read; byteCount++)
							{
								number((unsigned char) localBuf[byteCount]);
							}

							// for mouse - make the similar buffer size with keyboard and joystick
							for (;byteCount < 8; byteCount++)
							{
								number(0);
							}
#ifdef DEBUG			
							message(eol);
#endif				
							vos_gpio_write_pin(PKGSTARTPIN, 0);
						}
						else
						{
#ifdef DEBUG			
							message("USB Read Failed - code ");
							number(status);
							message(eol);
#endif				
							break;
						}
					}
			}

#ifdef DEBUG			
		message("Disconnected ");
		number(hostId);
		message(eol);
#endif				
		connectedCount--;
		if(!connectedCount)
			led(OFF);
			
		} // end of if PORT_STATE_ENUMERATED

		vos_dev_close(hUSBHOST_HID);
	        vos_dev_close(hUSBHOST);

	} while (1);
}

