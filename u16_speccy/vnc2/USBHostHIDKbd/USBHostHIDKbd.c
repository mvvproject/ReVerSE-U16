/*
** Filename: USBHostHIDKbd.c
**
** Automatically created by Application Wizard 1.4.2
**
** Part of solution USBHostHIDKbd in project USBHostHIDKbd
**
** Comments:
**
** Important: Sections between markers "FTDI:S*" and "FTDI:E*" will be overwritten by
** the Application Wizard
*/

#include "USBHostHIDKbd.h"

/* FTDI:STP Thread Prototypes */
vos_tcb_t *tcbFIRMWARE;

void firmware();
/* FTDI:ETP */

/* FTDI:SDH Driver Handles */
VOS_HANDLE hUSBHOST_2; // USB Host Port 2
VOS_HANDLE hUART; // UART Interface Driver
VOS_HANDLE hGPIO_PORT_A; // GPIO Port A Driver
VOS_HANDLE hUSBHOST_HID; // Connects to a HIDdevice on the USB Host Interface
/* FTDI:EDH */

/* Declaration for IOMUx setup function */
void iomux_setup(void);

#define MAX_STRING_LEN		 255
char buf[64];
//char *eol = "\r\n";

/*
** message
**
** Print a string in the terminal application.
**
** Parameters:	str - Message to be printed
** Returns:	void
** Comments:
*/
//void message(char *str)
//{

//	int length = 0;
//	char *tmp = str;

//	while ((tmp[length] != '\0') && (length < MAX_STRING_LEN))
//		length++;                           /*calculate string length*/

//	vos_dev_write(hUART, (uint8 *) str, (uint16) length, NULL);
//}

/*
** number
**
** Print a character in the terminal application.
**
** Parameters:	val - Byte to be printed
** Returns:	void
** Comments:
*/
void number(unsigned char val)
{
//	unsigned char nibble;

//	nibble = (val >> 4) + '0';
//	if (nibble > '9') nibble += ('A' - '9' - 1);

//	vos_dev_write(hUART, &nibble, (uint16) 1, NULL);

//	nibble = (val & 15) + '0';
//	if (nibble > '9') nibble += ('A' - '9' - 1);

//	vos_dev_write(hUART, &nibble, (uint16) 1, NULL);
	vos_dev_write(hUART, &val, (uint8) 1, NULL);
}

/* Main code - entry point to firmware */
void main(void)
{
	/* FTDI:SDD Driver Declarations */
	// UART Driver configuration context
	uart_context_t uartContext;
	// GPIO Port A configuration context
	gpio_context_t gpioContextA;
	// USB Host configuration context
	usbhost_context_t usbhostContext;
	/* FTDI:EDD */

	/* FTDI:SKI Kernel Initialisation */
	vos_init(50, VOS_TICK_INTERVAL, VOS_NUMBER_DEVICES);
	vos_set_clock_frequency(VOS_48MHZ_CLOCK_FREQUENCY);
	vos_set_idle_thread_tcb_size(512);
	/* FTDI:EKI */

	iomux_setup();

	/* FTDI:SDI Driver Initialisation */
	// Initialise UART
	uartContext.buffer_size = VOS_BUFFER_SIZE_128_BYTES;
	uart_init(VOS_DEV_UART,&uartContext);
	
	// Initialise GPIO A
	gpioContextA.port_identifier = GPIO_PORT_A;
	gpio_init(VOS_DEV_GPIO_PORT_A,&gpioContextA);
	
	// Initialise USB HID Device
	usbHostHID_init(VOS_DEV_USBHOST_HID);
	
	// Initialise USB Host
	usbhostContext.if_count = 8;
	usbhostContext.ep_count = 16;
	usbhostContext.xfer_count = 2;
	usbhostContext.iso_xfer_count = 2;
	usbhost_init(-1, VOS_DEV_USBHOST_2, &usbhostContext);
	/* FTDI:EDI */

	/* FTDI:SCT Thread Creation */
	tcbFIRMWARE = vos_create_thread_ex(20, 4096, firmware, "Application", 0);
	/* FTDI:ECT */
	
	vos_start_scheduler();

main_loop:
	goto main_loop;
}

/* FTDI:SSP Support Functions */

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

/* FTDI:ESP */

void open_drivers(void)
{
        /* Code for opening and closing drivers - move to required places in Application Threads */
        /* FTDI:SDA Driver Open */
        hUSBHOST_2 = vos_dev_open(VOS_DEV_USBHOST_2);
        hUART = vos_dev_open(VOS_DEV_UART);
        hGPIO_PORT_A = vos_dev_open(VOS_DEV_GPIO_PORT_A);
        /* FTDI:EDA */
}

void attach_drivers(void)
{
        /* FTDI:SUA Layered Driver Attach Function Calls */
        hUSBHOST_HID = hid_attach(hUSBHOST_2, VOS_DEV_USBHOST_HID);
        /* FTDI:EUA */
}

void close_drivers(void)
{
        /* FTDI:SDB Driver Close */
        vos_dev_close(hUSBHOST_2);
        vos_dev_close(hUART);
        vos_dev_close(hGPIO_PORT_A);
        /* FTDI:EDB */
}

/* Application Threads */

void firmware()
{
	/* Thread code to be added here */

	usbHostHID_ioctl_t	hid_iocb;
	usbhost_device_handle ifDev; 				// device handle
	usbhost_ioctl_cb_t hc_iocb;					// Host Controller ioctl request block
	unsigned char byteCount,status;
	unsigned short num_read;

	do
	{
		open_drivers();

		do
		{
			vos_delay_msecs(1000);
			// wait for enumeration to complete
//			message("Waiting for enumeration\r\n");
			status = usbhost_connect_state(hUSBHOST_2);
			
		} while (status != PORT_STATE_ENUMERATED);

		if (status == PORT_STATE_ENUMERATED)
		{
//			message("Enumeration complete\r\n");
			vos_gpio_set_port_mode(GPIO_PORT_A, 0b00000100); // A2 на выход
			vos_gpio_write_port(GPIO_PORT_A, 0b00000100); // зажечь светодиод
			
			attach_drivers();
			if (hUSBHOST_HID == NULL)
			{
//				message("No Wingman Found - code ");
//				number(status);
//				message(eol);
				break;
			}


			// get report descriptor
			hid_iocb.descriptorType = USB_DESCRIPTOR_TYPE_REPORT;
			hid_iocb.descriptorIndex = USB_HID_DESCRIPTOR_INDEX_ZERO;
			hid_iocb.Length = 0x40;
			hid_iocb.get.data=&buf[0];
			hid_iocb.ioctl_code = VOS_IOCTL_USBHOSTHID_GET_DESCRIPTOR;
			status = vos_dev_ioctl(hUSBHOST_HID, &hid_iocb);
			if (status != USBHOSTHID_OK)
			{
//				message("Get report descriptor failed - code ");
//				number(status);
//				message(eol);
				break;
			}

			// set idle
			hid_iocb.reportID = USB_HID_REPORT_ID_ZERO;
			hid_iocb.idleDuration = 0x20;
			hid_iocb.ioctl_code = VOS_IOCTL_USBHOSTHID_SET_IDLE;
			status = vos_dev_ioctl(hUSBHOST_HID, &hid_iocb);
			if (status != USBHOSTHID_OK)
			{
//				message("Set Idle failed - code ");
//				number(status);
//				message(eol);
				break;
			}


			// get idle
			hid_iocb.reportID = USB_HID_REPORT_ID_ZERO;
			hid_iocb.get.data=&buf[0];
			hid_iocb.ioctl_code = VOS_IOCTL_USBHOSTHID_GET_IDLE;
			status = vos_dev_ioctl(hUSBHOST_HID, &hid_iocb);
			if (status != USBHOSTHID_OK)
			{
//				message("Get Idle failed - code ");
//				number(status);
//				message(eol);
				break;
			}

			if (status == USBHOSTHID_OK)
			{
					while (1)
					{
						if (vos_dev_read(hUSBHOST_HID, buf, 8, &num_read) == USBHOSTHID_OK)
						{

							for (byteCount = 0; byteCount < num_read; byteCount++)
							{
								number(buf[byteCount]);
							}
//							message(eol);
						}
						else
						{
//							message("USB Read Failed - code ");
//							number(status);
//							message(eol);
							break;
						}
					}


			}

//		message("Disconnected!\r\n");
		vos_gpio_write_port(GPIO_PORT_A, 0b00000000); // погасить все

		} // end of if PORT_STATE_ENUMERATED


		vos_dev_close(hUSBHOST_HID);
		close_drivers();
	} while (1);


}

