/*
** USBPrinter.h
**
** Copyright © 2010-2011 Future Technology Devices International Limited
**
** THIS SOFTWARE IS PROVIDED BY FUTURE TECHNOLOGY DEVICES INTERNATIONAL LIMITED
** ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
** TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
** PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL FUTURE TECHNOLOGY DEVICES
** INTERNATIONAL LIMITED BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
** EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT
** OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
** INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
** STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
** OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH
** DAMAGE.
**
** Header file containing definitions for Vinculum II Host HID Driver
** Used internally by the HID driver only
**
** Author: FTDI
** Project: Vinculum II
** Module: Vinculum II USB Host HID Driver
** Requires: VOS
** Comments:
**
** History:
**  1 – Initial version
**
*/

#ifndef __USBHOSTHID_H__
#define __USBHOSTHID_H__

#define USBHOSTHID_VERSION_STRING "2.0.2"


enum USBHOSTHID_STATUS
{
    USBHOSTHID_OK = 0,
    USBHOSTHID_INVALID_PARAMETER,
    USBHOSTHID_ERROR,
    USBHOSTHID_NOT_FOUND,
    USBHOSTHID_USBHOST_ERROR = 0x80,
    USBHOSTHID_FATAL_ERROR = 0xFF
};


// USBHOSTHID IOCTL definitions
#define VOS_IOCTL_USBHOSTHID_BASE		0
#define VOS_IOCTL_USBHOSTHID_ATTACH					(VOS_IOCTL_USBHOSTHID_BASE + 1)
#define VOS_IOCTL_USBHOSTHID_DETACH					(VOS_IOCTL_USBHOSTHID_BASE + 2)
#define VOS_IOCTL_USBHOSTHID_GET_PROTOCOL			(VOS_IOCTL_USBHOSTHID_BASE + 3)
#define VOS_IOCTL_USBHOSTHID_SET_PROTOCOL			(VOS_IOCTL_USBHOSTHID_BASE + 4)
#define VOS_IOCTL_USBHOSTHID_GET_REPORT				(VOS_IOCTL_USBHOSTHID_BASE + 5)
#define VOS_IOCTL_USBHOSTHID_SET_REPORT				(VOS_IOCTL_USBHOSTHID_BASE + 6)
#define VOS_IOCTL_USBHOSTHID_GET_IDLE				(VOS_IOCTL_USBHOSTHID_BASE + 7)
#define VOS_IOCTL_USBHOSTHID_SET_IDLE				(VOS_IOCTL_USBHOSTHID_BASE + 8)
#define VOS_IOCTL_USBHOSTHID_GET_DESCRIPTOR			(VOS_IOCTL_USBHOSTHID_BASE + 9)
#define VOS_IOCTL_USBHOSTHID_GET_IN_REPORT_SIZE		(VOS_IOCTL_USBHOSTHID_BASE + 10)
#define VOS_IOCTL_USBHOSTHID_GET_OUT_REPORT_SIZE	(VOS_IOCTL_USBHOSTHID_BASE + 11)

// report types
#define USB_HID_REPORT_TYPE_INPUT		1
#define USB_HID_REPORT_TYPE_OUTPUT		2
#define USB_HID_REPORT_TYPE_FEATURE		3

// report ids
// set report id to 0 when report id is not used
#define USB_HID_REPORT_ID_ZERO			0
#define USB_HID_REPORT_ID_ONE			1
#define USB_HID_REPORT_ID_TWO			2
#define USB_HID_REPORT_ID_THREE			3

// protocol types
#define USB_HID_PROTOCOL_TYPE_BOOT		0
#define USB_HID_PROTOCOL_TYPE_REPORT	1

// descriptor index
#define USB_HID_DESCRIPTOR_INDEX_ZERO	0
#define USB_HID_DESCRIPTOR_INDEX_ONE	1
#define USB_HID_DESCRIPTOR_INDEX_TWO	2
#define USB_HID_DESCRIPTOR_INDEX_THREE	3

// USBHID IOCTL attach structure
typedef struct _usbHostHID_ioctl_cb_attach_t
{
    VOS_HANDLE				 hc_handle;
    usbhost_device_handle_ex ifDev;
} usbHostHID_ioctl_cb_attach_t;



// USBHID IOCTL structure
typedef struct _usbHostHID_ioctl_t
{
    uint8 	ioctl_code;

    uint8 	descriptorType;
    uint8 	descriptorIndex;

    uint8 	idleDuration;
    uint8 	protocolType;

    uint8 	reportType;
    uint8 	reportID;
    uint16 	Length;
    union
    {
        unsigned char *data;
        usbHostHID_ioctl_cb_attach_t *att;

    } set;
    union
    {
        unsigned char *data;
    } get;
} usbHostHID_ioctl_t;



uint8 usbHostHID_init(uint8 vos_dev_num);

#endif                                 /* __USBHOSTHID_H__ */
