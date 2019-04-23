-------------------------------------------------------------------[24.06.2018]
-- QuadSpeccy (build 20180624)
-- FPGA SoftCore for ReVerSE-U16 Rev.C
-------------------------------------------------------------------------------
-- Engineer: MVV <mvvproject@gmail.com>
-- https://github.com/mvvproject/ReVerSE-U16/tree/master/u16_quadspeccy
--
-- Copyright (c) 2015-2018 Vladislav Matlash
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
-- 68000-6BFFF		GLUK 		16K
-- 6C000-6FFFF		TR-DOS 		16K
-- 70000-73FFF		OS'86 		16K
-- 74000-77FFF		OS'82 		16K
-- 78000-7AFFF		DivMMC		 8K
-- 7B000-7BFFF		свободно	 8К
-- 7C000-7FFFF		свободно	16К

entity quadspeccy is
port (
	-- Clock (50MHz)
	CLK_50MHZ	: in std_logic;
	-- SDRAM (32MB 16x16bit)
	DRAM_DQ		: inout std_logic_vector(15 downto 0);
	DRAM_A		: out std_logic_vector(12 downto 0);
	DRAM_BA		: out std_logic_vector(1 downto 0);
	DRAM_CLK	: out std_logic;
	DRAM_DQML	: out std_logic;
	DRAM_DQMH	: out std_logic;
	DRAM_NWE	: out std_logic;
	DRAM_NCAS	: out std_logic;
	DRAM_NRAS	: out std_logic;
	-- I2C
	I2C_SCL		: inout std_logic;
	I2C_SDA		: inout std_logic;
	-- RTC (DS1338Z-33+)
--	RTC_SQW		: in std_logic;
	-- SPI FLASH (W25Q64)
	DATA0		: in std_logic;
	NCSO		: out std_logic;
	DCLK		: out std_logic;
	ASDO		: out std_logic;
	-- HDMI
--	HDMI_CEC	: inout std_logic;
--	HDMI_NDET	: in std_logic;
	TMDS		: out std_logic_vector(7 downto 0);
	-- SD/MMC Card
	SD_NDET		: in std_logic;	
	SD_SO		: in std_logic;
	SD_SI		: out std_logic;
	SD_CLK		: out std_logic;
	SD_NCS		: out std_logic;
	-- Ethernet (ENC424J600)
	ETH_SO		: in std_logic;
	ETH_NINT	: in std_logic;
	ETH_NCS		: out std_logic;
	-- USB HOST (VNC2-32)
	USB_NRESET	: in std_logic;
	USB_TX		: in std_logic;
--	USB_RX		: out std_logic;
	USB_IO1		: in std_logic;
--	USB_IO3		: in std_logic;
--	USB_CLK		: out std_logic;
--	USB_NCS		: inout std_logic;
--	USB_SI		: inout std_logic;
--	USB_SO		: in std_logic;
	-- uBUS+
--	AP		: out std_logic;
--	AN		: out std_logic;
--	BP		: in std_logic;
--	BN		: in std_logic;
--	CP		: in std_logic;
--	CN		: in std_logic;
	DP		: out std_logic;
	DN		: out std_logic);
end quadspeccy;

architecture rtl of quadspeccy is

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
signal zx0_fx		: std_logic;
signal zx0_ssg0_a	: std_logic_vector(7 downto 0);
signal zx0_ssg0_b	: std_logic_vector(7 downto 0);
signal zx0_ssg0_c	: std_logic_vector(7 downto 0);
signal zx0_ssg1_a	: std_logic_vector(7 downto 0);
signal zx0_ssg1_b	: std_logic_vector(7 downto 0);
signal zx0_ssg1_c	: std_logic_vector(7 downto 0);
signal zx0_covox_a	: std_logic_vector(7 downto 0);
signal zx0_covox_b	: std_logic_vector(7 downto 0);
signal zx0_covox_c	: std_logic_vector(7 downto 0);
signal zx0_covox_d	: std_logic_vector(7 downto 0);
signal zx0_ssg_left	: std_logic_vector(9 downto 0);
signal zx0_ssg_right	: std_logic_vector(9 downto 0);
signal zx0_covox_left	: std_logic_vector(8 downto 0);
signal zx0_covox_right	: std_logic_vector(8 downto 0);
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
signal zx1_fx		: std_logic;
signal zx1_ssg0_a	: std_logic_vector(7 downto 0);
signal zx1_ssg0_b	: std_logic_vector(7 downto 0);
signal zx1_ssg0_c	: std_logic_vector(7 downto 0);
signal zx1_ssg1_a	: std_logic_vector(7 downto 0);
signal zx1_ssg1_b	: std_logic_vector(7 downto 0);
signal zx1_ssg1_c	: std_logic_vector(7 downto 0);
signal zx1_covox_a	: std_logic_vector(7 downto 0);
signal zx1_covox_b	: std_logic_vector(7 downto 0);
signal zx1_covox_c	: std_logic_vector(7 downto 0);
signal zx1_covox_d	: std_logic_vector(7 downto 0);
signal zx1_ssg_left	: std_logic_vector(9 downto 0);
signal zx1_ssg_right	: std_logic_vector(9 downto 0);
signal zx1_covox_left	: std_logic_vector(8 downto 0);
signal zx1_covox_right	: std_logic_vector(8 downto 0);
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
signal zx2_zc_rd	: std_logic;
signal zx2_zc_wr	: std_logic;
signal zx2_spi_wr	: std_logic;
signal zx2_i2c_wr	: std_logic;
signal zx2_divmmc_cs	: std_logic;
signal zx2_divmmc_sclk	: std_logic;
signal zx2_divmmc_mosi	: std_logic;
signal zx2_divmmc_sel	: std_logic;
signal zx2_fx		: std_logic;
signal zx2_ssg0_a	: std_logic_vector(7 downto 0);
signal zx2_ssg0_b	: std_logic_vector(7 downto 0);
signal zx2_ssg0_c	: std_logic_vector(7 downto 0);
signal zx2_ssg1_a	: std_logic_vector(7 downto 0);
signal zx2_ssg1_b	: std_logic_vector(7 downto 0);
signal zx2_ssg1_c	: std_logic_vector(7 downto 0);
signal zx2_covox_a	: std_logic_vector(7 downto 0);
signal zx2_covox_b	: std_logic_vector(7 downto 0);
signal zx2_covox_c	: std_logic_vector(7 downto 0);
signal zx2_covox_d	: std_logic_vector(7 downto 0);
signal zx2_ssg_left	: std_logic_vector(9 downto 0);
signal zx2_ssg_right	: std_logic_vector(9 downto 0);
signal zx2_covox_left	: std_logic_vector(8 downto 0);
signal zx2_covox_right	: std_logic_vector(8 downto 0);
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
signal zx3_zc_rd	: std_logic;
signal zx3_zc_wr	: std_logic;
signal zx3_spi_wr	: std_logic;
signal zx3_i2c_wr	: std_logic;
signal zx3_divmmc_cs	: std_logic;
signal zx3_divmmc_sclk	: std_logic;
signal zx3_divmmc_mosi	: std_logic;
signal zx3_divmmc_sel	: std_logic;
signal zx3_fx		: std_logic;
signal zx3_ssg0_a	: std_logic_vector(7 downto 0);
signal zx3_ssg0_b	: std_logic_vector(7 downto 0);
signal zx3_ssg0_c	: std_logic_vector(7 downto 0);
signal zx3_ssg1_a	: std_logic_vector(7 downto 0);
signal zx3_ssg1_b	: std_logic_vector(7 downto 0);
signal zx3_ssg1_c	: std_logic_vector(7 downto 0);
signal zx3_covox_a	: std_logic_vector(7 downto 0);
signal zx3_covox_b	: std_logic_vector(7 downto 0);
signal zx3_covox_c	: std_logic_vector(7 downto 0);
signal zx3_covox_d	: std_logic_vector(7 downto 0);
signal zx3_ssg_left	: std_logic_vector(9 downto 0);
signal zx3_ssg_right	: std_logic_vector(9 downto 0);
signal zx3_covox_left	: std_logic_vector(8 downto 0);
signal zx3_covox_right	: std_logic_vector(8 downto 0);
-- Selector
signal zx_sel		: std_logic_vector(1 downto 0) := "00";
-- Keyboard
signal kb_soft_bus	: std_logic_vector(3 downto 0);
signal kb_a_bus		: std_logic_vector(7 downto 0);
signal kb_do_bus	: std_logic_vector(4 downto 0);
signal kb_fn_bus	: std_logic_vector(12 downto 1);
signal kb_joy_bus	: std_logic_vector(4 downto 0);
signal key_temp		: std_logic_vector(3 downto 0);
signal kb_soft		: std_logic_vector(3 downto 0);
signal key_scancode	: std_logic_vector(7 downto 0);
signal kb_key0		: std_logic_vector(7 downto 0);
signal kb_key1		: std_logic_vector(7 downto 0);
signal kb_key2		: std_logic_vector(7 downto 0);
signal kb_key3		: std_logic_vector(7 downto 0);
signal kb_key4		: std_logic_vector(7 downto 0);
signal kb_key5		: std_logic_vector(7 downto 0);
signal kb_key6		: std_logic_vector(7 downto 0);
-- Mouse
signal ms_x		: std_logic_vector(7 downto 0);
signal ms_y		: std_logic_vector(7 downto 0);
signal ms_z		: std_logic_vector(7 downto 0);
signal ms_b		: std_logic_vector(7 downto 0);
-- Video
signal video_hcnt	: std_logic_vector(9 downto 0);
signal video_vcnt	: std_logic_vector(9 downto 0);
signal video_hsync	: std_logic;
signal video_vsync	: std_logic;
signal video_blank	: std_logic;
signal video_rgb	: std_logic_vector(5 downto 0);
signal tmds_d		: std_logic_vector(2 downto 0);
-- Z-Controller
signal zc_a		: std_logic;
signal zc_do_bus	: std_logic_vector(7 downto 0);
signal zc_di_bus	: std_logic_vector(7 downto 0);
signal zc_rd		: std_logic;
signal zc_wr		: std_logic;
signal zc_cs_n		: std_logic;
signal zc_sclk		: std_logic;
signal zc_mosi		: std_logic;
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
-- RTC
signal zx0_rtc_wr	: std_logic;
signal zx1_rtc_wr	: std_logic;
signal zx2_rtc_wr	: std_logic;
signal zx3_rtc_wr	: std_logic;
signal zx0_rtc_addr	: std_logic_vector(5 downto 0);
signal zx1_rtc_addr	: std_logic_vector(5 downto 0);
signal zx2_rtc_addr	: std_logic_vector(5 downto 0);
signal zx3_rtc_addr	: std_logic_vector(5 downto 0);
signal rtc_wr		: std_logic;
signal rtc_addr		: std_logic_vector(5 downto 0);
signal rtc_1addr	: std_logic_vector(5 downto 0);
signal rtc_2addr	: std_logic_vector(5 downto 0);
signal rtc_3addr	: std_logic_vector(5 downto 0);
signal rtc_data		: std_logic_vector(7 downto 0);
signal rtc_do_bus	: std_logic_vector(7 downto 0);
signal rtc_1do_bus	: std_logic_vector(7 downto 0);
signal rtc_2do_bus	: std_logic_vector(7 downto 0);
signal rtc_3do_bus	: std_logic_vector(7 downto 0);
-- Sound
signal zx0_sum_left	: std_logic_vector(16 downto 0);
signal zx1_sum_left	: std_logic_vector(16 downto 0);
signal zx2_sum_left	: std_logic_vector(16 downto 0);
signal zx3_sum_left	: std_logic_vector(16 downto 0);
signal zx0_sum_right	: std_logic_vector(16 downto 0);
signal zx1_sum_right	: std_logic_vector(16 downto 0);
signal zx2_sum_right	: std_logic_vector(16 downto 0);
signal zx3_sum_right	: std_logic_vector(16 downto 0);
signal ssg_sum_left	: std_logic_vector(10 downto 0);
signal ssg_sum_right	: std_logic_vector(10 downto 0);
signal covox_sum_left	: std_logic_vector(9 downto 0);
signal covox_sum_right	: std_logic_vector(9 downto 0);
signal sum_left		: std_logic_vector(11 downto 0);
signal sum_right	: std_logic_vector(11 downto 0);
signal fx_sum		: std_logic_vector(2 downto 0);
signal audio_l		: std_logic_vector(15 downto 0);
signal audio_r		: std_logic_vector(15 downto 0);
-- DMA Sound
signal dmasound_left_out	: std_logic_vector(16 downto 0);
signal dmasound_right_out	: std_logic_vector(16 downto 0);
signal dmasound_mem_adr		: std_logic_vector(23 downto 0);
signal dmasound_mem_rd		: std_logic;
signal dmasound_mem_ack		: std_logic;
signal dmasound_do		: std_logic_vector( 7 downto 0);
signal dmasound_int		: std_logic;
-- CLOCK
signal clk_28mhz	: std_logic;
signal clk_84mhz	: std_logic;
signal clk_168mhz	: std_logic;
signal clk_tmds		: std_logic;
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
	c3		=> DRAM_CLK);	-- 84.0 MHz
	
-- PLL 1
U1: entity work.altpll1
port map (
	areset		=> areset,
	inclk0		=> CLK_50MHZ,
	locked		=> locked1,
	c0		=> clk_tmds,	-- 126.0 MHz
	c1		=> clk_vga );	--  25.2 MHz

-- ROM 1K
U2: entity work.altram0
port map (
	clock_a		=> clk_84mhz,
	clock_b		=> clk_84mhz,
	address_a	=> zx0_cpu_a(6 downto 0),
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
	I_CLK		=> clk_28mhz,
	I_ENA		=> ena_3_5mhz,
	I_CLK_VGA	=> clk_vga,
	-- Channal 0
	O_CH0_INT	=> zx0_cpu_int,
	O_CH0_ADR	=> zx0_video_a,
	I_CH0_DAT	=> zx0_video_do,
	I_CH0_BORDER	=> zx0_port_xxfe(2 downto 0),	-- Биты D0..D2 порта xxFE определяют цвет бордюра
	O_CH0_ATTR	=> zx0_video_attr,
	O_CH0_BORDER	=> zx0_video_border,
	-- Channal 1
	O_CH1_INT	=> zx1_cpu_int,
	O_CH1_ADR	=> zx1_video_a,
	I_CH1_DAT	=> zx1_video_do,
	I_CH1_BORDER	=> zx1_port_xxfe(2 downto 0),	-- Биты D0..D2 порта xxFE определяют цвет бордюра
	O_CH1_ATTR	=> zx1_video_attr,
	O_CH1_BORDER	=> zx1_video_border,
	-- Channal 2
	O_CH2_INT	=> zx2_cpu_int,
	O_CH2_ADR	=> zx2_video_a,
	I_CH2_DAT	=> zx2_video_do,
	I_CH2_BORDER	=> zx2_port_xxfe(2 downto 0),	-- Биты D0..D2 порта xxFE определяют цвет бордюра
	O_CH2_ATTR	=> zx2_video_attr,
	O_CH2_BORDER	=> zx2_video_border,
	-- Channal 3
	O_CH3_INT	=> zx3_cpu_int,
	O_CH3_ADR	=> zx3_video_a,
	I_CH3_DAT	=> zx3_video_do,
	I_CH3_BORDER	=> zx3_port_xxfe(2 downto 0),	-- Биты D0..D2 порта xxFE определяют цвет бордюра
	O_CH3_ATTR	=> zx3_video_attr,
	O_CH3_BORDER	=> zx3_video_border,
	--
	I_SEL		=> zx_sel,
	I_MODE		=> kb_soft(1),
	O_HCNT		=> video_hcnt,
	O_VCNT		=> video_vcnt,
	O_BLANK		=> video_blank,
	O_RGB		=> video_rgb,
	O_HSYNC		=> video_hsync,
	O_VSYNC		=> video_vsync);

-- HDMI
U4: entity work.hdmi
generic map (
	FREQ		=> 25200000,		-- pixel clock frequency = 25.2MHz
	FS		=> 48000,		-- audio sample rate - should be 32000, 41000 or 48000 = 48KHz
	CTS		=> 25200,		-- CTS = Freq(pixclk) * N / (128 * Fs)
	N		=> 6144)		-- N = 128 * Fs /1000,  128 * Fs /1500 <= N <= 128 * Fs /300 (Check HDMI spec 7.2 for details)
port map (
	I_CLK_VGA	=> clk_vga,
	I_CLK_TMDS	=> clk_tmds,
	I_HSYNC		=> video_hsync,
	I_VSYNC		=> video_vsync,
	I_BLANK		=> video_blank,
	I_RED		=> video_rgb(5 downto 4) & video_rgb(5 downto 4) & video_rgb(5 downto 4) & video_rgb(5 downto 4),
	I_GREEN		=> video_rgb(3 downto 2) & video_rgb(3 downto 2) & video_rgb(3 downto 2) & video_rgb(3 downto 2),
	I_BLUE		=> video_rgb(1 downto 0) & video_rgb(1 downto 0) & video_rgb(1 downto 0) & video_rgb(1 downto 0),
	I_AUDIO_PCM_L 	=> audio_l,
	I_AUDIO_PCM_R	=> audio_r,
	O_TMDS		=> TMDS);
	
-- USB HID
U5: entity work.deserializer
generic map (
	divisor			=> 434)		-- divisor = 50MHz / 115200 Baud = 434
port map(
	I_CLK			=> CLK_50MHZ,
	I_RESET			=> areset,
	I_RX			=> USB_TX,
	I_NEWFRAME		=> USB_IO1,
	I_ADDR			=> kb_a_bus,
	O_MOUSE_X		=> ms_x,
	O_MOUSE_Y		=> ms_y,
	O_MOUSE_Z		=> ms_z,
	O_MOUSE_BUTTONS		=> ms_b,
	O_KEY0			=> kb_key0,
	O_KEY1			=> kb_key1,
	O_KEY2			=> kb_key2,
	O_KEY3			=> kb_key3,
	O_KEY4			=> kb_key4,
	O_KEY5			=> kb_key5,
	O_KEY6			=> kb_key6,
	O_KEYBOARD_SCAN		=> kb_do_bus,
	O_KEYBOARD_FKEYS	=> kb_fn_bus,
	O_KEYBOARD_JOYKEYS	=> kb_joy_bus,
	O_KEYBOARD_CTLKEYS	=> kb_soft_bus);

-- DMA Sound
U6: entity work.dmasound
port map(
	I_RST		=> reset,
	I_CLK		=> clk_84mhz,
	I_ENA		=> cpu_ena,
	I_ADR		=> zx0_cpu_a,
	I_DAT		=> zx0_cpu_do,
	O_DAT		=> dmasound_do,
	I_WR_N		=> zx0_cpu_wr_n,
	I_RD_N		=> zx0_cpu_rd_n,
	I_IORQ_N	=> zx0_cpu_iorq_n,
	I_INTA		=> zx0_cpu_inta,
	O_INT		=> dmasound_int,
	-- Sound
	O_LEFT		=> dmasound_left_out,
	O_RIGHT		=> dmasound_right_out, 
	-- Memory
	O_MEM_ADR	=> dmasound_mem_adr,
	I_MEM_DAT	=> zx0_ram_di,
	O_MEM_RD	=> dmasound_mem_rd,
	I_MEM_ACK	=> dmasound_mem_ack);

-- Z-Controller
U7: entity work.zcontroller
port map (
	I_RESET		=> reset,
	I_CLK		=> clk_28mhz,
	I_ADDR		=> zc_a,
	I_DATA		=> zc_di_bus,
	O_DATA		=> zc_do_bus,
	I_RD		=> zc_rd,
	I_WR		=> zc_wr,
	I_SDDET		=> SD_NDET,
	I_SDPROT	=> '0',
	O_CS_N		=> zc_cs_n,
	O_SCLK		=> zc_sclk,
	O_MOSI		=> zc_mosi,
	I_MISO		=> SD_SO);

-- SPI FLASH 25MHz Max SCK -- Ethernet ENC424J600
U8: entity work.spi
port map (
	I_RESET		=> reset,
	I_CLK		=> clk_28mhz,
	I_SCK		=> clk_14mhz,
	I_ADDR		=> spi_a,
	I_DATA		=> spi_di_bus,
	O_DATA		=> spi_do_bus,
	I_WR		=> spi_wr,
	O_BUSY		=> spi_busy,
	O_CS_n		=> spi_cs_n,
	O_SCLK		=> spi_clk,
	O_MOSI		=> spi_si,
	I_MISO		=> spi_so);
	
-- SDRAM Controller
U9: entity work.sdram
port map (
	I_RESET		=> areset,
	I_CLK		=> clk_84mhz,
	O_ENA		=> cpu_ena,
	-- Channal 0
	I_CH0_ADDR	=> zx0_ram_a & zx0_cpu_a(12 downto 0),
	I_CH0_DATA	=> zx0_cpu_do,
	O_CH0_DATA	=> zx0_ram_di,
	I_CH0_WR	=> zx0_ram_wr,
	I_CH0_RD	=> zx0_ram_rd,
	I_CH0_RFSH	=> zx0_cpu_rfsh,
	I_CH0_DMA_ADDR	=> '0' & dmasound_mem_adr,
	I_CH0_DMA_RD	=> dmasound_mem_rd,
	O_CH0_DMA_ACK	=> dmasound_mem_ack,
	-- Channal 1
	I_CH1_ADDR	=> zx1_ram_a & zx1_cpu_a(12 downto 0),
	I_CH1_DATA	=> zx1_cpu_do,
	O_CH1_DATA	=> zx1_ram_di,
	I_CH1_WR	=> zx1_ram_wr,
	I_CH1_RD	=> zx1_ram_rd,
	I_CH1_RFSH	=> zx1_cpu_rfsh,
	-- Channal 2
	I_CH2_ADDR	=> zx2_ram_a & zx2_cpu_a(12 downto 0),
	I_CH2_DATA	=> zx2_cpu_do,
	O_CH2_DATA	=> zx2_ram_di,
	I_CH2_WR	=> zx2_ram_wr,
	I_CH2_RD	=> zx2_ram_rd,
	I_CH2_RFSH	=> zx2_cpu_rfsh,
	-- Channal 3
	I_CH3_ADDR	=> zx3_ram_a & zx3_cpu_a(12 downto 0),
	I_CH3_DATA	=> zx3_cpu_do,
	O_CH3_DATA	=> zx3_ram_di,
	I_CH3_WR	=> zx3_ram_wr,
	I_CH3_RD	=> zx3_ram_rd,
	I_CH3_RFSH	=> zx3_cpu_rfsh,
	-- SDRAM Pin
	O_CLK		=> open,
	O_RAS_N		=> DRAM_NRAS,
	O_CAS_N		=> DRAM_NCAS,
	O_WE_N		=> DRAM_NWE,
	O_DQML		=> DRAM_DQML,
	O_DQMH		=> DRAM_DQMH,
	O_BA		=> DRAM_BA,
	O_MA		=> DRAM_A,
	IO_DQ		=> DRAM_DQ);

-- I2C Controller
U10: entity work.i2c
port map (
	I_RESET		=> reset,
	I_CLK		=> clk_28mhz,
	I_ENA		=> ena_0_4375mhz,
	I_ADDR		=> i2c_a,
	I_DATA		=> i2c_di_bus,
	O_DATA		=> i2c_do_bus,
	I_WR		=> i2c_wr,
	IO_I2C_SCL	=> I2C_SCL,
	IO_I2C_SDA	=> I2C_SDA);

-- Delta-Sigma
U11: entity work.dac
generic map (
	msbi_g		=> 15)
port map (
	I_CLK  		=> clk_84mhz,
	I_RESET		=> areset,
	I_DATA		=> audio_l,
	O_DAC		=> DP);

-- Delta-Sigma
U12: entity work.dac
generic map (
	msbi_g		=> 15)
port map (
	I_CLK  		=> clk_84mhz,
	I_RESET 	=> areset,
	I_DATA		=> audio_r,
	O_DAC   	=> DN);

-- CPU0
U13: entity work.zx
generic map (
	Loader		=> '1',
	CPU		=> "00" )
port map (
	I_RESET		=> reset,
	I_CLK		=> clk_28mhz,
	I_SEL		=> zx0_sel,
	I_ENA_1_75MHZ	=> ena_1_75mhz,
	-- CPU
	O_CPU_DATA	=> zx0_cpu_do,
	O_CPU_ADDR	=> zx0_cpu_a,
	I_CPU_INT	=> zx0_cpu_int,
	I_CPU_CLK	=> clk_84mhz,
	I_CPU_ENA	=> cpu_ena,
	O_CPU_RFSH	=> zx0_cpu_rfsh,
	O_CPU_RD_N	=> zx0_cpu_rd_n,
	O_CPU_WR_N	=> zx0_cpu_wr_n,
	O_CPU_IORQ_N	=> zx0_cpu_iorq_n,
	O_CPU_INTA	=> zx0_cpu_inta,
	-- ROM
	I_ROM_DATA	=> rom_do,
	-- RAM
	O_RAM_ADDR	=> zx0_ram_a,
	I_RAM_DATA	=> zx0_ram_di,
	O_RAM_WR	=> zx0_ram_wr,
	O_RAM_RD	=> zx0_ram_rd,
	-- Video
	I_VIDEO_CLK	=> clk_vga,
	I_VIDEO_ADDR	=> zx0_video_a,
	O_VIDEO_DATA	=> zx0_video_do,
	I_VIDEO_ATTR	=> zx0_video_attr,
	I_VIDEO_BORDER	=> zx0_video_border,
	-- Port
	O_PORT_XXFE	=> zx0_port_xxfe,
	O_PORT_0001	=> zx0_port_0001,
	-- Keyboard
	I_KEYBOARD_DATA	=> kb_do_bus,
	I_KEYBOARD_FN	=> kb_fn_bus,
	I_KEYBOARD_JOY	=> kb_joy_bus,
	I_KEYBOARD_SOFT	=> kb_soft_bus(2 downto 0),
	I_KEY0		=> kb_key0,
	I_KEY1		=> kb_key1,
	I_KEY2		=> kb_key2,
	I_KEY3		=> kb_key3,
	I_KEY4		=> kb_key4,
	I_KEY5		=> kb_key5,
	I_KEY6		=> kb_key6,
	-- Mouse
	I_MOUSE_X	=> ms_x,
	I_MOUSE_Y	=> ms_y,
	I_MOUSE_Z	=> ms_z(3 downto 0),
	I_MOUSE_BUTTONS	=> ms_b(2 downto 0),
	-- Z Controller
	I_ZC_DATA	=> zc_do_bus,
	O_ZC_RD		=> zx0_zc_rd,
	O_ZC_WR		=> zx0_zc_wr,
	-- SPI Controller
	I_SPI_DATA	=> spi_do_bus,
	O_SPI_WR	=> zx0_spi_wr,
	I_SPI_BUSY	=> spi_busy,
	-- I2C Controller
	I_I2C_DATA	=> i2c_do_bus,
	O_I2C_WR	=> zx0_i2c_wr,
	-- DivMMC
	O_DIVMMC_SC	=> zx0_divmmc_cs,
	O_DIVMMC_SCLK	=> zx0_divmmc_sclk,
	O_DIVMMC_MOSI	=> zx0_divmmc_mosi,
	I_DIVMMC_MISO	=> SD_SO,
	O_DIVMMC_SEL	=> zx0_divmmc_sel,
	-- RTC
	O_RTC_WR	=> zx0_rtc_wr,
	O_RTC_ADDR	=> zx0_rtc_addr,
	I_RTC_DATA	=> rtc_do_bus,
	-- TurboSound
	O_SSG0_A	=> zx0_ssg0_a,
	O_SSG0_B	=> zx0_ssg0_b,
	O_SSG0_C	=> zx0_ssg0_c,
	O_SSG1_A	=> zx0_ssg1_a,
	O_SSG1_B	=> zx0_ssg1_b,
	O_SSG1_C	=> zx0_ssg1_c,
	-- SounDrive
	O_COVOX_A	=> zx0_covox_a,
	O_COVOX_B	=> zx0_covox_b,
	O_COVOX_C	=> zx0_covox_c,
	O_COVOX_D	=> zx0_covox_d,    
	-- DMA Sound
	I_DMASOUND_DATA	=> dmasound_do,
	I_DMASOUND_INT	=> dmasound_int);

-- CPU1
U14: entity work.zx
generic map (
	Loader		=> '0',
	CPU		=> "01" )
port map (
	I_RESET		=> reset,
	I_CLK		=> clk_28mhz,
	I_SEL		=> zx1_sel,
	I_ENA_1_75MHZ	=> ena_1_75mhz,
	-- CPU
	O_CPU_DATA	=> zx1_cpu_do,
	O_CPU_ADDR	=> zx1_cpu_a,
	I_CPU_INT	=> zx1_cpu_int,
	I_CPU_CLK	=> clk_84mhz,
	I_CPU_ENA	=> cpu_ena,
	O_CPU_RFSH	=> zx1_cpu_rfsh,
	O_CPU_RD_N	=> open,
	O_CPU_WR_N	=> open,
	O_CPU_IORQ_N	=> open,
	O_CPU_INTA	=> open,
	-- ROM
	I_ROM_DATA	=> (others => '1'),
	-- RAM
	O_RAM_ADDR	=> zx1_ram_a,
	I_RAM_DATA	=> zx1_ram_di,
	O_RAM_WR	=> zx1_ram_wr,
	O_RAM_RD	=> zx1_ram_rd,
	-- Video
	I_VIDEO_CLK	=> clk_vga,
	I_VIDEO_ADDR	=> zx1_video_a,
	O_VIDEO_DATA	=> zx1_video_do,
	I_VIDEO_ATTR	=> zx1_video_attr,
	I_VIDEO_BORDER	=> zx1_video_border,
	-- Port
	O_PORT_XXFE	=> zx1_port_xxfe,
	O_PORT_0001	=> zx1_port_0001,
	-- Keyboard
	I_KEYBOARD_DATA	=> kb_do_bus,
	I_KEYBOARD_FN	=> kb_fn_bus,
	I_KEYBOARD_JOY	=> kb_joy_bus,
	I_KEYBOARD_SOFT	=> kb_soft_bus(2 downto 0),
	I_KEY0		=> kb_key0,
	I_KEY1		=> kb_key1,
	I_KEY2		=> kb_key2,
	I_KEY3		=> kb_key3,
	I_KEY4		=> kb_key4,
	I_KEY5		=> kb_key5,
	I_KEY6		=> kb_key6,
	-- Mouse
	I_MOUSE_X	=> ms_x,
	I_MOUSE_Y	=> ms_y,
	I_MOUSE_Z	=> ms_z(3 downto 0),
	I_MOUSE_BUTTONS	=> ms_b(2 downto 0),
	-- Z Controller
	I_ZC_DATA	=> zc_do_bus,
	O_ZC_RD		=> zx1_zc_rd,
	O_ZC_WR		=> zx1_zc_wr,
	-- SPI Controller
	I_SPI_DATA	=> spi_do_bus,
	O_SPI_WR	=> zx1_spi_wr,
	I_SPI_BUSY	=> spi_busy,
	-- I2C Controller
	I_I2C_DATA	=> i2c_do_bus,
	O_I2C_WR	=> zx1_i2c_wr,
	-- DivMMC
	O_DIVMMC_SC	=> zx1_divmmc_cs,
	O_DIVMMC_SCLK	=> zx1_divmmc_sclk,
	O_DIVMMC_MOSI	=> zx1_divmmc_mosi,
	I_DIVMMC_MISO	=> SD_SO,
	O_DIVMMC_SEL	=> zx1_divmmc_sel,
	-- RTC
	O_RTC_WR	=> zx1_rtc_wr,
	O_RTC_ADDR	=> zx1_rtc_addr,
	I_RTC_DATA	=> rtc_1do_bus,
	-- TurboSound
	O_SSG0_A	=> zx1_ssg0_a,
	O_SSG0_B	=> zx1_ssg0_b,
	O_SSG0_C	=> zx1_ssg0_c,
	O_SSG1_A	=> zx1_ssg1_a,
	O_SSG1_B	=> zx1_ssg1_b,
	O_SSG1_C	=> zx1_ssg1_c,
	-- SounDrive
	O_COVOX_A	=> zx1_covox_a,
	O_COVOX_B	=> zx1_covox_b,
	O_COVOX_C	=> zx1_covox_c,
	O_COVOX_D	=> zx1_covox_d,
	-- DMA Sound
	I_DMASOUND_DATA	=> (others => '1'),
	I_DMASOUND_INT	=> '0' );

-- CPU2
U15: entity work.zx
generic map (
	Loader		=> '0',
	CPU		=> "10" )
port map (
	I_RESET		=> reset,
	I_CLK		=> clk_28mhz,
	I_SEL		=> zx2_sel,
	I_ENA_1_75MHZ	=> ena_1_75mhz,
	-- CPU
	O_CPU_DATA	=> zx2_cpu_do,
	O_CPU_ADDR	=> zx2_cpu_a,
	I_CPU_INT	=> zx2_cpu_int,
	I_CPU_CLK	=> clk_84mhz,
	I_CPU_ENA	=> cpu_ena,
	O_CPU_RFSH	=> zx2_cpu_rfsh,
	O_CPU_RD_N	=> open,
	O_CPU_WR_N	=> open,
	O_CPU_IORQ_N	=> open,
	O_CPU_INTA	=> open,
	-- ROM
	I_ROM_DATA	=> (others => '1'),
	-- RAM
	O_RAM_ADDR	=> zx2_ram_a,
	I_RAM_DATA	=> zx2_ram_di,
	O_RAM_WR	=> zx2_ram_wr,
	O_RAM_RD	=> zx2_ram_rd,
	-- Video
	I_VIDEO_CLK	=> clk_vga,
	I_VIDEO_ADDR	=> zx2_video_a,
	O_VIDEO_DATA	=> zx2_video_do,
	I_VIDEO_ATTR	=> zx2_video_attr,
	I_VIDEO_BORDER	=> zx2_video_border,
	-- Port
	O_PORT_XXFE	=> zx2_port_xxfe,
	O_PORT_0001	=> zx2_port_0001,
	-- Keyboard
	I_KEYBOARD_DATA	=> kb_do_bus,
	I_KEYBOARD_FN	=> kb_fn_bus,
	I_KEYBOARD_JOY	=> kb_joy_bus,
	I_KEYBOARD_SOFT	=> kb_soft_bus(2 downto 0),
	I_KEY0		=> kb_key0,
	I_KEY1		=> kb_key1,
	I_KEY2		=> kb_key2,
	I_KEY3		=> kb_key3,
	I_KEY4		=> kb_key4,
	I_KEY5		=> kb_key5,
	I_KEY6		=> kb_key6,
	-- Mouse
	I_MOUSE_X	=> ms_x,
	I_MOUSE_Y	=> ms_y,
	I_MOUSE_Z	=> ms_z(3 downto 0),
	I_MOUSE_BUTTONS	=> ms_b(2 downto 0),
	-- Z Controller
	I_ZC_DATA	=> zc_do_bus,
	O_ZC_RD		=> zx2_zc_rd,
	O_ZC_WR		=> zx2_zc_wr,
	-- SPI Controller
	I_SPI_DATA	=> spi_do_bus,
	O_SPI_WR	=> zx2_spi_wr,
	I_SPI_BUSY	=> spi_busy,
	-- I2C Controller
	I_I2C_DATA	=> i2c_do_bus,
	O_I2C_WR	=> zx2_i2c_wr,
	-- DivMMC
	O_DIVMMC_SC	=> zx2_divmmc_cs,
	O_DIVMMC_SCLK	=> zx2_divmmc_sclk,
	O_DIVMMC_MOSI	=> zx2_divmmc_mosi,
	I_DIVMMC_MISO	=> SD_SO,
	O_DIVMMC_SEL	=> zx2_divmmc_sel,
	-- RTC
	O_RTC_WR	=> zx2_rtc_wr,
	O_RTC_ADDR	=> zx2_rtc_addr,
	I_RTC_DATA	=> rtc_2do_bus,
	-- TurboSound
	O_SSG0_A	=> zx2_ssg0_a,
	O_SSG0_B	=> zx2_ssg0_b,
	O_SSG0_C	=> zx2_ssg0_c,
	O_SSG1_A	=> zx2_ssg1_a,
	O_SSG1_B	=> zx2_ssg1_b,
	O_SSG1_C	=> zx2_ssg1_c,
	-- SounDrive
	O_COVOX_A	=> zx2_covox_a,
	O_COVOX_B	=> zx2_covox_b,
	O_COVOX_C	=> zx2_covox_c,
	O_COVOX_D	=> zx2_covox_d,
	-- DMA Sound
	I_DMASOUND_DATA	=> (others => '1'),
	I_DMASOUND_INT	=> '0' );

-- CPU3
U16: entity work.zx
generic map (
	Loader		=> '0',
	CPU		=> "11" )
port map (
	I_RESET		=> reset,
	I_CLK		=> clk_28mhz,
	I_SEL		=> zx3_sel,
	I_ENA_1_75MHZ	=> ena_1_75mhz,
	-- CPU
	O_CPU_DATA	=> zx3_cpu_do,
	O_CPU_ADDR	=> zx3_cpu_a,
	I_CPU_INT	=> zx3_cpu_int,
	I_CPU_CLK	=> clk_84mhz,
	I_CPU_ENA	=> cpu_ena,
	O_CPU_RFSH	=> zx3_cpu_rfsh,
	O_CPU_RD_N	=> open,
	O_CPU_WR_N	=> open,
	O_CPU_IORQ_N	=> open,
	O_CPU_INTA	=> open,
	-- ROM
	I_ROM_DATA	=> (others => '1'),
	-- RAM
	O_RAM_ADDR	=> zx3_ram_a,
	I_RAM_DATA	=> zx3_ram_di,
	O_RAM_WR	=> zx3_ram_wr,
	O_RAM_RD	=> zx3_ram_rd,
	-- Video
	I_VIDEO_CLK	=> clk_vga,
	I_VIDEO_ADDR	=> zx3_video_a,
	O_VIDEO_DATA	=> zx3_video_do,
	I_VIDEO_ATTR	=> zx3_video_attr,
	I_VIDEO_BORDER	=> zx3_video_border,
	-- Port
	O_PORT_XXFE	=> zx3_port_xxfe,
	O_PORT_0001	=> zx3_port_0001,
	-- Keyboard
	I_KEYBOARD_DATA	=> kb_do_bus,
	I_KEYBOARD_FN	=> kb_fn_bus,
	I_KEYBOARD_JOY	=> kb_joy_bus,
	I_KEYBOARD_SOFT	=> kb_soft_bus(2 downto 0),
	I_KEY0		=> kb_key0,
	I_KEY1		=> kb_key1,
	I_KEY2		=> kb_key2,
	I_KEY3		=> kb_key3,
	I_KEY4		=> kb_key4,
	I_KEY5		=> kb_key5,
	I_KEY6		=> kb_key6,
	-- Mouse
	I_MOUSE_X	=> ms_x,
	I_MOUSE_Y	=> ms_y,
	I_MOUSE_Z	=> ms_z(3 downto 0),
	I_MOUSE_BUTTONS	=> ms_b(2 downto 0),
	-- Z Controller
	I_ZC_DATA	=> zc_do_bus,
	O_ZC_RD		=> zx3_zc_rd,
	O_ZC_WR		=> zx3_zc_wr,
	-- SPI Controller
	I_SPI_DATA	=> spi_do_bus,
	O_SPI_WR	=> zx3_spi_wr,
	I_SPI_BUSY	=> spi_busy,
	-- I2C Controller
	I_I2C_DATA	=> i2c_do_bus,
	O_I2C_WR	=> zx3_i2c_wr,
	-- DivMMC
	O_DIVMMC_SC	=> zx3_divmmc_cs,
	O_DIVMMC_SCLK	=> zx3_divmmc_sclk,
	O_DIVMMC_MOSI	=> zx3_divmmc_mosi,
	I_DIVMMC_MISO	=> SD_SO,
	O_DIVMMC_SEL	=> zx3_divmmc_sel,
	-- RTC
	O_RTC_WR	=> zx3_rtc_wr,
	O_RTC_ADDR	=> zx3_rtc_addr,
	I_RTC_DATA	=> rtc_3do_bus,
	-- TurboSound
	O_SSG0_A	=> zx3_ssg0_a,
	O_SSG0_B	=> zx3_ssg0_b,
	O_SSG0_C	=> zx3_ssg0_c,
	O_SSG1_A	=> zx3_ssg1_a,
	O_SSG1_B	=> zx3_ssg1_b,
	O_SSG1_C	=> zx3_ssg1_c,
	-- SounDrive
	O_COVOX_A	=> zx3_covox_a,
	O_COVOX_B	=> zx3_covox_b,
	O_COVOX_C	=> zx3_covox_c,
	O_COVOX_D	=> zx3_covox_d,
	-- DMA Sound
	I_DMASOUND_DATA	=> (others => '1'),
	I_DMASOUND_INT	=> '0' );
 
-- MC146818A
U17: entity work.mc146818a
port map (
	I_RESET		=> reset,
	I_CLK		=> clk_28mhz,
	I_ENA		=> ena_0_4375mhz,
	I_CS		=> '1',
	I_WR		=> rtc_wr,
	I_ADDR		=> rtc_addr,
	I_DATA		=> rtc_data,
	O_DATA		=> rtc_do_bus,
	--
	I_1ADDR		=> zx1_rtc_addr,
	I_2ADDR		=> zx2_rtc_addr,
	I_3ADDR		=> zx3_rtc_addr,
	O_1DATA		=> rtc_1do_bus,
	O_2DATA		=> rtc_2do_bus,
	O_3DATA		=> rtc_3do_bus);
	
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
zx0_ssg_left <= (others => '0') when (kb_soft(3) = '1' and zx_sel /= "00") else ("00" & zx0_ssg0_c) + ("00" & zx0_ssg0_b) + ("00" & zx0_ssg1_c) + ("00" & zx0_ssg1_b);
zx1_ssg_left <= (others => '0') when (kb_soft(3) = '1' and zx_sel /= "01") else ("00" & zx1_ssg0_c) + ("00" & zx1_ssg0_b) + ("00" & zx1_ssg1_c) + ("00" & zx1_ssg1_b);
zx2_ssg_left <= (others => '0') when (kb_soft(3) = '1' and zx_sel /= "10") else ("00" & zx2_ssg0_c) + ("00" & zx2_ssg0_b) + ("00" & zx2_ssg1_c) + ("00" & zx2_ssg1_b);
zx3_ssg_left <= (others => '0') when (kb_soft(3) = '1' and zx_sel /= "11") else ("00" & zx3_ssg0_c) + ("00" & zx3_ssg0_b) + ("00" & zx3_ssg1_c) + ("00" & zx3_ssg1_b);

zx0_ssg_right <= (others => '0') when (kb_soft(3) = '1' and zx_sel /= "00") else ("00" & zx0_ssg0_a) + ("00" & zx0_ssg0_b) + ("00" & zx0_ssg1_a) + ("00" & zx0_ssg1_b);
zx1_ssg_right <= (others => '0') when (kb_soft(3) = '1' and zx_sel /= "01") else ("00" & zx1_ssg0_a) + ("00" & zx1_ssg0_b) + ("00" & zx1_ssg1_a) + ("00" & zx1_ssg1_b);
zx2_ssg_right <= (others => '0') when (kb_soft(3) = '1' and zx_sel /= "10") else ("00" & zx2_ssg0_a) + ("00" & zx2_ssg0_b) + ("00" & zx2_ssg1_a) + ("00" & zx2_ssg1_b);
zx3_ssg_right <= (others => '0') when (kb_soft(3) = '1' and zx_sel /= "11") else ("00" & zx3_ssg0_a) + ("00" & zx3_ssg0_b) + ("00" & zx3_ssg1_a) + ("00" & zx3_ssg1_b);

zx0_covox_left <= (others => '0') when (kb_soft(3) = '1' and zx_sel /= "00") else ('0' & zx0_covox_c) + ('0' & zx0_covox_d);
zx1_covox_left <= (others => '0') when (kb_soft(3) = '1' and zx_sel /= "01") else ('0' & zx1_covox_c) + ('0' & zx1_covox_d);
zx2_covox_left <= (others => '0') when (kb_soft(3) = '1' and zx_sel /= "10") else ('0' & zx2_covox_c) + ('0' & zx2_covox_d);
zx3_covox_left <= (others => '0') when (kb_soft(3) = '1' and zx_sel /= "11") else ('0' & zx3_covox_c) + ('0' & zx3_covox_d);

zx0_covox_right <= (others => '0') when (kb_soft(3) = '1' and zx_sel /= "00") else ('0' & zx0_covox_a) + ('0' & zx0_covox_b);
zx1_covox_right <= (others => '0') when (kb_soft(3) = '1' and zx_sel /= "01") else ('0' & zx1_covox_a) + ('0' & zx1_covox_b);
zx2_covox_right <= (others => '0') when (kb_soft(3) = '1' and zx_sel /= "10") else ('0' & zx2_covox_a) + ('0' & zx2_covox_b);
zx3_covox_right <= (others => '0') when (kb_soft(3) = '1' and zx_sel /= "11") else ('0' & zx3_covox_a) + ('0' & zx3_covox_b);

zx0_fx <= '0' when (kb_soft(3) = '1' and zx_sel /= "00") else zx0_port_xxfe(4);
zx1_fx <= '0' when (kb_soft(3) = '1' and zx_sel /= "01") else zx1_port_xxfe(4);
zx2_fx <= '0' when (kb_soft(3) = '1' and zx_sel /= "10") else zx2_port_xxfe(4);
zx3_fx <= '0' when (kb_soft(3) = '1' and zx_sel /= "11") else zx3_port_xxfe(4);

ssg_sum_left  <= ('0' & zx0_ssg_left)  + ('0' & zx1_ssg_left)  + ('0' & zx2_ssg_left)  + ('0' & zx3_ssg_left);
ssg_sum_right <= ('0' & zx0_ssg_right) + ('0' & zx1_ssg_right) + ('0' & zx2_ssg_right) + ('0' & zx3_ssg_right);

covox_sum_left  <= ('0' & zx0_covox_left)  + ('0' & zx1_covox_left)  + ('0' & zx2_covox_left)  + ('0' & zx3_covox_left);
covox_sum_right <= ('0' & zx0_covox_right) + ('0' & zx1_covox_right) + ('0' & zx2_covox_right) + ('0' & zx3_covox_right);

fx_sum <= ("00" & zx0_fx) + ("00" & zx1_fx) + ("00" & zx2_fx) + ("00" & zx3_fx);

sum_left  <= ('0' & ssg_sum_left)  + ("00" & covox_sum_left);
sum_right <= ('0' & ssg_sum_right) + ("00" & covox_sum_right);

audio_l <= ("000" & fx_sum & "0000000000") + ("00" & sum_left & "00")  + ("00" & dmasound_left_out(13 downto 0));
audio_r <= ("000" & fx_sum & "0000000000") + ("00" & sum_right & "00") + ("00" & dmasound_right_out(13 downto 0));

-- Stereo Adder (serial)
--audio_l <= 	("00" & zx0_port_xxfe(4) & "0000000000000000") + ("00" & zx0_ssg0_c & "000000000") + ("00" & zx0_ssg0_b & "000000000") + ("00" & zx0_ssg1_c & "000000000") + ("00" & zx0_ssg1_b & "000000000") + ("00" & zx0_covox_c & "000000000") + ("00" & zx0_covox_d & "000000000") +
--		("00" & zx1_port_xxfe(4) & "0000000000000000") + ("00" & zx1_ssg0_c & "000000000") + ("00" & zx1_ssg0_b & "000000000") + ("00" & zx1_ssg1_c & "000000000") + ("00" & zx1_ssg1_b & "000000000") + ("00" & zx1_covox_c & "000000000") + ("00" & zx1_covox_d & "000000000") +
--		("00" & zx2_port_xxfe(4) & "0000000000000000") + ("00" & zx2_ssg0_c & "000000000") + ("00" & zx2_ssg0_b & "000000000") + ("00" & zx2_ssg1_c & "000000000") + ("00" & zx2_ssg1_b & "000000000") + ("00" & zx2_covox_c & "000000000") + ("00" & zx2_covox_d & "000000000") +
--		("00" & zx3_port_xxfe(4) & "0000000000000000") + ("00" & zx3_ssg0_c & "000000000") + ("00" & zx3_ssg0_b & "000000000") + ("00" & zx3_ssg1_c & "000000000") + ("00" & zx3_ssg1_b & "000000000") + ("00" & zx3_covox_c & "000000000") + ("00" & zx3_covox_d & "000000000") +
--		("00" & dmasound_left_out);
--
--audio_r <= 	("00" & zx0_port_xxfe(4) & "0000000000000000") + ("00" & zx0_ssg0_a & "000000000") + ("00" & zx0_ssg0_b & "000000000") + ("00" & zx0_ssg1_a & "000000000") + ("00" & zx0_ssg1_b & "000000000") + ("00" & zx0_covox_a & "000000000") + ("00" & zx0_covox_b & "000000000") +
--		("00" & zx1_port_xxfe(4) & "0000000000000000") + ("00" & zx1_ssg0_a & "000000000") + ("00" & zx1_ssg0_b & "000000000") + ("00" & zx1_ssg1_a & "000000000") + ("00" & zx1_ssg1_b & "000000000") + ("00" & zx1_covox_a & "000000000") + ("00" & zx1_covox_b & "000000000") +
--		("00" & zx2_port_xxfe(4) & "0000000000000000") + ("00" & zx2_ssg0_a & "000000000") + ("00" & zx2_ssg0_b & "000000000") + ("00" & zx2_ssg1_a & "000000000") + ("00" & zx2_ssg1_b & "000000000") + ("00" & zx2_covox_a & "000000000") + ("00" & zx2_covox_b & "000000000") +
--		("00" & zx3_port_xxfe(4) & "0000000000000000") + ("00" & zx3_ssg0_a & "000000000") + ("00" & zx3_ssg0_b & "000000000") + ("00" & zx3_ssg1_a & "000000000") + ("00" & zx3_ssg1_b & "000000000") + ("00" & zx3_covox_a & "000000000") + ("00" & zx3_covox_b & "000000000") +
--		("00" & dmasound_right_out);


-------------------------------------------------------------------------------
areset <= not USB_NRESET;
reset <= areset or kb_soft_bus(0) or not locked0 or not locked1;	-- ZX_RESET

-- SD Card					
SD_NCS	<= divmmc_cs_n when divmmc_sel = '1' else zc_cs_n;
SD_CLK 	<= divmmc_sclk when divmmc_sel = '1' else zc_sclk;
SD_SI 	<= divmmc_mosi when divmmc_sel = '1' else zc_mosi;

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

process (zx0_cpu_a, zx0_cpu_do, zx0_zc_rd, zx0_zc_wr, zx0_i2c_wr, zx0_divmmc_cs, zx0_divmmc_sclk, zx0_divmmc_mosi, zx0_spi_wr, zx0_port_0001, zx0_divmmc_sel,
	 zx1_cpu_a, zx1_cpu_do, zx1_zc_rd, zx1_zc_wr, zx1_i2c_wr, zx1_divmmc_cs, zx1_divmmc_sclk, zx1_divmmc_mosi, zx1_spi_wr, zx1_port_0001, zx1_divmmc_sel,
	 zx2_cpu_a, zx2_cpu_do, zx2_zc_rd, zx2_zc_wr, zx2_i2c_wr, zx2_divmmc_cs, zx2_divmmc_sclk, zx2_divmmc_mosi, zx2_spi_wr, zx2_port_0001, zx2_divmmc_sel,
	 zx3_cpu_a, zx3_cpu_do, zx3_zc_rd, zx3_zc_wr, zx3_i2c_wr, zx3_divmmc_cs, zx3_divmmc_sclk, zx3_divmmc_mosi, zx3_spi_wr, zx3_port_0001, zx3_divmmc_sel,
	 zx_sel, port_0001, kb_a_bus, zc_a, zc_di_bus, zc_rd, zc_wr, spi_a, spi_di_bus, spi_wr, divmmc_cs_n, divmmc_sclk, divmmc_mosi)
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
			-- Z Controller
			zc_a	    <= zx0_cpu_a(5);
			zc_di_bus   <= zx0_cpu_do;
			zc_rd       <= zx0_zc_rd;
			zc_wr       <= zx0_zc_wr;
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
			-- RTC
			rtc_wr	    <= zx0_rtc_wr;
			rtc_addr    <= zx0_rtc_addr;
			rtc_data    <= zx0_cpu_do;
		when "01" =>
			zx1_sel     <= '1';		-- CPU1 Select
			port_0001   <= zx1_port_0001;
			-- Keyboard Controller
			kb_a_bus    <= zx1_cpu_a(15 downto 8);
			-- Z Controller
			zc_a	    <= zx1_cpu_a(5);
			zc_di_bus   <= zx1_cpu_do;
			zc_rd       <= zx1_zc_rd;
			zc_wr       <= zx1_zc_wr;
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
			-- RTC
			rtc_wr	    <= zx1_rtc_wr;
			rtc_addr    <= zx1_rtc_addr;
			rtc_data    <= zx1_cpu_do;
		when "10" =>
			zx2_sel     <= '1';		-- CPU2 Select
			port_0001   <= zx2_port_0001;
			-- Keyboard Controller
			kb_a_bus    <= zx2_cpu_a(15 downto 8);
			-- Z Controller
			zc_a	    <= zx2_cpu_a(5);
			zc_di_bus   <= zx2_cpu_do;
			zc_rd       <= zx2_zc_rd;
			zc_wr       <= zx2_zc_wr;
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
			-- RTC
			rtc_wr	    <= zx2_rtc_wr;
			rtc_addr    <= zx2_rtc_addr;
			rtc_data    <= zx2_cpu_do;
		when "11" =>
			zx3_sel     <= '1';		-- CPU3 Select
			port_0001   <= zx3_port_0001;
			-- Keyboard Controller
			kb_a_bus    <= zx3_cpu_a(15 downto 8);
			-- Z Controller
			zc_a	    <= zx3_cpu_a(5);
			zc_di_bus   <= zx3_cpu_do;
			zc_rd       <= zx3_zc_rd;
			zc_wr       <= zx3_zc_wr;
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
			-- RTC
			rtc_wr	    <= zx3_rtc_wr;
			rtc_addr    <= zx3_rtc_addr;
			rtc_data    <= zx3_cpu_do;
		when others => null;
	end case;
end process;


end rtl;