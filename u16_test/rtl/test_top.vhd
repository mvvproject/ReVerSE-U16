-------------------------------------------------------------------[11.11.2014]
-- ReVerSE-u16 TEST (Power-On Self-Test) Version 0.1.1
-- DEVBOARD ReVerSE-U16
-------------------------------------------------------------------------------
-- V0.1.0	16.08.2014	Initial version
-- V0.1.1	11.11.2014	

-- http://zx-pk.ru/showthread.php?t=23528

-- Copyright (c) 2014 MVV
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

entity test_top is
port (
	-- Clock (50MHz)
	CLK		: in std_logic;
	-- SDRAM (32MB 16x16bit)
--	SDRAM_DQ	: inout std_logic_vector(15 downto 0);
--	SDRAM_A		: out std_logic_vector(12 downto 0);
--	SDRAM_BA	: out std_logic_vector(1 downto 0);
--	SDRAM_CLK	: out std_logic;
--	SDRAM_DQML	: out std_logic;
--	SDRAM_DQMH	: out std_logic;
--	SDRAM_WE_N	: out std_logic;
--	SDRAM_CAS_N	: out std_logic;
--	SDRAM_RAS_N	: out std_logic;
	-- I2C 
--	SCL		: inout std_logic;
--	SDA		: inout std_logic;
	-- RTC (DS1338Z-33+)
--	RTC_SQW		: in std_logic;
	-- SPI FLASH (M25P16)
--	DATA0		: in std_logic;
--	NCSO		: out std_logic;
--	DCLK		: out std_logic;
--	ASDO		: out std_logic;
	-- HDMI
--	HDMI_CEC	: inout std_logic;
--	HDMI_DET_N	: in std_logic;
	HDMI_D0		: out std_logic;
	HDMI_D1		: out std_logic;
	HDMI_D1N	: out std_logic := '0';
	HDMI_D2		: out std_logic;
	HDMI_CLK	: out std_logic;
	-- SD/MMC Memory Card
--	SD_DET_N	: in std_logic;
--	SD_SO		: in std_logic;
--	SD_SI		: out std_logic;
--	SD_CLK		: out std_logic;
--	SD_CS_N		: out std_logic;
	-- Ethernet (ENC424J600)
--	ETH_SO		: in std_logic;
--	ETH_INT_N	: in std_logic;
--	ETH_CS_N	: out std_logic;
	-- USB Host (VNC2-32)
	USB_RESET_N	: in std_logic);
--	USB_PROG_N	: inout std_logic;
--	USB_DBG		: inout std_logic;
--	USB_IO1		: in std_logic;
--	USB_IO3		: in std_logic;
--	USB_TX		: in std_logic;
--	USB_RX		: out std_logic;
--	USB_CLK		: out std_logic;
--	USB_SI		: out std_logic;
--	USB_SO		: in std_logic;
--	USB_CS_N	: out std_logic;
	-- uBUS
--	AP		: inout std_logic;
--	AN		: inout std_logic;
--	BP		: in std_logic;
--	BN		: in std_logic;
--	CP		: in std_logic;
--	CN		: in std_logic);
end test_top;


architecture rtl of test_top is

signal clk_bus		: std_logic;
signal clk_hdmi		: std_logic;
signal clk_vga		: std_logic;

signal areset		: std_logic := '1';
signal reset		: std_logic;
signal locked		: std_logic;

-- CPU
signal cpu_clken	: std_logic;
signal cpu_int		: std_logic;
signal cpu_di		: std_logic_vector(7 downto 0);
signal cpu_do		: std_logic_vector(7 downto 0);
signal cpu_addr		: std_logic_vector(15 downto 0);
signal cpu_wr		: std_logic;
signal cpu_mreq		: std_logic;
signal cpu_iorq		: std_logic;
signal cpu_m1		: std_logic;
signal cpu_inta		: std_logic;
-- Video
signal vram_wr		: std_logic;
signal vram_do		: std_logic_vector(7 downto 0);
signal red			: std_logic_vector(7 downto 0);
signal green		: std_logic_vector(7 downto 0);
signal blue			: std_logic_vector(7 downto 0);
signal blank		: std_logic;
signal hsync		: std_logic;
signal vsync		: std_logic;
signal char_addr	: std_logic_vector(11 downto 0);
signal char_data	: std_logic_vector(15 downto 0);
signal font_addr	: std_logic_vector(11 downto 0);
signal font_data	: std_logic_vector(7 downto 0);
signal txt_int		: std_logic;
signal hcnt			: std_logic_vector(9 downto 0);
signal vcnt			: std_logic_vector(9 downto 0);
signal hcnt_reg		: std_logic_vector(9 downto 0);
signal pixel_addr	: std_logic_vector(18 downto 0);

signal mux			: std_logic_vector(3 downto 0);
signal sdram_page_reg0	: std_logic_vector(7 downto 0);
signal sdram_page_reg1	: std_logic_vector(2 downto 0);

signal rom_do		: std_logic_vector(7 downto 0);
signal clk_cpu		: std_logic;
signal clk_test		: std_logic;


begin

-- PLL
pll_inst: entity work.pll0
port map (
	areset 			=> not USB_RESET_N,
	inclk0 			=> CLK,			--  50.0 MHz
	-- out
	locked 			=> locked,
	c0				=> clk_bus,		-- 100.0 MHz
	c1				=> clk_hdmi,	-- 125.0 MHz
	c2				=> clk_vga,		--  25.0 MHz
	c3				=> clk_cpu);	--  50.0 MHz
--	c4				=> DCLK);		-- 200.0 MHz 180'

-- VRAM 8K
vram_inst: entity work.m9k0
port map (
	clock_a			=> clk_bus,
	clock_b			=> clk_vga,
	enable_a		=> '1',
	enable_b		=> '1',
	wren_a			=> vram_wr,
	wren_b			=> '0',
	address_a		=> cpu_addr(12 downto 0),
	address_b		=> char_addr,
	data_a			=> cpu_do,
	data_b			=> x"ffff",
	-- out
	q_a				=> vram_do,
	q_b				=> char_data);

-- ROM 8K
rom_inst: entity work.m9k1
port map (
	clock	 		=> clk_bus,
	clken			=> '1',
	address	 		=> cpu_addr(12 downto 0),
	-- out
	q	 			=> rom_do);

-- CPU
cpu_inst: entity work.nz80cpu
port map (
	CLK				=> clk_cpu,
	CLKEN			=> '1',
	RESET			=> reset,
	NMI				=> '0',
	INT				=> cpu_int,
	DI				=> cpu_di,
	-- out
	DO				=> cpu_do,
	ADDR			=> cpu_addr,
	WR				=> cpu_wr,
	MREQ			=> cpu_mreq,
	IORQ			=> cpu_iorq,
	HALT			=> open,
	M1				=> cpu_m1);

-- HDMI
hdmi_inst: entity work.hdmi
port map (
	CLK_DVI			=> clk_hdmi,
	CLK_PIXEL		=> clk_vga,
	R				=> red,
	G				=> green,
	B				=> blue,
	BLANK			=> blank,
	HSYNC			=> hsync,
	VSYNC			=> vsync,
	-- out
	TMDS_D0			=> HDMI_D0,
	TMDS_D1			=> HDMI_D1,
	TMDS_D2			=> HDMI_D2,
	TMDS_CLK		=> HDMI_CLK);

vga_inst: entity work.vga
port map (
	CLK				=> clk_vga,
	CLKEN			=> '1',
	MODE			=> "10",			-- 00=TXT, 01=GRF, 10=GRF or TXT
	PIXEL_DI		=> pixel_addr(7 downto 0) & "00000000" & "00000000",
	CHAR_DI			=> char_data,
	CURSOR_X		=> "0011100",		-- 0..79
	CURSOR_Y		=> "00010",			-- 0..29
	CURSOR_COLOR	=> "11110000",		-- 7=type 0:big;1:small, 6..4=Paper(RGB), 3=Bright, 2..0=Ink(RGB)
	-- out
	INT				=> txt_int,
	PIXEL_ADDR		=> pixel_addr,
	CHAR_ADDR		=> char_addr,
	HSYNC			=> hsync,
	VSYNC			=> vsync,
	BLANK			=> blank,
	R				=> red,
	G				=> green,
	B				=> blue);



-- SDRAM Controller
--sdram_inst: entity work.sdram
--port map (
--	CLK			=> clk_sys,
--	A			=> sdram_page_reg1 & sdram_page_reg0 & cpu_addr(14 downto 0),
--	DI			=> cpu_do,
--	DO			=> sdram_do,
--	WR			=> sdram_wr,
--	RD			=> sdram_rd,
--	RFSH		=> sdram_rfsh,
--	RFSHREQ		=> sdram_rfshreq,
--	IDLE		=> sdram_idle,
--	--
--	CK			=> SDRAM_CLK,
--	RAS_n		=> SDRAM_RAS_N,
--	CAS_n		=> SDRAM_CAS_N,
--	WE_n		=> SDRAM_WE_N,
--	DQML		=> SDRAM_DQML,
--	DQMH		=> SDRAM_DQMH,
--	BA			=> SDRAM_BA,
--	MA			=> SDRAM_MA,
--	DQ			=> SDRAM_DQ);

-------------------------------------------------------------------------------

--reset <= not areset or not locked;

reset <= not locked;
vram_wr <= not cpu_addr(15) and not cpu_addr(14) and cpu_addr(13) and cpu_mreq and cpu_wr;


-- ����� ������
--
-- A15 A14 A13
-- 0   0   0	0000-1fff ( 8192) ROM
-- 0   0   1	2000-32bf ( 4800) ��������� ����� (������, ����, ������...)
-- 0   0   1	32c0-3fff ( 3392) RAM
-- 0   1   x	4000-7fff (16384) �� ������������
-- 1   x   x	8000-ffff (32768) SDRAM �������� (0..2047)

-- ����� �/�
--
-- �������� SDRAM:
-- #00	R/W	b7..0 = ����� �������� b7..0 SDRAM, ������������ � ������ 8000-ffff
-- #01	W	b2..0 = ����� �������� b10..8 SDRAM, ������������ � ������ 8000-ffff

process (mux, rom_do, vram_do, sdram_page_reg0, sdram_page_reg1)
begin			
	case mux is
		-- Memory
		when "0000" => cpu_di <= rom_do;
		when "0001" => cpu_di <= vram_do;
--		when "0010" => cpu_di <= sdram_do;
		-- Port
		when "0011" => cpu_di <= sdram_page_reg0;
		when "0100" => cpu_di <= "00000" & sdram_page_reg1;
		when others => cpu_di <= (others => '1');
	end case;
end process;

mux <= 	"0000" when cpu_addr(15 downto 13) = "000" and cpu_mreq = '1' and cpu_wr = '0' else
	"0001" when cpu_addr(15 downto 13) = "001" and cpu_mreq = '1' and cpu_wr = '0' else
	"0010" when cpu_addr(15) = '1' and cpu_mreq = '1' and cpu_wr = '0' else
	"0011" when cpu_addr(7 downto 0) = X"00" and cpu_iorq = '1' and cpu_wr = '0' else
	"0100" when cpu_addr(7 downto 0) = X"01" and cpu_iorq = '1' and cpu_wr = '0' else
	"1111";

-- CPU I/O
process (clk_bus, reset, cpu_addr, cpu_iorq, cpu_wr)
begin
	if reset = '1' then
		sdram_page_reg0 <= (others => '0');
		sdram_page_reg1 <= (others => '0');
	elsif clk_bus'event and clk_bus = '1' then
		if cpu_addr(7 downto 0) = X"00" and cpu_iorq = '1' and cpu_wr = '1' then sdram_page_reg0 <= cpu_do; end if;
		if cpu_addr(7 downto 0) = X"01" and cpu_iorq = '1' and cpu_wr = '1' then sdram_page_reg1 <= cpu_do(2 downto 0); end if;
	end if;
end process;
		
-- INTA
cpu_inta <= cpu_iorq and cpu_m1;

process (clk_bus, cpu_inta, txt_int)
begin
	if clk_bus'event and clk_bus = '1' then
		if cpu_inta = '1' then
			cpu_int <= '0';
		elsif txt_int = '1' then
			cpu_int <= '1';
		end if;
	end if;
end process;





end rtl;