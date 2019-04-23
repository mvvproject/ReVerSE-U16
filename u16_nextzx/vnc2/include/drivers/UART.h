/*
** UART.h
**
** Copyright © 2009-2011 Future Technology Devices International Limited
**
** Header file containing definitions for VNC2 UART interface.
**
** Author: FTDI
** Project: Vinculum II Drivers
** Module: Vinculum II UART Driver
** Requires: vos.h ioctl.h
** Comments:
**
** History:
**  1 – Initial version
**
*/

#ifndef __UART_H__
#define __UART_H__

#include "ioctl.h"

#define UART_VERSION_STRING "2.0.2"

// UART IOCTL definitions
#define VOS_IOCTL_UART_GET_MODEM_STATUS			(VOS_IOCTL_UART_BASE)      // get the modem status
#define VOS_IOCTL_UART_GET_LINE_STATUS			(VOS_IOCTL_UART_BASE + 1)  // get the line status
#define VOS_IOCTL_UART_SET_BAUD_RATE			(VOS_IOCTL_UART_BASE + 2)  // set the baud rate
#define VOS_IOCTL_UART_SET_FLOW_CONTROL			(VOS_IOCTL_UART_BASE + 3)  // set flow control
#define VOS_IOCTL_UART_SET_DATA_BITS			(VOS_IOCTL_UART_BASE + 4)  // set the number of data bits
#define VOS_IOCTL_UART_SET_STOP_BITS			(VOS_IOCTL_UART_BASE + 5)  // set the number of stop bits
#define VOS_IOCTL_UART_SET_PARITY				(VOS_IOCTL_UART_BASE + 6)  // set the parity
#define VOS_IOCTL_UART_SET_RTS					(VOS_IOCTL_UART_BASE + 7)  // assert the RTS line
#define VOS_IOCTL_UART_CLEAR_RTS				(VOS_IOCTL_UART_BASE + 8)  // deassert the RTS line
#define VOS_IOCTL_UART_SET_DTR					(VOS_IOCTL_UART_BASE + 9)  // assert the DTR line
#define VOS_IOCTL_UART_CLEAR_DTR				(VOS_IOCTL_UART_BASE + 10) // deassert the DTR line
#define VOS_IOCTL_UART_SET_BREAK_ON				(VOS_IOCTL_UART_BASE + 11) // set line break condition
#define VOS_IOCTL_UART_SET_BREAK_OFF			(VOS_IOCTL_UART_BASE + 12) // clear line break condition
#define VOS_IOCTL_UART_SET_XON_CHAR				(VOS_IOCTL_UART_BASE + 13) // set the XOn character
#define VOS_IOCTL_UART_SET_XOFF_CHAR			(VOS_IOCTL_UART_BASE + 14) // set the XOff character
#define VOS_IOCTL_UART_WAIT_ON_MODEM_STATUS_INT (VOS_IOCTL_UART_BASE + 15) // wait on a Tx status interrupt (CTS, DSR,
                                                                           // RI, DCD, BUSY)
#define VOS_IOCTL_UART_WAIT_ON_LINE_STATUS_INT	(VOS_IOCTL_UART_BASE + 16) // wait on a line status interrupt (OE, PE,
                                                                           // SE, BI)

// Standard UART baud rates
// UART_BAUD_0, UART_BAUD_1, UART_BAUD_2
#define UART_BAUD_300		  300
#define UART_BAUD_600		  600
#define UART_BAUD_1200		  1200
#define UART_BAUD_2400		  2400
#define UART_BAUD_4800		  4800
#define UART_BAUD_9600		  9600
#define UART_BAUD_19200		  19200
#define UART_BAUD_38400		  38400
#define UART_BAUD_57600		  57600
#define UART_BAUD_115200	  115200
#define UART_BAUD_256000	  256000
#define UART_BAUD_500000	  500000
#define UART_BAUD_1000000	  1000000
#define UART_BAUD_1500000	  1500000
#define UART_BAUD_2000000	  2000000
#define UART_BAUD_3000000	  3000000
#define UART_BAUD_6000000	  6000000

// Data Bits
#define UART_DATA_BITS_7	  0
#define UART_DATA_BITS_8	  1

// Stop Bits
#define UART_STOP_BITS_1	  0
#define UART_STOP_BITS_2	  1

// Parity
#define UART_PARITY_NONE	  0
#define UART_PARITY_ODD		  1
#define UART_PARITY_EVEN	  2
#define UART_PARITY_MARK	  3
#define UART_PARITY_SPACE	  4

// Flow Control
#define UART_FLOW_NONE		  0
#define UART_FLOW_RTS_CTS	  1
#define UART_FLOW_DTR_DSR	  2
#define UART_FLOW_XON_XOFF	  3

// Modem Status
#define UART_MODEM_STATUS_CTS 1
#define UART_MODEM_STATUS_DSR 2
#define UART_MODEM_STATUS_DCD 4
#define UART_MODEM_STATUS_RI  8

// Line Status
#define UART_LINE_STATUS_OE	  2
#define UART_LINE_STATUS_PE	  4
#define UART_LINE_STATUS_FE	  8
#define UART_LINE_STATUS_BI	  16

enum UART_STATUS {
    UART_OK = 0,
    UART_INVALID_PARAMETER,
    UART_DMA_NOT_ENABLED,
    UART_ERROR,
    UART_FATAL_ERROR = 0xFF
};

// Context for UART
typedef struct _uart_context_t {
    unsigned char buffer_size;
} uart_context_t;

// UART initialisation function
unsigned char uart_init(
    unsigned char devNum,
    uart_context_t *context
    );

#endif                                 /* __UART_H__ */

