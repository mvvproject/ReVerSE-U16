/*
** Filename: u16_vnc2_firmware_iomux.c
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
#include "vos.h"

void iomux_setup(void)
{
	/* FTDI:SIO IOMux Functions */
	unsigned char packageType;
	
	packageType = vos_get_package_type();
	if (packageType == VINCULUM_II_32_PIN)
	{
		// Debugger to pin 11 as Bi-Directional.
		vos_iomux_define_bidi(199, IOMUX_IN_DEBUGGER, IOMUX_OUT_DEBUGGER);
		// GPIO_Port_A_1 to pin 12 as Input.
		vos_iomux_define_input(12, IOMUX_IN_GPIO_PORT_A_1);
		// GPIO_Port_A_2 to pin 14 as Input.
		vos_iomux_define_input(14, IOMUX_IN_GPIO_PORT_A_2);
		// GPIO_Port_A_3 to pin 15 as Input.
		vos_iomux_define_input(15, IOMUX_IN_GPIO_PORT_A_3);
		// UART_TXD to pin 23 as Output.
		vos_iomux_define_output(23, IOMUX_OUT_UART_TXD);
		// UART_RXD to pin 24 as Input.
		vos_iomux_define_input(24, IOMUX_IN_UART_RXD);
		// UART_RTS_N to pin 25 as Output.
		vos_iomux_define_output(25, IOMUX_OUT_UART_RTS_N);
		// UART_CTS_N to pin 26 as Input.
		vos_iomux_define_input(26, IOMUX_IN_UART_CTS_N);
		vos_iocell_set_config(26, 0, 0, 0, 2);
		// SPI_Slave_0_CLK to pin 29 as Input.
		vos_iomux_define_input(29, IOMUX_IN_SPI_SLAVE_0_CLK);
		// SPI_Slave_0_MOSI to pin 30 as Input.
		vos_iomux_define_input(30, IOMUX_IN_SPI_SLAVE_0_MOSI);
		// SPI_Slave_0_MISO to pin 31 as Output.
		vos_iomux_define_output(31, IOMUX_OUT_SPI_SLAVE_0_MISO);
		// SPI_Slave_0_CS to pin 32 as Input.
		vos_iomux_define_input(32, IOMUX_IN_SPI_SLAVE_0_CS);
	
	}
	
	/* FTDI:EIO */
}
