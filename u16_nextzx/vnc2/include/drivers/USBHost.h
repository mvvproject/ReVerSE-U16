/*
** USBHost.h
**
** Copyright © 2009-2011 Future Technology Devices International Limited
**
** Header file containing definitions for Vinculum II USB Host Controller.
**
** Author: FTDI
** Project: Vinculum II Drivers
** Module: Vinculum II USB Host controller Driver
** Requires: vos.h
** Comments:
**
** History:
**  1 – Initial version
**
*/

#ifndef __USBHOST_H__
#define __USBHOST_H__

#define USBHOST_VERSION_STRING "2.0.2"

#define USBHOST_MEMORY_REQUIRED 0x700

#define USBHOST_PORT_1			0
#define USBHOST_PORT_2			1

enum USBHOST_STATUS {
    USBHOST_OK = 0,                    // 0
    USBHOST_NOT_FOUND,                 // 1
    USBHOST_PENDING,                   // 2
    USBHOST_INVALID_PARAMETER,         // 3
    USBHOST_INVALID_BUFFER,            // 4
    USBHOST_INCOMPLETE_ENUM,           // 5
    USBHOST_INVALID_CONFIGURATION,     // 6
    USBHOST_TD_FULL,                   // 7
    USBHOST_EP_FULL,                   // 8
    USBHOST_IF_FULL,                   // 9
    USBHOST_EP_HALTED,                 // 10
    USBHOST_EP_INVALID,                // 11
    USBHOST_INVALID_STATE,             // 12
    USBHOST_ERROR,                     // 13
    USBHOST_CC_ERROR = 0x10,           // 16
    USBHOST_FATAL_ERROR = 0xff,        // -1
};

// NOERROR
// General TD or isochronous data packet processing
// completed with no detected errors
#define USBHOST_CC_NOERROR			   0
// CRC
// Last data packet from endpoint contained a CRC error.
#define USBHOST_CC_CRC				   1
// BITSTUFFING
// Last data packet from endpoint contained a bit stuffing
// violation
#define USBHOST_CC_BITSTUFFING		   2
// DATATOGGLEMISMATCH
// Last packet from endpoint had data toggle PID that did
// not match the expected value.
#define USBHOST_CC_DATATOGGLEMISMATCH  3
// STALL
// TD was moved to the Done Queue because the endpoint
// returned a STALL PID
#define USBHOST_CC_STALL			   4
// DEVICENOTRESPONDING
// Device did not respond to token (IN) or did not provide a
// handshake (OUT)
#define USBHOST_CC_DEVICENOTRESPONDING 5
// PIDCHECKFAILURE
// Check bits on PID from endpoint failed on data PID (IN)
// or handshake (OUT)
#define USBHOST_CC_PIDCHECKFAILURE	   6
// UNEXPECTEDPID
// Receive PID was not valid when encountered or PID
// value is not defined.
#define USBHOST_CC_UNEXPECTEDPID	   7
// DATAOVERRUN
// The amount of data returned by the endpoint exceeded
// either the size of the maximum data packet allowed from
// the endpoint (found in MaximumPacketSize field of ED)
// or the remaining buffer size.
#define USBHOST_CC_DATAOVERRUN 8
// DATAUNDERRUN
// The endpoint returned less than MaximumPacketSize
// and that amount was not sufficient to fill the specified
// buffer
#define USBHOST_CC_DATAUNDERRUN	 9
// BUFFEROVERRUN
// During an IN, HC received data from endpoint faster than
// it could be written to system memory (Non-Isochronous TDs only)
#define USBHOST_CC_BUFFEROVERRUN 10
// BUFFERUNDERRUN
// During an OUT, HC could not retrieve data from system
// memory fast enough to keep up with data USB data rate.
// (Non-Isochronous TDs only)
#define USBHOST_CC_BUFFERUNDERRUN	 11
// BUFFEROVERRUN
// During an IN, HC received data from endpoint faster than
// it could be written to system memory (Isochronous TDs Only)
#define USBHOST_CC_BUFFEROVERRUN_ISO 12
// BUFFERUNDERRUN
// During an OUT, HC could not retrieve data from system
// memory fast enough to keep up with data USB data rate.
// (Isochronous TDs Only)
#define USBHOST_CC_BUFFERUNDERRUN_ISO 13
// NOT ACCESSED
// This code is set by software before the TD is placed on a
// list to be processed by the HC.
#define USBHOST_CC_NOTACCESSED		  15

// Root Hub State
// Response from VOS_IOCTL_USBHOST_GET_CONNECT_STATE
#define PORT_STATE_DISCONNECTED		  0x00
#define PORT_STATE_CONNECTED		  0x01
#define PORT_STATE_ENUMERATED		  0x11

// Host controller state
// VOS_IOCTL_USBHOST_GET_USB_STATE
#define USB_STATE_RESET				  0x00
#define USB_STATE_OPERATIONAL		  0x01
#define USB_STATE_RESUME			  0x02
#define USB_STATE_SUSPEND			  0x03
#define USB_STATE_CHANGE_PENDING	  0x10

// interface handle
typedef void *usbhost_device_handle;   // basic handle mode
typedef int	 usbhost_device_handle_ex; // extended handle mode
// endpoint handle
typedef void *usbhost_ep_handle;       // basic handle mode
typedef int	 usbhost_ep_handle_ex;     // extended handle mode

// for Control, Bulk, Interrupt Transfers
typedef struct _usbhost_xfer_t {
    // handle of endpoint to use
    // can use either usbhost_ep_handle or usbhost_ep_handle_ex types
    usbhost_ep_handle_ex ep;
    // reference for report completion notification
    // used for blocking on control and bulk
    vos_semaphore_t		 *s;

    // result condition code (4 bits)
    unsigned char		 cond_code;

    // buffer pointer and size
    unsigned char		 *buf;
    // total size of buffer
    // modified to actual total size of transfer
    unsigned short		 len;

    // start list enable, blocking and notification
    unsigned char		 flags;

    // internal driver use only
    unsigned char		 resv1;

    // MUST be set to zero
    unsigned char		 zero;
} usbhost_xfer_t;

// for Isochronous Transfers only
typedef struct _usbhost_xfer_iso_t {
    // handle of endpoint to use
    // can use either usbhost_ep_handle or usbhost_ep_handle_ex types
    usbhost_ep_handle_ex ep;
    // reference for report completion notification
    // used for blocking on control and bulk
    vos_semaphore_t		 *s;

    // result condition code (4 bits)
    unsigned char		 cond_code;

    // buffer pointer and size
    unsigned char		 *buf;
    
    // not used for ISO, refer to the size field in len_psw
    unsigned short		 len;

    // start list enable, blocking and notification
    unsigned char		 flags;

    // internal driver use only
    unsigned char		 resv1;

    // Isochronous Only
    // frame count (number of buffers - 1; max 8 buffers)
    unsigned char		 count;

    // size of each frame transaction
    struct {
        unsigned short size : 11;
        unsigned short pad : 1;
        unsigned short cond_code : 4;
    }			   len_psw[8];

    // start frame number
    unsigned short frame;
} usbhost_xfer_iso_t;

// flags for usbhost_xfer_t
/* deprecated: not used */
#define USBHOST_XFER_FLAG_START_CTRL_ENDPOINT_LIST_BIT 0
/* set only for BULK endpoints */
#define USBHOST_XFER_FLAG_START_BULK_ENDPOINT_LIST_BIT 1
#define USBHOST_XFER_FLAG_NONBLOCKING_BIT			   5
#define USBHOST_XFER_FLAG_ROUNDING_BIT				   6
/* deprecated: not used */
#define USBHOST_XFER_FLAG_START_CTRL_ENDPOINT_LIST	   0
/* set only for BULK endpoints */
#define USBHOST_XFER_FLAG_START_BULK_ENDPOINT_LIST	   (1 << USBHOST_XFER_FLAG_START_BULK_ENDPOINT_LIST_BIT)
#define USBHOST_XFER_FLAG_NONBLOCKING				   (1 << USBHOST_XFER_FLAG_NONBLOCKING_BIT)
#define USBHOST_XFER_FLAG_ROUNDING					   (1 << USBHOST_XFER_FLAG_ROUNDING_BIT)

// HC IOCTL definitions

// HUB status class requests
#define VOS_IOCTL_USBHUB_HUB_PORT_COUNT						  0x00
#define VOS_IOCTL_USBHUB_HUB_STATUS							  0x01
#define VOS_IOCTL_USBHUB_PORT_STATUS						  0x02

// HUB features class requests (Hubs)
#define VOS_IOCTL_USBHUB_CLEAR_C_HUB_LOCAL_POWER			  0x03
#define VOS_IOCTL_USBHUB_CLEAR_C_HUB_OVERCURRENT			  0x04

// HUB features class requests (Ports)
#define VOS_IOCTL_USBHUB_CLEAR_PORT_ENABLE					  0x05
#define VOS_IOCTL_USBHUB_SET_PORT_SUSPEND					  0x06
#define VOS_IOCTL_USBHUB_CLEAR_PORT_SUSPEND					  0x07
#define VOS_IOCTL_USBHUB_SET_PORT_RESET						  0x08
#define VOS_IOCTL_USBHUB_SET_PORT_POWER						  0x09
#define VOS_IOCTL_USBHUB_CLEAR_PORT_POWER					  0x0a

// HUB features class requests (Port Change Stauts)
#define VOS_IOCTL_USBHUB_CLEAR_C_PORT_CONNECTION			  0x0b
#define VOS_IOCTL_USBHUB_CLEAR_C_PORT_ENABLE				  0x0c
#define VOS_IOCTL_USBHUB_CLEAR_C_PORT_SUSPEND				  0x0d
#define VOS_IOCTL_USBHUB_CLEAR_C_PORT_OVERCURRENT			  0x0e
#define VOS_IOCTL_USBHUB_CLEAR_C_PORT_RESET					  0x0f

// host controller control and status commands
#define VOS_IOCTL_USBHOST_GET_CONNECT_STATE					  0x10
#define VOS_IOCTL_USBHOST_ENUMERATE							  0x11
#define VOS_IOCTL_USBHOST_GET_ENUMERATION_HANDLE              0x12
#define VOS_IOCTL_USBHOST_GET_USB_STATE						  0x14
#define VOS_IOCTL_USBHOST_SET_HANDLE_MODE_EXTENDED			  0x18
#define VOS_IOCTL_USBHOST_DEVICE_GET_CONFIGURATION			  0x1E
#define VOS_IOCTL_USBHOST_DEVICE_SET_CONFIGURATION			  0x1F

// finding devices
#define VOS_IOCTL_USBHOST_DEVICE_GET_COUNT					  0x20
#define VOS_IOCTL_USBHOST_DEVICE_GET_NEXT_HANDLE			  0x21
#define VOS_IOCTL_USBHOST_DEVICE_FIND_HANDLE_BY_VID_PID		  0x22
#define VOS_IOCTL_USBHOST_DEVICE_FIND_HANDLE_BY_CLASS		  0x23
#define VOS_IOCTL_USBHOST_DEVICE_GET_VID_PID				  0x24
#define VOS_IOCTL_USBHOST_DEVICE_GET_CLASS_INFO				  0x25
#define VOS_IOCTL_USBHOST_DEVICE_GET_DEV_INFO				  0x26
// finding endpoints
#define VOS_IOCTL_USBHOST_DEVICE_GET_CONTROL_ENDPOINT_HANDLE  0x30
#define VOS_IOCTL_USBHOST_DEVICE_GET_BULK_IN_ENDPOINT_HANDLE  0x31
#define VOS_IOCTL_USBHOST_DEVICE_GET_BULK_OUT_ENDPOINT_HANDLE 0x32
#define VOS_IOCTL_USBHOST_DEVICE_GET_INT_IN_ENDPOINT_HANDLE	  0x33
#define VOS_IOCTL_USBHOST_DEVICE_GET_INT_OUT_ENDPOINT_HANDLE  0x34
#define VOS_IOCTL_USBHOST_DEVICE_GET_ISO_IN_ENDPOINT_HANDLE	  0x35
#define VOS_IOCTL_USBHOST_DEVICE_GET_ISO_OUT_ENDPOINT_HANDLE  0x36
#define VOS_IOCTL_USBHOST_DEVICE_GET_NEXT_ENDPOINT_HANDLE	  0x37
#define VOS_IOCTL_USBHOST_DEVICE_GET_ENDPOINT_INFO			  0x38
// controlling endpoints and interfaces
#define VOS_IOCTL_USBHOST_SET_INTERFACE						  0x40
#define VOS_IOCTL_USBHOST_DEVICE_CLEAR_ENDPOINT_HALT		  0x41
#define VOS_IOCTL_USBHOST_DEVICE_CLEAR_HOST_HALT			  0x42
#define VOS_IOCTL_USBHOST_DEVICE_SET_HOST_HALT				  0x43
#define VOS_IOCTL_USBHOST_DEVICE_CLEAR_ENDPOINT_CARRY		  0x44
#define VOS_IOCTL_USBHOST_DEVICE_CLEAR_ENPOINT_CARRY		  VOS_IOCTL_USBHOST_DEVICE_CLEAR_ENDPOINT_CARRY // deprecated spelling
#define VOS_IOCTL_USBHOST_DEVICE_TOGGLE_ENDPOINT_CARRY		  0x45
#define VOS_IOCTL_USBHOST_DEVICE_TOGGLE_ENPOINT_CARRY		  VOS_IOCTL_USBHOST_DEVICE_TOGGLE_ENDPOINT_CARRY // deprecated spelling
#define VOS_IOCTL_USBHOST_DEVICE_CLEAR_ENDPOINT_TRANSFER	  0x48
// transactions
#define VOS_IOCTL_USBHOST_DEVICE_SETUP_TRANSFER				  0x50
// controlling hardware interface
#define VOS_IOCTL_USBHOST_HW_GET_FRAME_NUMBER				  0x58
// 0x80 upwards reserved for hub specific requests

// USB Host control block for use with HC IOCTL function
typedef struct _usbhost_ioctl_cb_t {
    unsigned char ioctl_code;
    // hub port number (ignored on root hub)
    unsigned char hub_port;
    union
    {
        // handle of endpoint to use
        // can use either usbhost_ep_handle or usbhost_ep_handle_ex types
        usbhost_ep_handle_ex	 ep;
        // handle of interface to use
        // can use either usbhost_device_handle or usbhost_device_handle_ex types
        usbhost_device_handle_ex dif;
    }	 handle;
    // read buffer
    void *get;
    // write butter
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
    // interface number from descriptor
    unsigned char interface_number;
    unsigned char speed;
    // alternate setting for this interface SET_INTERFACE
    unsigned char alt;
    // active configuration value SET_CONFIGURATION
    unsigned char configuration;
    // total number of configurations for this device
    unsigned char num_configurations;
} usbhost_ioctl_cb_dev_info_t;

typedef struct _usbhost_ioctl_cb_ep_info_t {
    unsigned char  number;
    unsigned short max_size;
    unsigned char  speed;
} usbhost_ioctl_cb_ep_info_t;

// Context for USB Host
typedef struct _usbhost_context_t {
    // number of interfaces both USB hosts combined
    unsigned char if_count;
    // number of endpoints (excluding control endpoints) expected
    unsigned char ep_count;
    // number of concurrent transaction expected
    unsigned char xfer_count;
    // number of concurrent isochronous transactions expected
    unsigned char iso_xfer_count;
} usbhost_context_t;

// USB Host initialisation function
unsigned char usbhost_init(unsigned char devNum_1, unsigned char devNum_2, usbhost_context_t *context);

#endif                                 /* __USBHOST_H__ */
