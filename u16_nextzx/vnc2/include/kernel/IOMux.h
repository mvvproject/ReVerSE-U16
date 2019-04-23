/*
** IOMux.h
**
** Copyright © 2009-2011 Future Technology Devices International Limited
**
** Header file containing definitions for Vinculum II Kernel IO multiplexer
**
** Author: FTDI
** Project: Vinculum II Kernel
** Module: Vinculum II Kernel IOMux Driver
** Requires: vos.h
** Comments:
**
** History:
**  1 – Initial version
**
*/

#ifndef __IOMUX_H__
#define __IOMUX_H__

#define IOMUX_VERSION_STRING "2.0.2"

enum IOMUX_SIGNALS {
    // Define input signals
    // Debugger interface inputs
    IOMUX_IN_DEBUGGER = 0,
    // UART interface inputs
    IOMUX_IN_UART_RXD,
    IOMUX_IN_UART_CTS_N,
    IOMUX_IN_UART_DSR_N,
    IOMUX_IN_UART_DCD,
    IOMUX_IN_UART_RI,
    // FIFO interface inputs
    IOMUX_IN_FIFO_DATA_0,
    IOMUX_IN_FIFO_DATA_1,
    IOMUX_IN_FIFO_DATA_2,
    IOMUX_IN_FIFO_DATA_3,
    IOMUX_IN_FIFO_DATA_4,
    IOMUX_IN_FIFO_DATA_5,
    IOMUX_IN_FIFO_DATA_6,
    IOMUX_IN_FIFO_DATA_7,
    IOMUX_IN_FIFO_OE_N,
    IOMUX_IN_FIFO_RD_N,
    IOMUX_IN_FIFO_WR_N,
    // SPI Slave 0 interface inputs
    IOMUX_IN_SPI_SLAVE_0_CLK,
    IOMUX_IN_SPI_SLAVE_0_MOSI,
    IOMUX_IN_SPI_SLAVE_0_CS,
    // SPI Slave 1 interface inputs
    IOMUX_IN_SPI_SLAVE_1_CLK,
    IOMUX_IN_SPI_SLAVE_1_MOSI,
    IOMUX_IN_SPI_SLAVE_1_CS,
    // SPI Master interface inputs
    IOMUX_IN_SPI_MASTER_MISO,
    // GPIO port A interface inputs
    IOMUX_IN_GPIO_PORT_A_0,            // gpio[A0]
    IOMUX_IN_GPIO_PORT_A_1,            // gpio[A1]
    IOMUX_IN_GPIO_PORT_A_2,            // gpio[A2]
    IOMUX_IN_GPIO_PORT_A_3,            // gpio[A3]
    IOMUX_IN_GPIO_PORT_A_4,            // gpio[A4]
    IOMUX_IN_GPIO_PORT_A_5,            // gpio[A5]
    IOMUX_IN_GPIO_PORT_A_6,            // gpio[A6]
    IOMUX_IN_GPIO_PORT_A_7,            // gpio[A7]
    // GPIO port B interface inputs
    IOMUX_IN_GPIO_PORT_B_0,            // gpio[B0]
    IOMUX_IN_GPIO_PORT_B_1,            // gpio[B1]
    IOMUX_IN_GPIO_PORT_B_2,            // gpio[B2]
    IOMUX_IN_GPIO_PORT_B_3,            // gpio[B3]
    IOMUX_IN_GPIO_PORT_B_4,            // gpio[B4]
    IOMUX_IN_GPIO_PORT_B_5,            // gpio[B5]
    IOMUX_IN_GPIO_PORT_B_6,            // gpio[B6]
    IOMUX_IN_GPIO_PORT_B_7,            // gpio[B7]
    // GPIO port C interface inputs
    IOMUX_IN_GPIO_PORT_C_0,            // gpio[C0]
    IOMUX_IN_GPIO_PORT_C_1,            // gpio[C1]
    IOMUX_IN_GPIO_PORT_C_2,            // gpio[C2]
    IOMUX_IN_GPIO_PORT_C_3,            // gpio[C3]
    IOMUX_IN_GPIO_PORT_C_4,            // gpio[C4]
    IOMUX_IN_GPIO_PORT_C_5,            // gpio[C5]
    IOMUX_IN_GPIO_PORT_C_6,            // gpio[C6]
    IOMUX_IN_GPIO_PORT_C_7,            // gpio[C7]
    // GPIO port D interface inputs
    IOMUX_IN_GPIO_PORT_D_0,            // gpio[D0]
    IOMUX_IN_GPIO_PORT_D_1,            // gpio[D1]
    IOMUX_IN_GPIO_PORT_D_2,            // gpio[D2]
    IOMUX_IN_GPIO_PORT_D_3,            // gpio[D3]
    IOMUX_IN_GPIO_PORT_D_4,            // gpio[D4]
    IOMUX_IN_GPIO_PORT_D_5,            // gpio[D5]
    IOMUX_IN_GPIO_PORT_D_6,            // gpio[D6]
    IOMUX_IN_GPIO_PORT_D_7,            // gpio[D7]
    // GPIO port E interface inputs
    IOMUX_IN_GPIO_PORT_E_0,            // gpio[E0]
    IOMUX_IN_GPIO_PORT_E_1,            // gpio[E1]
    IOMUX_IN_GPIO_PORT_E_2,            // gpio[E2]
    IOMUX_IN_GPIO_PORT_E_3,            // gpio[E3]
    IOMUX_IN_GPIO_PORT_E_4,            // gpio[E4]
    IOMUX_IN_GPIO_PORT_E_5,            // gpio[E5]
    IOMUX_IN_GPIO_PORT_E_6,            // gpio[E6]
    IOMUX_IN_GPIO_PORT_E_7,            // gpio[E7]

    // Define output signals
    // Debugger interface outputs
    IOMUX_OUT_DEBUGGER,
    // UART interface outputs
    IOMUX_OUT_UART_TXD,
    IOMUX_OUT_UART_RTS_N,
    IOMUX_OUT_UART_DTR_N,
    IOMUX_OUT_UART_TX_ACTIVE,
    // FIFO interface outputs
    IOMUX_OUT_FIFO_DATA_0,
    IOMUX_OUT_FIFO_DATA_1,
    IOMUX_OUT_FIFO_DATA_2,
    IOMUX_OUT_FIFO_DATA_3,
    IOMUX_OUT_FIFO_DATA_4,
    IOMUX_OUT_FIFO_DATA_5,
    IOMUX_OUT_FIFO_DATA_6,
    IOMUX_OUT_FIFO_DATA_7,
    IOMUX_OUT_FIFO_RXF_N,
    IOMUX_OUT_FIFO_TXE_N,
    // PWM interface outputs
    IOMUX_OUT_PWM_0,
    IOMUX_OUT_PWM_1,
    IOMUX_OUT_PWM_2,
    IOMUX_OUT_PWM_3,
    IOMUX_OUT_PWM_4,
    IOMUX_OUT_PWM_5,
    IOMUX_OUT_PWM_6,
    IOMUX_OUT_PWM_7,
    // SPI Slave 0 outputs
    IOMUX_OUT_SPI_SLAVE_0_MOSI,
    IOMUX_OUT_SPI_SLAVE_0_MISO,
    // SPI Slave 1 outputs
    IOMUX_OUT_SPI_SLAVE_1_MOSI,
    IOMUX_OUT_SPI_SLAVE_1_MISO,
    // SPI Master outputs
    IOMUX_OUT_SPI_MASTER_CLK,
    IOMUX_OUT_SPI_MASTER_MOSI,
    IOMUX_OUT_SPI_MASTER_CS_0,
    IOMUX_OUT_SPI_MASTER_CS_1,
    // Synchronous 245 FIFO clock output
    IOMUX_OUT_FIFO_CLKOUT_245,
    // GPIO port A interface outputs
    IOMUX_OUT_GPIO_PORT_A_0,           // gpio[A0]
    IOMUX_OUT_GPIO_PORT_A_1,           // gpio[A1]
    IOMUX_OUT_GPIO_PORT_A_2,           // gpio[A2]
    IOMUX_OUT_GPIO_PORT_A_3,           // gpio[A3]
    IOMUX_OUT_GPIO_PORT_A_4,           // gpio[A4]
    IOMUX_OUT_GPIO_PORT_A_5,           // gpio[A5]
    IOMUX_OUT_GPIO_PORT_A_6,           // gpio[A6]
    IOMUX_OUT_GPIO_PORT_A_7,           // gpio[A7]
    // GPIO port B interface outputs
    IOMUX_OUT_GPIO_PORT_B_0,           // gpio[B0]
    IOMUX_OUT_GPIO_PORT_B_1,           // gpio[B1]
    IOMUX_OUT_GPIO_PORT_B_2,           // gpio[B2]
    IOMUX_OUT_GPIO_PORT_B_3,           // gpio[B3]
    IOMUX_OUT_GPIO_PORT_B_4,           // gpio[B4]
    IOMUX_OUT_GPIO_PORT_B_5,           // gpio[B5]
    IOMUX_OUT_GPIO_PORT_B_6,           // gpio[B6]
    IOMUX_OUT_GPIO_PORT_B_7,           // gpio[B7]
    // GPIO port C interface outputs
    IOMUX_OUT_GPIO_PORT_C_0,           // gpio[C0]
    IOMUX_OUT_GPIO_PORT_C_1,           // gpio[C1]
    IOMUX_OUT_GPIO_PORT_C_2,           // gpio[C2]
    IOMUX_OUT_GPIO_PORT_C_3,           // gpio[C3]
    IOMUX_OUT_GPIO_PORT_C_4,           // gpio[C4]
    IOMUX_OUT_GPIO_PORT_C_5,           // gpio[C5]
    IOMUX_OUT_GPIO_PORT_C_6,           // gpio[C6]
    IOMUX_OUT_GPIO_PORT_C_7,           // gpio[C7]
    // GPIO port D interface outputs
    IOMUX_OUT_GPIO_PORT_D_0,           // gpio[D0]
    IOMUX_OUT_GPIO_PORT_D_1,           // gpio[D1]
    IOMUX_OUT_GPIO_PORT_D_2,           // gpio[D2]
    IOMUX_OUT_GPIO_PORT_D_3,           // gpio[D3]
    IOMUX_OUT_GPIO_PORT_D_4,           // gpio[D4]
    IOMUX_OUT_GPIO_PORT_D_5,           // gpio[D5]
    IOMUX_OUT_GPIO_PORT_D_6,           // gpio[D6]
    IOMUX_OUT_GPIO_PORT_D_7,           // gpio[D7]
    // GPIO port E interface outputs
    IOMUX_OUT_GPIO_PORT_E_0,           // gpio[E0]
    IOMUX_OUT_GPIO_PORT_E_1,           // gpio[E1]
    IOMUX_OUT_GPIO_PORT_E_2,           // gpio[E2]
    IOMUX_OUT_GPIO_PORT_E_3,           // gpio[E3]
    IOMUX_OUT_GPIO_PORT_E_4,           // gpio[E4]
    IOMUX_OUT_GPIO_PORT_E_5,           // gpio[E5]
    IOMUX_OUT_GPIO_PORT_E_6,           // gpio[E6]
    IOMUX_OUT_GPIO_PORT_E_7            // gpio[E7]
};

enum IOMUX_STATUS {
    IOMUX_OK = 0,
    IOMUX_INVALID_SIGNAL,
    IOMUX_INVALID_PIN_SELECTION,
    IOMUX_UNABLE_TO_ROUTE_SIGNAL,
    IOMUX_INVALID_IOCELL_DRIVE_CURRENT,
    IOMUX_INVALID_IOCELL_TRIGGER,
    IOMUX_INVALID_IOCELL_SLEW_RATE,
    IOMUX_INVALID_IOCELL_PULL,
    IOMUX_ERROR
};

// IO Cell driver current definitions
#define VOS_IOCELL_DRIVE_CURRENT_4MA  0x00
#define VOS_IOCELL_DRIVE_CURRENT_8MA  0x01
#define VOS_IOCELL_DRIVE_CURRENT_12MA 0x02
#define VOS_IOCELL_DRIVE_CURRENT_16MA 0x03

// IO Cell trigger definitions
#define VOS_IOCELL_TRIGGER_NORMAL	  0x00
#define VOS_IOCELL_TRIGGER_SCHMITT	  0x01

// IO Cell slew rate definitions
#define VOS_IOCELL_SLEW_RATE_FAST	  0x00
#define VOS_IOCELL_SLEW_RATE_SLOW	  0x01

// IO Cell pull definitions
#define VOS_IOCELL_PULL_NONE		  0x00
#define VOS_IOCELL_PULL_DOWN_75K	  0x01
#define VOS_IOCELL_PULL_UP_75K		  0x02
#define VOS_IOCELL_PULL_KEEPER_75K	  0x03

// VOS interface functions
uint8 vos_iomux_define_input(uint8 pin, uint8 signal);
uint8 vos_iomux_define_output(uint8 pin, uint8 signal);
uint8 vos_iomux_define_bidi(uint8 pin, uint8 input_signal, uint8 output_signal);
uint8 vos_iomux_disable_output(uint8 pin);

uint8 vos_iocell_get_config(uint8 pin, uint8 *drive_current, uint8 *trigger, uint8 *slew_rate, uint8 *pull);
uint8 vos_iocell_set_config(uint8 pin, uint8 drive_current, uint8 trigger, uint8 slew_rate, uint8 pull);

#endif                                 /*__IOMUX_H__*/
