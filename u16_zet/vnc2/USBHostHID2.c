//-----------------------------------------------------------------[22.05.2015]
// 22.05.2015	MVV		//Bit 7=1 указывает на префикс 0xE0, добавлены: 0x00=Overrun Error, 0x80=POST Fail, 0x7f=None. Исправлен код Caps Lock

/*
** Filename: USBHostHID2.c
**
** Automatically created by Application Wizard 1.4.2
**
** Part of solution USBHostHID2 in project USBHostHID2
**
** Comments:
**
** Important: Sections between markers "FTDI:S*" and "FTDI:E*" will be overwritten by
** the Application Wizard
*/
#include <vos.h>
#include <stdio.h>
#include <string.h>

#include <USBHost.h>
#include <USB.h>
#include <UART.h>
#include <USBHID.h>

//==============================
#include "USBHostHID2.h"
#include "hidparser.h"
#include "ps2dev.h"
#include "ps2_mouse.h"
#include "ps2_keyboard.h"

/* FTDI:STP Thread Prototypes */
vos_tcb_t *tcbFIRMWARE;

void USB_thread();
void PS2_MSthread(void);
void PS2_KBthread(void);

/* FTDI:ETP */

/* FTDI:SDH Driver Handles */
VOS_HANDLE hUSBHOST_1; // USB Host Port 1
VOS_HANDLE hUSBHOST_2; // USB Host Port 2
VOS_HANDLE hUART; // UART Interface Driver
VOS_HANDLE hGPIO_PORT_A; // GPIO Port A Driver
/* FTDI:EDH */
// use our own driver handles to simplify code later
VOS_HANDLE hUsb[2];

/* Declaration for IOMUx setup function */
void iomux_setup(void);

//=================================================================My

//===========================================
HIDParser_t        hid_parser;
HIDParser_t*	   pParser;
HIDData_t		   hid_parce_data;
//hid_parser.pData = &hid_parce_data;
//-----------------------------------
HIDData_t   hid_data;
HIDData_t*  phid_data;
//--------------------------
unsigned char MS_OK;
ReportID_t 	ReportID_MS[10];
HIDData_t   hid_Bdata;
HIDData_t*  phid_Bdata;
HIDData_t   hid_Xdata;
HIDData_t*  phid_Xdata;
HIDData_t   hid_Ydata;
HIDData_t*  phid_Ydata;
HIDData_t   hid_Wdata;
HIDData_t*  phid_Wdata;
//===================================
uchar 		max_ReportID;
ReportID_t 	ReportID_tbl[10];

HIDPath_t   hid_path;

//MOUSE
PS2_mouse_t PS2_MS;
int Xpos;
int Ypos;

unsigned char *pDATA;

//KEYBOARD
PS2_keyboard_t    PS2_KB;	
PS2_keyboard_t*  pPS2_KB;


// test buffer
char buf[0x80];


//============================================

usbhost_ioctl_cb_dev_info_t		ifInfo;
usbhost_ioctl_cb_class_t		hc_iocb_class;

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
	vos_init(50, VOS_TICK_INTERVAL, VOS_NUMBER_DEVICES); //#define VOS_TICK_INTERVAL 1
	vos_set_clock_frequency(VOS_48MHZ_CLOCK_FREQUENCY);
	vos_set_idle_thread_tcb_size(512);
	/* FTDI:EKI */

	iomux_setup();
	PS2_mouse_init    (&PS2_MS);
	PS2_keyboard_init (&PS2_KB);
	//PS2_keyboard_init(&PS2_KB);
	pPS2_KB = &PS2_KB;

	/* FTDI:SDI Driver Initialisation */
	// Initialise UART
	uartContext.buffer_size = VOS_BUFFER_SIZE_128_BYTES;
	uart_init(VOS_DEV_UART,&uartContext);

	// Initialise GPIO A
	gpioContextA.port_identifier = GPIO_PORT_A;
	gpio_init(VOS_DEV_GPIO_PORT_A, &gpioContextA);
	//-----------
	
	
	// Initialise USB Host
	usbhostContext.if_count = 8;
	usbhostContext.ep_count = 16;
	usbhostContext.xfer_count = 2;
	usbhostContext.iso_xfer_count = 2;
	usbhost_init(VOS_DEV_USBHOST_1, VOS_DEV_USBHOST_2, &usbhostContext);
	/* FTDI:EDI */

	/* FTDI:SCT Thread Creation */
	tcbFIRMWARE = vos_create_thread_ex(20, 4096, USB_thread,   "USB_thread",   0);
	tcbFIRMWARE = vos_create_thread_ex(20, 2048, PS2_MSthread, "PS2_MSthread", 0);
	//tcbFIRMWARE = vos_create_thread_ex(20, 2048, PS2_KBthread, "PS2_KBthread", 0);
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

/* FTDI:ESP */

void open_drivers(void)
{
	/* Code for opening and closing drivers - move to required places in Application Threads */
	/* FTDI:SDA Driver Open */
	hUSBHOST_1		= vos_dev_open(VOS_DEV_USBHOST_1);
	hUSBHOST_2		= vos_dev_open(VOS_DEV_USBHOST_2);
	hUART			= vos_dev_open(VOS_DEV_UART);
	hGPIO_PORT_A	= vos_dev_open(VOS_DEV_GPIO_PORT_A);
	/* FTDI:EDA */
}

void attach_drivers(void)
{
	/* FTDI:SUA Layered Driver Attach Function Calls */
	/* FTDI:EUA */
}

void close_drivers(void)
{
	/* FTDI:SDB Driver Close */
	vos_dev_close(hUSBHOST_1);
	vos_dev_close(hUSBHOST_2);
	vos_dev_close(hUART);
	vos_dev_close(hGPIO_PORT_A);
	/* FTDI:EDB */
}

/* Application Threads */

void message(char *msg)
{
//	 vos_dev_write(hUART, (unsigned char *) msg, strlen(msg), NULL);
}

void number(unsigned char val)
{  
/*
	char letter;
	unsigned char nibble;

	nibble = (val >> 4) + '0';

	if (nibble > '9')
		nibble += ('A' - '9' - 1);

	vos_dev_write(hUART, &nibble, 1, NULL);
	nibble = (val & 15) + '0';

	if (nibble > '9')
		nibble += ('A' - '9' - 1);

	vos_dev_write(hUART, &nibble, 1, NULL);
*/

}

void D_number(unsigned char val)
{
	vos_dev_write(hUART, &val, (uint8) 1, NULL);
}

vos_semaphore_list_t *sem_list;        // pointer to semaphore list

void USB_thread(void)
{
	// test buffer
	char buf[0x80];  
	char *eol = "\r\n";
	//uchar usb
	unsigned char i;
	unsigned short len;
	unsigned short written;
	unsigned char status;
	unsigned char n, m;
	//==============================================
	unsigned char USBaddress, DeviceSpeed, Location;
	unsigned char descIndex;
	unsigned char byteCount;
	//---KB----------------------
	unsigned char  BUFF;
	unsigned char *  LIN_BUF_prev;
    unsigned char *  LIN_BUF_curr;
	
	ushort XYW;
	uchar Found[2], FoundB[2], FoundX[2], FoundY[2], FoundW[2];
	int Xpos, Ypos, Wheel, Buttons;
	//==============================================

	// device handle
	usbhost_device_handle_ex ifDev;
	// endpoint handles
	usbhost_ep_handle_ex epInt[2], epCtrl[2];
	// endpoint maxPacketLength values
	unsigned char maxPack[2];
	
	// completion semaphore and set semaphore list
	vos_semaphore_t endpointSem[2];

	// Host Controller ioctl request block
	usbhost_ioctl_cb_t hc_iocb;
	usbhost_ioctl_cb_vid_pid_t hc_ioctVidPid;

	// interrupt endpoint transfer descriptor
	usbhost_xfer_t xfer[2];

	// UART ioctl request block
	common_ioctl_cb_t uart_iocb;

	// host controller device descriptor
	usb_deviceRequest_t desc_dev;

	// endpoint information
	usbhost_ioctl_cb_ep_info_t epInfo;
	
	hid_parser.pData = &hid_parce_data; //
	pParser   		 = &hid_parser; //<-  INPUT STR
	//----------------------------
	phid_data 		 = &hid_data;   //<== OUTPUT STR
	//--------------------------------
	phid_Bdata = &hid_Bdata;
	phid_Xdata = &hid_Xdata;		
	phid_Ydata = &hid_Ydata;
	phid_Wdata = &hid_Wdata;
	//--------------------------------

	epInt[0] = NULL;
	epCtrl[0] = NULL;
	epInt[1] = NULL;
	epCtrl[1] = NULL;
	
	Found[0]  = 0;
	Found[1]  = 0;
	FoundB[0] = 0;
	FoundB[1] = 0;
	FoundX[0] = 0;
	FoundX[1] = 0;
	FoundY[0] = 0;
	FoundY[1] = 0;
	FoundW[0] = 0;
	FoundW[1] = 0;
	memset(buf, 0, sizeof(buf));
	//================================================
	//PS2dev_init ();
	open_drivers();
	PS2dev_init ();
	PS2dev_unlock();
	//=============
	
	//hUsb[0] = hUSBHOST_1;
	//hUsb[1] = hUSBHOST_2;
	hUsb[0] = hUSBHOST_2;
	hUsb[1] = hUSBHOST_1;

	uart_iocb.ioctl_code = VOS_IOCTL_COMMON_ENABLE_DMA;
	uart_iocb.set.param  = DMA_ACQUIRE_AS_REQUIRED;
	vos_dev_ioctl(hUART, &uart_iocb);

	// set baud rate
	uart_iocb.ioctl_code = VOS_IOCTL_UART_SET_BAUD_RATE;
	uart_iocb.set.uart_baud_rate = UART_BAUD_9600;
	vos_dev_ioctl(hUART, &uart_iocb);

	// set flow control
	uart_iocb.ioctl_code = VOS_IOCTL_UART_SET_FLOW_CONTROL;
	uart_iocb.set.param = UART_FLOW_RTS_CTS;
	vos_dev_ioctl(hUART, &uart_iocb);

	// set data bits
	uart_iocb.ioctl_code = VOS_IOCTL_UART_SET_DATA_BITS;
	uart_iocb.set.param = UART_DATA_BITS_8;
	vos_dev_ioctl(hUART, &uart_iocb);

	// set stop bits
	uart_iocb.ioctl_code = VOS_IOCTL_UART_SET_STOP_BITS;
	uart_iocb.set.param = UART_STOP_BITS_1;
	vos_dev_ioctl(hUART, &uart_iocb);

	// set parity
	uart_iocb.ioctl_code = VOS_IOCTL_UART_SET_PARITY;
	uart_iocb.set.param = UART_PARITY_NONE;
	vos_dev_ioctl(hUART, &uart_iocb);
	
	//=================================================
	

	message("Starting...\r\n");
	
	do {
		vos_delay_msecs(1000);
		PS2_MS.conected = 0  ;
		// check if USB port 1 is configured already
		for (n = 0; n < 2; n++) {
			if (epCtrl[n] == NULL) {
				// user ioctl to see if selected USB port available
				if (usbhost_connect_state(hUsb[n]) == PORT_STATE_ENUMERATED) {
					message("Enumeration complete Port ");
					number(n);
					message(eol);

					// user ioctl to find first hub device
					hc_iocb.ioctl_code = VOS_IOCTL_USBHOST_DEVICE_GET_NEXT_HANDLE;
					// find first device interface
					hc_iocb.handle.dif = NULL;
					// hc_iocb.set = &hc_ioctVidPid;
					hc_iocb.get = &ifDev;
					status = vos_dev_ioctl(hUsb[n], &hc_iocb);

					if (status != USBHOST_OK)
					{
						message("No Device Found - code ");
						number(status);
						message(eol);
						break;
					}

					// user ioctl to find control endpoint on this device ====================!!!!!!!!!!!!!!
					hc_iocb.ioctl_code = VOS_IOCTL_USBHOST_DEVICE_GET_CONTROL_ENDPOINT_HANDLE;
					hc_iocb.handle.dif = ifDev;
					hc_iocb.get = &epCtrl[n];    // usbhost_ep_handle_ex epInt[2], epCtrl[2];

					status = vos_dev_ioctl(hUsb[n], &hc_iocb);

					if (status != USBHOST_OK)
					{
						message("No Control Endpoint Found - code ");
						number(status);
						message(eol);
						break;
					}

					// user ioctl to find first interrupt endpoint on this device
					hc_iocb.ioctl_code = VOS_IOCTL_USBHOST_DEVICE_GET_INT_IN_ENDPOINT_HANDLE;
					hc_iocb.handle.dif = ifDev;
					hc_iocb.get = &epInt[n];
					status = vos_dev_ioctl(hUsb[n], &hc_iocb);

					if (status != USBHOST_OK)
					{
						message("No interrupt Endpoint Found - code ");
						number(status);
						message(eol);
						break;
					}

					// user ioctl to find interrupt endpoint on this device
					hc_iocb.ioctl_code = VOS_IOCTL_USBHOST_DEVICE_GET_ENDPOINT_INFO;
					hc_iocb.handle.ep = epInt[n];
					hc_iocb.get = &epInfo;

					status = vos_dev_ioctl(hUsb[n], &hc_iocb);

					if (status != USBHOST_OK)
					{
						message("Interrupt Endpoint Info Not Found - code ");
						number(status);
						message(eol);
						break;
					}
					maxPack[n] = epInfo.max_size;
					//==========================================================================
					//========Report Desciptor==================================================
					descIndex =0x0;
					desc_dev.bmRequestType	=	USB_BMREQUESTTYPE_DEV_TO_HOST |
												USB_BMREQUESTTYPE_STANDARD |
												USB_BMREQUESTTYPE_INTERFACE;

					desc_dev.bRequest		=	USB_REQUEST_CODE_GET_DESCRIPTOR;
					// HID Report descriptor
					desc_dev.wValue			=	(USB_DESCRIPTOR_TYPE_REPORT << 8) | descIndex;
					desc_dev.wIndex			=	0x0000;
					desc_dev.wLength		=	0x00ff;
					//----------------------------------
					hc_iocb.ioctl_code		=	VOS_IOCTL_USBHOST_DEVICE_SETUP_TRANSFER;
					hc_iocb.handle.ep		=	epCtrl[n];
					hc_iocb.set				=	&desc_dev;
					hc_iocb.get				=	pParser->ReportDesc; //char buf[0x80]; //pParser->ReportDescbuf;
					
					memset(pParser->ReportDesc, 0, REPORT_DSC_SIZE);
					status = vos_dev_ioctl(hUsb[n], &hc_iocb);
					if (status != USBHOST_OK)
					{
						message("CONFIGURATION Descriptor failed - code ");
						number(status);
						message(eol);
						break;
					}
					//printf("\n Report Descriptor %d:\n", descIndex);
					message("Report Descriptor : ");
					number(descIndex);
					message(eol);
                    //============================================================		
					for (byteCount = 0x0; byteCount < 0x80; byteCount++)
					{
						number(pParser->ReportDesc[byteCount]);
						if  (byteCount == 0x0F) {message(eol);}
						if  (byteCount == 0x1F) {message(eol);}
						if  (byteCount == 0x2F) {message(eol);}
						if  (byteCount == 0x3F) {message(eol);}
						if  (byteCount == 0x4F) {message(eol);}
						if  (byteCount == 0x5F) {message(eol);}
						if  (byteCount == 0x6F) {message(eol);}
						if  (byteCount == 0x7F) {message(eol);}
					}
					//==Copy;
					//===============================================================================
					//===============================================================================
					ResetParser(pParser) ;
					pParser->ReportDescSize = REPORT_DSC_SIZE;
					max_ReportID = FindReport_max_ID(pParser);
					for (i=0; i < max_ReportID+1; ++i) {
						ReportID_tbl[i].ReportID_Offset = ReportID_Offset(pParser, (uchar)i);
						ReportID_tbl[i].ReportID_Length = ReportID_DataLength(pParser, (uchar)i);
					};
					message("Max Report ID : ");
					number(max_ReportID);
					message(eol);
					//======================HID DATA ===============================================================
					//TRACE("preparing search path of depth %d for parse tree of USB device %s...",depth, hidif->id);
					for (i=0; i < PATH_SIZE; ++i) {
						phid_data->Path_Node[i].UPage = 0x00;
						phid_data->Path_Node[i].Usage = 0x00;
					}
					phid_data->Path_Size = PATH_SIZE;
					//==============================================================
					Found[n]  = FindMouse_Buttons(pParser, phid_data)  ;
					if(Found[n]){
						PS2_MS.conected = 1;
						memcpy(ReportID_MS, ReportID_tbl, 10 * sizeof(ReportID_t));

						//ResetParser(pParser) ; //Restart
						FoundB[n]  = FindMouse_Buttons(pParser, phid_Bdata)  ;
						
						XYW = 0x30; //X - pos
						FoundX[n] = FindMouse_XYW(pParser, phid_Xdata, XYW);
						
						XYW = 0x31; //Y - pos
						FoundY[n] = FindMouse_XYW(pParser, phid_Ydata, XYW);
						
						XYW = 0x38; //Wheel
						FoundW[n] = FindMouse_XYW(pParser, phid_Wdata, XYW);
					}
					//=======================================================================================
					//=======================================================================================
					//-----------------Data extracting---------------
					message(eol);
					if (FoundB[n]){
						message("Mouse Button was found ");
						message(eol);
						message("Bit offset: ");
						number(phid_Bdata->Offset);
						message(eol);
						message("Sise(bit): ");
						number(phid_Bdata->Size);
						message(eol);
					}
					if (FoundX[n]){
						message("Mouse Xpos was found ");
						message(eol);
						message("Bit offset: ");
						number(phid_Xdata->Offset);
						message(eol);
						message("Sise(bit): ");
						number(phid_Xdata->Size);
						message(eol);
					}
					if (FoundY[n]){
						message("Mouse Ypos was found ");
						message(eol);
						message("Bit offset: ");
						number(phid_Ydata->Offset);
						message(eol);
						message("Sise(bit): ");
						number(phid_Ydata->Size);
						message(eol);
					}
					if (FoundW[n]){
						message("Mouse Wheel was found ");
						message(eol);
						message("Bit offset: ");
						number(phid_Wdata->Offset);
						message(eol);
						message("Sise(bit): ");
						number(phid_Wdata->Size);
						message(eol);
					}
					//==========================SETUP_TRANSFER======================
					// Prepare to transfer Data
					desc_dev.bmRequestType	=	USB_BMREQUESTTYPE_HOST_TO_DEV |
												USB_BMREQUESTTYPE_CLASS |
												USB_BMREQUESTTYPE_INTERFACE;
					desc_dev.bRequest		=	0x0a; //USB_REQUEST_CODE_GET_INTERFACE
					desc_dev.wValue			=	0;
					desc_dev.wIndex			=	0;
					desc_dev.wLength		=	0;
					//----------------------------------
					hc_iocb.ioctl_code		=	VOS_IOCTL_USBHOST_DEVICE_SETUP_TRANSFER;
					hc_iocb.handle.ep		=	epCtrl[n];
					hc_iocb.set				=	&desc_dev;

					vos_dev_ioctl(hUsb[n], &hc_iocb);

					message("Init complete Port ");
					number(n);
					message(eol);
				} // end of usbhost_connect_state(hUsb[i]) == PORT_STATE_ENUMERATED)
			} // end of epCtrl[i] == NULL
		} // end of for (n = 0; n < 2; i++)

		//message("Second Part "); ===================================================
		// message(eol);           ===================================================
		//if (epCtrl[0] || epCtrl[1])
		if (epCtrl[0])
		{
			LED_ON();		
			sem_list = (vos_semaphore_list_t *) vos_malloc(VOS_SEMAPHORE_LIST_SIZE(2));
			sem_list->next = NULL;     // initialise semaphore list
			sem_list->siz = 2;         // 2 semaphores (1 for each device endpoint)
			sem_list->flags = VOS_SEMAPHORE_FLAGS_WAIT_ANY;

			// initialise semaphore
			vos_init_semaphore(&endpointSem[0], 0);
			vos_init_semaphore(&endpointSem[1], 0);
			
			memset(xfer, 0, sizeof(xfer));
			xfer[0].flags 	= USBHOST_XFER_FLAG_NONBLOCKING | USBHOST_XFER_FLAG_ROUNDING;
			xfer[0].buf 	= buf;
			xfer[0].ep 		= epInt[0];
			xfer[0].s 		= &endpointSem[0];
			// Do not block on completion... we will wait on the sempaphore later
			xfer[1].flags 	= USBHOST_XFER_FLAG_NONBLOCKING | USBHOST_XFER_FLAG_ROUNDING;
			xfer[1].buf 	= buf;
			xfer[1].ep 		= epInt[1];
			xfer[1].s 		= &endpointSem[1];
			
			n = -1;
			while (1)
			{
				// Start or restart each endpoint transfer
				if (n != 1 && epCtrl[0]) // first: n= -1 
				{
					sem_list->list[0] = &endpointSem[0];
					xfer[0].len = maxPack[0];
					xfer[0].cond_code = USBHOST_CC_NOTACCESSED;
					status = vos_dev_read(hUsb[0], (unsigned char *) &xfer[0], sizeof(usbhost_xfer_t), NULL);

					if (status != USBHOST_OK)
					{
						message("Port 00 Read Failed - code ");
						number(status);
						message(eol);
						epCtrl[0] = 0x0;
						LED_OFF();
						break;
					}
				}

				if (n != 0 && epCtrl[1]) // first: n=-1
				{
					sem_list->list[1] = &endpointSem[1];
					xfer[1].len = maxPack[1];
					xfer[1].cond_code = USBHOST_CC_NOTACCESSED;

					status = vos_dev_read(hUsb[1], (unsigned char *) &xfer[1], sizeof(usbhost_xfer_t), NULL);

					if (status != USBHOST_OK)
					{
						message("Port 01 Read Failed - code ");
						number(status);
						message(eol);
						epCtrl[1] = 0x0;
						break;
					}
				}

				// Wait on a key press from either endpoint...
				n = vos_wait_semaphore_ex(sem_list);

				// Display data received
				message("Port ");
				number(n);
				message(" Data: ");

				//===========================================================
				// Display the data from the keyboard...=====================
				if (n == 0)
				{
					//  sem0 has signalled
					for (i = 0; i < xfer[0].len; i++)
						number(buf[i]);
						message(eol);
				}
				else if (n == 1)
				{
					// sem1 has signalled
					for (i = 0; i < xfer[1].len; i++)
						number(buf[i]);
						message(eol);
				}
				
				//===============================================
				//-----------------Data extracting---------------
				if (FoundB[n]){
					GetValue(buf,  phid_Bdata, ReportID_MS);
					PS2_MS.Button = phid_Bdata->Value;
					message("Mouse Button: ");
					number(PS2_MS.Button);
					message(eol);
				}
				if (FoundX[n]){
					GetValueXY(buf,  phid_Xdata, ReportID_MS);
					PS2_MS.Xpos = phid_Xdata->Value;
					Xpos = phid_Xdata->Value;
					pDATA = (unsigned char*) &PS2_MS.Xpos;
					message("Mouse Xpos: ");
					pDATA++;
					number(*pDATA); //Hi bit first 
					pDATA--;
					number(*pDATA);
					message(eol);
				}
				if (FoundY[n]){
					GetValueXY(buf,  phid_Ydata, ReportID_MS);
					PS2_MS.Ypos = phid_Ydata->Value;
					Ypos = phid_Ydata->Value;
					pDATA = (unsigned char*) &PS2_MS.Ypos;
					message("Mouse Ypos: ");
					pDATA++;
					number(*pDATA); //Hi bit first 
					pDATA--;
					number(*pDATA);
					message(eol);
				}
				if (FoundW[n]){
					GetValue(buf,  phid_Wdata, ReportID_MS);
					PS2_MS.Wheel = phid_Wdata->Value;
					pDATA = (unsigned char*) &PS2_MS.Wheel;
					message("Mouse Wheel: ");
					pDATA++;
					number(*pDATA); //Hi bit first 
					pDATA--;
					number(*pDATA);
					message(eol);
				}
				if (FoundB[n] || FoundX[n] || FoundY[n] || FoundW[n]){   //MS
					PS2_MS.new_data = 0x1;
				}
				else{                                                    //KB
					for (i = 0; i < 8; i++) {
						D_number(buf[i]);
						PS2_KB.usbkb_buf[i] = buf[i];
					}
					//memcpy(PS2_KB.usbkb_buf, buf, 8 * sizeof(char));
					PS2_KB.new_data = 0x0;
					//========PARSE===========================================
					KBParse(pPS2_KB);
					
					if (pPS2_KB->SW == 0x0){
						LIN_BUF_curr = pPS2_KB->LIN_BUF_0;
						LIN_BUF_prev = pPS2_KB->LIN_BUF_1;
					} else {
						LIN_BUF_curr = pPS2_KB->LIN_BUF_1;
						LIN_BUF_prev = pPS2_KB->LIN_BUF_0;
					}
					// ST_4 Check Release 
					for (i=0; i<14; i++)
					{
						if (CHECK_BIT(pPS2_KB->release, i))
						{
							BUFF = USB_PS2(LIN_BUF_prev[i]);
							
							if (BUFF > 0x80)
							{
								PS2KB_write(0xE0);
								PS2KB_write(0xF0);	// Break
								PS2KB_write(BUFF-0x80);
							}
							
							if (BUFF < 0x7F)
							{
								PS2KB_write(0xF0);	// Break
								PS2KB_write(BUFF);
							}
					

							//------------------------------
							//message("Key Release: ");
							//number(BUFF);
							//message(eol);
						}
					}   
					// ST_5 Check Press 
					for (i=0; i<14; i++){
						if (CHECK_BIT(pPS2_KB->press, i))
						{
							BUFF = USB_PS2(LIN_BUF_curr[i]);
							
							if (BUFF > 0x80) {
								PS2KB_write(0xE0);
								PS2KB_write(BUFF-0x80);
							}
							if (BUFF == 0x80) {
								PS2KB_write(0xFC);
							}
							if (BUFF < 0x7f) {
								PS2KB_write(BUFF);
							}
							
							//------------------------------
							//message("Key Press: ");
							//number(BUFF);
							//message(eol);
						}
					}
					//==========================================================
				}	
				//===========================================
 
				message(eol);
			}//while
		}//if (epCtrl[0] => Enter
	}
	while (1);
}

void PS2_MSthread(void)
{
	unsigned char  cmd;
	unsigned char  req;
	unsigned int   CLK;
	
	CLK = 0;
	
	do {
		req = PS2dev_host_req();      // PS2_clk or PS2_data - Low;
		if(req && PS2_MS.conected) {  
			while(PS2dev_read(&cmd))  ;   
			MS_cmd(cmd, &PS2_MS);
			CLK = 50000; 
		}
		else{ // == SEND BYTEs from USB device
			if(PS2_MS.StreamMode && PS2_MS.DataRepEN && PS2_MS.new_data && CLK == 0) {		
				MS_wr_packet(&PS2_MS);
				PS2_MS.new_data = 0x0;
			}
			if (CLK > 0){
			CLK--;
			}
		}
	}
	while (1);
}

void PS2_KBthread(void)
{
	;
}


