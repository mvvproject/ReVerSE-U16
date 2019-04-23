-------------------------------------------------------------------[24.06.2018]
-- Video
-------------------------------------------------------------------------------
-- Engineer: 	MVV <mvvproject@gmail.com>
--
-- 25.02.2015	Initial
-- 11.03.2015	Added full window mode and attr port #ff
-- 26.11.2015	720x640@60Hz, HCNT, VCNT
-- 24.08.2016	640x480@60Hz

library IEEE; 
use IEEE.std_logic_1164.all; 
use IEEE.numeric_std.ALL;
use IEEE.std_logic_unsigned.all;

entity video is
port (
	I_CLK		: in std_logic;
	I_ENA		: in std_logic;
	I_CLK_VGA	: in std_logic;

	O_CH0_INT	: out std_logic;
	O_CH0_ADR	: out std_logic_vector(12 downto 0);
	I_CH0_DAT	: in std_logic_vector(7 downto 0);
	I_CH0_BORDER	: in std_logic_vector(2 downto 0);	-- Биты D0..D2 порта xxFE определяют цвет бордюра
	O_CH0_ATTR	: out std_logic_vector(7 downto 0);
	O_CH0_BORDER	: out std_logic;
	
	O_CH1_INT	: out std_logic;
	O_CH1_ADR	: out std_logic_vector(12 downto 0);
	I_CH1_DAT	: in std_logic_vector(7 downto 0);
	I_CH1_BORDER	: in std_logic_vector(2 downto 0);	-- Биты D0..D2 порта xxFE определяют цвет бордюра
	O_CH1_ATTR	: out std_logic_vector(7 downto 0);
	O_CH1_BORDER	: out std_logic;

	O_CH2_INT	: out std_logic;
	O_CH2_ADR	: out std_logic_vector(12 downto 0);
	I_CH2_DAT	: in std_logic_vector(7 downto 0);
	I_CH2_BORDER	: in std_logic_vector(2 downto 0);	-- Биты D0..D2 порта xxFE определяют цвет бордюра
	O_CH2_ATTR	: out std_logic_vector(7 downto 0);
	O_CH2_BORDER	: out std_logic;

	O_CH3_INT	: out std_logic;
	O_CH3_ADR	: out std_logic_vector(12 downto 0);
	I_CH3_DAT	: in std_logic_vector(7 downto 0);
	I_CH3_BORDER	: in std_logic_vector(2 downto 0);	-- Биты D0..D2 порта xxFE определяют цвет бордюра
	O_CH3_ATTR	: out std_logic_vector(7 downto 0);
	O_CH3_BORDER	: out std_logic;
	
	I_SEL		: in std_logic_vector(1 downto 0);
	I_MODE		: in std_logic := '0';
	O_HCNT		: out std_logic_vector(9 downto 0);
	O_VCNT		: out std_logic_vector(9 downto 0);
	O_BLANK		: out std_logic;
	O_RGB		: out std_logic_vector(5 downto 0);	-- RRGGBB
	O_HSYNC		: out std_logic;
	O_VSYNC		: out std_logic);
end entity;

architecture rtl of video is

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

	constant spec_t_state_per_int	: natural := 71680;
	constant spec_int_len		: natural := 32;
---------------------------------------------------------------------------------------	

	signal h_count_reg		: std_logic_vector(9 downto 0) := (others => '0'); 	-- horizontal pixel counter
	signal v_count_reg		: std_logic_vector(9 downto 0) := (others => '0'); 	-- vertical line counter

	signal h_sync			: std_logic;
	signal v_sync			: std_logic;
	signal blank_sig		: std_logic;
	signal int_sig			: std_logic;
	
	signal spec_h_count_reg		: std_logic_vector(9 downto 0);
	signal spec_v_count_reg		: std_logic_vector(9 downto 0);
	
	signal temp_h			: std_logic_vector(8 downto 0);
	signal temp_v			: std_logic_vector(8 downto 0);
	signal scr_sel			: std_logic_vector(1 downto 0);
	signal spec_data		: std_logic_vector(7 downto 0);
	signal spec_border		: std_logic_vector(2 downto 0);
	
	signal paper			: std_logic;
	signal pixel			: std_logic;
	signal paper1			: std_logic;
	signal flash			: std_logic_vector(4 downto 0) := (others => '0');
	signal vid_reg			: std_logic_vector(7 downto 0);
	signal pixel_reg		: std_logic_vector(7 downto 0);
	signal attr_reg			: std_logic_vector(7 downto 0);
	signal vga_rgb			: std_logic_vector(5 downto 0);
	signal addr_reg			: std_logic_vector(12 downto 0);
	signal timer			: std_logic_vector(16 downto 0) := (others => '0');
	
begin

process (I_CLK_VGA, h_count_reg)
begin
	if (I_CLK_VGA'event and I_CLK_VGA = '1') then
		if (h_count_reg = h_end_count) then
			h_count_reg <= (others => '0');
		else
			h_count_reg <= h_count_reg + 1;
		end if;
		
		if ((h_count_reg = spec_border_left - 8 or h_count_reg = h_visible_area / 2 + spec_border_left - 8) and I_MODE = '0') or ((h_count_reg = spec_border_left * 2 - 16) and I_MODE = '1') then
			spec_h_count_reg <= (others => '0');
		else
			spec_h_count_reg <= spec_h_count_reg + 1;
		end if;

		if h_count_reg = h_sync_on then
			if (v_count_reg = v_end_count) then
				v_count_reg <= (others => '0');
			else
				v_count_reg <= v_count_reg + 1;
			end if;
			
			if ((v_count_reg = spec_border_top or v_count_reg = v_visible_area / 2 + spec_border_top) and I_MODE = '0') or ((v_count_reg = spec_border_top * 2) and I_MODE = '1') then
				spec_v_count_reg <= (others => '0');
			else
				spec_v_count_reg <= spec_v_count_reg + 1;
			end if;
			
		end if;

		case temp_h(2 downto 0) is
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
				addr_reg <= temp_v(7 downto 6) & temp_v(2 downto 0) & temp_v(5 downto 3) & temp_h(7 downto 3);
			when "101" =>
				pixel <= pixel_reg(1);
				vid_reg <= spec_data;
			when "110" =>
				pixel <= pixel_reg(0);
				addr_reg <= "110" & temp_v(7 downto 3) & temp_h(7 downto 3);
			when "111" =>
				pixel <= vid_reg(7);
				pixel_reg <= vid_reg;
				attr_reg <= spec_data;
				paper1 <= paper;
			when others => null;
		end case;
		
	end if;
end process;


h_sync		<= '1' when (h_count_reg < h_sync_on) or (h_count_reg > h_sync_off) else '0';
v_sync		<= '1' when (v_count_reg < v_sync_on) or (v_count_reg > v_sync_off) else '0';
blank_sig	<= '1' when (h_count_reg > h_pixels_across) or (v_count_reg > v_pixels_down) else '0';

--int_sig	<= '1' when (h_count_reg = h_sync_on and v_count_reg = v_sync_on) else '0';
scr_sel(0)	<= I_SEL(0) when (I_MODE = '1') else
			'0' when (h_count_reg < h_visible_area / 2) else
			'1';
scr_sel(1)	<= I_SEL(1) when (I_MODE = '1') else
			'0' when (v_count_reg < v_visible_area / 2) else
			'1';

temp_h		<= spec_h_count_reg(8 downto 0) when (I_MODE = '0') else spec_h_count_reg(9 downto 1);
temp_v		<= spec_v_count_reg(8 downto 0) when (I_MODE = '0') else spec_v_count_reg(9 downto 1);
			
paper		<= '1' when (temp_h < spec_screen_h and temp_v < spec_screen_v) else '0';

vga_rgb <= 	(others => '0') when (blank_sig = '1') else
		"001100" when ((h_count_reg < h_visible_area/2 and (v_count_reg = 0 or v_count_reg = v_pixels_down/2)) or ((h_count_reg = 0 or h_count_reg = h_pixels_across/2) and v_count_reg < v_visible_area/2)) and I_SEL = "00" and I_MODE = '0' else
		"001100" when ((h_count_reg > h_pixels_across/2 and (v_count_reg = 0 or v_count_reg = v_pixels_down/2)) or ((h_count_reg = h_visible_area/2 or h_count_reg = h_pixels_across) and v_count_reg < v_visible_area/2)) and I_SEL = "01" and I_MODE = '0' else
		"001100" when ((h_count_reg < h_visible_area/2 and (v_count_reg = v_visible_area/2 or v_count_reg = v_pixels_down)) or ((h_count_reg = 0 or h_count_reg = h_pixels_across/2) and v_count_reg > v_pixels_down/2)) and I_SEL = "10" and I_MODE = '0' else
		"001100" when ((h_count_reg > h_pixels_across/2 and (v_count_reg = v_visible_area/2 or v_count_reg = v_pixels_down)) or ((h_count_reg = h_visible_area/2 or h_count_reg = h_pixels_across) and v_count_reg > v_pixels_down/2)) and I_SEL = "11" and I_MODE = '0' else
		
		attr_reg(4) & (attr_reg(4) and attr_reg(6)) & attr_reg(5) & (attr_reg(5) and attr_reg(6)) & attr_reg(3) & (attr_reg(3) and attr_reg(6)) when paper1 = '1' and (pixel xor (flash(4) and attr_reg(7))) = '0' else
		attr_reg(1) & (attr_reg(1) and attr_reg(6)) & attr_reg(2) & (attr_reg(2) and attr_reg(6)) & attr_reg(0) & (attr_reg(0) and attr_reg(6)) when paper1 = '1' and (pixel xor (flash(4) and attr_reg(7))) = '1' else
		spec_border(1) & '0' & spec_border(2) & '0' & spec_border(0) & '0';

process (scr_sel, paper, attr_reg, I_CH0_BORDER, I_CH1_BORDER, I_CH2_BORDER, I_CH3_BORDER, I_CH0_DAT, I_CH1_DAT, I_CH2_DAT, I_CH3_DAT)
begin
	case scr_sel is
		when "00" =>
			spec_border  <= I_CH0_BORDER;
			spec_data    <= I_CH0_DAT;
			O_CH0_BORDER <= paper;
			O_CH0_ATTR   <= attr_reg;
			O_CH1_BORDER <= '0';
			O_CH1_ATTR   <= (others => '1');
			O_CH2_BORDER <= '0';
			O_CH2_ATTR   <= (others => '1');
			O_CH3_BORDER <= '0';
			O_CH3_ATTR   <= (others => '1');
		when "01" =>
			spec_border  <= I_CH1_BORDER;
			spec_data    <= I_CH1_DAT;
			O_CH1_BORDER <= paper;
			O_CH1_ATTR   <= attr_reg;
			O_CH2_BORDER <= '0';
			O_CH2_ATTR   <= (others => '1');
			O_CH3_BORDER <= '0';
			O_CH3_ATTR   <= (others => '1');
			O_CH0_BORDER <= '0';
			O_CH0_ATTR   <= (others => '1');
		when "10" =>
			spec_border  <= I_CH2_BORDER;
			spec_data    <= I_CH2_DAT;
			O_CH2_BORDER <= paper;
			O_CH2_ATTR   <= attr_reg;
			O_CH3_BORDER <= '0';
			O_CH3_ATTR   <= (others => '1');
			O_CH0_BORDER <= '0';
			O_CH0_ATTR   <= (others => '1');
			O_CH1_BORDER <= '0';
			O_CH1_ATTR   <= (others => '1');
		when "11" =>
			spec_border  <= I_CH3_BORDER;
			spec_data    <= I_CH3_DAT;
			O_CH3_BORDER <= paper;
			O_CH3_ATTR   <= attr_reg;
			O_CH0_BORDER <= '0';
			O_CH0_ATTR   <= (others => '1');
			O_CH1_BORDER <= '0';
			O_CH1_ATTR   <= (others => '1');
			O_CH2_BORDER <= '0';
			O_CH2_ATTR   <= (others => '1');
		when others => null;
	end case;
end process;

-- 3.5MHz = 285,71428571428571428571428571429ns
-- 50Hz = 20ms = 20000000ns : 285,71428571428571428571428571429ns = spec_t_state_per_int = 70000

process (I_CLK, I_ENA)
begin
	if (I_CLK'event and I_CLK = '1' and I_ENA = '1') then
		if (timer = spec_t_state_per_int) then
			timer <= (others => '0');
			flash <= flash + 1;
			int_sig <= '1';
		else
			timer <= timer + 1;
		end if;
		
		if (timer = spec_int_len) then
			int_sig <= '0';
		end if;
	end if;
end process;	
		
O_CH0_INT	<= int_sig;
O_CH1_INT	<= int_sig;
O_CH2_INT	<= int_sig;
O_CH3_INT	<= int_sig;

O_CH0_ADR	<= addr_reg;
O_CH1_ADR	<= addr_reg;
O_CH2_ADR	<= addr_reg;
O_CH3_ADR	<= addr_reg;

O_RGB 		<= vga_rgb;
O_HSYNC 	<= h_sync;
O_VSYNC 	<= v_sync;
O_BLANK		<= blank_sig;
O_HCNT		<= h_count_reg;
O_VCNT		<= v_count_reg;

end architecture;