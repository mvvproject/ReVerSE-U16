/*
** devman.h
**
** Copyright © 2009-2011 Future Technology Devices International Limited
**
** Header file containing definitions for Vinculum II Kernel device manager
**
** Author: FTDI
** Project: Vinculum II Kernel
** Module: Vinculum II Kernel Device Manager
** Requires: vos.h
** Comments:
**
** History:
**  1 – Initial version
**
*/

#ifndef __DEVMAN_H__
#define __DEVMAN_H__

#define DEVMAN_VERSION_STRING "2.0.2"

// vos driver structure definition
typedef struct _vos_driver_t {
    PF_OPEN	 open;                     // dev_open()
    PF_CLOSE close;                    // dev_close()
    PF_IO	 read;                     // dev_read()
    PF_IO	 write;                    // dev_write()
    PF_IOCTL ioctl;                    // dev_ioctl()
    PF_INT	 interrupt;                // interrupt routine
    uint8	 flags;                    // miscellaneous flags tbd
} vos_driver_t;

// vos device structure definition
typedef struct _vos_device_t {
    vos_mutex_t	 mutex;                // mutex for exclusive access
    vos_driver_t *driver;              // driver struct
    void		 *context;             // context
} vos_device_t;

// device flags definition
#define VOS_DEV_OPEN 1

#define DEV_OPEN(d) ((d)->driver->flags & VOS_DEV_OPEN)

#define VOS_HANDLE	 uint16

// device manager registration function - called from a driver's init routine
void vos_dev_init(uint8 dev_num, vos_driver_t *driver_cb, void *context);

// vos device manager functions - mapped to driver routines for a device when calling vos_dev_init
VOS_HANDLE vos_dev_open(uint8 dev_num);
uint8 vos_dev_read(VOS_HANDLE h, uint8 *buf, uint16 num_to_read, uint16 *num_read);
uint8 vos_dev_write(VOS_HANDLE h, uint8 *buf, uint16 num_to_write, uint16 *num_written);
uint8 vos_dev_ioctl(VOS_HANDLE h, void *cb);
void vos_dev_close(VOS_HANDLE h);

// interrupt enable bit definitions
#define VOS_UART_INT_IEN		0x00001 // Interrupt enable bit for uart_int
#define VOS_USB_0_DEV_INT_IEN	0x00002 // Interrupt enable bit for usb_0_dev_int
#define VOS_USB_1_DEV_INT_IEN	0x00004 // Interrupt enable bit for usb_1_dev_int
#define VOS_USB_0_HC_INT_IEN	0x00100 // Interrupt enable bit for usb_0_hc_int
#define VOS_USB_1_HC_INT_IEN	0x00200 // Interrupt enable bit for usb_1_hc_int
#define VOS_GPIO_INT_IEN		0x00800 // Interrupt enable bit for gpio_int
#define VOS_SPI_MASTER_INT_IEN	0x01000 // Interrupt enable bit for spi_master_int
#define VOS_SPI_0_SLAVE_INT_IEN 0x02000 // Interrupt enable bit for spi_0_slave_int
#define VOS_SPI_1_SLAVE_INT_IEN 0x04000 // Interrupt enable bit for spi_1_slave_int
#define VOS_PWM_TOP_INT_IEN		0x08000 // Interrupt enable bit for pwm_top_int
#define VOS_FIFO_245_INT_IEN	0x10000 // Interrupt enable bit for fifo_245_int

void vos_enable_interrupts(uint32 mask);
void vos_disable_interrupts(uint32 mask);

// available buffer sizes for interface peripherals
#define VOS_BUFFER_SIZE_64_BYTES  0x00
#define VOS_BUFFER_SIZE_128_BYTES 0x40
#define VOS_BUFFER_SIZE_256_BYTES 0x80
#define VOS_BUFFER_SIZE_512_BYTES 0xC0

#endif
