-------------------------------------------------------------------[14.07.2014]
-- VIDEO Pentagon or Spectrum mode
-------------------------------------------------------------------------------
-- V0.1 	05.10.2011	первая версия
-- V0.2 	11.10.2011	RGB, CLKEN
-- V0.3 	19.12.2011	INT
-- V0.4 	20.05.2013	изменены параметры растра для режима Video 15КГц
-- V0.5 	20.07.2013	изменено формирование сигнала INT, FLASH
-- V0.6		09.03.2014	изменены параметры для режима pentagon 48K, добавлена рамка
-- V0.7		14.07.2014	добавлен сигнал BLANK

library IEEE; 
use IEEE.std_logic_1164.all; 
use IEEE.numeric_std.ALL;
use IEEE.std_logic_unsigned.all;

entity video is
	port (
		CLK		: in std_logic;							-- системная частота
		ENA		: in std_logic_vector(1 downto 0);
		INTA	: in std_logic;
		INT		: out std_logic;
		BORDER	: in std_logic_vector(2 downto 0);		-- цвет бордюра (порт #xxFE)
		BORDON	: out std_logic;
		ATTR	: out std_logic_vector(7 downto 0);
		A		: out std_logic_vector(12 downto 0);
		DI		: in std_logic_vector(7 downto 0);
		MODE	: in std_logic_vector(1 downto 0);		-- ZX видео режим 0: Spectrum; 1: Pentagon
		BLANK	: out std_logic;						-- BLANK
		RGB		: out std_logic_vector(5 downto 0);		-- RRGGBB
		HSYNC	: out std_logic;
		VSYNC	: out std_logic);
end entity;

architecture rtl of video is

-- pentagon	48K screen mode
	constant pent_screen_h		: natural := 256;
	constant pent_border_right	: natural :=  72;	-- для выравнивания из-за задержки на чтение vid_reg и attr_reg задано на 8 точек больше 
	constant pent_blank_front	: natural :=   8;
	constant pent_sync_h		: natural :=  48;
	constant pent_blank_back	: natural :=   8;
	constant pent_border_left	: natural :=  56;	-- для выравнивания из-за задержки на чтение vid_reg и attr_reg задано на 8 точек меньше

	constant pent_screen_v		: natural := 192;
	constant pent_border_bot	: natural :=  48;
	constant pent_blank_up		: natural :=   6;
	constant pent_sync_v		: natural :=   4;
	constant pent_blank_down	: natural :=   6;
	constant pent_border_top	: natural :=  64;

	constant pent_h_blank_on	: natural := (pent_screen_h + pent_border_right) - 1;
	constant pent_h_sync_on		: natural := (pent_screen_h + pent_border_right + pent_blank_front) - 1;
	constant pent_h_sync_off	: natural := (pent_screen_h + pent_border_right + pent_blank_front + pent_sync_h);
	constant pent_h_blank_off	: natural := (pent_screen_h + pent_border_right + pent_blank_front + pent_sync_h + pent_blank_back);
	constant pent_h_end_count	: natural := 447;

	constant pent_v_blank_on	: natural := (pent_screen_v + pent_border_bot) - 1;
	constant pent_v_sync_on		: natural := (pent_screen_v + pent_border_bot + pent_blank_up) - 1;
	constant pent_v_sync_off	: natural := (pent_screen_v + pent_border_bot + pent_blank_up + pent_sync_v);
	constant pent_v_blank_off	: natural := (pent_screen_v + pent_border_bot + pent_blank_up + pent_sync_v + pent_blank_down);
	constant pent_v_end_count	: natural := 319;

	constant pent_h_int_on		: natural := pent_h_blank_on - 8;	-- 319 (-8 точек компенсация на выравнивании)
	constant pent_v_int_on		: natural := pent_v_blank_on;		-- 239
	
-- zx-spectum 48K screen mode
	constant spec_screen_h		: natural := 256;
	constant spec_border_right	: natural :=  56;	-- для выравнивания из-за задержки на чтение vid_reg и attr_reg задано на 8 точек больше
	constant spec_blank_front	: natural :=  24;
	constant spec_sync_h		: natural :=  32;
	constant spec_blank_back	: natural :=  40;
	constant spec_border_left	: natural :=  40;	-- для выравнивания из-за задержки на чтение vid_reg и attr_reg задано на 8 точек меньше

	constant spec_screen_v		: natural := 192;
	constant spec_border_bot	: natural :=  56;
	constant spec_blank_up		: natural :=   6;
	constant spec_sync_v		: natural :=   4;
	constant spec_blank_down	: natural :=   6;
	constant spec_border_top	: natural :=  48;

	constant spec_h_blank_on	: natural := (spec_screen_h + spec_border_right) - 1;
	constant spec_h_sync_on		: natural := (spec_screen_h + spec_border_right + spec_blank_front) - 1;
	constant spec_h_sync_off	: natural := (spec_screen_h + spec_border_right + spec_blank_front + spec_sync_h);
	constant spec_h_blank_off	: natural := (spec_screen_h + spec_border_right + spec_blank_front + spec_sync_h + spec_blank_back);
	constant spec_h_end_count	: natural := 447;

	constant spec_v_blank_on	: natural := (spec_screen_v + spec_border_bot) - 1;
	constant spec_v_sync_on		: natural := (spec_screen_v + spec_border_bot + spec_blank_up) - 1;
	constant spec_v_sync_off	: natural := (spec_screen_v + spec_border_bot + spec_blank_up + spec_sync_v);
	constant spec_v_blank_off	: natural := (spec_screen_v + spec_border_bot + spec_blank_up + spec_sync_v + spec_blank_down);
	constant spec_v_end_count	: natural := 311;

	constant spec_h_int_on		: natural := 16;
	constant spec_v_int_on		: natural := spec_v_blank_off - 1;
---------------------------------------------------------------------------------------	

	signal h_cnt			: unsigned(8 downto 0) := (others => '0');
	signal v_cnt			: unsigned(8 downto 0) := (others => '0');
	signal paper			: std_logic;
	signal paper1			: std_logic;
	signal flash			: unsigned(4 downto 0) := (others => '0');
	signal vid_reg			: std_logic_vector(7 downto 0);
	signal pixel_reg		: std_logic_vector(7 downto 0);
	signal attr_reg			: std_logic_vector(7 downto 0);
	signal h_sync			: std_logic;
	signal v_sync			: std_logic;
	signal int_sig			: std_logic;
	signal blank_sig		: std_logic;
	signal scan_cnt			: std_logic_vector(8 downto 0);
	signal scan_cnt1		: std_logic_vector(8 downto 0);
	signal scan_in			: std_logic_vector(5 downto 0);
	signal scan_out			: std_logic_vector(5 downto 0);

begin

-- Scan buffer
--buf: entity work.scan_buffer
--port map (
--	clock	 	=> CLK,
--	data	 	=> scan_in,
--	rdaddress	=> v_cnt(0) & scan_cnt,
--	wraddress	=> not v_cnt(0) & scan_cnt1,
--	wren	 	=> '1',
--	q	 		=> scan_out);

process (CLK)
begin
	if (CLK'event and CLK = '1') then
		if (ENA(1) = '1') then		-- 7MHz
			if (h_cnt = spec_h_end_count and MODE(0) = '0') or (h_cnt = pent_h_end_count and MODE(0) = '1') then
				h_cnt <= (others => '0');
			else
				h_cnt <= h_cnt + 1;
			end if;
			if (h_cnt = spec_h_sync_on and MODE(0) = '0') or (h_cnt = pent_h_sync_on and MODE(0) = '1') then
				if (v_cnt = spec_v_end_count and MODE(0) = '0') or (v_cnt = pent_v_end_count and MODE(0) = '1') then
					v_cnt <= (others => '0');
				else
					v_cnt <= v_cnt + 1;
				end if;
			end if;
			if (h_cnt = spec_h_sync_on and MODE(0) = '0') or (h_cnt = pent_h_sync_on and MODE(0) = '1') then
				scan_cnt1 <= (others => '0');
			else
				scan_cnt1 <= scan_cnt1 + 1;
			end if;
			if (v_cnt = spec_v_sync_on and MODE(0) = '0') or (v_cnt = pent_v_sync_on and MODE(0) = '1') then
				v_sync <= '0';
			elsif (v_cnt = spec_v_sync_off and MODE(0) = '0') or (v_cnt = pent_v_sync_off and MODE(0) = '1') then
				v_sync <= '1';
			end if;

			if (h_cnt = spec_h_sync_on and MODE(0) = '0') or (h_cnt = pent_h_sync_on and MODE(0) = '1') then
				h_sync <= '0';
			elsif (h_cnt = spec_h_sync_off and MODE(0) = '0') or (h_cnt = pent_h_sync_off and MODE(0) = '1') then
				h_sync <= '1';
			end if;


			if ((h_cnt = spec_h_int_on and v_cnt = spec_v_int_on) and MODE(0)= '0') or ((h_cnt = pent_h_int_on and v_cnt = pent_v_int_on) and MODE(0) = '1') then
				flash <= flash + 1;
				int_sig <= '0';
			elsif (INTA = '0') then
				int_sig <= '1';
			end if;
			case h_cnt(2 downto 0) is
				when "100" => 
					A <= std_logic_vector(v_cnt(7 downto 6)) & std_logic_vector(v_cnt(2 downto 0)) & std_logic_vector(v_cnt(5 downto 3)) & std_logic_vector(h_cnt(7 downto 3));
				when "101" =>
					vid_reg <= DI;
				when "110" =>
					A <= "110" & std_logic_vector(v_cnt(7 downto 3)) & std_logic_vector(h_cnt(7 downto 3));
				when "111" =>
					pixel_reg <= vid_reg;
					attr_reg <= DI;
					paper1 <= paper;
				when others => null;
			end case;
		end if;
	end if;
end process;

-- Scandoubler
--process (CLK, ENA, h_cnt)
--begin
--	if (CLK'event and CLK = '1') then
--		if (ENA(0) = '1') then		-- 14MHz
--			if ((h_cnt = spec_h_sync_on or h_cnt = spec_h_sync_on - 224) and MODE(0) = '0') or ((h_cnt = pent_h_sync_on or h_cnt = pent_h_sync_on - 224) and MODE(0) = '1') then
--				scan_cnt <= (others => '0');
--			else
--				scan_cnt <= scan_cnt + 1;
--			end if;
--			if (scan_cnt = 0) then
--				h_sync <= '0';
--			elsif ((scan_cnt = spec_sync_h - 1) and MODE(0) = '0') or ((scan_cnt = pent_sync_h - 1) and MODE(0) = '1') then
--				h_sync <= '1';
--			end if;
--		end if;
--	end if;
--end process;

scan_in <= 	(others => '0') when (blank_sig = '1') else
			"111111" when ((h_cnt = spec_h_blank_on or h_cnt = spec_h_blank_off or v_cnt = spec_v_blank_on or v_cnt = spec_v_blank_off) and MODE = "10") or ((h_cnt = pent_h_blank_on or h_cnt = pent_h_blank_off or v_cnt = pent_v_blank_on or v_cnt = pent_v_blank_off) and MODE = "11") else	-- видео рамка
			attr_reg(4) & (attr_reg(4) and attr_reg(6)) & attr_reg(5) & (attr_reg(5) and attr_reg(6)) & attr_reg(3) & (attr_reg(3) and attr_reg(6)) when paper1 = '1' and (pixel_reg(7 - to_integer(h_cnt(2 downto 0))) xor (flash(4) and attr_reg(7))) = '0' else
			attr_reg(1) & (attr_reg(1) and attr_reg(6)) & attr_reg(2) & (attr_reg(2) and attr_reg(6)) & attr_reg(0) & (attr_reg(0) and attr_reg(6)) when paper1 = '1' and (pixel_reg(7 - to_integer(h_cnt(2 downto 0))) xor (flash(4) and attr_reg(7))) = '1' else
			BORDER(1) & '0' & BORDER(2) & '0' & BORDER(0) & '0';


			
blank_sig	<= '1' when (((h_cnt > spec_h_blank_on and h_cnt < spec_h_blank_off) or (v_cnt > spec_v_blank_on and v_cnt < spec_v_blank_off)) and MODE(0) = '0') or (((h_cnt > pent_h_blank_on and h_cnt < pent_h_blank_off) or (v_cnt > pent_v_blank_on and v_cnt < pent_v_blank_off)) and MODE(0) = '1') else '0';
paper	<= '1' when ((h_cnt < spec_screen_h and v_cnt < spec_screen_v) and MODE(0) = '0') or ((h_cnt < pent_screen_h and v_cnt < pent_screen_v) and MODE(0) = '1') else '0';
INT		<= int_sig;
RGB 	<= scan_in; --scan_out;
HSYNC 	<= h_sync;
VSYNC 	<= v_sync;
BORDON	<= paper;	-- для порта атрибутов #FF
ATTR	<= attr_reg;
BLANK	<= blank_sig;

end architecture;