-------------------------------------------------------------------[19.08.2016]
-- Spec256
-- DEVBOARD ReVerSE-U16 Rev.C
-------------------------------------------------------------------------------
-- Engineer: MVV <mvvproject@gmail.com>
--
-- https://github.com/mvvproject/ReVerSE-U16
--
-- Copyright (c) 2016 Vladislav Matlash
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

entity spec256 is
port (
	-- Clock
	CLK_50MHZ	: in std_logic;	-- 50MHz
	-- HDMI
	TMDS		: out std_logic_vector(7 downto 0);
	-- USB VNC2
	USB_NRESET	: in std_logic;
	USB_TX		: in std_logic;
	USB_IO1		: in std_logic;
	-- SPI
	DATA0		: in std_logic;
	ASDO		: out std_logic;
	DCLK		: out std_logic;
	NCSO		: out std_logic;
	-- Audio
	DAC_OUT_L	: out std_logic;
	DAC_OUT_R	: out std_logic;
	--- SDRAM
	DRAM_CLK	: out std_logic;
	DRAM_NRAS	: out std_logic;
	DRAM_NCAS	: out std_logic;
	DRAM_NWE	: out std_logic;
	DRAM_DQM	: out std_logic_vector(1 downto 0);
	DRAM_BA		: out std_logic_vector(1 downto 0);
	DRAM_A		: out std_logic_vector(12 downto 0);
	DRAM_DQ		: inout std_logic_vector(15 downto 0));
end spec256;

architecture rtl of spec256 is

-- CPU
signal cpu_reset_n	: std_logic;
signal cpu_addr		: std_logic_vector(15 downto 0);
signal cpu_mreq_n	: std_logic;
signal cpu_iorq_n	: std_logic;
signal cpu_wr_n		: std_logic;
signal cpu_rd_n		: std_logic;
signal cpu_int_n	: std_logic;
signal cpu_m1_n		: std_logic;
signal cpu_nmi_n	: std_logic;
signal cpu_ena		: std_logic;
signal cpu_do		: std_logic_vector(63 downto 0);
signal cpu_di		: std_logic_vector(63 downto 0);
-- Memory
signal lram_do		: std_logic_vector(7 downto 0);
signal lram_wr		: std_logic;
signal vram_wr		: std_logic;
-- Port
signal port_xxfe_reg	: std_logic_vector(7 downto 0);
signal port_xx00_reg	: std_logic_vector(7 downto 0);
signal port_xx01_reg	: std_logic_vector(15 downto 0);
signal port_xx04_reg	: std_logic_vector(7 downto 0);
-- Keyboard
signal kb_do		: std_logic_vector(4 downto 0);
signal kb_fn		: std_logic_vector(12 downto 1);
signal kb_joy		: std_logic_vector(4 downto 0);
-- Video
signal vga_addr		: std_logic_vector(12 downto 0);
signal vga_data		: std_logic_vector(63 downto 0);
signal vga_wr		: std_logic;
signal vga_r		: std_logic_vector(7 downto 0);
signal vga_g		: std_logic_vector(7 downto 0);
signal vga_b		: std_logic_vector(7 downto 0);
signal sync_hcnt	: std_logic_vector(9 downto 0);
signal sync_vcnt	: std_logic_vector(9 downto 0);
signal sync_hsync	: std_logic;
signal sync_vsync	: std_logic;
signal sync_blank	: std_logic;
signal sync_int		: std_logic;
-- CLOCK
signal clk_vga		: std_logic;
signal clk_tmds		: std_logic;
signal clk_sdram	: std_logic;
signal clk_1m75hz	: std_logic;
-- System
signal reset		: std_logic;
signal areset		: std_logic;
signal locked		: std_logic;
signal locked1		: std_logic;
signal selector		: std_logic_vector(2 downto 0);
signal key_f		: std_logic_vector(12 downto 1);
signal key		: std_logic_vector(12 downto 1) := "000000000000";
signal inta_n		: std_logic;
signal loader		: std_logic := '1';
-- SDRAM
signal sdram_do		: std_logic_vector(63 downto 0);
signal sdram_rd		: std_logic;
signal sdram_wr		: std_logic;
-- SPI
signal spi_busy		: std_logic;
signal spi_do		: std_logic_vector(7 downto 0);
signal spi_wr		: std_logic;
-- Audio
signal audio_l		: std_logic_vector(15 downto 0);
signal audio_r		: std_logic_vector(15 downto 0);


begin

-- PLL
U01: entity work.altpll0
port map (
	areset		=> areset,
	locked		=> locked,
	inclk0		=> CLK_50MHZ,		-- 50.00 MHz
	c0		=> clk_sdram,		-- 56.00 MHz
	c1		=> clk_1m75hz);		--  1.75 MHz
	
-- PLL1
U02: entity work.altpll1
port map (
	areset		=> areset,
	inclk0		=> CLK_50MHZ,
	locked		=> locked1,
	c0		=> clk_tmds,		-- 126.0 MHz
	c1		=> clk_vga);		--  25.2 MHz	

-- LRAM 1K Loader
U1: entity work.lram
port map (
	address		=> cpu_addr(10 downto 0),
	clock		=> clk_sdram,
	wren		=> lram_wr,
	data		=> cpu_do(7 downto 0),
	q	 	=> lram_do);
	
-- CPU0
U2: entity work.t80se
generic map (
	Mode		=> 0,	-- 0 => Z80, 1 => Fast Z80, 2 => 8080, 3 => GB
	T2Write		=> 0,	-- 0 => WR_n active in T3, /=0 => WR_n active in T2
	IOWait		=> 1 )	-- 0 => Single cycle I/O, 1 => Std I/O cycle

port map (
	RESET_n		=> cpu_reset_n,
	CLK_n		=> clk_sdram,
	ENA		=> cpu_ena,
	WAIT_n		=> '1',
	INT_n		=> cpu_int_n,
	NMI_n		=> cpu_nmi_n,
	BUSRQ_n		=> '1',
	M1_n		=> cpu_m1_n,
	MREQ_n		=> cpu_mreq_n,
	IORQ_n		=> cpu_iorq_n,
	RD_n		=> cpu_rd_n,
	WR_n		=> cpu_wr_n,
	RFSH_n		=> open,
	HALT_n		=> open,
	BUSAK_n		=> open,
	A		=> cpu_addr,
	DI		=> cpu_di(7 downto 0),
	DO		=> cpu_do(7 downto 0));

-- CPU1
U3: entity work.t80se
generic map (
	Mode		=> 0,	-- 0 => Z80, 1 => Fast Z80, 2 => 8080, 3 => GB
	T2Write		=> 0,	-- 0 => WR_n active in T3, /=0 => WR_n active in T2
	IOWait		=> 1 )	-- 0 => Single cycle I/O, 1 => Std I/O cycle

port map (
	RESET_n		=> cpu_reset_n,
	CLK_n		=> clk_sdram,
	ENA		=> cpu_ena,
	WAIT_n		=> '1',
	INT_n		=> cpu_int_n,
	NMI_n		=> cpu_nmi_n,
	BUSRQ_n		=> '1',
	M1_n		=> open,
	MREQ_n		=> open,
	IORQ_n		=> open,
	RD_n		=> open,
	WR_n		=> open,
	RFSH_n		=> open,
	HALT_n		=> open,
	BUSAK_n		=> open,
	A		=> open,
	DI		=> cpu_di(15 downto 8),
	DO		=> cpu_do(15 downto 8));
	
-- CPU2
U4: entity work.t80se
generic map (
	Mode		=> 0,	-- 0 => Z80, 1 => Fast Z80, 2 => 8080, 3 => GB
	T2Write		=> 0,	-- 0 => WR_n active in T3, /=0 => WR_n active in T2
	IOWait		=> 1 )	-- 0 => Single cycle I/O, 1 => Std I/O cycle

port map (
	RESET_n		=> cpu_reset_n,
	CLK_n		=> clk_sdram,
	ENA		=> cpu_ena,
	WAIT_n		=> '1',
	INT_n		=> cpu_int_n,
	NMI_n		=> cpu_nmi_n,
	BUSRQ_n		=> '1',
	M1_n		=> open,
	MREQ_n		=> open,
	IORQ_n		=> open,
	RD_n		=> open,
	WR_n		=> open,
	RFSH_n		=> open,
	HALT_n		=> open,
	BUSAK_n		=> open,
	A		=> open,
	DI		=> cpu_di(23 downto 16),
	DO		=> cpu_do(23 downto 16));

-- CPU3
U5: entity work.t80se
generic map (
	Mode		=> 0,	-- 0 => Z80, 1 => Fast Z80, 2 => 8080, 3 => GB
	T2Write		=> 0,	-- 0 => WR_n active in T3, /=0 => WR_n active in T2
	IOWait		=> 1 )	-- 0 => Single cycle I/O, 1 => Std I/O cycle

port map (
	RESET_n		=> cpu_reset_n,
	CLK_n		=> clk_sdram,
	ENA		=> cpu_ena,
	WAIT_n		=> '1',
	INT_n		=> cpu_int_n,
	NMI_n		=> cpu_nmi_n,
	BUSRQ_n		=> '1',
	M1_n		=> open,
	MREQ_n		=> open,
	IORQ_n		=> open,
	RD_n		=> open,
	WR_n		=> open,
	RFSH_n		=> open,
	HALT_n		=> open,
	BUSAK_n		=> open,
	A		=> open,
	DI		=> cpu_di(31 downto 24),
	DO		=> cpu_do(31 downto 24));

-- CPU4
U6: entity work.t80se
generic map (
	Mode		=> 0,	-- 0 => Z80, 1 => Fast Z80, 2 => 8080, 3 => GB
	T2Write		=> 0,	-- 0 => WR_n active in T3, /=0 => WR_n active in T2
	IOWait		=> 1 )	-- 0 => Single cycle I/O, 1 => Std I/O cycle

port map (
	RESET_n		=> cpu_reset_n,
	CLK_n		=> clk_sdram,
	ENA		=> cpu_ena,
	WAIT_n		=> '1',
	INT_n		=> cpu_int_n,
	NMI_n		=> cpu_nmi_n,
	BUSRQ_n		=> '1',
	M1_n		=> open,
	MREQ_n		=> open,
	IORQ_n		=> open,
	RD_n		=> open,
	WR_n		=> open,
	RFSH_n		=> open,
	HALT_n		=> open,
	BUSAK_n		=> open,
	A		=> open,
	DI		=> cpu_di(39 downto 32),
	DO		=> cpu_do(39 downto 32));
	
-- CPU5
U7: entity work.t80se
generic map (
	Mode		=> 0,	-- 0 => Z80, 1 => Fast Z80, 2 => 8080, 3 => GB
	T2Write		=> 0,	-- 0 => WR_n active in T3, /=0 => WR_n active in T2
	IOWait		=> 1 )	-- 0 => Single cycle I/O, 1 => Std I/O cycle

port map (
	RESET_n		=> cpu_reset_n,
	CLK_n		=> clk_sdram,
	ENA		=> cpu_ena,
	WAIT_n		=> '1',
	INT_n		=> cpu_int_n,
	NMI_n		=> cpu_nmi_n,
	BUSRQ_n		=> '1',
	M1_n		=> open,
	MREQ_n		=> open,
	IORQ_n		=> open,
	RD_n		=> open,
	WR_n		=> open,
	RFSH_n		=> open,
	HALT_n		=> open,
	BUSAK_n		=> open,
	A		=> open,
	DI		=> cpu_di(47 downto 40),
	DO		=> cpu_do(47 downto 40));	

-- CPU6
U8: entity work.t80se
generic map (
	Mode		=> 0,	-- 0 => Z80, 1 => Fast Z80, 2 => 8080, 3 => GB
	T2Write		=> 0,	-- 0 => WR_n active in T3, /=0 => WR_n active in T2
	IOWait		=> 1 )	-- 0 => Single cycle I/O, 1 => Std I/O cycle

port map (
	RESET_n		=> cpu_reset_n,
	CLK_n		=> clk_sdram,
	ENA		=> cpu_ena,
	WAIT_n		=> '1',
	INT_n		=> cpu_int_n,
	NMI_n		=> cpu_nmi_n,
	BUSRQ_n		=> '1',
	M1_n		=> open,
	MREQ_n		=> open,
	IORQ_n		=> open,
	RD_n		=> open,
	WR_n		=> open,
	RFSH_n		=> open,
	HALT_n		=> open,
	BUSAK_n		=> open,
	A		=> open,
	DI		=> cpu_di(55 downto 48),
	DO		=> cpu_do(55 downto 48));

-- CPU7
U9: entity work.t80se
generic map (
	Mode		=> 0,	-- 0 => Z80, 1 => Fast Z80, 2 => 8080, 3 => GB
	T2Write		=> 0,	-- 0 => WR_n active in T3, /=0 => WR_n active in T2
	IOWait		=> 1 )	-- 0 => Single cycle I/O, 1 => Std I/O cycle

port map (
	RESET_n		=> cpu_reset_n,
	CLK_n		=> clk_sdram,
	ENA		=> cpu_ena,
	WAIT_n		=> '1',
	INT_n		=> cpu_int_n,
	NMI_n		=> cpu_nmi_n,
	BUSRQ_n		=> '1',
	M1_n		=> open,
	MREQ_n		=> open,
	IORQ_n		=> open,
	RD_n		=> open,
	WR_n		=> open,
	RFSH_n		=> open,
	HALT_n		=> open,
	BUSAK_n		=> open,
	A		=> open,
	DI		=> cpu_di(63 downto 56),
	DO		=> cpu_do(63 downto 56));

-- Video
U10: entity work.vga_spec256
port map (
	I_CLK		=> clk_vga,
	I_DATA		=> vga_data,
	I_BORDER	=> port_xxfe_reg(2 downto 0),	-- Биты D0..D2 порта xxFE определяют цвет бордюра
	I_HCNT		=> sync_hcnt,
	I_VCNT		=> sync_vcnt,
	I_BLANK		=> sync_blank,
	O_ADDR		=> vga_addr,
	O_R		=> vga_r,
	O_G		=> vga_g,
	O_B		=> vga_b);
	
-- USB HID
U11: entity work.deserializer
generic map (
	divisor			=> 434)		-- divisor = 50MHz / 115200 Baud = 434
port map (
	I_CLK			=> CLK_50MHZ,
	I_RESET			=> areset,
	I_RX			=> USB_TX,
	I_NEWFRAME		=> USB_IO1,
	I_ADDR			=> cpu_addr(15 downto 8),
	O_MOUSE_X		=> open,
	O_MOUSE_Y		=> open,
	O_MOUSE_Z		=> open,
	O_MOUSE_BUTTONS		=> open,
	O_KEY0			=> open,
	O_KEY1			=> open,
	O_KEY2			=> open,
	O_KEY3			=> open,
	O_KEY4			=> open,
	O_KEY5			=> open,
	O_KEY6			=> open,
	O_KEYBOARD_SCAN		=> kb_do,
	O_KEYBOARD_FKEYS	=> kb_fn,
	O_KEYBOARD_JOYKEYS	=> kb_joy,
	O_KEYBOARD_CTLKEYS	=> open);	
	
-- Delta-Sigma
U12: entity work.dac
port map (
	I_CLK		=> clk_sdram,
	I_RESET		=> areset,
	I_DAC_DATA	=> port_xxfe_reg(4) & '0',
	O_DAC		=> DAC_OUT_L);

-- Delta-Sigma
U13: entity work.dac
port map (
	I_CLK		=> clk_sdram,
	I_RESET		=> areset,
	I_DAC_DATA	=> port_xxfe_reg(4) & '0',
	O_DAC		=> DAC_OUT_R);

-- HDMI
U14: entity work.hdmi
generic map (
	FREQ		=> 25200000,		-- pixel clock frequency = 25.2MHz
	FS		=> 48000,		-- audio sample rate - should be 32000, 41000 or 48000 = 48KHz
	CTS		=> 25200,		-- CTS = Freq(pixclk) * N / (128 * Fs)
	N		=> 6144)		-- N = 128 * Fs /1000,  128 * Fs /1500 <= N <= 128 * Fs /300 (Check HDMI spec 7.2 for details)
port map (
	I_CLK_VGA	=> clk_vga,
	I_CLK_TMDS	=> clk_tmds,
	I_HSYNC		=> sync_hsync,
	I_VSYNC		=> sync_vsync,
	I_BLANK		=> sync_blank,
	I_RED		=> vga_r,
	I_GREEN		=> vga_g,
	I_BLUE		=> vga_b,
	I_AUDIO_PCM_L 	=> audio_l,
	I_AUDIO_PCM_R	=> audio_r,
	O_TMDS		=> TMDS);
	
-- Sync
U15: entity work.sync
port map (
	I_CLK		=> clk_vga,
	I_EN		=> '1',
	O_HCNT		=> sync_hcnt,
	O_VCNT		=> sync_vcnt,
	O_INT		=> sync_int,
	O_FLASH		=> open,
	O_BLANK		=> sync_blank,
	O_HSYNC		=> sync_hsync,
	O_VSYNC		=> sync_vsync);
	
U16: entity work.sdram
port map (
	I_CLK		=> clk_sdram,
	I_RESET		=> areset,
	I_WR		=> sdram_wr,
	I_RD	 	=> sdram_rd,
	I_DQM		=> port_xx04_reg,
	I_ADDR		=> "000000" & cpu_addr,
	I_DATA		=> cpu_do,
	O_DATA	 	=> sdram_do,
	O_ENA		=> cpu_ena,
	-- SDRAM Pin
	O_CLK		=> DRAM_CLK,
	O_RAS_N		=> DRAM_NRAS,
	O_CAS_N		=> DRAM_NCAS,
	O_WE_N		=> DRAM_NWE,
	O_DQM		=> DRAM_DQM,
	O_BA		=> DRAM_BA,
	O_MA		=> DRAM_A,
	IO_DQ		=> DRAM_DQ);

-- VRAM 8K
U17: entity work.vram
port map (
	address_a	=> cpu_addr(12 downto 0),
	address_b	=> vga_addr,
	clock_a		=> clk_sdram,
	clock_b		=> clk_vga,
	data_a	 	=> cpu_do(7 downto 0),
	data_b	 	=> (others => '0'),
	wren_a	 	=> vram_wr and not port_xx04_reg(0),
	wren_b	 	=> '0',
	q_a	 	=> open,
	q_b	 	=> vga_data(7 downto 0));

-- VRAM1 8K
U18: entity work.vram
port map (
	address_a	=> cpu_addr(12 downto 0),
	address_b	=> vga_addr,
	clock_a		=> clk_sdram,
	clock_b		=> clk_vga,
	data_a	 	=> cpu_do(15 downto 8),
	data_b	 	=> (others => '0'),
	wren_a	 	=> vram_wr and not port_xx04_reg(1),
	wren_b	 	=> '0',
	q_a	 	=> open,
	q_b	 	=> vga_data(15 downto 8));
	
-- VRAM2 8K
U19: entity work.vram
port map (
	address_a	=> cpu_addr(12 downto 0),
	address_b	=> vga_addr,
	clock_a		=> clk_sdram,
	clock_b		=> clk_vga,
	data_a	 	=> cpu_do(23 downto 16),
	data_b	 	=> (others => '0'),
	wren_a	 	=> vram_wr and not port_xx04_reg(2),
	wren_b	 	=> '0',
	q_a	 	=> open,
	q_b	 	=> vga_data(23 downto 16));	
	
-- VRAM3 8K
U20: entity work.vram
port map (
	address_a	=> cpu_addr(12 downto 0),
	address_b	=> vga_addr,
	clock_a		=> clk_sdram,
	clock_b		=> clk_vga,
	data_a	 	=> cpu_do(31 downto 24),
	data_b	 	=> (others => '0'),
	wren_a	 	=> vram_wr and not port_xx04_reg(3),
	wren_b	 	=> '0',
	q_a	 	=> open,
	q_b	 	=> vga_data(31 downto 24));	
	
-- VRAM4 8K
U21: entity work.vram
port map (
	address_a	=> cpu_addr(12 downto 0),
	address_b	=> vga_addr,
	clock_a		=> clk_sdram,
	clock_b		=> clk_vga,
	data_a	 	=> cpu_do(39 downto 32),
	data_b	 	=> (others => '0'),
	wren_a	 	=> vram_wr and not port_xx04_reg(4),
	wren_b	 	=> '0',
	q_a	 	=> open,
	q_b	 	=> vga_data(39 downto 32));	

-- VRAM5 8K
U22: entity work.vram
port map (
	address_a	=> cpu_addr(12 downto 0),
	address_b	=> vga_addr,
	clock_a		=> clk_sdram,
	clock_b		=> clk_vga,
	data_a	 	=> cpu_do(47 downto 40),
	data_b	 	=> (others => '0'),
	wren_a	 	=> vram_wr and not port_xx04_reg(5),
	wren_b	 	=> '0',
	q_a	 	=> open,
	q_b	 	=> vga_data(47 downto 40));

-- VRAM6 8K
U23: entity work.vram
port map (
	address_a	=> cpu_addr(12 downto 0),
	address_b	=> vga_addr,
	clock_a		=> clk_sdram,
	clock_b		=> clk_vga,
	data_a	 	=> cpu_do(55 downto 48),
	data_b	 	=> (others => '0'),
	wren_a	 	=> vram_wr and not port_xx04_reg(6),
	wren_b	 	=> '0',
	q_a	 	=> open,
	q_b	 	=> vga_data(55 downto 48));

-- VRAM7 8K
U24: entity work.vram
port map (
	address_a	=> cpu_addr(12 downto 0),
	address_b	=> vga_addr,
	clock_a		=> clk_sdram,
	clock_b		=> clk_vga,
	data_a	 	=> cpu_do(63 downto 56),
	data_b	 	=> (others => '0'),
	wren_a	 	=> vram_wr and not port_xx04_reg(7),
	wren_b	 	=> '0',
	q_a	 	=> open,
	q_b	 	=> vga_data(63 downto 56));
	
-- SPI FLASH 25MHz Max SCK
U25: entity work.spi
port map (
	I_RESET		=> reset,
	I_CLK		=> clk_sdram,
	I_SCK		=> clk_vga,
	I_ADDR		=> cpu_addr(0),
	I_DATA		=> cpu_do(7 downto 0),
	O_DATA		=> spi_do,
	I_WR		=> spi_wr,
	O_BUSY		=> spi_busy,
	O_CS_n		=> NCSO,
	O_SCLK		=> DCLK,
	O_MOSI		=> ASDO,
	I_MISO		=> DATA0);
	
-------------------------------------------------------------------------------
-- Формирование глобальных сигналов
process (sync_int, inta_n)
begin
	if inta_n = '0' then
		cpu_int_n <= '1';
	elsif sync_int'event and sync_int = '1' then
		cpu_int_n <= '0';
	end if;
end process;

areset		<= not USB_NRESET;	-- глобальный сброс
reset		<= areset or not locked or not locked1 or kb_fn(5);	-- горячий сброс
cpu_reset_n	<= not(reset or kb_fn(4));		-- CPU сброс
inta_n		<= cpu_iorq_n or cpu_m1_n;		-- inta_n
cpu_nmi_n	<= '1';					-- NMI


lram_wr		<= '1' when cpu_mreq_n = '0' and cpu_wr_n = '0' and cpu_addr(15 downto 11) = "00000" and port_xx00_reg(1) = '1' and loader = '1' else '0';
vram_wr		<= '1' when cpu_mreq_n = '0' and cpu_wr_n = '0' and cpu_addr(15 downto 13) = "010" else '0';
sdram_wr	<= '1' when cpu_mreq_n = '0' and cpu_wr_n = '0' and (cpu_addr(15 downto 14) /= "00" or (port_xx00_reg(1) = '0' and loader = '1')) else '0';
sdram_rd	<= '1' when cpu_mreq_n = '0' and cpu_rd_n = '0' and (cpu_addr(15 downto 11) /= "00000" or loader = '0') else '0';
spi_wr		<= '1' when cpu_iorq_n = '0' and cpu_wr_n = '0' and cpu_addr(7 downto 1) = "0000001" else '0';

audio_l		<= "0000" & port_xxfe_reg(4) & "00000000000";
audio_r		<= "0000" & port_xxfe_reg(4) & "00000000000";

-------------------------------------------------------------------------------
-- Регистры
process (reset, clk_sdram, cpu_addr, port_xxfe_reg, cpu_wr_n, cpu_do, loader)
begin
	if reset = '1' then
		loader <= '1';
		port_xx00_reg <= (others => '0');
		port_xx04_reg <= (others => '0');
	elsif clk_sdram'event and clk_sdram = '1' then
		if cpu_iorq_n = '0' and cpu_wr_n = '0' and cpu_addr(7 downto 0) = X"FE" then port_xxfe_reg <= cpu_do(7 downto 0); end if;
		if cpu_iorq_n = '0' and cpu_wr_n = '0' and cpu_addr(7 downto 0) = X"00" then port_xx00_reg <= cpu_do(7 downto 0); end if;
		if cpu_iorq_n = '0' and cpu_wr_n = '0' and cpu_addr(7 downto 0) = X"01" then port_xx01_reg <= cpu_addr(15 downto 8) & cpu_do(7 downto 0); end if;
		if cpu_iorq_n = '0' and cpu_wr_n = '0' and cpu_addr(7 downto 0) = X"04" then port_xx04_reg <= cpu_do(7 downto 0); end if;
		if cpu_mreq_n = '0' and cpu_m1_n = '0' and cpu_addr = port_xx01_reg and port_xx00_reg(0) = '1' then loader <= '0'; end if;
	end if;
end process;

-------------------------------------------------------------------------------
-- Функциональные клавиши Fx
process (clk_sdram, key, kb_fn, key_f)
begin
	if clk_sdram'event and clk_sdram = '1' then
		key <= kb_fn;
		if kb_fn /= key then
			key_f <= key_f xor key;
		end if;
	end if;
end process;

-------------------------------------------------------------------------------
-- Шина данных CPU
process (selector, lram_do, sdram_do, kb_do, kb_joy, spi_do, spi_busy)
begin
	case selector is
		when "000" => cpu_di <= lram_do & lram_do & lram_do & lram_do & lram_do & lram_do & lram_do & lram_do;
		when "001" => cpu_di <= sdram_do;
		when "010" => cpu_di <= "111" & kb_do & "111" & kb_do & "111" & kb_do & "111" & kb_do & "111" & kb_do & "111" & kb_do & "111" & kb_do & "111" & kb_do;
		when "011" => cpu_di <= "000" & kb_joy & "000" & kb_joy & "000" & kb_joy & "000" & kb_joy & "000" & kb_joy & "000" & kb_joy & "000" & kb_joy & "000" & kb_joy;
		when "100" => cpu_di <= spi_do & spi_do & spi_do & spi_do & spi_do & spi_do & spi_do & spi_do;
		when "101" => cpu_di <= spi_busy & "1111111" & spi_busy & "1111111" & spi_busy & "1111111" & spi_busy & "1111111" & spi_busy & "1111111" & spi_busy & "1111111" & spi_busy & "1111111" & spi_busy & "1111111";
		when others => cpu_di <= (others => '1');
	end case;
end process;

selector <=	"000" when cpu_mreq_n = '0' and cpu_rd_n = '0' and cpu_addr(15 downto 11) = "00000" and loader = '1' else	-- LRAM
		"001" when cpu_mreq_n = '0' and cpu_rd_n = '0' and (cpu_addr(15 downto 11) /= "00000" or loader = '0') else	-- SDRAM
		"010" when cpu_iorq_n = '0' and cpu_rd_n = '0' and cpu_addr(7 downto 0) = X"FE" else	-- Клавиатура, порт xxFE
		"011" when cpu_iorq_n = '0' and cpu_rd_n = '0' and cpu_addr(7 downto 0) = X"1F" else	-- Joystick, порт xx1F
		"100" when cpu_iorq_n = '0' and cpu_rd_n = '0' and cpu_addr(7 downto 0) = X"02" else	-- порт xx02
		"101" when cpu_iorq_n = '0' and cpu_rd_n = '0' and cpu_addr(7 downto 0) = X"03" else	-- порт xx03
		(others => '1');

	
end rtl;