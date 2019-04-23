-------------------------------------------------------------------[22.06.2015]
-- U16-ZX128K Version 2.0
-- DEVBOARD ReVerSE-U16
-------------------------------------------------------------------------------
-- Engineer: 	MVV
--
-- 07.06.2015	Initial release
--		CPU: T80@3.5MHz
--		RAM: M9K 56K (32K ROM + 8K ROM + 16K RAM)
--		SDRAM: 640K (128K + 512K)
--		Video: HDMI 640x480@60Hz(ZX-Spectrum screen x2 = H:32+256+32; V=24+192+24)
--		Int: 60Hz (h_sync_on and v_sync_on)
--		Sound: Stereo (Delta-sigma) AY3-8910 + Beeper
--		Keyboard: USB HID Keyboard (F4=CPU Reset, F5=NMI, ScrollLock=Hard Reset)
--		DivMMC: 512K (Press Space+F5+F4 to initial, F5=Go to ESXDOS)
-------------------------------------------------------------------------------
-- github.com/mvvproject/ReVerSE-U16
--
-- Copyright (c) 2015 MVV
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

entity zx is
port (
	-- Clock (50MHz)
	CLK_50MHZ	: in std_logic;
	-- USB (VNC2)
	USB_NRESET	: in std_logic;
	USB_TX		: in std_logic;
	-- SDRAM
	DRAM_DQ		: inout std_logic_vector(15 downto 0);
	DRAM_A		: out std_logic_vector(12 downto 0);
	DRAM_CLK	: out std_logic;
	DRAM_NCAS	: out std_logic;
	DRAM_NRAS	: out std_logic;
	DRAM_BA		: out std_logic_vector(1 downto 0);
	DRAM_NWE	: out std_logic;
	DRAM_DQM	: out std_logic_vector(1 downto 0);
	-- HDMI
	HDMI_D0		: out std_logic;
	HDMI_D1		: out std_logic;
	HDMI_D1N	: out std_logic := '0';
	HDMI_D2		: out std_logic;
	HDMI_CLK	: out std_logic;
	-- SD
	SD_SO		: in std_logic;
	SD_CLK		: out std_logic;
	SD_SI		: out std_logic;
	SD_NCS		: out std_logic;
	-- Audio (Delta-sigma)
	DAC_OUT_L	: out std_logic;
	DAC_OUT_R	: out std_logic);
end zx;

architecture rtl of zx is

-- CPU
signal cpu_reset	: std_logic;
signal cpu_addr		: std_logic_vector(15 downto 0);
signal cpu_data_o	: std_logic_vector(7 downto 0);
signal cpu_data_i	: std_logic_vector(7 downto 0);
signal cpu_mreq		: std_logic;
signal cpu_iorq		: std_logic;
signal cpu_wr		: std_logic;
signal cpu_rd		: std_logic;
signal cpu_int		: std_logic;
signal cpu_m1		: std_logic;
signal cpu_nmi		: std_logic;
signal cpu_rfsh		: std_logic;
-- Memory
signal rom0_data_o	: std_logic_vector(7 downto 0);
signal rom1_data_o	: std_logic_vector(7 downto 0);
signal ram_addr		: std_logic_vector(11 downto 0);
signal mux		: std_logic_vector(3 downto 0);
-- Port
signal port_xxfe_reg	: std_logic_vector(7 downto 0);
signal port_7ffd_reg	: std_logic_vector(7 downto 0);
-- PS/2 Keyboard
signal kb_do_bus	: std_logic_vector(4 downto 0);
signal kb_f_bus		: std_logic_vector(12 downto 1);
signal kb_joy_bus	: std_logic_vector(4 downto 0);
-- Video
signal vga_addr		: std_logic_vector(12 downto 0);
signal vga_data		: std_logic_vector(7 downto 0);
signal vga_wr		: std_logic;
signal vga_hsync	: std_logic;
signal vga_vsync	: std_logic;
signal vga_blank	: std_logic;
signal vga_rgb		: std_logic_vector(5 downto 0);
signal vga_int		: std_logic;
signal vga_hcnt		: std_logic_vector(9 downto 0);
signal vram_wr		: std_logic;
signal vram_scr		: std_logic;
-- Clock
signal clk_bus		: std_logic;
signal clk_vga		: std_logic;
signal clk_hdmi		: std_logic;
signal clk_cpu		: std_logic;
signal clk_divmmc	: std_logic;
signal clk_ssg		: std_logic;
-- System
signal reset		: std_logic;
signal areset		: std_logic;
signal key_reset	: std_logic;
signal locked0		: std_logic;
signal locked1		: std_logic;
signal selector		: std_logic_vector(3 downto 0);
signal key_f		: std_logic_vector(12 downto 1);
signal key		: std_logic_vector(12 downto 1) := "000000000000";
signal inta		: std_logic;
-- SDRAM
signal sdram_wr		: std_logic;
signal sdram_rd		: std_logic;
signal sdram_data_o	: std_logic_vector(7 downto 0);
-- DivMMC
signal divmmc_data_o	: std_logic_vector(7 downto 0);
signal divmmc_e3reg	: std_logic_vector(7 downto 0);
signal divmmc_amap	: std_logic;
-- SSG
signal ssg_bdir		: std_logic;
signal ssg_bc		: std_logic;
signal ssg_data_o	: std_logic_vector(7 downto 0);
signal ssg_ch_a		: std_logic_vector(7 downto 0);
signal ssg_ch_b		: std_logic_vector(7 downto 0);
signal ssg_ch_c		: std_logic_vector(7 downto 0);
signal dac_left		: std_logic_vector(8 downto 0);
signal dac_right	: std_logic_vector(8 downto 0);

signal ecc		: std_logic_vector(7 downto 0);

begin

-- PLL
U0: entity work.altpll0
port map (
	areset		=> areset,
	locked		=> locked0,
	inclk0		=> CLK_50MHZ,	-- 50.0 MHz
	c0		=> clk_vga,	-- 25.0 MHz
	c1		=> clk_hdmi);	-- 125.0 MHz
	
U1: entity work.altpll1
port map (
	areset		=> areset,
	locked		=> locked1,
	inclk0		=> CLK_50MHZ,	-- 50.0MHz
	c0		=> clk_bus,	-- 84.0MHz
	c1		=> clk_cpu,	-- 3.5MHz
	c2		=> clk_divmmc,	-- 28.0MHz
	c3		=> clk_ssg);	-- 1.75MHz

-- ROM 32K
U2: entity work.rom0
port map (
	address		=> port_7ffd_reg(4) & cpu_addr(13 downto 0),
	clock		=> clk_bus,
	q	 	=> rom0_data_o);

-- Video RAM 16K
U3: entity work.ram
port map (
	address_a	=> vram_scr & cpu_addr(12 downto 0),
	address_b	=> port_7ffd_reg(3) & vga_addr,
	clock_a		=> clk_bus,
	clock_b		=> clk_vga,
	data_a	 	=> cpu_data_o,
	data_b	 	=> (others => '0'),
	wren_a	 	=> vram_wr,
	wren_b	 	=> '0',
	q_a	 	=> open,
	q_b	 	=> vga_data);
	
-- CPU
U4: entity work.T80CPU
port map (
	RESET_N_I	=> cpu_reset,
	CLK_N_I		=> clk_cpu,
	CLKEN_I		=> '1',
	WAIT_N_I	=> '1',
	INT_N_I		=> cpu_int,
	NMI_N_I		=> cpu_nmi,
	BUSRQ_N_I	=> '1',
	DATA_I		=> cpu_data_i,
	DATA_O		=> cpu_data_o,
	ADDR_O		=> cpu_addr,
	M1_N_O		=> cpu_m1,
	MREQ_N_O	=> cpu_mreq,
	IORQ_N_O	=> cpu_iorq,
	RD_N_O		=> cpu_rd,
	WR_N_O		=> cpu_wr,
	RFSH_N_O	=> cpu_rfsh,
	HALT_N_O	=> open,
	BUSAK_N_O	=> open);
	
-- Video
U5: entity work.vga
port map (
	CLK_I		=> clk_vga,
	DATA_I		=> vga_data,
	BORDER_I	=> port_xxfe_reg(2 downto 0),	-- Биты D0..D2 порта xxFE определяют цвет бордюра
	INT_O		=> vga_int,
	ADDR_O		=> vga_addr,
	BLANK_O		=> vga_blank,
	RGB_O		=> vga_rgb,	-- RRGGBB
	HCNT_O		=> vga_hcnt,
	HSYNC_O		=> vga_hsync,
	VSYNC_O		=> vga_vsync);
	
-- Keyboard
U6: entity work.keyboard
port map(
	CLK_I		=> clk_bus,
	RESET_I		=> areset,
	ADDR_I		=> cpu_addr(15 downto 8),
	KEYB_O		=> kb_do_bus,
	KEYF_O		=> kb_f_bus,
	KEYJOY_O	=> kb_joy_bus,
	KEYRESET_O	=> key_reset,
	RX_I		=> USB_TX);
	
-- Delta-Sigma
U7: entity work.dac
port map (
	CLK_I  		=> clk_bus,
	RESET_I		=> areset,
	DAC_DATA_I	=> dac_left,
	DAC_O		=> DAC_OUT_L);

-- Delta-Sigma
U8: entity work.dac
port map (
	CLK_I		=> clk_bus,
	RESET_I		=> areset,
	DAC_DATA_I	=> dac_right,
	DAC_O		=> DAC_OUT_R);

-- HDMI
U9: entity work.hdmi
port map(
	CLK_DVI_I	=> clk_hdmi,
	CLK_PIXEL_I	=> clk_vga,
	R_I		=> vga_rgb(5 downto 4) & vga_rgb(5 downto 4) & vga_rgb(5 downto 4) & vga_rgb(5 downto 4),
	G_I		=> vga_rgb(3 downto 2) & vga_rgb(3 downto 2) & vga_rgb(3 downto 2) & vga_rgb(3 downto 2),
	B_I		=> vga_rgb(1 downto 0) & vga_rgb(1 downto 0) & vga_rgb(1 downto 0) & vga_rgb(1 downto 0),
	BLANK_I		=> vga_blank,
	HSYNC_I		=> vga_hsync,
	VSYNC_I		=> vga_vsync,
	HB_I		=>
-- Packets header 2:
			  X"4A" & X"00" & X"00" & X"01" &	-- ECC(31..24), HB2(23..16), HB1(15..8), HB0(7..0)
-- Packets header 1:			   
-- 00000000 HB0 Packet Type = 0x02
-- 00000000 HB1 0 0 0 layout sample_present.sp3 sample_present.sp2 sample_present.sp1 sample_present.sp0
-- 00000000 HB2 B.3 B.2 B.1 B.0 sample_flat.sp3 sample_flat.sp2 sample_flat.sp1 sample_flat.sp0
-- 00000000 ECC
			   X"D6" & X"10" & X"01" & X"02" &	-- ECC(31..24), HB2(23..16), HB1(15..8), HB0(7..0)
-- Packets header 0:
-- 00000000 HB0 Packet Type = 0x84
-- 00000000 HB1 Version Number = 0x01
-- 00000000 HB2 Length = 0x0A
-- 00000000 ECC (0x4A)
			   X"4A" & X"0A" & X"01" & X"84",	-- ECC(31..24), HB2(23..16), HB1(15..8), HB0(7..0)
	PB_I		=>
-- Packets 2:
			   X"00" & X"00" & X"00" & X"00" & X"00" & X"00" & X"00" & X"00" &	-- ECC(255..248),PB27(247..240),PB26(239..232),PB25(231..224),PB24(223..216),PB23(215..208),PB22(207..200),PB21(199..192)
			   X"00" & X"00" & X"00" & X"00" & X"00" & X"00" & X"00" & X"00" &	-- ECC(191..184),PB20(183..176),PB19(175..168),PB18(167..160),PB17(159..152),PB16(151..144),PB15(143..136),PB14(135..128)
			   X"8A" & X"00" & X"18" & X"00" & X"18" & X"44" & X"02" & X"00" &	-- ECC(127..120),PB13(119..112),PB12(111..104),PB11(103..96),PB10(95..88),PB9(87..80),PB8(79..72),PB7(71..64)
			   X"8A" & X"00" & X"18" & X"00" & X"18" & X"44" & X"02" & X"00" &	-- ECC(63..56),PB6(55..48),PB5(47..40),PB4(39..32),PB3(31..24),PB2(23..16),PB1(15..8),PB0(7..0)
			   
-- Packets 1:
--               | 7      | 6    | 5    | 4    | 3    | 2   | 1   | 0    |
-- 00000000 SB0  | L.11   |      |      |      |      |     |     | L.4  |
-- 00000000 SB1  | L.19   |      |      |      |      |     |     | L.12 |
-- 00000000 SB2  | L.27   |      |      |      |      |     |     | L.20 |
-- 00000000 SB3  | R.11   |      |      |      |      |     |     | R.4  |
-- 00000000 SB4  | R.19   |      |      |      |      |     |     | R.12 |
-- 00000000 SB5  | R.27   |      |      |      |      |     |     | R.20 |
-- 00000000 SB6  | Pr     | Cr   | Ur   | Vr   | Pl   | Cl  | Ul  | Vl   |
			   X"00" & X"00" & X"00" & X"00" & X"00" & X"00" & X"00" & X"00" &	-- ECC(255..248),PB27(247..240),PB26(239..232),PB25(231..224),PB24(223..216),PB23(215..208),PB22(207..200),PB21(199..192)
			   X"00" & X"00" & X"00" & X"00" & X"00" & X"00" & X"00" & X"00" &	-- ECC(191..184),PB20(183..176),PB19(175..168),PB18(167..160),PB17(159..152),PB16(151..144),PB15(143..136),PB14(135..128)
			   X"00" & X"00" & X"00" & X"00" & X"00" & X"00" & X"00" & X"00" &	-- ECC(127..120),PB13(119..112),PB12(111..104),PB11(103..96),PB10(95..88),PB9(87..80),PB8(79..72),PB7(71..64)
			   ecc   & X"4B" & X"00" & X"00" & X"00" & X"00" & port_xxfe_reg(4) & "0000000" & X"00" &	-- ECC(63..56),PB6(55..48),PB5(47..40),PB4(39..32),PB3(31..24),PB2(23..16),PB1(15..8),PB0(7..0)
-- Packets 0:
--               | 7      | 6    | 5    | 4    | 3    | 2   | 1   | 0   |
-- 00000000 PB0  | Checksum                                             |	00 - (84+01+0A + 81) = F0
-- 00000000 PB1  | CT3    | CT2  | CT1  | CT0  | Rsvd | CC2 | CC1 | CC0 |
-- 00000000 PB2  | Reserved (0)         | SF2  | SF1  | SF0 | SS1 | SS0 |
-- 00000000 PB3  | Format depends on coding type (i.e. CT0CT3)          |	Data Byte 3 shall always be set to a value of 0.
-- 00000000 PB4  | CA7    | CA6  | CA5  | CA4  | CA3  | CA2 | CA1 | CA0 |
-- 00000000 PB5  | DM_INH | LSV3 | LSV2 | LSV1 | LSV0 | Reserved (0)    |
-- 00000000 PB6- | Reserved (0)                                         |
-- 00000000 PB27 | Reserved (0)                                         |
			   X"00" & X"00" & X"00" & X"00" & X"00" & X"00" & X"00" & X"00" &	-- ECC(255..248),PB27(247..240),PB26(239..232),PB25(231..224),PB24(223..216),PB23(215..208),PB22(207..200),PB21(199..192)
			   X"00" & X"00" & X"00" & X"00" & X"00" & X"00" & X"00" & X"00" &	-- ECC(191..184),PB20(183..176),PB19(175..168),PB18(167..160),PB17(159..152),PB16(151..144),PB15(143..136),PB14(135..128)
			   X"00" & X"00" & X"00" & X"00" & X"00" & X"00" & X"00" & X"00" &	-- ECC(127..120),PB13(119..112),PB12(111..104),PB11(103..96),PB10(95..88),PB9(87..80),PB8(79..72),PB7(71..64)
			   X"7D" & X"00" & X"00" & X"00" & X"00" & X"00" & X"01" & X"70",	-- ECC(63..56),PB6(55..48),PB5(47..40),PB4(39..32),PB3(31..24),PB2(23..16),PB1(15..8),PB0(7..0)
	HCNT_I		=> vga_hcnt,
	TMDS_D0_O	=> HDMI_D0,
	TMDS_D1_O	=> HDMI_D1,
	TMDS_D2_O	=> HDMI_D2,
	TMDS_CLK_O	=> HDMI_CLK);

-- SDRAM
U10: entity work.sdram
port map(
	CLK_I		=> clk_bus,
	ADDR_I		=> ram_addr & cpu_addr(12 downto 0),
	DATA_I		=> cpu_data_o,
	DATA_O		=> sdram_data_o,
	WR_I		=> sdram_wr,
	RD_I		=> sdram_rd,
	RFSH_I		=> not(cpu_rfsh),
	IDLE_O		=> open,
	CLK_O		=> DRAM_CLK,
	RAS_O		=> DRAM_NRAS,
	CAS_O		=> DRAM_NCAS,
	WE_O		=> DRAM_NWE,
	DQM_O		=> DRAM_DQM,
	BA_O		=> DRAM_BA,
	MA_O		=> DRAM_A,
	DQ_IO		=> DRAM_DQ);

-- ROM DivMMC 8K
U11: entity work.rom1
port map (
	address		=> cpu_addr(12 downto 0),
	clock		=> clk_bus,
	q	 	=> rom1_data_o);

-- DivMMC
U12: entity work.divMMC
port map (
	CLK_I		=> clk_divmmc,
	EN_I		=> port_7ffd_reg(4),
	RESET_I		=> reset,
	ADDR_I		=> cpu_addr,
	DATA_I		=> cpu_data_o,
	DATA_O		=> divmmc_data_o,
	WR_N_I		=> cpu_wr,
	RD_N_I		=> cpu_rd,
	IORQ_N_I	=> cpu_iorq,
	MREQ_N_I	=> cpu_mreq,
	M1_N_I		=> cpu_m1,
	E3REG_O		=> divmmc_e3reg,
	AMAP_O		=> divmmc_amap,
	CS_N_O		=> SD_NCS,
	SCLK_O		=> SD_CLK,
	MOSI_O		=> SD_SI,
	MISO_I		=> SD_SO);

-- SSG
U13: entity work.ay8910
port map (
	CLK_I   	=> clk_ssg,
	EN_I   		=> '1',
	RESET_I 	=> reset,
	BDIR_I  	=> ssg_bdir,
	CS_I    	=> '1',
	BC_I    	=> ssg_bc,
	DATA_I    	=> cpu_data_o,
	DATA_O		=> ssg_data_o,
	CH_A_O		=> ssg_ch_a,
	CH_B_O		=> ssg_ch_b,
	CH_C_O		=> ssg_ch_c);
	
-------------------------------------------------------------------------------
-- Формирование глобальных сигналов
process (clk_bus, inta)
begin
	if (inta = '0') then
		cpu_int <= '1';
	elsif (clk_bus'event and clk_bus = '1') then
		if (vga_int = '1') then cpu_int <= '0'; end if;
	end if;
end process;

areset    <= not USB_NRESET;	-- глобальный сброс
reset     <= areset or key_reset or not locked0 or not locked1;	-- горячий сброс
cpu_reset <= not(reset or kb_f_bus(4));	-- CPU сброс
inta      <= cpu_iorq or cpu_m1;	-- INTA
cpu_nmi   <= not(kb_f_bus(5));	-- NMI

-------------------------------------------------------------------------------
-- Video
vram_scr <= '1' when (ram_addr = "000000001110") else '0';
vram_wr  <= '1' when (cpu_mreq = '0' and cpu_wr = '0' and ((ram_addr = "000000001010") or (ram_addr = "000000001110"))) else '0';

-------------------------------------------------------------------------------
-- Регистры
process (reset, clk_bus, cpu_addr, port_7ffd_reg, cpu_wr, cpu_data_o)
begin
	if (reset = '1') then
		port_7ffd_reg <= (others => '0');
	elsif (clk_bus'event and clk_bus = '1') then
		if (cpu_iorq = '0' and cpu_wr = '0' and cpu_addr = X"7FFD" and port_7ffd_reg(5) = '0') then port_7ffd_reg <= cpu_data_o; end if;	-- D7-D6=не используются; D5=запрещение расширенной памяти (48K защёлка); D4=номер страницы ПЗУ(0-BASIC128, 1-BASIC48); D3=выбор отображаемой видеостраницы(0-страница в банке 5, 1 - в банке 7); D2-D0=номер страницы ОЗУ подключенной в верхние 16 КБ памяти (с адреса #C000)
	end if;
end process;

process (clk_bus, cpu_addr, port_xxfe_reg, cpu_wr, cpu_data_o)
begin
	if (clk_bus'event and clk_bus = '1') then
		if (cpu_iorq = '0' and cpu_wr = '0' and cpu_addr(7 downto 0) = X"FE") then port_xxfe_reg <= cpu_data_o; end if;	-- D7-D5=не используются; D4=бипер; D3=MIC; D2-D0=цвет бордюра
	end if;
end process;

-------------------------------------------------------------------------------
-- Функциональные клавиши Fx триггер
process (clk_bus, key, kb_f_bus, key_f)
begin
	if (clk_bus'event and clk_bus = '1') then
		key <= kb_f_bus;
		if (kb_f_bus /= key) then
			key_f <= key_f xor key;
		end if;
	end if;
end process;

-------------------------------------------------------------------------------
-- Шина данных CPU
selector <=	"0000" when (cpu_mreq = '0' and cpu_rd = '0' and cpu_addr(15 downto 14) = "00"  and divmmc_amap = '0' and divmmc_e3reg(7) = '0') else	-- ROM 0000-3FFF
		"0001" when (cpu_mreq = '0' and cpu_rd = '0' and cpu_addr(15 downto 13) = "000" and (divmmc_amap or divmmc_e3reg(7)) /= '0') else	-- ESXDOS ROM 0000-1FFF
		"0010" when (cpu_mreq = '0' and cpu_rd = '0') else	-- SDRAM
		
		"0011" when (cpu_iorq = '0' and cpu_rd = '0' and cpu_addr(7 downto 0) = X"FE") else	-- Клавиатура, порт xxFE
		"0100" when (cpu_iorq = '0' and cpu_rd = '0' and cpu_addr(7 downto 0) = X"1F") else	-- Joystick, порт xx1F
		"0101" when (cpu_iorq = '0' and cpu_rd = '0' and cpu_addr = X"7FFD") else	-- чтение порта 7FFD
		"0110" when (cpu_iorq = '0' and cpu_rd = '0' and cpu_addr(7 downto 0) = X"EB") else	-- DivMMC
		"0111" when (cpu_iorq = '0' and cpu_rd = '0' and cpu_addr = X"FFFD") else	-- TurboSound
		(others => '1');

process (selector, ssg_data_o, sdram_data_o, rom0_data_o, rom1_data_o, kb_do_bus, kb_joy_bus, port_7ffd_reg, divmmc_data_o)
begin
	case selector is
		when "0000" => cpu_data_i <= rom0_data_o;	-- ROM
		when "0001" => cpu_data_i <= rom1_data_o;	-- ESXDOS ROM
		when "0010" => cpu_data_i <= sdram_data_o;	-- SDRAM
		when "0011" => cpu_data_i <= "111" & kb_do_bus;	-- D7=не используется; D6=EAR; D5=не используется; D4-D0=отображают состояние определённого полуряда клавиатуры
		when "0100" => cpu_data_i <= "000" & kb_joy_bus;	-- D7-D5=0; D4=огонь;  D3=вниз; D2=вверх; D1=вправо; D0=влево
		when "0101" => cpu_data_i <= port_7ffd_reg;
		when "0110" => cpu_data_i <= divmmc_data_o;
		when "0111" => cpu_data_i <= ssg_data_o;
		when others  => cpu_data_i <= (others => '1');
	end case;
end process;

------------------------------------------------------------------------------
-- Селектор
mux <= (divmmc_amap or divmmc_e3reg(7)) & cpu_addr(15 downto 13);

process (mux, port_7ffd_reg, ram_addr, divmmc_e3reg)
begin
	case mux is
		when "1001"        => ram_addr <= "000001" & divmmc_e3reg(5 downto 0);	-- ESXDOS RAM 2000-3FFF
		when "0010"|"1010" => ram_addr <= "000000001010";	-- Seg1 RAM 4000-5FFF
		when "0011"|"1011" => ram_addr <= "000000001011";	-- Seg1 RAM 6000-7FFF
		when "0100"|"1100" => ram_addr <= "000000000100";	-- Seg2 RAM 8000-9FFF
		when "0101"|"1101" => ram_addr <= "000000000101";	-- Seg2 RAM A000-BFFF
		when "0110"|"1110" => ram_addr <= "00000000" & port_7ffd_reg(2 downto 0) & '0';	-- Seg3 RAM C000-DFFF
		when "0111"|"1111" => ram_addr <= "00000000" & port_7ffd_reg(2 downto 0) & '1';	-- Seg3 RAM E000-FFFF
		when others => ram_addr <= "XXXXXXXXXXXX";
	end case;
end process;

-------------------------------------------------------------------------------
-- SDRAM
sdram_wr <= '1' when (cpu_mreq = '0' and cpu_wr = '0' and (mux(3 downto 1) /= "000" or mux /= "1000")) else '0';
sdram_rd <= '1' when (cpu_mreq = '0' and cpu_rd = '0' and (mux(3 downto 1) /= "000" or mux /= "1000")) else '0';

-------------------------------------------------------------------------------
-- SSG
ssg_bc   <= '1' when (cpu_iorq = '0' and cpu_addr(15 downto 14) = "11" and cpu_addr(1) = '0' and cpu_m1 = '1') else '0';
ssg_bdir <= '1' when (cpu_iorq = '0' and cpu_addr(15) = '1' and cpu_addr(1) = '0' and cpu_m1 = '1' and cpu_wr = '0') else '0';

dac_left  <= ('0' & ssg_ch_a) + ('0' & ssg_ch_b) + ('0' & port_xxfe_reg(4) & "000000");
dac_right <= ('0' & ssg_ch_c) + ('0' & ssg_ch_b) + ('0' & port_xxfe_reg(4) & "000000");

ecc <= X"00" when port_xxfe_reg(4) = '0' else X"32";

end rtl;