-------------------------------------------------------------------[05.10.2011]
-- Kempston Mouse
-------------------------------------------------------------------------------
-- V0.1 	05.10.2011	первая версия

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

entity mouse is
	generic (
		-- Enable support for intelli-mouse mode.
		-- This allows the use of the scroll-wheel on mice that have them.
		intelliMouseSupport : boolean := true;
		-- Number of system-cycles used for PS/2 clock filtering
		clockFilter : integer := 15;
		-- Timer calibration
		ticksPerUsec : integer := 33 );  -- 33 Mhz clock

	port (
		CLK 			: in std_logic;
		RESET 			: in std_logic := '0';
		PS2_CLK 		: inout std_logic;
		PS2_DAT 		: inout std_logic;
		
		mousePresent 	: out std_logic;

		leftButton 		: out std_logic;
		middleButton 	: out std_logic;
		rightButton 	: out std_logic;
		X 				: out std_logic_vector(7 downto 0);
		Y 				: out std_logic_vector(7 downto 0);
		Z 				: out std_logic_vector(3 downto 0) );
end entity;

-- -----------------------------------------------------------------------

architecture rtl of mouse is
	signal currentX 	: unsigned(7 downto 0);
	signal currentY 	: unsigned(7 downto 0);
	signal cursorX 		: signed(7 downto 0) := X"7F";
	signal cursorY 		: signed(7 downto 0) := X"7F";
	signal trigger		: std_logic;
	signal ps2_clk_out	: std_logic;
	signal ps2_dat_out	: std_logic;
	signal deltaX		: signed(8 downto 0);
	signal deltaY		: signed(8 downto 0);
	signal deltaZ		: signed(3 downto 0);
	
begin
	Ps2Mouse : entity work.io_ps2_mouse
	generic map (
		intelliMouseSupport => intelliMouseSupport,
		clockFilter => clockFilter,
		ticksPerUsec => ticksPerUsec )
	port map (
		CLK => CLK,
		RESET => RESET,
		
		ps2_clk_in => PS2_CLK,
		ps2_dat_in => PS2_DAT,
		ps2_clk_out => ps2_clk_out,
		ps2_dat_out => ps2_dat_out,
		
		mousePresent => mousePresent,
		
		trigger => trigger,
		leftButton => leftButton,
		middleButton => middleButton,
		rightButton => rightButton,
		deltaX => deltaX,
		deltaY => deltaY,
		deltaZ => deltaZ );

	process (CLK)
		variable newX : signed(7 downto 0);
		variable newY : signed(7 downto 0);
	begin
		if rising_edge (CLK) then

			newX := cursorX + (deltaX(8) & deltaX(6 downto 0));
			newY := cursorY + (deltaY(8) & deltaY(6 downto 0));

			if trigger = '1' then
				cursorX <= newX;
				cursorY <= newY;
			end if;
		end if;
	end process;
	
	x 		<= std_logic_vector(cursorX);
	y 		<= std_logic_vector(cursorY);
	z		<= std_logic_vector(deltaZ);
	PS2_CLK <= '0' when ps2_clk_out = '0' else 'Z';
	PS2_DAT <= '0' when ps2_dat_out = '0' else 'Z';

end architecture;