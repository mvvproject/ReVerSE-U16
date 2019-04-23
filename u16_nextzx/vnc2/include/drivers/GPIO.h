/*
** GPIO.h
**
** Copyright © 2009-2011 Future Technology Devices International Limited
**
** Header file containing definitions for Vinculum II GPIOs
**
** Author: FTDI
** Project: Vinculum II Drivers
** Module: Vinculum II GPIO Driver
** Requires: vos.h
** Comments:
**
** History:
**  1 – Initial version
**
*/

#ifndef __GPIO_H__
#define __GPIO_H__

#define GPIO_VERSION_STRING "2.0.2"

#define VOS_IOCTL_GPIO_SET_MASK			  1  // set pins to either input (0) or output (1)
#define VOS_IOCTL_GPIO_SET_PROG_INT0_PIN  2  // configure programmable interrupt 0 pin
#define VOS_IOCTL_GPIO_SET_PROG_INT1_PIN  3  // configure programmable interrupt 1 pin
#define VOS_IOCTL_GPIO_SET_PROG_INT2_PIN  4  // configure programmable interrupt 2 pin
#define VOS_IOCTL_GPIO_SET_PROG_INT3_PIN  5  // configure programmable interrupt 3 pin
#define VOS_IOCTL_GPIO_SET_PROG_INT0_MODE 6  // configure programmable interrupt 0 mode
#define VOS_IOCTL_GPIO_SET_PROG_INT1_MODE 7  // configure programmable interrupt 1 mode
#define VOS_IOCTL_GPIO_SET_PROG_INT2_MODE 8  // configure programmable interrupt 2 mode
#define VOS_IOCTL_GPIO_SET_PROG_INT3_MODE 9  // configure programmable interrupt 3 mode
#define VOS_IOCTL_GPIO_SET_PORT_INT		  10 // configure port interrupt
#define VOS_IOCTL_GPIO_WAIT_ON_INT0		  11 // wait on interrupt 0 firing
#define VOS_IOCTL_GPIO_WAIT_ON_INT1		  12 // wait on interrupt 1 firing
#define VOS_IOCTL_GPIO_WAIT_ON_INT2		  13 // wait on interrupt 2 firing
#define VOS_IOCTL_GPIO_WAIT_ON_INT3		  14 // wait on interrupt 3 firing
#define VOS_IOCTL_GPIO_WAIT_ON_PORT_INT	  15 // wait on port interrupt firing

// GPIO port identifier definitions
#define GPIO_PORT_A						  0
#define GPIO_PORT_B						  1
#define GPIO_PORT_C						  2
#define GPIO_PORT_D						  3
#define GPIO_PORT_E						  4

// GPIO configurable interrupt pin definitions - port B only
#define GPIO_PIN_0						  0
#define GPIO_PIN_1						  1
#define GPIO_PIN_2						  2
#define GPIO_PIN_3						  3
#define GPIO_PIN_4						  4
#define GPIO_PIN_5						  5
#define GPIO_PIN_6						  6
#define GPIO_PIN_7						  7

// GPIO_INT0_MODE, GPIO_INT1_MODE, GPIO_INT2_MODE & GPIO_INT3_MODE - port B only
#define GPIO_INT_ON_POS_EDGE			  0x00 // Generate an interrupt on a positive edge
#define GPIO_INT_ON_NEG_EDGE			  0x01 // Generate an interrupt on a negative edge
#define GPIO_INT_ON_ANY_EDGE			  0x02 // Generate an interrupt on any edge
#define GPIO_INT_ON_LOW_STATE			  0x03 // Generate an interrupt on the specified GPIO being low
#define GPIO_INT_ON_HIGH_STATE			  0x04 // Generate an interrupt on the specified GPIO being high
#define GPIO_INT_DISABLE				  0x05 // Disable interrupts

// GPIO_PORT_INT - port A only
#define GPIO_PORT_INT_ENABLE			  0x00 // Enable port interrupts on Port A
#define GPIO_PORT_INT_DISABLE			  0x01 // Disable port interrupts on Port A

enum GPIO_STATUS {
    GPIO_OK = 0,
    GPIO_INVALID_PORT_IDENTIFIER,
    GPIO_INVALID_PARAMETER,
    GPIO_INTERRUPT_NOT_ENABLED,
    GPIO_ERROR,
    GPIO_FATAL_ERROR = 0xFF
};

// GPIO context
typedef struct _gpio_context_t {
    unsigned char port_identifier;
} gpio_context_t;

// GPIO control block for use with GPIO IOCTL function
typedef struct _gpio_ioctl_cb_t {
    unsigned char ioctl_code;
    unsigned char value;
} gpio_ioctl_cb_t;

// GPIO initialisation function
unsigned char gpio_init(
    unsigned char devNum,
    void *context
    );

#endif                                 /* __GPIO_H__ */

