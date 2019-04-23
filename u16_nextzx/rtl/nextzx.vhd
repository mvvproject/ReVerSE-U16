-------------------------------------------------------------------[30.03.2016]
-- NextZX 48K
-- DEVBOARD ReVerSE-U16 Rev.C
-------------------------------------------------------------------------------
-- Engineer: 	MVV
--
-- 13.03.2016	Initial release
-- 29.03.2016	nZ80@42MHz, deserializer.vhd
-- 30.03.2016	SDRAM
-------------------------------------------------------------------------------
-- github.com/mvvproject/ReVerSE-U16
--
-- Copyright (c) 2016 MVV
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

entity nextzx is
port (
	-- Clock
	CLK_50MHZ	: in std_logic;	-- 50MHz
	-- HDMI
	HDMI_D0		: out std_logic;
	HDMI_D1		: out std_logic;
	HDMI_D1N	: out std_logic := '0';
	HDMI_D2		: out std_logic;
	HDMI_CLK	: out std_logic;
	-- USB VNC2
	USB_NRESET	: in std_logic;
	USB_TX		: in std_logic;
	USB_NCS		: out std_logic := '0';
	USB_SI		: in std_logic;
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
end nextzx;

architecture rtl of nextzx is

-- CPU
signal cpu_reset	: std_logic;
signal cpu_addr		: std_logic_vector(15 downto 0);
signal cpu_do		: std_logic_vector(7 downto 0);
signal cpu_di		: std_logic_vector(7 downto 0);
signal cpu_mreq		: std_logic;
signal cpu_iorq		: std_logic;
signal cpu_wr		: std_logic;
signal cpu_int		: std_logic;
signal cpu_m1		: std_logic;
signal cpu_wait		: std_logic;
signal cpu_nmi		: std_logic;
-- Memory
signal rom_do		: std_logic_vector(7 downto 0);
signal vram_wr		: std_logic;
-- Port
signal port_xxfe_reg	: std_logic_vector(7 downto 0);
-- Keyboard
signal kb_do_bus	: std_logic_vector(4 downto 0);
signal kb_fn_bus	: std_logic_vector(12 downto 1);
signal kb_joy_bus	: std_logic_vector(4 downto 0);
-- Video
signal vga_addr		: std_logic_vector(12 downto 0);
signal vga_data		: std_logic_vector(7 downto 0);
signal vga_wr		: std_logic;
signal vga_r		: std_logic_vector(1 downto 0);
signal vga_g		: std_logic_vector(1 downto 0);
signal vga_b		: std_logic_vector(1 downto 0);
signal sync_hcnt	: std_logic_vector(9 downto 0);
signal sync_vcnt	: std_logic_vector(9 downto 0);
signal sync_hsync	: std_logic;
signal sync_vsync	: std_logic;
signal sync_blank	: std_logic;
signal sync_int		: std_logic;
signal sync_flash	: std_logic;
-- CLOCK
signal clk_25m2hz	: std_logic;
signal clk_126m0hz	: std_logic;
-- System
signal reset		: std_logic;
signal areset		: std_logic;
signal locked		: std_logic;
signal selector		: std_logic_vector(1 downto 0);
signal key_f		: std_logic_vector(12 downto 1);
signal key		: std_logic_vector(12 downto 1) := "000000000000";
signal inta		: std_logic;
signal cnt		: std_logic_vector(2 downto 0) := "110";

signal sdram_do		: std_logic_vector(7 downto 0);
signal sdram_req	: std_logic := '0';
signal sdram_ack	: std_logic;
signal state		: std_logic_vector(1 downto 0) := "00";

begin

-- PLL
U0: entity work.altpll0
port map (
	areset		=> areset,
	locked		=> locked,
	inclk0		=> CLK_50MHZ,			--  50.0 MHz
	c0		=> clk_25m2hz,			--  25.2 MHz
	c1		=> clk_126m0hz);		-- 126.0 MHz

-- ROM 16K
U1: entity work.ram
port map (
	address_a	=> cpu_addr(13 downto 0),
	address_b	=> (others => '0'),
	clock_a		=> clk_126m0hz,
	clock_b		=> clk_126m0hz,
	data_a	 	=> (others => '0'),
	data_b	 	=> (others => '0'),
	wren_a	 	=> '0',
	wren_b	 	=> '0',
	q_a	 	=> rom_do,
	q_b	 	=> open);
	
-- CPU
U2: entity work.nz80cpu
port map (
	I_WAIT		=> cpu_wait,
	I_RESET		=> cpu_reset,
	I_CLK		=> clk_126m0hz,
	I_NMI		=> cpu_nmi,
	I_INT		=> cpu_int,
	I_DATA		=> cpu_di,
	O_DATA		=> cpu_do,
	O_ADDR		=> cpu_addr,
	O_M1		=> cpu_m1,
	O_MREQ		=> cpu_mreq,
	O_IORQ		=> cpu_iorq,
	O_WR		=> cpu_wr,
	O_HALT		=> open );

-- Video
U3: entity work.vga_zx
port map (
	I_CLK		=> clk_25m2hz,
	I_EN		=> '1',
	I_DATA		=> vga_data,
	I_BORDER	=> port_xxfe_reg(2 downto 0),	-- Биты D0..D2 порта xxFE определяют цвет бордюра
	I_HCNT		=> sync_hcnt,
	I_VCNT		=> sync_vcnt,
	I_BLANK		=> sync_blank,
	I_FLASH		=> sync_flash,
	O_ADDR		=> vga_addr,
	O_R		=> vga_r,
	O_G		=> vga_g,
	O_B		=> vga_b);

-- USB HID
U4: entity work.deserializer
generic map (
	divisor			=> 434)		-- divisor = 50MHz / 115200 Baud = 434
port map(
	I_CLK			=> CLK_50MHZ,
	I_RESET			=> areset,
	I_RX			=> USB_TX,
	I_NEWFRAME		=> USB_SI,
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
	O_KEYBOARD_SCAN		=> kb_do_bus,
	O_KEYBOARD_FKEYS	=> kb_fn_bus,
	O_KEYBOARD_JOYKEYS	=> kb_joy_bus,
	O_KEYBOARD_CTLKEYS	=> open);	
	
-- Delta-Sigma
U5: entity work.dac
port map (
	I_CLK		=> clk_126m0hz,
	I_RESET		=> areset,
	I_DAC_DATA	=> port_xxfe_reg(4) & '0',
	O_DAC		=> DAC_OUT_L);

-- Delta-Sigma
U6: entity work.dac
port map (
	I_CLK		=> clk_126m0hz,
	I_RESET		=> areset,
	I_DAC_DATA	=> port_xxfe_reg(4) & '0',
	O_DAC		=> DAC_OUT_R);

-- HDMI
U7: entity work.hdmi
port map(
	I_CLK_DVI	=> clk_126m0hz,
	I_CLK_PIXEL	=> clk_25m2hz,
	I_R		=> vga_r & vga_r & vga_r & vga_r,
	I_G		=> vga_g & vga_g & vga_g & vga_g,
	I_B		=> vga_b & vga_b & vga_b & vga_b,
	I_BLANK		=> sync_blank,
	I_HSYNC		=> sync_hsync,
	I_VSYNC		=> sync_vsync,
	O_TMDS_D0	=> HDMI_D0,
	O_TMDS_D1	=> HDMI_D1,
	O_TMDS_D2	=> HDMI_D2,
	O_TMDS_CLK	=> HDMI_CLK);

-- Sync 640x480@60Hz Pixelclock=25.2MHz
U8: entity work.sync
port map (
	I_CLK		=> clk_25m2hz,
	I_EN		=> '1',
	O_HCNT		=> sync_hcnt,
	O_HCNT_REG	=> open,
	O_VCNT		=> sync_vcnt,
	O_INT		=> sync_int,
	O_FLASH		=> sync_flash,
	O_BLANK		=> sync_blank,
	O_HSYNC		=> sync_hsync,
	O_VSYNC		=> sync_vsync);
	
U9: entity work.sdram
port map (
	I_CLK		=> clk_126m0hz,
	I_RESET		=> areset,
	I_WR		=> cpu_wr,
	I_REQ	 	=> sdram_req,
	I_ADDR		=> "000000000" & cpu_addr,
	I_DATA		=> cpu_do,
	O_DATA	 	=> sdram_do,
	O_ACK	 	=> sdram_ack,
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
U10: entity work.vram
port map (
	address_a	=> cpu_addr(12 downto 0),
	address_b	=> vga_addr,
	clock_a		=> clk_126m0hz,
	clock_b		=> clk_25m2hz,
	data_a	 	=> cpu_do,
	data_b	 	=> (others => '0'),
	wren_a	 	=> vram_wr,
	wren_b	 	=> '0',
	q_a	 	=> open,
	q_b	 	=> vga_data);

-------------------------------------------------------------------------------
-- Формирование глобальных сигналов
process (sync_int, inta)
begin
	if inta = '1' then
		cpu_int <= '0';
	elsif sync_int'event and sync_int = '1' then
		cpu_int <= '1';
	end if;
end process;

areset		<= not USB_NRESET;			-- глобальный сброс
reset		<= areset or not locked;		-- горячий сброс
cpu_reset	<= reset or kb_fn_bus(4);		-- CPU сброс
inta		<= cpu_iorq and cpu_m1;			-- INTA
cpu_nmi		<= kb_fn_bus(5);			-- NMI

vram_wr		<= '1' when cpu_mreq = '1' and cpu_wr = '1' and cpu_addr(15 downto 13) = "010" and cnt(2) = '0' else '0';


cpu_wait <= cnt(2);


process (clk_126m0hz)
begin
	if clk_126m0hz'event and clk_126m0hz = '1' then
		case state is
			when "00" =>
				if cpu_mreq = '1' and cpu_addr(15 downto 14) /= "00" then 
					sdram_req <= '1';
					state <= "01";
					cnt <= "111";
				else
					cnt <= cnt(1 downto 0) & cnt(2);
				end if;
			when "01" =>
				if sdram_ack = '1' then
					sdram_req <= '0';
					state <= "10";
				end if;
			when "10" =>
				if sdram_ack = '0' then
					state <= "11";
					cnt <= "011";
				end if;
			when "11" =>
				cnt <= "110";
				state <= "00";
			when others => null;
		end case;
	end if;
end process;
	
	
-------------------------------------------------------------------------------
-- Регистры
process (reset, clk_126m0hz, cpu_addr, port_xxfe_reg, cpu_wr, cpu_do)
begin
	if clk_126m0hz'event and clk_126m0hz = '1' then
		if cpu_iorq = '1' and cpu_wr = '1' and cpu_addr(7 downto 0) = X"FE" then port_xxfe_reg <= cpu_do; end if;
	end if;
end process;

-------------------------------------------------------------------------------
-- Функциональные клавиши Fx
process (clk_126m0hz, key, kb_fn_bus, key_f)
begin
	if clk_126m0hz'event and clk_126m0hz = '1' then
		key <= kb_fn_bus;
		if kb_fn_bus /= key then
			key_f <= key_f xor key;
		end if;
	end if;
end process;

-------------------------------------------------------------------------------
-- Шина данных CPU
process (selector, rom_do, sdram_do, kb_do_bus, kb_joy_bus)
begin
	case selector is
		when "00" => cpu_di <= rom_do;
		when "01" => cpu_di <= sdram_do;
		when "10" => cpu_di <= "111" & kb_do_bus;
		when "11" => cpu_di <= "000" & kb_joy_bus;
		when others => cpu_di <= (others => '1');
	end case;
end process;

selector <=	"00" when cpu_mreq = '1' and cpu_wr = '0' and cpu_addr(15 downto 14) = "00" else	-- ROM
		"01" when cpu_mreq = '1' and cpu_wr = '0' and cpu_addr(15 downto 14) /= "00" else	-- SDRAM
		"10" when cpu_iorq = '1' and cpu_wr = '0' and cpu_addr(7 downto 0) = X"FE" else		-- Клавиатура, порт xxFE
		"11" when cpu_iorq = '1' and cpu_wr = '0' and cpu_addr(7 downto 0) = X"1F" else		-- Joystick, порт xx1F
		(others => '1');

end rtl;