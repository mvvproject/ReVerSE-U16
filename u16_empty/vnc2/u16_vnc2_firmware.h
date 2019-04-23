/*
** Filename: u16_vnc2_firmware.h
**
** Automatically created by Application Wizard 2.0.2
** 
** Part of solution firmware in project u16_vnc2_firmware
**
** Comments: 
**
** Important: Sections between markers "FTDI:S*" and "FTDI:E*" will be overwritten by
** the Application Wizard
*/

#ifndef _u16_vnc2_firmware_H_
#define _u16_vnc2_firmware_H_

#include "vos.h"

/* FTDI:SHF Header Files */
#include "USB.h"
#include "USBHost.h"
#include "ioctl.h"
#include "UART.h"
#include "GPIO.h"
#include "USBHID.h"
#include "USBHostHID.h"
#include "stdio.h"
#include "errno.h"
#include "string.h"
/* FTDI:EHF */

/* FTDI:SDC Driver Constants */
#define VOS_DEV_USBHOST_1 0
#define VOS_DEV_USBHOST_2 1
#define VOS_DEV_UART 2
#define VOS_DEV_GPIO_PORT_A 3
#define VOS_DEV_USBHOST_HID_1 4
#define VOS_DEV_USBHOST_HID_2 5

#define VOS_NUMBER_DEVICES 6
/* FTDI:EDC */

/* FTDI:SXH Externs */
/* FTDI:EXH */

#endif /* _u16_vnc2_firmware_H_ */
