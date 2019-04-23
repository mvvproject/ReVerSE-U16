-------------------------------------------------------------------[16.05.2015]
-- VGA
-------------------------------------------------------------------------------
-- Engineer: 	MVV
--
-- 15.05.2015	Initial release
-------------------------------------------------------------------------------

library IEEE; 
use IEEE.std_logic_1164.all; 
use IEEE.numeric_std.ALL;
use IEEE.std_logic_unsigned.all;

entity vga is
port (
	CLK_I		: in std_logic;
	DATA_I		: in std_logic_vector(7 downto 0);
	BORDER_I	: in std_logic_vector(2 downto 0);	-- Биты D0..D2 порта xxFE определяют цвет бордюра
	INT_O		: out std_logic;
	ADDR_O		: out std_logic_vector(12 downto 0);
	BLANK_O		: out std_logic;
	RGB_O		: out std_logic_vector(5 downto 0);	-- RRGGBB
	HSYNC_O		: out std_logic;
	VSYNC_O		: out std_logic);
end entity;

architecture rtl of vga is

--VGA Signal 640 x 480 @ 60 Hz Industry standard timing
--
--General timing:
--
--Screen refresh rate	60 Hz
--Vertical refresh	31.46875 kHz
--Pixel freq.		25.175 MHz
--
--Horizontal timing (line):
--
--Polarity of horizontal sync pulse is negative.
--Scanline part		Pixels	Time [µs]
--Visible area		640	25.422045680238
--Front porch		16	0.63555114200596
--Sync pulse		96	3.8133068520357
--Back porch		48	1.9066534260179
--Whole line		800	31.777557100298
--
--Vertical timing (frame):
--
--Polarity of vertical sync pulse is negative.
--Frame part		Lines	Time [ms]
--Visible area		480	15.253227408143
--Front porch		10	0.31777557100298
--Sync pulse		2	0.063555114200596
--Back porch		33	1.0486593843098
--Whole frame		525	16.683217477656

-- VGA
	-- Horizontal timing (line)
	constant h_visible_area		: integer := 640;
	constant h_front_porch		: integer := 24;
	constant h_sync_pulse		: integer := 96;
	constant h_back_porch		: integer := 40;
	constant h_whole_line		: integer := 800;
	-- Vertical timing (frame)	
	constant v_visible_area		: integer := 480;
	constant v_front_porch		: integer := 11;
	constant v_sync_pulse		: integer := 2;
	constant v_back_porch		: integer := 32;
	constant v_whole_frame		: integer := 525;
	-- Horizontal Timing constants  
	constant h_pixels_across	: integer := h_visible_area - 1;
	constant h_sync_on		: integer := h_visible_area + h_front_porch - 1;
	constant h_sync_off		: integer := h_visible_area + h_front_porch + h_sync_pulse - 2;
	constant h_end_count		: integer := h_whole_line - 1;
	-- Vertical Timing constants
	constant v_pixels_down		: integer := v_visible_area - 1;
	constant v_sync_on		: integer := v_visible_area + v_front_porch - 1;
	constant v_sync_off		: integer := v_visible_area + v_front_porch + v_sync_pulse - 2;
	constant v_end_count		: integer := v_whole_frame - 1;
	
-- ZX-Spectum screen
	constant spec_border_left	: natural :=  32;
	constant spec_screen_h		: natural := 256;
	constant spec_border_right	: natural :=  32;

	constant spec_border_top	: natural :=  24;
	constant spec_screen_v		: natural := 192;
	constant spec_border_bot	: natural :=  24;

---------------------------------------------------------------------------------------	

	signal h_count_reg		: std_logic_vector(9 downto 0) := (others => '0'); 	-- horizontal pixel counter
	signal v_count_reg		: std_logic_vector(9 downto 0) := (others => '0'); 	-- vertical line counter

	signal h_sync			: std_logic;
	signal v_sync			: std_logic;
	signal blank_sig		: std_logic;
	signal int_sig			: std_logic;
	
	signal spec_h_count_reg		: std_logic_vector(9 downto 0);
	signal spec_v_count_reg		: std_logic_vector(9 downto 0);

	signal paper			: std_logic;
	signal pixel			: std_logic;
	signal paper1			: std_logic;
	signal flash			: std_logic_vector(4 downto 0) := (others => '0');
	signal vid_reg			: std_logic_vector(7 downto 0);
	signal pixel_reg		: std_logic_vector(7 downto 0);
	signal attr_reg			: std_logic_vector(7 downto 0);
	signal vga_rgb			: std_logic_vector(5 downto 0);
	signal addr_reg			: std_logic_vector(12 downto 0);
	
begin

process (CLK_I, h_count_reg)
begin
	if (CLK_I'event and CLK_I = '1') then
		if (h_count_reg = h_end_count) then
			h_count_reg <= (others => '0');
		else
			h_count_reg <= h_count_reg + 1;
		end if;
		
		if (h_count_reg = spec_border_left * 2 - 16) then
			spec_h_count_reg <= (others => '0');
		else
			spec_h_count_reg <= spec_h_count_reg + 1;
		end if;

		if (h_count_reg = h_sync_on) then
			if (v_count_reg = v_end_count) then
				v_count_reg <= (others => '0');
			else
				v_count_reg <= v_count_reg + 1;
			end if;
			
			if (v_count_reg = spec_border_top * 2) then
				spec_v_count_reg <= (others => '0');
			else
				spec_v_count_reg <= spec_v_count_reg + 1;
			end if;
			
		end if;

		case spec_h_count_reg(3 downto 1) is
			when "000" =>
				pixel <= pixel_reg(6);
			when "001" =>
				pixel <= pixel_reg(5);
			when "010" =>
				pixel <= pixel_reg(4);
			when "011" =>
				pixel <= pixel_reg(3);
			when "100" => 
				pixel <= pixel_reg(2);
				addr_reg <= spec_v_count_reg(8 downto 7) & spec_v_count_reg(3 downto 1) & spec_v_count_reg(6 downto 4) & spec_h_count_reg(8 downto 4);
			when "101" =>
				pixel <= pixel_reg(1);
				vid_reg <= DATA_I;
			when "110" =>
				pixel <= pixel_reg(0);
				addr_reg <= "110" & spec_v_count_reg(8 downto 4) & spec_h_count_reg(8 downto 4);
			when "111" =>
				pixel <= vid_reg(7);
				pixel_reg <= vid_reg;
				attr_reg <= DATA_I;
				paper1 <= paper;
			when others => null;
		end case;
		
	end if;
end process;

h_sync		<= '1' when (h_count_reg < h_sync_on) or (h_count_reg > h_sync_off) else '0';
v_sync		<= '1' when (v_count_reg < v_sync_on) or (v_count_reg > v_sync_off) else '0';
blank_sig	<= '1' when (h_count_reg > h_pixels_across) or (v_count_reg > v_pixels_down) else '0';
int_sig		<= '1' when (h_count_reg = h_sync_on and v_count_reg = v_sync_on) else '0';
paper		<= '1' when (spec_h_count_reg(9 downto 1) < spec_screen_h and spec_v_count_reg(9 downto 1) < spec_screen_v) else '0';

vga_rgb <= 	(others => '0') when (blank_sig = '1') else
		attr_reg(4) & (attr_reg(4) and attr_reg(6)) & attr_reg(5) & (attr_reg(5) and attr_reg(6)) & attr_reg(3) & (attr_reg(3) and attr_reg(6)) when paper1 = '1' and (pixel xor (flash(4) and attr_reg(7))) = '0' else
		attr_reg(1) & (attr_reg(1) and attr_reg(6)) & attr_reg(2) & (attr_reg(2) and attr_reg(6)) & attr_reg(0) & (attr_reg(0) and attr_reg(6)) when paper1 = '1' and (pixel xor (flash(4) and attr_reg(7))) = '1' else
		BORDER_I(1) & '0' & BORDER_I(2) & '0' & BORDER_I(0) & '0';

process (CLK_I, int_sig)
begin
	if (CLK_I'event and CLK_I = '1') then
		if (int_sig = '1') then
			flash <= flash + 1;
		end if;
	end if;
end process;	

INT_O		<= int_sig;
ADDR_O		<= addr_reg;
RGB_O 		<= vga_rgb;
HSYNC_O 	<= h_sync;
VSYNC_O 	<= v_sync;
BLANK_O		<= blank_sig;

end architecture;