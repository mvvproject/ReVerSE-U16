-------------------------------------------------------------------[02.06.2015]
-- U16-ZX48K T80CPU Version 1.0
-- DEVBOARD ReVerSE-U16
-------------------------------------------------------------------------------
-- Engineer: 	MVV
--
-- 02.06.2015	Initial release
--		CPU: T80@50MHz
--		RAM: M9K 64K (16K ROM + 48K RAM)
--		Video: HDMI 640x480@60Hz(ZX-Spectrum screen x2 = H:32+256+32; V=24+192+24)
--		Int: 60Hz (h_sync_on and v_sync_on)
--		Sound: Stereo (Delta-sigma)
--		Keyboard: USB HID Keyboard
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
	-- HDMI
	HDMI_D0		: out std_logic;
	HDMI_D1		: out std_logic;
	HDMI_D1N	: out std_logic := '0';
	HDMI_D2		: out std_logic;
	HDMI_CLK	: out std_logic;
	-- USB (VNC2)
	USB_NRESET	: in std_logic;
	USB_TX		: in std_logic;
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
signal cpu_en		: std_logic;
signal cpu_nmi		: std_logic;
-- Memory
signal ram_data_o	: std_logic_vector(7 downto 0);
signal ram_wr		: std_logic;
-- Port
signal port_xxfe_reg	: std_logic_vector(7 downto 0);
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
-- CLOCK
signal clk_bus		: std_logic;
signal clk_vga		: std_logic;
signal clk_hdmi		: std_logic;
-- System
signal reset		: std_logic;
signal areset		: std_logic;
signal key_reset	: std_logic;
signal locked		: std_logic;
signal selector		: std_logic_vector(1 downto 0);
signal key_f		: std_logic_vector(12 downto 1);
signal key		: std_logic_vector(12 downto 1) := "000000000000";
signal inta		: std_logic;


begin

-- PLL
U0: entity work.altpll0
port map (
	areset		=> areset,
	locked		=> locked,
	inclk0		=> CLK_50MHZ,			--  50.0 MHz
	c0		=> clk_vga,			--  25.0 MHz
	c1		=> clk_bus,			-- 100.0 MHz
	c2		=> clk_hdmi);			-- 125.0 MHz

-- RAM 64K
U1: entity work.ram
port map (
	address_a	=> cpu_addr,
	address_b	=> "010" & vga_addr,
	clock_a		=> clk_bus,
	clock_b		=> clk_vga,
	data_a	 	=> cpu_data_o,
	data_b	 	=> (others => '0'),
	wren_a	 	=> ram_wr,
	wren_b	 	=> '0',
	q_a	 	=> ram_data_o,
	q_b	 	=> vga_data);
	
-- CPU
U2: entity work.T80CPU
port map (
	RESET_N_I	=> cpu_reset,
	CLK_N_I		=> clk_bus,
	CLKEN_I		=> cpu_en,
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
	RFSH_N_O	=> open,
	HALT_N_O	=> open,
	BUSAK_N_O	=> open);
	
-- Video
U3: entity work.vga
port map (
	CLK_I		=> clk_vga,
	DATA_I		=> vga_data,
	BORDER_I	=> port_xxfe_reg(2 downto 0),	-- Биты D0..D2 порта xxFE определяют цвет бордюра
	INT_O		=> vga_int,
	ADDR_O		=> vga_addr,
	BLANK_O		=> vga_blank,
	RGB_O		=> vga_rgb,			-- RRGGBB
	HSYNC_O		=> vga_hsync,
	VSYNC_O		=> vga_vsync);
	
-- Keyboard
U4: entity work.keyboard
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
U5: entity work.dac
port map (
	CLK_I  		=> clk_bus,
	RESET_I		=> areset,
	DAC_DATA_I	=> port_xxfe_reg(4) & '0',
	DAC_O		=> DAC_OUT_L);

-- Delta-Sigma
U6: entity work.dac
port map (
	CLK_I		=> clk_bus,
	RESET_I		=> areset,
	DAC_DATA_I	=> port_xxfe_reg(4) & '0',
	DAC_O		=> DAC_OUT_R);

-- HDMI
U7: entity work.hdmi
port map(
	CLK_DVI_I	=> clk_hdmi,
	CLK_PIXEL_I	=> clk_vga,
	R_I		=> vga_rgb(5 downto 4) & vga_rgb(5 downto 4) & vga_rgb(5 downto 4) & vga_rgb(5 downto 4),
	G_I		=> vga_rgb(3 downto 2) & vga_rgb(3 downto 2) & vga_rgb(3 downto 2) & vga_rgb(3 downto 2),
	B_I		=> vga_rgb(1 downto 0) & vga_rgb(1 downto 0) & vga_rgb(1 downto 0) & vga_rgb(1 downto 0),
	BLANK_I		=> vga_blank,
	HSYNC_I		=> vga_hsync,
	VSYNC_I		=> vga_vsync,
	TMDS_D0_O	=> HDMI_D0,
	TMDS_D1_O	=> HDMI_D1,
	TMDS_D2_O	=> HDMI_D2,
	TMDS_CLK_O	=> HDMI_CLK);


-------------------------------------------------------------------------------
-- Формирование глобальных сигналов
process (clk_bus)
begin
	if (clk_bus'event and clk_bus = '0') then
		cpu_en <= not cpu_en;
	end if;
end process;

process (clk_bus, inta)
begin
	if (inta = '0') then
		cpu_int <= '1';
	elsif (clk_bus'event and clk_bus = '1') then
		if (vga_int = '1') then cpu_int <= '0'; end if;
	end if;
end process;

areset		<= not USB_NRESET;			-- глобальный сброс
reset		<= areset or key_reset or not locked;	-- горячий сброс
cpu_reset	<= not(reset or kb_f_bus(4));		-- CPU сброс
inta		<= cpu_iorq or cpu_m1;			-- INTA
cpu_nmi		<= not(kb_f_bus(5));			-- NMI
ram_wr		<= '1' when (cpu_mreq = '0' and cpu_wr = '0' and cpu_addr(15 downto 14) /= "00") else '0';

-------------------------------------------------------------------------------
-- Регистры
process (reset, clk_bus, cpu_addr, port_xxfe_reg, cpu_wr, cpu_data_o)
begin
	if (clk_bus'event and clk_bus = '1') then
		if (cpu_iorq = '0' and cpu_wr = '0' and cpu_addr(7 downto 0) = X"FE") then port_xxfe_reg <= cpu_data_o; end if;
	end if;
end process;

-------------------------------------------------------------------------------
-- Функциональные клавиши Fx
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
process (selector, ram_data_o, kb_do_bus, kb_joy_bus)
begin
	case selector is
		when "00" => cpu_data_i <= ram_data_o;
		when "01" => cpu_data_i <= "111" & kb_do_bus;
		when "10" => cpu_data_i <= "000" & kb_joy_bus;
		when others  => cpu_data_i <= (others => '1');
	end case;
end process;

selector <=	"00" when (cpu_mreq = '0' and cpu_rd = '0') else					-- RAM
		"01" when (cpu_iorq = '0' and cpu_rd = '0' and cpu_addr(7 downto 0) = X"FE") else	-- Клавиатура, порт xxFE
		"10" when (cpu_iorq = '0' and cpu_rd = '0' and cpu_addr(7 downto 0) = X"1F") else	-- Joystick, порт xx1F
		(others => '1');

end rtl;