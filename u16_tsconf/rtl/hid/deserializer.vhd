-------------------------------------------------------------------[31.12.2016]
-- CONTROLLER USB HID
-------------------------------------------------------------------------------
-- Engineer: 	MVV <mvvproject@gmail.com>

library IEEE; 
use IEEE.std_logic_1164.all; 
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all; 

entity deserializer is
generic (
	divisor			: integer := 434 );	-- divisor = 50MHz / 115200 Baud = 434
port (
	I_CLK			: in std_logic;
	I_RESET			: in std_logic;
	I_RX			: in std_logic;
	I_NEWFRAME		: in std_logic;
	I_ADDR			: in std_logic_vector(7 downto 0);
	O_MOUSE0_X		: out std_logic_vector(7 downto 0);
	O_MOUSE0_Y		: out std_logic_vector(7 downto 0);
	O_MOUSE0_Z		: out std_logic_vector(7 downto 0);
	O_MOUSE0_BUTTONS	: out std_logic_vector(7 downto 0);
	O_MOUSE1_X		: out std_logic_vector(7 downto 0);
	O_MOUSE1_Y		: out std_logic_vector(7 downto 0);
	O_MOUSE1_Z		: out std_logic_vector(7 downto 0);
	O_MOUSE1_BUTTONS	: out std_logic_vector(7 downto 0);
	O_KEYBOARD_REPORT	: out std_logic_vector(55 downto 0);
	O_KEYBOARD_SCAN		: out std_logic_vector(4 downto 0);
	O_KEYBOARD_SCANCODE	: out std_logic_vector(7 downto 0);
	O_KEYBOARD_FKEYS	: out std_logic_vector(4 downto 0);
	O_KEYBOARD_JOYKEYS	: out std_logic_vector(4 downto 0));
end deserializer;

architecture rtl of deserializer is
	type key_matrix is array (9 downto 0) of std_logic_vector(4 downto 0);
	signal keys		: key_matrix;
	signal row0, row1, row2, row3, row4, row5, row6, row7 : std_logic_vector(4 downto 0);
	signal count		: integer range 0 to 8;
	signal data		: std_logic_vector(7 downto 0);
	signal ready		: std_logic;
	signal device_id	: std_logic_vector(7 downto 0);
	signal scancode		: std_logic_vector(7 downto 0);
	signal x0		: std_logic_vector(8 downto 0) := "111111111";
	signal y0		: std_logic_vector(8 downto 0) := "000000000";
	signal z0		: std_logic_vector(8 downto 0) := "111111111";
	signal b0		: std_logic_vector(7 downto 0) := "00000000";
	signal x1		: std_logic_vector(8 downto 0) := "111111111";
	signal y1		: std_logic_vector(8 downto 0) := "000000000";
	signal z1		: std_logic_vector(8 downto 0) := "111111111";
	signal b1		: std_logic_vector(7 downto 0) := "00000000";
	signal keyboard_report	: std_logic_vector(55 downto 0);
	
begin

	inst_rx : entity work.receiver
	generic map (
		divisor		=> 434 )	-- divisor = 50MHz / 115200 Baud = 434
	port map (
		I_CLK		=> I_CLK,
		I_RESET		=> I_RESET,
		I_RX		=> I_RX,
		O_DATA		=> data,
		O_READY		=> ready
	);

	-- Output addressed row to ULA
	row0	<= keys(0) when I_ADDR(0) = '0' else (others => '1');
	row1	<= keys(1) when I_ADDR(1) = '0' else (others => '1');
	row2	<= keys(2) when I_ADDR(2) = '0' else (others => '1');
	row3	<= keys(3) when I_ADDR(3) = '0' else (others => '1');
	row4	<= keys(4) when I_ADDR(4) = '0' else (others => '1');
	row5	<= keys(5) when I_ADDR(5) = '0' else (others => '1');
	row6	<= keys(6) when I_ADDR(6) = '0' else (others => '1');
	row7	<= keys(7) when I_ADDR(7) = '0' else (others => '1');
	
	-- Keyboard
	O_KEYBOARD_SCAN		<= row0 and row1 and row2 and row3 and row4 and row5 and row6 and row7;
	O_KEYBOARD_JOYKEYS	<= keys(8);
	O_KEYBOARD_FKEYS	<= keys(9);
	O_KEYBOARD_SCANCODE	<= scancode;
	O_KEYBOARD_REPORT	<= keyboard_report;
	
	-- Mouse
	O_MOUSE0_BUTTONS	<= b0;
	O_MOUSE0_X		<= x0(7 downto 0);
	O_MOUSE0_Y		<= y0(7 downto 0);
	O_MOUSE0_Z		<= z0(7 downto 0);
	O_MOUSE1_BUTTONS	<= b1;
	O_MOUSE1_X		<= x1(7 downto 0);
	O_MOUSE1_Y		<= y1(7 downto 0);
	O_MOUSE1_Z		<= z1(7 downto 0);
	
	process (I_RESET, I_CLK, data, I_NEWFRAME, ready)
	begin
		if I_RESET = '1' then
			keys(0) <= (others => '1');
			keys(1) <= (others => '1');
			keys(2) <= (others => '1');
			keys(3) <= (others => '1');
			keys(4) <= (others => '1');
			keys(5) <= (others => '1');
			keys(6) <= (others => '1');
			keys(7) <= (others => '1');
			keys(8) <= (others => '0');
			keys(9) <= (others => '0');
			count <= 0;
			x0 <= (others => '1');
			y0 <= (others => '0');
			z0 <= (others => '1');
			b0 <= (others => '0');
			x1 <= (others => '1');
			y1 <= (others => '0');
			z1 <= (others => '1');
			b1 <= (others => '0');
			scancode <= (others => '1');
		elsif I_NEWFRAME = '0' then
			count <= 0;
		elsif I_CLK'event and I_CLK = '1' and ready = '1' then
			if count = 0 then
				count <= 1;
				device_id <= data;
				case data(3 downto 0) is
					when x"6" =>	-- Keyboard
						keys(0) <= (others => '1');
						keys(1) <= (others => '1');
						keys(2) <= (others => '1');
						keys(3) <= (others => '1');
						keys(4) <= (others => '1');
						keys(5) <= (others => '1');
						keys(6) <= (others => '1');
						keys(7) <= (others => '1');
						keys(8) <= (others => '0');
						keys(9) <= (others => '0');
						scancode <= (others => '1');
					when others => null;
				end case;
			else
				count <= count + 1;
				case device_id is
					when x"02" =>	-- Mouse0
					-- Input report - 5 bytes
 					--     Byte | D7      D6      D5      D4      D3      D2      D1      D0
					--    ------+---------------------------------------------------------------------
					--      0   |  0       0       0    Forward  Back    Middle  Right   Left (Button)
					--      1   |                             X
					--      2   |                             Y
					--      3   |                       Vertical Wheel
					--      4   |                    Horizontal (Tilt) Wheel
					
						case count is
							when 1 => b0 <= data;		-- Buttons
							when 2 => x0 <= x0 + data;	-- Left/Right delta
							when 3 => y0 <= y0 + data;	-- Up/Down delta
							when 4 => z0 <= z0 + data;	-- Wheel delta
							when others => null;
						end case;

					when x"82" =>	-- Mouse1
						case count is
							when 1 => b1 <= data;		-- Buttons
							when 2 => x1 <= x1 + data;	-- Left/Right delta
							when 3 => y1 <= y1 + data;	-- Up/Down delta
							when 4 => z1 <= z1 + data;	-- Wheel delta
							when others => null;
						end case;
						
					when x"06" | x"86" =>	-- Keyboard
						case count is
							when 1 => keyboard_report( 7 downto 0) <= data;
							when 3 => keyboard_report(15 downto 8) <= data;
							when 4 => keyboard_report(23 downto 16) <= data;
							when 5 => keyboard_report(31 downto 24) <= data;
							when 6 => keyboard_report(39 downto 32) <= data;
							when 7 => keyboard_report(47 downto 40) <= data;
							when 8 => keyboard_report(55 downto 48) <= data;
							when others => null;
						end case;
						
						if count = 1 then
--							if data(0) = '1' then end if;	-- E0 Left Control
							if data(1) = '1' then keys(0)(0) <= '0'; scancode <= X"12"; end if;	-- E1 Left shift (CAPS SHIFT)
--							if data(2) = '1' then end if;	-- E2 Left Alt
--							if data(3) = '1' then end if;	-- E3 Left Gui
							if data(4) = '1' then keys(7)(1) <= '0'; scancode <= x"14"; end if;	-- E4 CTRL (Symbol Shift)
							if data(5) = '1' then keys(0)(0) <= '0'; scancode <= x"59"; end if;	-- E5 Right shift (CAPS SHIFT)
--							if data(6) = '1' then end if;	-- E6 Right Alt
							if data(7) = '1' then scancode <= x"27"; end if;	-- E7 Right Gui
						else
							case data is
								when X"1d" =>	keys(0)(1) <= '0'; scancode <= x"1a";	-- Z
								when X"1b" =>	keys(0)(2) <= '0'; scancode <= x"22";	-- X
								when X"06" =>	keys(0)(3) <= '0'; scancode <= x"21";	-- C
								when X"19" =>	keys(0)(4) <= '0'; scancode <= x"2a";	-- V

								when X"04" =>	keys(1)(0) <= '0'; scancode <= x"1c";	-- A
								when X"16" =>	keys(1)(1) <= '0'; scancode <= x"1b";	-- S
								when X"07" =>	keys(1)(2) <= '0'; scancode <= x"23";	-- D
								when X"09" =>	keys(1)(3) <= '0'; scancode <= x"2b";	-- F
								when X"0a" =>	keys(1)(4) <= '0'; scancode <= x"34";	-- G

								when X"14" =>	keys(2)(0) <= '0'; scancode <= x"15";	-- Q
								when X"1a" =>	keys(2)(1) <= '0'; scancode <= x"1d";	-- W
								when X"08" =>	keys(2)(2) <= '0'; scancode <= x"24";	-- E
								when X"15" =>	keys(2)(3) <= '0'; scancode <= x"2d";	-- R
								when X"17" =>	keys(2)(4) <= '0'; scancode <= x"2c";	-- T

								when X"1e" =>	keys(3)(0) <= '0'; scancode <= x"16";	-- 1
								when X"1f" =>	keys(3)(1) <= '0'; scancode <= x"1e";	-- 2
								when X"20" =>	keys(3)(2) <= '0'; scancode <= x"26";	-- 3
								when X"21" =>	keys(3)(3) <= '0'; scancode <= x"25";	-- 4
								when X"22" =>	keys(3)(4) <= '0'; scancode <= x"2e";	-- 5

								when X"27" =>	keys(4)(0) <= '0'; scancode <= x"45";	-- 0
								when X"26" =>	keys(4)(1) <= '0'; scancode <= x"46";	-- 9
								when X"25" =>	keys(4)(2) <= '0'; scancode <= x"3e";	-- 8
								when X"24" =>	keys(4)(3) <= '0'; scancode <= x"3d";	-- 7
								when X"23" =>	keys(4)(4) <= '0'; scancode <= x"36";	-- 6

								when X"13" =>	keys(5)(0) <= '0'; scancode <= x"4d";	-- P
								when X"12" =>	keys(5)(1) <= '0'; scancode <= x"44";	-- O
								when X"0c" =>	keys(5)(2) <= '0'; scancode <= x"43";	-- I
								when X"18" =>	keys(5)(3) <= '0'; scancode <= x"3c";	-- U
								when X"1c" =>	keys(5)(4) <= '0'; scancode <= x"35";	-- Y

								when X"28" =>	keys(6)(0) <= '0'; scancode <= x"5a";	-- ENTER
								when X"0f" =>	keys(6)(1) <= '0'; scancode <= x"4b";	-- L
								when X"0e" =>	keys(6)(2) <= '0'; scancode <= x"42";	-- K
								when X"0d" =>	keys(6)(3) <= '0'; scancode <= x"3b";	-- J
								when X"0b" =>	keys(6)(4) <= '0'; scancode <= x"33";	-- H

								when X"2c" =>	keys(7)(0) <= '0'; scancode <= x"29";	-- SPACE
								when X"10" =>	keys(7)(2) <= '0'; scancode <= x"3a";	-- M
								when X"11" =>	keys(7)(3) <= '0'; scancode <= x"31";	-- N
								when X"05" =>	keys(7)(4) <= '0'; scancode <= x"32";	-- B

								-- Cursor keys
								when X"50" =>	keys(0)(0) <= '0'; keys(3)(4) <= '0'; scancode <= x"6b";	-- Left (CAPS 5)
								when X"51" =>	keys(0)(0) <= '0'; keys(4)(4) <= '0'; scancode <= x"72";	-- Down (CAPS 6)
								when X"52" =>	keys(0)(0) <= '0'; keys(4)(3) <= '0'; scancode <= x"75";	-- Up (CAPS 7)
								when X"4f" =>	keys(0)(0) <= '0'; keys(4)(2) <= '0'; scancode <= x"74";	-- Right (CAPS 8)

								-- Other special keys sent to the ULA as key combinations
								when X"2a" =>	keys(0)(0) <= '0'; keys(4)(0) <= '0'; scancode <= x"66";	-- Backspace (CAPS 0)
								when X"39" =>	keys(0)(0) <= '0'; keys(3)(1) <= '0'; scancode <= x"58";	-- Caps lock (CAPS 2)
								when X"2b" =>	keys(0)(0) <= '0'; keys(7)(0) <= '0'; scancode <= x"0d";	-- Tab (CAPS SPACE)
								when X"37" =>	keys(7)(2) <= '0'; keys(7)(1) <= '0'; scancode <= x"49";	-- .
								when X"2d" =>	keys(6)(3) <= '0'; keys(7)(1) <= '0'; scancode <= x"4e";	-- -
								when X"35" =>	keys(3)(0) <= '0'; keys(0)(0) <= '0'; scancode <= x"0e";	-- ` (EDIT)
								when X"36" =>	keys(7)(3) <= '0'; keys(7)(1) <= '0'; scancode <= x"41";	-- ,
								when X"33" =>	keys(5)(1) <= '0'; keys(7)(1) <= '0'; scancode <= x"4c";	-- ;
								when X"34" =>	keys(5)(0) <= '0'; keys(7)(1) <= '0'; scancode <= x"52";	-- "
								when X"31" =>	keys(0)(1) <= '0'; keys(7)(1) <= '0'; scancode <= x"5d";	-- :
								when X"2e" =>	keys(6)(1) <= '0'; keys(7)(1) <= '0'; scancode <= x"55";	-- =
								when X"2f" =>	keys(4)(2) <= '0'; keys(7)(1) <= '0'; scancode <= x"54";	-- (
								when X"30" =>	keys(4)(1) <= '0'; keys(7)(1) <= '0'; scancode <= x"5b";	-- )
								when X"38" =>	keys(0)(3) <= '0'; keys(7)(1) <= '0'; scancode <= x"4a";	-- ?
										
								-- Kempston keys
								when X"5e" =>	keys(8)(0) <= '1';	-- [6] (Right)
								when X"5c" =>	keys(8)(1) <= '1';	-- [4] (Left)
								when X"5a" =>	keys(8)(2) <= '1';	-- [2] (Down)
								when X"60" =>	keys(8)(3) <= '1';	-- [8] (Up)
								when X"62" =>	keys(8)(4) <= '1';	-- [0] (Fire)
		
								-- Fx keys
								when X"3a" =>	scancode <= x"05";	-- F1
								when X"3b" =>	scancode <= x"06";	-- F2
								when X"3c" =>	scancode <= x"04";	-- F3
								when X"3d" =>	scancode <= x"0c";	-- F4
								when X"3e" =>	scancode <= x"03";	-- F5
								when X"3f" =>	scancode <= x"0b";	-- F6
								when X"40" =>	scancode <= x"83";	-- F7
								when X"41" =>	scancode <= x"0a";	-- F8
								when X"42" =>	scancode <= x"01";	-- F9
								when X"43" =>	scancode <= x"09";	-- F10
								when X"44" =>	keys(9)(1) <= '1'; scancode <= x"78";	-- F11
								when X"45" =>	keys(9)(0) <= '1'; scancode <= x"07";	-- F12
				 
								-- Soft keys
								when X"46" =>	keys(9)(2) <= '1'; scancode <= x"7c";	-- PrtScr
								when X"47" =>	keys(9)(3) <= '1'; scancode <= x"7e";	-- Scroll Lock
								when X"48" =>	keys(9)(4) <= '1'; scancode <= x"77";	-- Pause
								when X"65" =>	scancode <= x"2f";	-- WinMenu
								when X"29" =>	scancode <= x"76";	-- Esc
								when X"49" =>	scancode <= x"70";	-- Insert
								when X"4a" =>	scancode <= x"6c";	-- Home
								when X"4b" =>	scancode <= x"7d";	-- Page Up
								when X"4c" =>	scancode <= x"71";	-- Delete
								when X"4d" =>	scancode <= x"69";	-- End
								when X"4e" =>	scancode <= x"7a";	-- Page Down
		
								when others => null;
							end case;
						end if;
					
					when others => null;
				end case;
			end if;
		end if;
	end process;

end architecture;
