-------------------------------------------------------------------[19.07.2015]
-- Sync
-------------------------------------------------------------------------------
-- Author:	MVV
-- Description: Sync
--
-- 16.08.2014	Initial release.
-------------------------------------------------------------------------------

--	General timing:
--	Screen refresh rate	= 60 Hz			60 Hz		700000 cycles
--	Vertical refresh	= 31.46875 kHz		31.5 kHz
--	Pixel freq.		= 25.175 MHz		25.2 MHz	23,809523809523809523809523809524 ns
--
--	Horizontal timing (line)
--	Polarity of horizontal sync pulse is negative.
--
--	Scanline part	Pixels	Time [us]
--	---------------------------------
--	Visible area 	640 	25.422045680238 	25,396825396825396825396825396825
--	Front porch 	 16	0.63555114200596 	0,63492063492063492063492063492063
--	Sync pulse 	 96	3.8133068520357 	3,8095238095238095238095238095238
--	Back porch 	 48	1.9066534260179 	1,9047619047619047619047619047619
--	Whole line 	800 	31.777557100298 	31,746031746031746031746031746032
--
--	Vertical timing (frame)
--	Polarity of vertical sync pulse is negative.
--
--	Frame part	Lines	Time [ms]
--	---------------------------------
--	Visible area 	480	15.253227408143 	15,238095238095238095238095238095
--	Front porch 	 10 	0.31777557100298 	0,31746031746031746031746031746032
--	Sync pulse 	  2 	0.063555114200596 	0,06349206349206349206349206349206
--	Back porch 	 33 	1.0486593843098 	1,047619047619047619047619047619
--	Whole frame 	525 	16.683217477656 	16,666666666666666666666666666667	16666666,666666666666666666666667 ns / 23,809523809523809523809523809524 ns = 700000 cycles

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use IEEE.STD_LOGIC_ARITH.all;

entity sync is port (
	I_CLK		: in std_logic; 			-- VGA dot clock
	I_EN		: in std_logic;
	O_HCNT		: out std_logic_vector(9 downto 0);
	O_HCNT_REG	: out std_logic_vector(9 downto 0);
	O_VCNT		: out std_logic_vector(9 downto 0);
	O_INT		: out std_logic;
	O_FLASH		: out std_logic;			-- скорость мерцания курсора 1.875Гц
	O_BLANK		: out std_logic;
	O_HSYNC		: out std_logic;			-- horizontal (line) sync
	O_VSYNC		: out std_logic);			-- vertical (frame) sync
end entity;

architecture rtl of sync is

	-- Horizontal timing (line)
	constant h_visible_area		: integer := 640;
	constant h_front_porch		: integer := 16;
	constant h_sync_pulse		: integer := 96;
	constant h_back_porch		: integer := 48;
	constant h_whole_line		: integer := 800;
	-- Vertical timing (frame)	
	constant v_visible_area		: integer := 480;
	constant v_front_porch		: integer := 10;
	constant v_sync_pulse		: integer := 2;
	constant v_back_porch		: integer := 33;
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

	signal h_count_reg		: std_logic_vector(9 downto 0) := "0000000000"; 	-- horizontal pixel counter
	signal v_count_reg		: std_logic_vector(9 downto 0) := "0000000000"; 	-- vertical line counter
	signal h_count_sig		: std_logic_vector(9 downto 0) := "0000000000";
	signal v_count_sig		: std_logic_vector(9 downto 0) := "0000000000";
	signal h_sync			: std_logic;
	signal v_sync			: std_logic;
	signal blank_sig		: std_logic;
	signal int_sig			: std_logic;
	signal counter			: std_logic_vector(5 downto 0);
	
begin
		
	process (I_CLK, I_EN, h_count_reg, int_sig)
	begin
		if (I_CLK'event and I_CLK = '1') then
			if (I_EN = '1') then
				h_count_reg <= h_count_sig;
				if h_count_reg = h_sync_on then
					v_count_reg <= v_count_sig;
				end if;
				if (int_sig = '1') then
					counter <= counter + 1;
				end if;
			end if;
		end if;
	end process;

	h_count_sig	<= (others => '0') when (h_count_reg = h_end_count) else h_count_reg + 1;
	v_count_sig	<= (others => '0') when (v_count_reg = v_end_count) else v_count_reg + 1;
	h_sync		<= '1' when (h_count_reg < h_sync_on) or (h_count_reg > h_sync_off) else '0';
	v_sync		<= '1' when (v_count_reg < v_sync_on) or (v_count_reg > v_sync_off) else '0';
	blank_sig	<= '1' when (h_count_reg > h_pixels_across) or (v_count_sig > v_pixels_down) else '0';
	int_sig		<= '1' when (h_count_reg = h_sync_on and v_count_reg = v_sync_on) else '0';

	O_HCNT		<= h_count_sig;
	O_HCNT_REG	<= h_count_reg;
	O_VCNT		<= v_count_sig;
	O_INT		<= int_sig;
	O_FLASH		<= counter(5);
	O_HSYNC 	<= h_sync;
	O_BLANK 	<= blank_sig;
	O_VSYNC		<= v_sync;

end architecture;