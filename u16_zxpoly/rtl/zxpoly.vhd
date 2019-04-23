-------------------------------------------------------------------[06.04.2015]
-- ReVerSE-u16 ZX-Poly Version 2.10
-- DEVBOARD ReVerSE-U16
-------------------------------------------------------------------------------
-- Engineer: 	MVV
--
-- 21.03.2015	первая версия
-------------------------------------------------------------------------------

-- http://zx-pk.ru/showthread.php?t=24856

-- Copyright © 2015 MVV, Raydac
--
-- All rights reserved
--
-- Redistribution and use in source and synthezised forms, with or without
-- modification, are permitted provided that the following conditions are met:
--
-- * Redistributions of source code must retain the above copyright notice,
--   this list of conditions and the following disclaimer.
--
-- * Redistributions in synthesized form must reproduce the above copyright
--   notice, this list of conditions and the following disclaimer in the
--   documentation and/or other materials provided with the distribution.
--
-- * Neither the name of the author nor the names of other contributors may
--   be used to endorse or promote products derived from this software without
--   specific prior written agreement from the author.
--
-- * License is granted for non-commercial use only.  A fee may not be charged
--   for redistributions as source code or in synthesized/hardware form without 
--   specific prior written agreement from the author.
--
-- THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
-- AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
-- THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
-- PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE
-- LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
-- CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
-- SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
-- INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
-- CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
-- ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
-- POSSIBILITY OF SUCH DAMAGE.

library IEEE; 
use IEEE.std_logic_1164.all; 
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all; 

-- M9K 66K:
-- 00000-01FFF	CPU0 SCR0	8K
-- 02000-03FFF	CPU0 SCR1	8K
-- 04000-05FFF	CPU1 SCR0	8K
-- 06000-07FFF	CPU1 SCR1	8K
-- 08000-09FFF	CPU2 SCR0	8K
-- 0A000-0BFFF	CPU2 SCR1	8K
-- 0C000-0DFFF	CPU3 SCR0	8K
-- 0E000-0FFFF	CPU3 SCR1	8K
-- 10000-107FF	Loader		2K


-- SDRAM 32M:
-- 0000000-1FFFFFF

-- FLASH 2MB:
-- 68000-6BFFF		GLUK 			16K
-- 6C000-6FFFF		TR-DOS 			16K
-- 70000-73FFF		OS'86 			16K
-- 74000-77FFF		OS'82 			16K
-- 78000-7AFFF		DivMMC			 8K
-- 7B000-7BFFF		свободно		 8К
-- 7C000-7FFFF		свободно		16К

entity zxpoly is
port (
	-- Clock (50MHz)
	CLK_50MHZ	: in std_logic;
	-- SDRAM (32MB 16x16bit)
	SDRAM_D		: inout std_logic_vector(15 downto 0);
	SDRAM_A		: out std_logic_vector(12 downto 0);
	SDRAM_BA	: out std_logic_vector(1 downto 0);
	SDRAM_CLK	: out std_logic;
	SDRAM_DQML	: out std_logic;
	SDRAM_DQMH	: out std_logic;
	SDRAM_WE_n	: out std_logic;
	SDRAM_CAS_n	: out std_logic;
	SDRAM_RAS_n	: out std_logic;
	-- RTC (DS1338Z-33+)
	SCL		: inout std_logic;
	SDA		: inout std_logic;
	-- SPI FLASH (M25P16)
	DATA0		: in std_logic;
	NCSO		: out std_logic;
	DCLK		: out std_logic;
	ASDO		: out std_logic;
	-- SPI (ENC424J600)
	ETH_SO		: in std_logic;
	ETH_NINT	: in std_logic;
	ETH_NCS		: out std_logic;
	-- HDMI
	HDMI_D0		: out std_logic;
	HDMI_D1		: out std_logic;
	HDMI_D1_n	: out std_logic;
	HDMI_D2		: out std_logic;
	HDMI_CLK	: out std_logic;
	-- External I/O
	RST_n		: in std_logic;
	GPI		: in std_logic;
	RX		: in std_logic;
	DAC_OUT_L	: out std_logic;
	DAC_OUT_R	: out std_logic;
	-- SD/MMC Card
	SD_DET_n	: in std_logic;		
	SD_SO		: in std_logic;
	SD_SI		: out std_logic;
	SD_CLK		: out std_logic;
	SD_CS_n		: out std_logic);
end zxpoly;

architecture rtl of zxpoly is

-- zx 0
signal zx0_sel		: std_logic;
signal zx0_cpu_do	: std_logic_vector(7 downto 0);
signal zx0_cpu_a	: std_logic_vector(15 downto 0);
signal zx0_cpu_int	: std_logic;
signal zx0_cpu_inta	: std_logic;
signal zx0_cpu_rfsh	: std_logic;
signal zx0_cpu_rd_n	: std_logic;
signal zx0_cpu_wr_n	: std_logic;
signal zx0_cpu_iorq_n	: std_logic;
signal zx0_ram_a	: std_logic_vector(11 downto 0);
signal zx0_ram_di	: std_logic_vector(7 downto 0);
signal zx0_ram_wr	: std_logic;
signal zx0_ram_rd	: std_logic;
signal zx0_video_a	: std_logic_vector(12 downto 0);
signal zx0_video_do	: std_logic_vector(7 downto 0);
signal zx0_video_attr	: std_logic_vector(7 downto 0);
signal zx0_video_border	: std_logic;
signal zx0_port_xxfe	: std_logic_vector(7 downto 0);
signal zx0_port_0001	: std_logic_vector(7 downto 0);
signal zx0_zc_rd	: std_logic;
signal zx0_zc_wr	: std_logic;
signal zx0_spi_wr	: std_logic;
signal zx0_i2c_wr	: std_logic;
signal zx0_divmmc_cs	: std_logic;
signal zx0_divmmc_sclk	: std_logic;
signal zx0_divmmc_mosi	: std_logic;
signal zx0_divmmc_sel	: std_logic;
-- zx 1
signal zx1_sel		: std_logic;
signal zx1_cpu_do	: std_logic_vector(7 downto 0);
signal zx1_cpu_a	: std_logic_vector(15 downto 0);
signal zx1_cpu_int	: std_logic;
signal zx1_cpu_rfsh	: std_logic;
signal zx1_ram_a	: std_logic_vector(11 downto 0);
signal zx1_ram_di	: std_logic_vector(7 downto 0);
signal zx1_ram_wr	: std_logic;
signal zx1_ram_rd	: std_logic;
signal zx1_video_a	: std_logic_vector(12 downto 0);
signal zx1_video_do	: std_logic_vector(7 downto 0);
signal zx1_video_attr	: std_logic_vector(7 downto 0);
signal zx1_video_border	: std_logic;
signal zx1_port_xxfe	: std_logic_vector(7 downto 0);
signal zx1_port_0001	: std_logic_vector(7 downto 0);
signal zx1_zc_rd	: std_logic;
signal zx1_zc_wr	: std_logic;
signal zx1_spi_wr	: std_logic;
signal zx1_i2c_wr	: std_logic;
signal zx1_divmmc_cs	: std_logic;
signal zx1_divmmc_sclk	: std_logic;
signal zx1_divmmc_mosi	: std_logic;
signal zx1_divmmc_sel	: std_logic;
-- zx 2
signal zx2_sel		: std_logic;
signal zx2_cpu_do	: std_logic_vector(7 downto 0);
signal zx2_cpu_a	: std_logic_vector(15 downto 0);
signal zx2_cpu_int	: std_logic;
signal zx2_cpu_rfsh	: std_logic;
signal zx2_ram_a	: std_logic_vector(11 downto 0);
signal zx2_ram_di	: std_logic_vector(7 downto 0);
signal zx2_ram_wr	: std_logic;
signal zx2_ram_rd	: std_logic;
signal zx2_video_a	: std_logic_vector(12 downto 0);
signal zx2_video_do	: std_logic_vector(7 downto 0);
signal zx2_video_attr	: std_logic_vector(7 downto 0);
signal zx2_video_border	: std_logic;
signal zx2_port_xxfe	: std_logic_vector(7 downto 0);
signal zx2_port_0001	: std_logic_vector(7 downto 0);
signal zx2_spi_wr	: std_logic;
signal zx2_i2c_wr	: std_logic;
signal zx2_divmmc_cs	: std_logic;
signal zx2_divmmc_sclk	: std_logic;
signal zx2_divmmc_mosi	: std_logic;
signal zx2_divmmc_sel	: std_logic;
-- zx 3
signal zx3_sel		: std_logic;
signal zx3_cpu_do	: std_logic_vector(7 downto 0);
signal zx3_cpu_a	: std_logic_vector(15 downto 0);
signal zx3_cpu_int	: std_logic;
signal zx3_cpu_rfsh	: std_logic;
signal zx3_ram_a	: std_logic_vector(11 downto 0);
signal zx3_ram_di	: std_logic_vector(7 downto 0);
signal zx3_ram_wr	: std_logic;
signal zx3_ram_rd	: std_logic;
signal zx3_video_a	: std_logic_vector(12 downto 0);
signal zx3_video_do	: std_logic_vector(7 downto 0);
signal zx3_video_attr	: std_logic_vector(7 downto 0);
signal zx3_video_border	: std_logic;
signal zx3_port_xxfe	: std_logic_vector(7 downto 0);
signal zx3_port_0001	: std_logic_vector(7 downto 0);
signal zx3_spi_wr	: std_logic;
signal zx3_i2c_wr	: std_logic;
signal zx3_divmmc_cs	: std_logic;
signal zx3_divmmc_sclk	: std_logic;
signal zx3_divmmc_mosi	: std_logic;
signal zx3_divmmc_sel	: std_logic;
-- Selector
signal zx_sel		: std_logic_vector(1 downto 0) := "00";
-- Keyboard
signal kb_soft_bus	: std_logic_vector(2 downto 0);
signal kb_a_bus		: std_logic_vector(7 downto 0);
signal kb_do_bus	: std_logic_vector(4 downto 0);
signal kb_fn_bus	: std_logic_vector(12 downto 1);
signal kb_joy_bus	: std_logic_vector(4 downto 0);
signal key_temp		: std_logic_vector(2 downto 0);
signal kb_soft		: std_logic_vector(2 downto 0);
-- Video
signal video_hsync	: std_logic;
signal video_vsync	: std_logic;
signal video_blank	: std_logic;
signal video_rgb	: std_logic_vector(5 downto 0);
-- SPI
signal spi_si		: std_logic;
signal spi_so		: std_logic;
signal spi_clk		: std_logic;
signal spi_wr		: std_logic;
signal spi_cs_n		: std_logic;
signal spi_a		: std_logic;
signal spi_di_bus	: std_logic_vector(7 downto 0);
signal spi_do_bus	: std_logic_vector(7 downto 0);
signal spi_busy		: std_logic;
-- I2C Controller
signal i2c_do_bus	: std_logic_vector(7 downto 0);
signal i2c_wr		: std_logic;
signal i2c_di_bus	: std_logic_vector(7 downto 0);
signal i2c_a		: std_logic;
-- DivMMC
signal divmmc_cs_n	: std_logic;
signal divmmc_sclk	: std_logic;
signal divmmc_mosi	: std_logic;
signal divmmc_sel	: std_logic;
-- Sound
signal fx_sum		: std_logic_vector(2 downto 0);
signal audio_l		: std_logic_vector(18 downto 0);
signal audio_r		: std_logic_vector(18 downto 0);
-- CLOCK
signal clk_28mhz	: std_logic;
signal clk_84mhz	: std_logic;
signal clk_168mhz	: std_logic;
signal clk_hdmi		: std_logic;
signal clk_vga		: std_logic;
signal clk_14mhz	: std_logic;
------------------------------------
signal ena_3_5mhz	: std_logic;
signal ena_1_75mhz	: std_logic;
signal ena_0_4375mhz	: std_logic;
signal ena_cnt		: std_logic_vector(7 downto 0);
-- System
signal reset		: std_logic;
signal areset		: std_logic;
signal locked0		: std_logic;
signal locked1		: std_logic;
signal rom_do		: std_logic_vector(7 downto 0);
signal port_0001	: std_logic_vector(7 downto 0);
signal cpu_ena		: std_logic;


begin

-- PLL 0
U0: entity work.altpll0
port map (
	areset		=> areset,
	inclk0		=> CLK_50MHZ,
	locked		=> locked0,
	c0		=> clk_84mhz,	-- 84.0 MHz
	c1		=> clk_28mhz,	-- 28.0 MHz
	c2		=> clk_14mhz,	-- 14.0 MHz
	c3		=> SDRAM_CLK);	-- 84.0 MHz
-- PLL 1
U1: entity work.altpll1
port map (
	areset		=> areset,
	inclk0		=> CLK_50MHZ,
	locked		=> locked1,
	c0		=> clk_hdmi,	-- 125.0 MHz
	c1		=> clk_vga );	--  25.0 MHz

-- ROM 1K
U2: entity work.altram0
port map (
	clock_a		=> clk_84mhz,
	clock_b		=> clk_84mhz,
	address_a	=> zx0_cpu_a(10 downto 0),
	address_b	=> (others => '0'),
	data_a	 	=> (others => '0'),
	data_b	 	=> (others => '0'),
	q_a	 	=> rom_do,
	q_b	 	=> open,
	wren_a	 	=> '0',
	wren_b	 	=> '0');

-- Video
U3: entity work.video
port map (
	CLK_I		=> clk_28mhz,
	ENA_I		=> ena_3_5mhz,
	CLK_VGA_I	=> clk_vga,
	-- Channal 0
	CH0_INT_O	=> zx0_cpu_int,
	CH0_ADR_O	=> zx0_video_a,
	CH0_DAT_I	=> zx0_video_do,
	CH0_BORDER_I	=> zx0_port_xxfe(2 downto 0),	-- Биты D0..D2 порта xxFE определяют цвет бордюра
	CH0_ATTR_O	=> zx0_video_attr,
	CH0_BORDER_O	=> zx0_video_border,
	-- Channal 1
	CH1_INT_O	=> zx1_cpu_int,
	CH1_ADR_O	=> zx1_video_a,
	CH1_DAT_I	=> zx1_video_do,
	CH1_BORDER_I	=> zx1_port_xxfe(2 downto 0),	-- Биты D0..D2 порта xxFE определяют цвет бордюра
	CH1_ATTR_O	=> zx1_video_attr,
	CH1_BORDER_O	=> zx1_video_border,
	-- Channal 2
	CH2_INT_O	=> zx2_cpu_int,
	CH2_ADR_O	=> zx2_video_a,
	CH2_DAT_I	=> zx2_video_do,
	CH2_BORDER_I	=> zx2_port_xxfe(2 downto 0),	-- Биты D0..D2 порта xxFE определяют цвет бордюра
	CH2_ATTR_O	=> zx2_video_attr,
	CH2_BORDER_O	=> zx2_video_border,
	-- Channal 3
	CH3_INT_O	=> zx3_cpu_int,
	CH3_ADR_O	=> zx3_video_a,
	CH3_DAT_I	=> zx3_video_do,
	CH3_BORDER_I	=> zx3_port_xxfe(2 downto 0),	-- Биты D0..D2 порта xxFE определяют цвет бордюра
	CH3_ATTR_O	=> zx3_video_attr,
	CH3_BORDER_O	=> zx3_video_border,
	--
	SEL_I		=> zx_sel,
	MODE_I		=> kb_soft(1),
	BLANK_O		=> video_blank,
	RGB_O		=> video_rgb,
	HSYNC_O		=> video_hsync,
	VSYNC_O		=> video_vsync);

U4: entity work.hdmi
port map(
	CLK_I		=> clk_hdmi,
	CLK_PIXEL_I	=> clk_vga,
	R_I		=> video_rgb(5 downto 4) & video_rgb(5 downto 4) & video_rgb(5 downto 4) & video_rgb(5 downto 4),
	G_I		=> video_rgb(3 downto 2) & video_rgb(3 downto 2) & video_rgb(3 downto 2) & video_rgb(3 downto 2),
	B_I		=> video_rgb(1 downto 0) & video_rgb(1 downto 0) & video_rgb(1 downto 0) & video_rgb(1 downto 0),
	BLANK_I		=> video_blank,
	HSYNC_I		=> video_hsync,
	VSYNC_I		=> video_vsync,
	TMDS_D0_O	=> HDMI_D0,
	TMDS_D1_O	=> HDMI_D1,
	TMDS_D2_O	=> HDMI_D2,
	TMDS_CLK_O	=> HDMI_CLK);
	
-- Keyboard
U5: entity work.keyboard
port map(
	CLK		=> clk_28mhz,
	RESET		=> areset,
	A		=> kb_a_bus,
	KEYB		=> kb_do_bus,
	KEYF		=> kb_fn_bus,
	KEYJOY		=> kb_joy_bus,
	KEYSOFT		=> kb_soft_bus,
	RX		=> RX);

-- SPI FLASH 25MHz Max SCK -- Ethernet ENC424J600
U8: entity work.spi
port map (
	RESET		=> reset,
	CLK		=> clk_28mhz,
	SCK		=> clk_14mhz,
	A		=> spi_a,
	DI		=> spi_di_bus,
	DO		=> spi_do_bus,
	WR		=> spi_wr,
	BUSY		=> spi_busy,
	CS_n		=> spi_cs_n,
	SCLK		=> spi_clk,
	MOSI		=> spi_si,
	MISO		=> spi_so);
	
-- SDRAM Controller
U9: entity work.sdram
port map (
	RST_I		=> areset,
	CLK_I		=> clk_84mhz,
	ENA_O		=> cpu_ena,
	-- Channal 0
	CH0_ADR_I	=> zx0_ram_a & zx0_cpu_a(12 downto 0),
	CH0_DAT_I	=> zx0_cpu_do,
	CH0_DAT_O	=> zx0_ram_di,
	CH0_WR_I	=> zx0_ram_wr,
	CH0_RD_I	=> zx0_ram_rd,
	CH0_RFSH_I	=> zx0_cpu_rfsh,
	-- Channal 1
	CH1_ADR_I	=> zx1_ram_a & zx1_cpu_a(12 downto 0),
	CH1_DAT_I	=> zx1_cpu_do,
	CH1_DAT_O	=> zx1_ram_di,
	CH1_WR_I	=> zx1_ram_wr,
	CH1_RD_I	=> zx1_ram_rd,
	CH1_RFSH_I	=> zx1_cpu_rfsh,
	-- Channal 2
	CH2_ADR_I	=> zx2_ram_a & zx2_cpu_a(12 downto 0),
	CH2_DAT_I	=> zx2_cpu_do,
	CH2_DAT_O	=> zx2_ram_di,
	CH2_WR_I	=> zx2_ram_wr,
	CH2_RD_I	=> zx2_ram_rd,
	CH2_RFSH_I	=> zx2_cpu_rfsh,
	-- Channal 3
	CH3_ADR_I	=> zx3_ram_a & zx3_cpu_a(12 downto 0),
	CH3_DAT_I	=> zx3_cpu_do,
	CH3_DAT_O	=> zx3_ram_di,
	CH3_WR_I	=> zx3_ram_wr,
	CH3_RD_I	=> zx3_ram_rd,
	CH3_RFSH_I	=> zx3_cpu_rfsh,
	-- SDRAM Pin
	CK		=> open,
	RAS_n		=> SDRAM_RAS_n,
	CAS_n		=> SDRAM_CAS_n,
	WE_n		=> SDRAM_WE_n,
	DQML		=> SDRAM_DQML,
	DQMH		=> SDRAM_DQMH,
	BA		=> SDRAM_BA,
	MA		=> SDRAM_A,
	DQ		=> SDRAM_D);

-- I2C Controller
U10: entity work.i2c
port map (
	RESET		=> reset,
	CLK		=> clk_28mhz,
	ENA		=> ena_0_4375mhz,
	A		=> i2c_a,
	DI		=> i2c_di_bus,
	DO		=> i2c_do_bus,
	WR		=> i2c_wr,
	I2C_SCL		=> SCL,
	I2C_SDA		=> SDA);

-- Delta-Sigma
U11: entity work.dac
generic map (
	msbi_g		=> 18)
port map (
	CLK   		=> clk_84mhz,
	RESET 		=> areset,
	DAC_DATA	=> audio_l,
	DAC_OUT		=> dac_out_l);

-- Delta-Sigma
U12: entity work.dac
generic map (
	msbi_g		=> 18)
port map (
	CLK   		=> clk_84mhz,
	RESET 		=> areset,
	DAC_DATA	=> audio_r,
	DAC_OUT   	=> dac_out_r);

-- CPU0
U13: entity work.zx
generic map (
	Loader		=> '1',
	CPU		=> "00" )
port map (
	RST_I		=> reset,
	CLK_I		=> clk_28mhz,
	SEL_I		=> zx0_sel,
	ENA_1_75MHZ_I	=> ena_1_75mhz,
	ENA_0_4375MHZ_I	=> ena_0_4375mhz,
	-- CPU
	CPU_DAT_O	=> zx0_cpu_do,
	CPU_ADR_O	=> zx0_cpu_a,
	CPU_INT_I	=> zx0_cpu_int,
	CPU_CLK_I	=> clk_84mhz,
	CPU_ENA_I	=> cpu_ena,
	CPU_RFSH_O	=> zx0_cpu_rfsh,
	CPU_RDn_O	=> zx0_cpu_rd_n,
	CPU_WRn_O	=> zx0_cpu_wr_n,
	CPU_IORQn_O	=> zx0_cpu_iorq_n,
	CPU_INTA_O	=> zx0_cpu_inta,
	-- ROM
	ROM_DAT_I	=> rom_do,
	-- RAM
	RAM_ADR_O	=> zx0_ram_a,
	RAM_DAT_I	=> zx0_ram_di,
	RAM_WR_O	=> zx0_ram_wr,
	RAM_RD_O	=> zx0_ram_rd,
	-- Video
	VIDEO_CLK_I	=> clk_vga,
	VIDEO_ADR_I	=> zx0_video_a,
	VIDEO_DAT_O	=> zx0_video_do,
	VIDEO_ATTR_I	=> zx0_video_attr,
	VIDEO_BORDER_I	=> zx0_video_border,
	-- Port
	PORT_XXFE_O	=> zx0_port_xxfe,
	PORT_0001_O	=> zx0_port_0001,
	-- Keyboard
	KEYBOARD_DAT_I	=> kb_do_bus,
	KEYBOARD_FN_I	=> kb_fn_bus,
	KEYBOARD_JOY_I	=> kb_joy_bus,
	KEYBOARD_SOFT_I	=> kb_soft_bus,
	-- SPI Controller
	SPI_DAT_I	=> spi_do_bus,
	SPI_WR_O	=> zx0_spi_wr,
	SPI_BUSY	=> spi_busy,
	-- I2C Controller
	I2C_DAT_I	=> i2c_do_bus,
	I2C_WR_O	=> zx0_i2c_wr,
	-- DivMMC
	DIVMMC_SC_O	=> zx0_divmmc_cs,
	DIVMMC_SCLK_O	=> zx0_divmmc_sclk,
	DIVMMC_MOSI_O	=> zx0_divmmc_mosi,
	DIVMMC_MISO_I	=> SD_SO,
	DIVMMC_SEL_O	=> zx0_divmmc_sel );

-- CPU1
U14: entity work.zx
generic map (
	Loader		=> '0',
	CPU		=> "01" )
port map (
	RST_I		=> reset,
	CLK_I		=> clk_28mhz,
	SEL_I		=> zx1_sel,
	ENA_1_75MHZ_I	=> ena_1_75mhz,
	ENA_0_4375MHZ_I	=> ena_0_4375mhz,
	-- CPU
	CPU_DAT_O	=> zx1_cpu_do,
	CPU_ADR_O	=> zx1_cpu_a,
	CPU_INT_I	=> zx1_cpu_int,
	CPU_CLK_I	=> clk_84mhz,
	CPU_ENA_I	=> cpu_ena,
	CPU_RFSH_O	=> zx1_cpu_rfsh,
	CPU_RDn_O	=> open,
	CPU_WRn_O	=> open,
	CPU_IORQn_O	=> open,
	CPU_INTA_O	=> open,
	-- ROM
	ROM_DAT_I	=> (others => '1'),
	-- RAM
	RAM_ADR_O	=> zx1_ram_a,
	RAM_DAT_I	=> zx1_ram_di,
	RAM_WR_O	=> zx1_ram_wr,
	RAM_RD_O	=> zx1_ram_rd,
	-- Video
	VIDEO_CLK_I	=> clk_vga,
	VIDEO_ADR_I	=> zx1_video_a,
	VIDEO_DAT_O	=> zx1_video_do,
	VIDEO_ATTR_I	=> zx1_video_attr,
	VIDEO_BORDER_I	=> zx1_video_border,
	-- Port
	PORT_XXFE_O	=> zx1_port_xxfe,
	PORT_0001_O	=> zx1_port_0001,
	-- Keyboard
	KEYBOARD_DAT_I	=> kb_do_bus,
	KEYBOARD_FN_I	=> kb_fn_bus,
	KEYBOARD_JOY_I	=> kb_joy_bus,
	KEYBOARD_SOFT_I	=> kb_soft_bus,
	-- SPI Controller
	SPI_DAT_I	=> spi_do_bus,
	SPI_WR_O	=> zx1_spi_wr,
	SPI_BUSY	=> spi_busy,
	-- I2C Controller
	I2C_DAT_I	=> i2c_do_bus,
	I2C_WR_O	=> zx1_i2c_wr,
	-- DivMMC
	DIVMMC_SC_O	=> zx1_divmmc_cs,
	DIVMMC_SCLK_O	=> zx1_divmmc_sclk,
	DIVMMC_MOSI_O	=> zx1_divmmc_mosi,
	DIVMMC_MISO_I	=> SD_SO,
	DIVMMC_SEL_O	=> zx1_divmmc_sel );

-- CPU2
U15: entity work.zx
generic map (
	Loader		=> '0',
	CPU		=> "10" )
port map (
	RST_I		=> reset,
	CLK_I		=> clk_28mhz,
	SEL_I		=> zx2_sel,
	ENA_1_75MHZ_I	=> ena_1_75mhz,
	ENA_0_4375MHZ_I	=> ena_0_4375mhz,
	-- CPU
	CPU_DAT_O	=> zx2_cpu_do,
	CPU_ADR_O	=> zx2_cpu_a,
	CPU_INT_I	=> zx2_cpu_int,
	CPU_CLK_I	=> clk_84mhz,
	CPU_ENA_I	=> cpu_ena,
	CPU_RFSH_O	=> zx2_cpu_rfsh,
	CPU_RDn_O	=> open,
	CPU_WRn_O	=> open,
	CPU_IORQn_O	=> open,
	CPU_INTA_O	=> open,
	-- ROM
	ROM_DAT_I	=> (others => '1'),
	-- RAM
	RAM_ADR_O	=> zx2_ram_a,
	RAM_DAT_I	=> zx2_ram_di,
	RAM_WR_O	=> zx2_ram_wr,
	RAM_RD_O	=> zx2_ram_rd,
	-- Video
	VIDEO_CLK_I	=> clk_vga,
	VIDEO_ADR_I	=> zx2_video_a,
	VIDEO_DAT_O	=> zx2_video_do,
	VIDEO_ATTR_I	=> zx2_video_attr,
	VIDEO_BORDER_I	=> zx2_video_border,
	-- Port
	PORT_XXFE_O	=> zx2_port_xxfe,
	PORT_0001_O	=> zx2_port_0001,
	-- Keyboard
	KEYBOARD_DAT_I	=> kb_do_bus,
	KEYBOARD_FN_I	=> kb_fn_bus,
	KEYBOARD_JOY_I	=> kb_joy_bus,
	KEYBOARD_SOFT_I	=> kb_soft_bus,
	-- SPI Controller
	SPI_DAT_I	=> spi_do_bus,
	SPI_WR_O	=> zx2_spi_wr,
	SPI_BUSY	=> spi_busy,
	-- I2C Controller
	I2C_DAT_I	=> i2c_do_bus,
	I2C_WR_O	=> zx2_i2c_wr,
	-- DivMMC
	DIVMMC_SC_O	=> zx2_divmmc_cs,
	DIVMMC_SCLK_O	=> zx2_divmmc_sclk,
	DIVMMC_MOSI_O	=> zx2_divmmc_mosi,
	DIVMMC_MISO_I	=> SD_SO,
	DIVMMC_SEL_O	=> zx2_divmmc_sel );

-- CPU3
U16: entity work.zx
generic map (
	Loader		=> '0',
	CPU		=> "11" )
port map (
	RST_I		=> reset,
	CLK_I		=> clk_28mhz,
	SEL_I		=> zx3_sel,
	ENA_1_75MHZ_I	=> ena_1_75mhz,
	ENA_0_4375MHZ_I	=> ena_0_4375mhz,
	-- CPU
	CPU_DAT_O	=> zx3_cpu_do,
	CPU_ADR_O	=> zx3_cpu_a,
	CPU_INT_I	=> zx3_cpu_int,
	CPU_CLK_I	=> clk_84mhz,
	CPU_ENA_I	=> cpu_ena,
	CPU_RFSH_O	=> zx3_cpu_rfsh,
	CPU_RDn_O	=> open,
	CPU_WRn_O	=> open,
	CPU_IORQn_O	=> open,
	CPU_INTA_O	=> open,
	-- ROM
	ROM_DAT_I	=> (others => '1'),
	-- RAM
	RAM_ADR_O	=> zx3_ram_a,
	RAM_DAT_I	=> zx3_ram_di,
	RAM_WR_O	=> zx3_ram_wr,
	RAM_RD_O	=> zx3_ram_rd,
	-- Video
	VIDEO_CLK_I	=> clk_vga,
	VIDEO_ADR_I	=> zx3_video_a,
	VIDEO_DAT_O	=> zx3_video_do,
	VIDEO_ATTR_I	=> zx3_video_attr,
	VIDEO_BORDER_I	=> zx3_video_border,
	-- Port
	PORT_XXFE_O	=> zx3_port_xxfe,
	PORT_0001_O	=> zx3_port_0001,
	-- Keyboard
	KEYBOARD_DAT_I	=> kb_do_bus,
	KEYBOARD_FN_I	=> kb_fn_bus,
	KEYBOARD_JOY_I	=> kb_joy_bus,
	KEYBOARD_SOFT_I	=> kb_soft_bus,
	-- SPI Controller
	SPI_DAT_I	=> spi_do_bus,
	SPI_WR_O	=> zx3_spi_wr,
	SPI_BUSY	=> spi_busy,
	-- I2C Controller
	I2C_DAT_I	=> i2c_do_bus,
	I2C_WR_O	=> zx3_i2c_wr,
	-- DivMMC
	DIVMMC_SC_O	=> zx3_divmmc_cs,
	DIVMMC_SCLK_O	=> zx3_divmmc_sclk,
	DIVMMC_MOSI_O	=> zx3_divmmc_mosi,
	DIVMMC_MISO_I	=> SD_SO,
	DIVMMC_SEL_O	=> zx3_divmmc_sel );
 
-------------------------------------------------------------------------------
-- Формирование глобальных сигналов
process (clk_28mhz)
begin
	if clk_28mhz'event and clk_28mhz = '0' then
		ena_cnt <= ena_cnt + 1;
	end if;
end process;

ena_3_5mhz <= ena_cnt(2) and ena_cnt(1) and ena_cnt(0);
ena_1_75mhz <= ena_cnt(3) and ena_cnt(2) and ena_cnt(1) and ena_cnt(0);
ena_0_4375mhz <= ena_cnt(5) and ena_cnt(4) and ena_cnt(3) and ena_cnt(2) and ena_cnt(1) and ena_cnt(0);

-------------------------------------------------------------------------------
-- ENC424J600 <> SPI FLASH
process (port_0001, spi_si, spi_so, spi_clk, spi_cs_n, ETH_SO, DATA0)
begin
	if (port_0001(0) = '1') then
		NCSO <= '1';
		spi_so <= ETH_SO;
		ETH_NCS <= spi_cs_n;
	else
		NCSO <= spi_cs_n;
		spi_so <= DATA0;
		ETH_NCS <= '1';
	end if;
end process;

ASDO <= spi_si;
DCLK <= spi_clk;

-------------------------------------------------------------------------------
-- Stereo Adder (parallel)
fx_sum <= ("00" & zx0_port_xxfe(4)) + ("00" & zx1_port_xxfe(4)) + ("00" & zx2_port_xxfe(4)) + ("00" & zx3_port_xxfe(4));

audio_l <= ("000" & fx_sum & "0000000000000");
audio_r <= ("000" & fx_sum & "0000000000000");

------------------------------------------------------------------------------
areset <= not RST_n;
reset <= areset or kb_soft_bus(0) or not locked0 or not locked1;	-- ZX_RESET
-- SD Card					
SD_CS_n	<= divmmc_cs_n when divmmc_sel = '1' else '1';
SD_CLK 	<= divmmc_sclk when divmmc_sel = '1' else '0';
SD_SI 	<= divmmc_mosi when divmmc_sel = '1' else '0';

-------------------------------------------------------------------------------
-- Функциональные клавиши Fx

-- F1 = CPU0, F2 = CPU1, F3 = CPU2, F4 = CPU4, F5 = NMI, F6 = Z-Controller/DivMMC, F7 = SounDrive, F12 = CPU_RESET, Scroll = HARD_RESET, Pause = ZX_RESET, WinMenu = Win
process (clk_28mhz, key_temp, kb_soft_bus, kb_soft)
begin
	if (clk_28mhz'event and clk_28mhz = '1') then
		key_temp <= kb_soft_bus;
		if (kb_soft_bus /= key_temp) then
			kb_soft <= kb_soft xor key_temp;
		end if;
	end if;
end process;

-------------------------------------------------------------------------------
-- ZX CPU Selector
process (reset, clk_28mhz, kb_fn_bus)
begin
	if (reset = '1') then
		zx_sel <= "00";
	elsif (clk_28mhz'event and clk_28mhz = '1') then
		if (kb_fn_bus(1) = '1') then
			zx_sel <= "00";
		elsif (kb_fn_bus(2) = '1') then
			zx_sel <= "01";
		elsif (kb_fn_bus(3) = '1') then
			zx_sel <= "10";
		elsif (kb_fn_bus(4) = '1') then
			zx_sel <= "11";
		end if;
	end if;
end process;

process (zx0_cpu_a, zx0_cpu_do, zx0_i2c_wr, zx0_divmmc_cs, zx0_divmmc_sclk, zx0_divmmc_mosi, zx0_spi_wr, zx0_port_0001, zx0_divmmc_sel,
	 zx1_cpu_a, zx1_cpu_do, zx1_i2c_wr, zx1_divmmc_cs, zx1_divmmc_sclk, zx1_divmmc_mosi, zx1_spi_wr, zx1_port_0001, zx1_divmmc_sel,
	 zx2_cpu_a, zx2_cpu_do, zx2_i2c_wr, zx2_divmmc_cs, zx2_divmmc_sclk, zx2_divmmc_mosi, zx2_spi_wr, zx2_port_0001, zx2_divmmc_sel,
	 zx3_cpu_a, zx3_cpu_do, zx3_i2c_wr, zx3_divmmc_cs, zx3_divmmc_sclk, zx3_divmmc_mosi, zx3_spi_wr, zx3_port_0001, zx3_divmmc_sel,
	 zx_sel, port_0001, kb_a_bus, spi_a, spi_di_bus, spi_wr, divmmc_cs_n, divmmc_sclk, divmmc_mosi)
begin
	zx0_sel <= '0';
	zx1_sel <= '0';
	zx2_sel <= '0';
	zx3_sel <= '0';
	
	case zx_sel is
		when "00" =>
			zx0_sel     <= '1';		-- CPU0 Select
			port_0001   <= zx0_port_0001;
			-- Keyboard Controller
			kb_a_bus    <= zx0_cpu_a(15 downto 8);
			-- SPI Controller
			spi_a       <= zx0_cpu_a(0);
			spi_di_bus  <= zx0_cpu_do;
			spi_wr      <= zx0_spi_wr;
			-- I2C Controller
			i2c_a       <= zx0_cpu_a(4);
			i2c_di_bus  <= zx0_cpu_do;
			i2c_wr      <= zx0_i2c_wr;
			-- DivMMC
			divmmc_cs_n <= zx0_divmmc_cs;
			divmmc_sclk <= zx0_divmmc_sclk;
			divmmc_mosi <= zx0_divmmc_mosi;
			divmmc_sel  <= zx0_divmmc_sel;
		when "01" =>
			zx1_sel     <= '1';		-- CPU1 Select
			port_0001   <= zx1_port_0001;
			-- Keyboard Controller
			kb_a_bus    <= zx1_cpu_a(15 downto 8);
			-- SPI Controller
			spi_a       <= zx1_cpu_a(0);
			spi_di_bus  <= zx1_cpu_do;
			spi_wr      <= zx1_spi_wr;
			-- I2C Controller
			i2c_a       <= zx1_cpu_a(4);
			i2c_di_bus  <= zx1_cpu_do;
			i2c_wr      <= zx1_i2c_wr;
			-- DivMMC
			divmmc_cs_n <= zx1_divmmc_cs;
			divmmc_sclk <= zx1_divmmc_sclk;
			divmmc_mosi <= zx1_divmmc_mosi;
			divmmc_sel  <= zx1_divmmc_sel;
		when "10" =>
			zx2_sel     <= '1';		-- CPU2 Select
			port_0001   <= zx2_port_0001;
			-- Keyboard Controller
			kb_a_bus    <= zx2_cpu_a(15 downto 8);
			-- SPI Controller
			spi_a       <= zx2_cpu_a(0);
			spi_di_bus  <= zx2_cpu_do;
			spi_wr      <= zx2_spi_wr;
			-- I2C Controller
			i2c_a       <= zx2_cpu_a(4);
			i2c_di_bus  <= zx2_cpu_do;
			i2c_wr      <= zx2_i2c_wr;
			-- DivMMC
			divmmc_cs_n <= zx2_divmmc_cs;
			divmmc_sclk <= zx2_divmmc_sclk;
			divmmc_mosi <= zx2_divmmc_mosi;
			divmmc_sel  <= zx2_divmmc_sel;
		when "11" =>
			zx3_sel     <= '1';		-- CPU3 Select
			port_0001   <= zx3_port_0001;
			-- Keyboard Controller
			kb_a_bus    <= zx3_cpu_a(15 downto 8);
			-- SPI Controller
			spi_a       <= zx3_cpu_a(0);
			spi_di_bus  <= zx3_cpu_do;
			spi_wr      <= zx3_spi_wr;
			-- I2C Controller
			i2c_a       <= zx3_cpu_a(4);
			i2c_di_bus  <= zx3_cpu_do;
			i2c_wr      <= zx3_i2c_wr;
			-- DivMMC
			divmmc_cs_n <= zx3_divmmc_cs;
			divmmc_sclk <= zx3_divmmc_sclk;
			divmmc_mosi <= zx3_divmmc_mosi;
			divmmc_sel  <= zx3_divmmc_sel;
		when others => null;
	end case;
end process;
	
HDMI_D1_n <= '0';
	
end rtl;