/*
** GPIO.h
**
** Copyright © 2009-2011 Future Technology Devices International Limited
**
** Header file containing definitions for Vinculum II Kernel GPIO
**
** Author: FTDI
** Project: Vinculum II Kernel
** Module: Vinculum II Kernel GPIO
** Requires: vos.h
** Comments:
**
** History:
**  1 – Initial version
**
*/

#ifndef __GPIOCTRL_H__
#define __GPIOCTRL_H__

#define GPIOCTRL_VERSION_STRING "1.4.4"


// GPIO status definitions
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


// GPIO pin definitions
#define GPIO_A_0						  0
#define GPIO_A_1						  1
#define GPIO_A_2						  2
#define GPIO_A_3						  3
#define GPIO_A_4						  4
#define GPIO_A_5						  5
#define GPIO_A_6						  6
#define GPIO_A_7						  7
#define GPIO_B_0						  8
#define GPIO_B_1						  9
#define GPIO_B_2						  10
#define GPIO_B_3						  11
#define GPIO_B_4						  12
#define GPIO_B_5						  13
#define GPIO_B_6						  14
#define GPIO_B_7						  15
#define GPIO_C_0						  16
#define GPIO_C_1						  17
#define GPIO_C_2						  18
#define GPIO_C_3						  19
#define GPIO_C_4						  20
#define GPIO_C_5						  21
#define GPIO_C_6						  22
#define GPIO_C_7						  23
#define GPIO_D_0						  24
#define GPIO_D_1						  25
#define GPIO_D_2						  26
#define GPIO_D_3						  27
#define GPIO_D_4						  28
#define GPIO_D_5						  29
#define GPIO_D_6						  30
#define GPIO_D_7						  31
#define GPIO_E_0						  32
#define GPIO_E_1						  33
#define GPIO_E_2						  34
#define GPIO_E_3						  35
#define GPIO_E_4						  36
#define GPIO_E_5						  37
#define GPIO_E_6						  38
#define GPIO_E_7						  39


// GPIO port definitions
#define GPIO_PORT_A						  0
#define GPIO_PORT_B						  1
#define GPIO_PORT_C						  2
#define GPIO_PORT_D						  3
#define GPIO_PORT_E						  4


// GPIO interrupt identifiers
#define GPIO_INT_0						  0
#define GPIO_INT_1						  1
#define GPIO_INT_2						  2
#define GPIO_INT_3						  3
#define GPIO_INT_PORT_A					  4


// GPIO interrupt types
#define GPIO_INT_ON_POS_EDGE			  0x00 // Generate an interrupt on a positive edge
#define GPIO_INT_ON_NEG_EDGE			  0x01 // Generate an interrupt on a negative edge
#define GPIO_INT_ON_ANY_EDGE			  0x02 // Generate an interrupt on any edge
#define GPIO_INT_ON_LOW_STATE			  0x03 // Generate an interrupt on the specified GPIO being low
#define GPIO_INT_ON_HIGH_STATE			  0x04 // Generate an interrupt on the specified GPIO being high


typedef struct _vos_gpio_t {
    uint8 gpio_port_a;
    uint8 gpio_port_b;
    uint8 gpio_port_c;
    uint8 gpio_port_d;
    uint8 gpio_port_e;
} vos_gpio_t;




uint8 vos_gpio_set_pin_mode (uint8 pinId, uint8 mask);
uint8 vos_gpio_set_port_mode (uint8 portId, uint8 mask);
uint8 vos_gpio_set_all_mode (vos_gpio_t *masks);

uint8 vos_gpio_read_pin(uint8 pinId, uint8 *val);
uint8 vos_gpio_read_port(uint8 portId, uint8 *val);
uint8 vos_gpio_read_all(vos_gpio_t *vals);

uint8 vos_gpio_write_pin(uint8 pinId, uint8 val);
uint8 vos_gpio_write_port(uint8 portId, uint8 val);
uint8 vos_gpio_write_all(vos_gpio_t *vals);

uint8 vos_gpio_enable_int(uint8 intNum, uint8 intType, uint8 pinId);
uint8 vos_gpio_disable_int(uint8 intNum);
uint8 vos_gpio_wait_on_int(uint8 intNum);
uint8 vos_gpio_wait_on_any_int(uint8 *intNum);
uint8 vos_gpio_wait_on_all_ints(void);


#endif /* __GPIOCTRL_H__ */
