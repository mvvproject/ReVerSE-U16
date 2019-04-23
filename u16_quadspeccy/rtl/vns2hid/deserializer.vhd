-------------------------------------------------------------------[01.01.2016]
-- CONTROLLER USB HID scancode to Spectrum matrix conversion
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
	O_MOUSE_X		: out std_logic_vector(7 downto 0);
	O_MOUSE_Y		: out std_logic_vector(7 downto 0);
	O_MOUSE_Z		: out std_logic_vector(7 downto 0);
	O_MOUSE_BUTTONS		: out std_logic_vector(7 downto 0);
	O_KEY0			: out std_logic_vector(7 downto 0);
	O_KEY1			: out std_logic_vector(7 downto 0);
	O_KEY2			: out std_logic_vector(7 downto 0);
	O_KEY3			: out std_logic_vector(7 downto 0);
	O_KEY4			: out std_logic_vector(7 downto 0);
	O_KEY5			: out std_logic_vector(7 downto 0);
	O_KEY6			: out std_logic_vector(7 downto 0);
	O_KEYBOARD_SCAN		: out std_logic_vector(4 downto 0);
	O_KEYBOARD_FKEYS	: out std_logic_vector(12 downto 1);
	O_KEYBOARD_JOYKEYS	: out std_logic_vector(4 downto 0);
	O_KEYBOARD_CTLKEYS	: out std_logic_vector(3 downto 0));
end deserializer;

architecture rtl of deserializer is
	type key_matrix is array (11 downto 0) of std_logic_vector(4 downto 0);
	signal keys		: key_matrix;
	signal row0, row1, row2, row3, row4, row5, row6, row7 : std_logic_vector(4 downto 0);
	signal count		: integer range 0 to 8;
	signal data		: std_logic_vector(7 downto 0);
	signal ready		: std_logic;
	signal device_id	: std_logic_vector(3 downto 0);

	signal x		: std_logic_vector(8 downto 0) := "111111111";
	signal y		: std_logic_vector(8 downto 0) := "000000000";
	signal z		: std_logic_vector(8 downto 0) := "111111111";
	signal b		: std_logic_vector(7 downto 0) := "00000000";
	
	signal key0		: std_logic_vector(7 downto 0);
	signal key1		: std_logic_vector(7 downto 0);
	signal key2		: std_logic_vector(7 downto 0);
	signal key3		: std_logic_vector(7 downto 0);
	signal key4		: std_logic_vector(7 downto 0);
	signal key5		: std_logic_vector(7 downto 0);
	signal key6		: std_logic_vector(7 downto 0);
	
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
	O_KEYBOARD_CTLKEYS 	<= keys(10)(3) & keys(11)(2) & keys(11)(3) & keys(11)(4);
	O_KEYBOARD_FKEYS	<= keys(11)(1) & keys(11)(0) & keys(10) & keys(9);
	O_KEY0			<= key0;
	O_KEY1			<= key1;
	O_KEY2			<= key2;
	O_KEY3			<= key3;
	O_KEY4			<= key4;
	O_KEY5			<= key5;
	O_KEY6			<= key6;
	-- Mouse
	O_MOUSE_BUTTONS		<= b;
	O_MOUSE_X		<= x(7 downto 0);
	O_MOUSE_Y		<= y(7 downto 0);
	O_MOUSE_Z		<= z(7 downto 0);
	
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
			keys(10) <= (others => '0');
			keys(11) <= (others => '0');
			count <= 0;
			x <= (others => '1');
			y <= (others => '0');
			z <= (others => '1');
			b <= (others => '0');
		elsif I_NEWFRAME = '0' then
			count <= 0;
		elsif I_CLK'event and I_CLK = '1' and ready = '1' then
			if count = 0 then
				count <= 1;
				device_id <= data(3 downto 0);
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
						keys(10) <= (others => '0');
						keys(11) <= (others => '0');
					when others => null;
				end case;
			else
				count <= count + 1;
				case device_id is
					when x"2" =>	-- Mouse
					-- Input report - 5 bytes
 					--     Byte | D7      D6      D5      D4      D3      D2      D1      D0
					--    ------+---------------------------------------------------------------------
					--      0   |  0       0       0    Forward  Back    Middle  Right   Left (Button)
					--      1   |                             X
					--      2   |                             Y
					--      3   |                       Vertical Wheel
					--      4   |                    Horizontal (Tilt) Wheel
					
						case count is
							when 1 => b <= data;		-- Buttons
							when 2 => x <= x + data;	-- Left/Right delta
							when 3 => y <= y + data;	-- Up/Down delta
							when 4 => z <= z + data;	-- Wheel delta
							when others => null;
						end case;
						
					when x"6" =>	-- Keyboard
						case count is
							when 1 => key0 <= data;	-- клавиши модификаторы
							when 3 => key1 <= data;	-- код клавиши 1
							when 4 => key2 <= data;	-- код клавиши 2
							when 5 => key3 <= data;	-- код клавиши 3
							when 6 => key4 <= data;	-- код клавиши 4
							when 7 => key5 <= data;	-- код клавиши 5
							when 8 => key6 <= data;	-- код клавиши 6
							when others => null;
						end case;

						if count = 1 then
--							if data(0) = '1' then keys(11)(3) <= '1'; end if;	-- E0 Left Control
							if data(1) = '1' then keys(0)(0) <= '0'; end if;	-- E1 Left shift (CAPS SHIFT)
--							if data(2) = '1' then rx_buffer <= X"E2"; end if;	-- E2 Left Alt
							if data(3) = '1' then keys(11)(3) <= '1'; end if;	-- E3 Left Gui
							if data(4) = '1' then keys(7)(1) <= '0'; end if;	-- E4 CTRL (Symbol Shift)
							if data(5) = '1' then keys(0)(0) <= '0'; end if;	-- E5 Right shift (CAPS SHIFT)
--							if data(6) = '1' then keys(11)(3) <= '1'; end if;	-- E6 Right Alt
--							if data(7) = '1' then keys(11)(3) <= '1'; end if;	-- E7 Right Gui
						else
							case data is
								when X"1d" =>	keys(0)(1) <= '0'; -- Z
								when X"1b" =>	keys(0)(2) <= '0'; -- X
								when X"06" =>	keys(0)(3) <= '0'; -- C
								when X"19" =>	keys(0)(4) <= '0'; -- V

								when X"04" =>	keys(1)(0) <= '0'; -- A
								when X"16" =>	keys(1)(1) <= '0'; -- S
								when X"07" =>	keys(1)(2) <= '0'; -- D
								when X"09" =>	keys(1)(3) <= '0'; -- F
								when X"0a" =>	keys(1)(4) <= '0'; -- G

								when X"14" =>	keys(2)(0) <= '0'; -- Q
								when X"1a" =>	keys(2)(1) <= '0'; -- W
								when X"08" =>	keys(2)(2) <= '0'; -- E
								when X"15" =>	keys(2)(3) <= '0'; -- R
								when X"17" =>	keys(2)(4) <= '0'; -- T

								when X"1e" =>	keys(3)(0) <= '0'; -- 1
								when X"1f" =>	keys(3)(1) <= '0'; -- 2
								when X"20" =>	keys(3)(2) <= '0'; -- 3
								when X"21" =>	keys(3)(3) <= '0'; -- 4
								when X"22" =>	keys(3)(4) <= '0'; -- 5

								when X"27" =>	keys(4)(0) <= '0'; -- 0
								when X"26" =>	keys(4)(1) <= '0'; -- 9
								when X"25" =>	keys(4)(2) <= '0'; -- 8
								when X"24" =>	keys(4)(3) <= '0'; -- 7
								when X"23" =>	keys(4)(4) <= '0'; -- 6

								when X"13" =>	keys(5)(0) <= '0'; -- P
								when X"12" =>	keys(5)(1) <= '0'; -- O
								when X"0c" =>	keys(5)(2) <= '0'; -- I
								when X"18" =>	keys(5)(3) <= '0'; -- U
								when X"1c" =>	keys(5)(4) <= '0'; -- Y

								when X"28" =>	keys(6)(0) <= '0'; -- ENTER
								when X"0f" =>	keys(6)(1) <= '0'; -- L
								when X"0e" =>	keys(6)(2) <= '0'; -- K
								when X"0d" =>	keys(6)(3) <= '0'; -- J
								when X"0b" =>	keys(6)(4) <= '0'; -- H

								when X"2c" =>	keys(7)(0) <= '0'; -- SPACE
								when X"10" =>	keys(7)(2) <= '0'; -- M
								when X"11" =>	keys(7)(3) <= '0'; -- N
								when X"05" =>	keys(7)(4) <= '0'; -- B

								-- Cursor keys
								when X"50" =>	keys(0)(0) <= '0'; -- Left (CAPS 5)
										keys(3)(4) <= '0';
								when X"51" =>	keys(0)(0) <= '0'; -- Down (CAPS 6)
										keys(4)(4) <= '0';
								when X"52" =>	keys(0)(0) <= '0'; -- Up (CAPS 7)
										keys(4)(3) <= '0';
								when X"4f" =>	keys(0)(0) <= '0'; -- Right (CAPS 8)
										keys(4)(2) <= '0';

								-- Other special keys sent to the ULA as key combinations
								when X"2a" =>	keys(0)(0) <= '0'; -- Backspace (CAPS 0)
										keys(4)(0) <= '0';
								when X"39" =>	keys(0)(0) <= '0'; -- Caps lock (CAPS 2)
										keys(3)(1) <= '0';
								when X"2b" =>	keys(0)(0) <= '0'; -- Tab (CAPS SPACE)
										keys(7)(0) <= '0';
								when X"37" =>	keys(7)(2) <= '0'; -- .
										keys(7)(1) <= '0';
								when X"2d" =>	keys(6)(3) <= '0'; -- -
										keys(7)(1) <= '0';
								when X"35" =>	keys(3)(0) <= '0'; -- ` (EDIT)
										keys(0)(0) <= '0';
								when X"36" =>	keys(7)(3) <= '0'; -- ,
										keys(7)(1) <= '0';
								when X"33" =>	keys(5)(1) <= '0'; -- ;
										keys(7)(1) <= '0';
								when X"34" =>	keys(5)(0) <= '0'; -- "
										keys(7)(1) <= '0';
								when X"31" =>	keys(0)(1) <= '0'; -- :
										keys(7)(1) <= '0';
								when X"2e" =>	keys(6)(1) <= '0'; -- =
										keys(7)(1) <= '0';
								when X"2f" =>	keys(4)(2) <= '0'; -- (
										keys(7)(1) <= '0';
								when X"30" =>	keys(4)(1) <= '0'; -- )
										keys(7)(1) <= '0';
								when X"38" =>	keys(0)(3) <= '0'; -- ?
										keys(7)(1) <= '0';
										
								-- Kempston keys
								when X"5e" =>	keys(8)(0) <= '1'; -- [6] (Right)
								when X"5c" =>	keys(8)(1) <= '1'; -- [4] (Left)
								when X"5a" =>	keys(8)(2) <= '1'; -- [2] (Down)
								when X"60" =>	keys(8)(3) <= '1'; -- [8] (Up)
								when X"62" =>	keys(8)(4) <= '1'; -- [0] (Fire)
		
								-- Fx keys
								when X"3a" =>	keys(9)(0) <= '1'; -- F1
								when X"3b" =>	keys(9)(1) <= '1'; -- F2
								when X"3c" =>	keys(9)(2) <= '1'; -- F3
								when X"3d" =>	keys(9)(3) <= '1'; -- F4
								when X"3e" =>	keys(9)(4) <= '1'; -- F5
								when X"3f" =>	keys(10)(0) <= '1'; -- F6
								when X"40" =>	keys(10)(1) <= '1'; -- F7
								when X"41" =>	keys(10)(2) <= '1'; -- F8
								when X"42" =>	keys(10)(3) <= '1'; -- F9
								when X"43" =>	keys(10)(4) <= '1'; -- F10
								when X"44" =>	keys(11)(0) <= '1'; -- F11
								when X"45" =>	keys(11)(1) <= '1'; -- F12
				 
								-- Soft keys
								when X"46" =>	keys(11)(2) <= '1'; -- PrtScr
								when X"48" =>	keys(11)(4) <= '1'; -- Pause
								
								when others => null;
							end case;
						end if;
					
					when others => null;
				end case;
			end if;
		end if;
	end process;

end architecture;
