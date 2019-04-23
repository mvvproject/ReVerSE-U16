-------------------------------------------------------------------[30.03.2017]
-- CONTROLLER USB HID scancode to matrix conversion
-------------------------------------------------------------------------------
-- Engineer: MVV <mvvproject@gmail.com>

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
	I_KEY_ROW		: in std_logic_vector(3 downto 0);
	O_MOUSE0_X		: out std_logic_vector(7 downto 0);
	O_MOUSE0_Y		: out std_logic_vector(7 downto 0);
	O_MOUSE0_Z		: out std_logic_vector(7 downto 0);
	O_MOUSE0_BUTTONS	: out std_logic_vector(7 downto 0);
	O_MOUSE1_X		: out std_logic_vector(7 downto 0);
	O_MOUSE1_Y		: out std_logic_vector(7 downto 0);
	O_MOUSE1_Z		: out std_logic_vector(7 downto 0);
	O_MOUSE1_BUTTONS	: out std_logic_vector(7 downto 0);
	O_KEY_SCAN		: out std_logic_vector(7 downto 0);
	O_KEY_F			: out std_logic_vector(7 downto 0);
	O_GAMEPAD		: out std_logic_vector(13 downto 0));
end deserializer;

architecture rtl of deserializer is
	type key_matrix is array (11 downto 0) of std_logic_vector(7 downto 0);
	signal keys		: key_matrix;
	signal count		: integer range 0 to 8;
	signal data		: std_logic_vector(7 downto 0);
	signal ready		: std_logic;
	signal device_id	: std_logic_vector(7 downto 0);
	signal shift		: std_logic;
	signal ru		: std_logic;

	signal x0		: std_logic_vector(8 downto 0) := "111111111";
	signal y0		: std_logic_vector(8 downto 0) := "000000000";
	signal z0		: std_logic_vector(8 downto 0) := "111111111";
	signal b0		: std_logic_vector(7 downto 0) := "00000000";
	signal x1		: std_logic_vector(8 downto 0) := "111111111";
	signal y1		: std_logic_vector(8 downto 0) := "000000000";
	signal z1		: std_logic_vector(8 downto 0) := "111111111";
	signal b1		: std_logic_vector(7 downto 0) := "00000000";

	signal gamepad		: std_logic_vector(13 downto 0) := "00000000000000";
	
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

	-- Output addressed row
	process (I_KEY_ROW, keys)
	begin
		case I_KEY_ROW is
			when X"0" => O_KEY_SCAN <= keys(0);
			when X"1" => O_KEY_SCAN <= keys(1);
			when X"2" => O_KEY_SCAN <= keys(2);
			when X"3" => O_KEY_SCAN <= keys(3);
			when X"4" => O_KEY_SCAN <= keys(4);
			when X"5" => O_KEY_SCAN <= keys(5);
			when X"6" => O_KEY_SCAN <= keys(6);
			when X"7" => O_KEY_SCAN <= keys(7);
			when X"8" => O_KEY_SCAN <= keys(8);
			when X"9" => O_KEY_SCAN <= keys(9);
			when X"A" => O_KEY_SCAN <= keys(10);
			when others => O_KEY_SCAN <= (others => '1');
		end case;
	end process;

	
	-- | b7  | b6   | b5   | b4   | b3  | b2  | b1  | b0  |
	-- | SHI | --   | PgUp | PgDn | F9  | F10 | F11 | F12 |
	O_KEY_F			<= keys(6)(0) & '1' & keys(11)(5 downto 0);
	-- Mouse
	O_MOUSE0_BUTTONS	<= b0;
	O_MOUSE0_X		<= x0(7 downto 0);
	O_MOUSE0_Y		<= y0(7 downto 0);
	O_MOUSE0_Z		<= z0(7 downto 0);
	O_MOUSE1_BUTTONS	<= b1;
	O_MOUSE1_X		<= x1(7 downto 0);
	O_MOUSE1_Y		<= y1(7 downto 0);
	O_MOUSE1_Z		<= z1(7 downto 0);
	-- Gamepad
	O_GAMEPAD		<= gamepad;


	
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
			keys(8) <= (others => '1');
			keys(9) <= (others => '1');
			keys(10) <= (others => '1');
			keys(11) <= (others => '1');
			shift <= '0';
			ru <= '0';

			count <= 0;
			x0 <= (others => '1');
			y0 <= (others => '0');
			z0 <= (others => '1');
			b0 <= (others => '0');
			x1 <= (others => '1');
			y1 <= (others => '0');
			z1 <= (others => '1');
			b1 <= (others => '0');
			gamepad <= (others => '0');
			
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
						keys(8) <= (others => '1');
						keys(9) <= (others => '1');
						keys(10) <= (others => '1');
						keys(11) <= (others => '1');
						shift <= '0';
					when others => null;
				end case;
			else
				count <= count + 1;
				case device_id is
					when x"02" =>	-- HID0 Mouse
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
--							when 2 => x0 <= x0 + data;	-- Left/Right delta
--							when 3 => y0 <= y0 + data;	-- Up/Down delta
--							when 4 => z0 <= z0 + data;	-- Wheel delta
							when 2 => x0(7 downto 0) <= data;	-- Left/Right delta
							when 3 => y0(7 downto 0) <= data;	-- Up/Down delta
							when 4 => z0(7 downto 0) <= data;	-- Wheel delta

							when others => null;
						end case;
					when x"82" =>	-- HID1 Mouse
						case count is
							when 1 => b1 <= data;		-- Buttons
							when 2 => x1 <= x1 + data;	-- Left/Right delta
							when 3 => y1 <= y1 + data;	-- Up/Down delta
							when 4 => z1 <= z1 + data;	-- Wheel delta
							when others => null;
						end case;
					
					when x"04" | x"84" => -- Gamepad (Defender Game Master G2)
						case count is
							when 4 => gamepad(0) <= data(7);		-- [Right]
								  gamepad(1) <= not data(6);		-- [Left]
							when 5 => gamepad(2) <= data(7);		-- [Down]
								  gamepad(3) <= not data(6);		-- [Up]
							when 6 => gamepad(6) <= data(4);		-- [1]
								  gamepad(5) <= data(5);		-- [2]
								  gamepad(4) <= data(6);		-- [3]
								  gamepad(7) <= data(7);		-- [4]
							when 7 => gamepad(8) <= data(1);		-- [R1]
								  gamepad(9) <= data(3);		-- [R2]
								  gamepad(10) <= data(0);		-- [L1]
								  gamepad(11) <= data(2);		-- [L2]
								  gamepad(12) <= data(4);		-- [9]
								  gamepad(13) <= data(5);		-- [10]
							when others => null;
						end case;					
					
					when x"06" | x"86" =>	-- Keyboard
						if count = 1 then
--							if data(0) = '1' then keys(0)(0) <= '1'; end if;	-- E0 Left Control
							if data(1) = '1' then keys(6)(0) <= '0'; shift <= '1'; end if;	-- E1 Left Shift
--							if data(2) = '1' then keys(0)(0) <= '0'; end if;	-- E2 Left Alt
--							if data(3) = '1' then keys(0)(0) <= '1'; end if;	-- E3 Left GUI
--							if data(4) = '1' then keys(0)(0) <= '0'; end if;	-- E4 Right Control
							if data(5) = '1' then keys(6)(0) <= '0'; shift <= '1'; end if;	-- E5 Right Shift
--							if data(6) = '1' then keys(0)(0) <= '1'; end if;	-- E6 Right Alt
--							if data(7) = '1' then keys(0)(0) <= '1'; end if;	-- E7 Right GUI
						else
							case data is
								when X"04" => 	if ru = '0' then keys(2)(6) <= '0'; else keys(2)(6) <= '0'; end if;	-- a A ф Ф
								when X"05" =>	if ru = '0' then keys(2)(7) <= '0'; else keys(2)(7) <= '0'; end if;	-- b B и И
								when X"06" =>	if ru = '0' then keys(3)(0) <= '0'; else keys(3)(0) <= '0'; end if;	-- c C с С					
								when X"07" =>	if ru = '0' then keys(3)(1) <= '0'; else keys(3)(1) <= '0'; end if;	-- d D в В					
								when X"08" =>	if ru = '0' then keys(3)(2) <= '0'; else keys(3)(2) <= '0'; end if;	-- e E у У					
								when X"09" =>	if ru = '0' then keys(3)(3) <= '0'; else keys(3)(3) <= '0'; end if;	-- f F а А					
								when X"0A" =>	if ru = '0' then keys(3)(4) <= '0'; else keys(3)(4) <= '0'; end if;	-- g G п П
								when X"0B" =>	if ru = '0' then keys(3)(5) <= '0'; else keys(3)(5) <= '0'; end if;	-- h H р Р
								when X"0C" =>	if ru = '0' then keys(3)(6) <= '0'; else keys(3)(6) <= '0'; end if;	-- i I ш Ш
								when X"0D" =>	if ru = '0' then keys(3)(7) <= '0'; else keys(3)(7) <= '0'; end if;	-- j J о О
								when X"0E" =>	if ru = '0' then keys(4)(0) <= '0'; else keys(4)(0) <= '0'; end if;	-- k K л Л
								when X"0F" =>	if ru = '0' then keys(4)(1) <= '0'; else keys(4)(1) <= '0'; end if;	-- l L д Д
								when X"10" =>	if ru = '0' then keys(4)(2) <= '0'; else keys(4)(2) <= '0'; end if;	-- m M ь Ь
								when X"11" =>	if ru = '0' then keys(4)(3) <= '0'; else keys(4)(3) <= '0'; end if;	-- n N т Т
								when X"12" =>	if ru = '0' then keys(4)(4) <= '0'; else keys(4)(4) <= '0'; end if;	-- o O щ Щ
								when X"13" =>	if ru = '0' then keys(4)(5) <= '0'; else keys(4)(5) <= '0'; end if;	-- p P з З
								when X"14" =>	if ru = '0' then keys(4)(6) <= '0'; else keys(4)(6) <= '0'; end if;	-- q Q й Й
								when X"15" =>	if ru = '0' then keys(4)(7) <= '0'; else keys(4)(7) <= '0'; end if;	-- r R к К
								when X"16" =>	if ru = '0' then keys(5)(0) <= '0'; else keys(5)(0) <= '0'; end if;	-- s S ы Ы
								when X"17" =>	if ru = '0' then keys(5)(1) <= '0'; else keys(5)(1) <= '0'; end if;	-- t T е Е
								when X"18" =>	if ru = '0' then keys(5)(2) <= '0'; else keys(5)(2) <= '0'; end if;	-- u U г Г
								when X"19" =>	if ru = '0' then keys(5)(3) <= '0'; else keys(5)(3) <= '0'; end if;	-- v V м М
								when X"1A" =>	if ru = '0' then keys(5)(4) <= '0'; else keys(5)(4) <= '0'; end if;	-- w W ц Ц
								when X"1B" =>	if ru = '0' then keys(5)(5) <= '0'; else keys(5)(5) <= '0'; end if;	-- x X ч Ч
								when X"1C" =>	if ru = '0' then keys(5)(6) <= '0'; else keys(5)(6) <= '0'; end if;	-- y Y н Н
								when X"1D" =>	if ru = '0' then keys(5)(7) <= '0'; else keys(5)(7) <= '0'; end if;	-- z Z я Я
								when X"1E" =>	keys(0)(1) <= '0';	-- 1 !
								when X"1F" =>	if shift = '0' then keys(0)(2) <= '0'; else if ru = '0' then keys(0)(2) <= '0'; else keys(0)(3) <= '0'; end if; end if;	-- 2 @ "
								when X"20" =>	keys(0)(3) <= '0';	-- 3 #
								when X"21" =>	if shift = '0' then keys(0)(4) <= '0'; else if ru = '0' then keys(0)(4) <= '0'; else keys(1)(7) <= '0'; end if; end if;	-- 4 $ ;
								when X"22" =>	keys(0)(5) <= '0';	-- 5 %
								when X"23" =>	if shift = '0' then keys(0)(6) <= '0'; else if ru = '0' then keys(0)(6) <= '0'; else keys(1)(6) <= '0'; end if; end if;	-- 6 ^ :
								when X"24" =>	if shift = '0' then keys(0)(7) <= '0'; else if ru = '0' then keys(0)(7) <= '0'; else keys(2)(5) <= '0'; end if; end if;	-- 7 & ?
								when X"25" =>	if shift = '0' then keys(1)(0) <= '0'; else keys(1)(0) <= '0'; end if;	-- 8 *
								when X"26" =>	if shift = '0' then keys(1)(1) <= '0'; else keys(1)(1) <= '0'; end if;	-- 9 (
								when X"27" =>	if shift = '0' then keys(0)(0) <= '0'; else keys(0)(0) <= '0'; end if;	-- 0 )
								when X"28" =>	keys(7)(7) <= '0';	-- Return
								when X"29" =>	keys(7)(2) <= '0';	-- Escape
								when X"2A" =>	keys(7)(5) <= '0';	-- Backspace
								when X"2B" =>	keys(7)(3) <= '0';	-- Tab
								when X"2C" =>	keys(8)(0) <= '0';	-- Space
								when X"2D" =>	keys(1)(2) <= '0';	-- - _
								when X"2E" =>	keys(1)(3) <= '0';	-- = +
								when X"2F" =>	if shift = '0' then keys(1)(5) <= '0'; else if ru = '0' then keys(1)(5) <= '0'; else keys(1)(5) <= '0'; end if; end if;	-- [ { х Х
								when X"30" =>	if shift = '0' then keys(1)(6) <= '0'; else if ru = '0' then keys(1)(6) <= '0'; else keys(1)(4) <= '0'; end if; end if;	-- ] } ъ Ъ
								when X"31" =>	if shift = '0' then keys(1)(4) <= '0'; else if ru = '0' then keys(1)(4) <= '0'; else keys(2)(5) <= '0'; end if; end if;	-- \ | \ /
								when X"33" =>	if shift = '0' then keys(1)(7) <= '0'; else if ru = '0' then keys(1)(7) <= '0'; else keys(1)(7) <= '0'; end if; end if;	-- ; : ж Ж
								when X"34" =>	if shift = '0' then keys(2)(0) <= '0'; else if ru = '0' then keys(2)(0) <= '0'; else keys(2)(0) <= '0'; end if; end if;	-- ' " э Э
								when X"35" =>	if shift = '0' then keys(2)(1) <= '0'; else if ru = '0' then keys(2)(1) <= '0'; else keys(5)(1) <= '0'; end if; end if;	-- ` ~ ё Ё
								when X"36" =>	if shift = '0' then keys(2)(2) <= '0'; else if ru = '0' then keys(2)(2) <= '0'; else keys(2)(2) <= '0'; end if; end if;	-- , < б Б
								when X"37" =>	if shift = '0' then keys(2)(3) <= '0'; else if ru = '0' then keys(2)(3) <= '0'; else keys(2)(3) <= '0'; end if; end if;	-- . > ю Ю
								when X"38" =>	if ru = '0' then if shift = '0' then keys(2)(4) <= '0'; else keys(2)(4) <= '0'; end if; else if shift = '0' then keys(5)(0) <= '0'; else keys(5)(0) <= '0'; end if; end if;	-- / ? . ,
								when X"39" =>	keys(6)(3) <= '0';	-- Caps Lock
								when X"3A" =>	keys(6)(5) <= '0';	-- F1
								when X"3B" =>	keys(6)(6) <= '0';	-- F2
								when X"3C" =>	keys(6)(7) <= '0';	-- F3
								when X"3D" =>	keys(7)(0) <= '0';	-- F4
								when X"3E" =>	keys(7)(1) <= '0';	-- F5
								when X"3F" =>	keys(6)(2) <= '0';	-- F6
								when X"40" =>	keys(6)(4) <= '0'; ru <= not ru;	-- F7
								when X"41" =>	keys(7)(6) <= '0';	-- F8
								when X"42" =>	keys(11)(3) <= '0';	-- F9
								when X"43" =>	keys(11)(2) <= '0';	-- F10
								when X"44" =>	keys(11)(1) <= '0';	-- F11
								when X"45" =>	keys(11)(0) <= '0';	-- F12
--								when X"46" =>	keys(0)(0) <= '0';	-- Print Screen
--								when X"47" =>	keys(0)(0) <= '0';	-- Scroll Lock
--								when X"48" =>	keys(0)(0) <= '0';	-- Pause
								when X"49" =>	keys(8)(2) <= '0';	-- Insert
								when X"4A" =>	keys(8)(1) <= '0';	-- Home
								when X"4B" =>	keys(11)(5) <= '0';	-- Page Up
								when X"4C" =>	keys(8)(3) <= '0';	-- Delete
								when X"4D" =>	keys(7)(4) <= '0';	-- End
								when X"4E" =>	keys(11)(4) <= '0';	-- Page Down
								when X"4F" =>	keys(8)(7) <= '0';	-- Right Arrow
								when X"50" =>	keys(8)(4) <= '0';	-- Left Arrow
								when X"51" =>	keys(8)(6) <= '0';	-- Down Arrow
								when X"52" =>	keys(8)(5) <= '0';	-- Up Arrow

								when others => null;
							end case;
						end if;
					
					when others => null;
				end case;
			end if;
		end if;
	end process;

end architecture;
