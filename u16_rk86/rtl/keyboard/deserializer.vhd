-------------------------------------------------------------------[27.02.2016]
-- CONTROLLER USB HID
-------------------------------------------------------------------------------
-- Engineer: 	MVV

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
	O_DATA			: out std_logic_vector(7 downto 0);
	O_SHIFT			: out std_logic_vector(2 downto 0);
	O_K_RESET		: out std_logic);
end deserializer;

architecture rtl of deserializer is
	type key_matrix is array (7 downto 0) of std_logic_vector(7 downto 0);	-- multi-dimensional array of key matrix 
	signal keymatrix	: key_matrix;
	signal shifts		: std_logic_vector(2 downto 0);
	signal kres		: std_logic;
	signal device_id	: std_logic_vector(3 downto 0);
	signal ready		: std_logic;	
	signal count		: integer range 0 to 8;
	signal data		: std_logic_vector(7 downto 0);
	signal row0, row1, row2, row3, row4, row5, row6, row7 : std_logic_vector(7 downto 0);
	
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
	row0	<= keymatrix(0) when I_ADDR(0) = '0' else (others => '1');
	row1	<= keymatrix(1) when I_ADDR(1) = '0' else (others => '1');
	row2	<= keymatrix(2) when I_ADDR(2) = '0' else (others => '1');
	row3	<= keymatrix(3) when I_ADDR(3) = '0' else (others => '1');
	row4	<= keymatrix(4) when I_ADDR(4) = '0' else (others => '1');
	row5	<= keymatrix(5) when I_ADDR(5) = '0' else (others => '1');
	row6	<= keymatrix(6) when I_ADDR(6) = '0' else (others => '1');
	row7	<= keymatrix(7) when I_ADDR(7) = '0' else (others => '1');
	
	-- Keyboard
	O_SHIFT 	<= shifts;
	O_K_RESET 	<= kres;
	O_DATA 		<= row0 and row1 and row2 and row3 and row4 and row5 and row6 and row7;
	
	process (I_RESET, I_CLK, data, I_NEWFRAME, ready)
	begin
		if I_RESET = '1' then
			keymatrix(0) <= (others => '1');
			keymatrix(1) <= (others => '1');
			keymatrix(2) <= (others => '1');
			keymatrix(3) <= (others => '1');
			keymatrix(4) <= (others => '1');
			keymatrix(5) <= (others => '1');
			keymatrix(6) <= (others => '1');
			keymatrix(7) <= (others => '1');
			shifts <= (others => '1');
			count <= 0;
			kres <= '0';
		elsif I_NEWFRAME = '0' then
			count <= 0;
		elsif I_CLK'event and I_CLK = '1' and ready = '1' then
			if count = 0 then
				count <= 1;
				device_id <= data(3 downto 0);
				case data(3 downto 0) is
					when x"6" =>	-- Keyboard
						keymatrix(0) <= (others => '1');
						keymatrix(1) <= (others => '1');
						keymatrix(2) <= (others => '1');
						keymatrix(3) <= (others => '1');
						keymatrix(4) <= (others => '1');
						keymatrix(5) <= (others => '1');
						keymatrix(6) <= (others => '1');
						keymatrix(7) <= (others => '1');
						shifts <= (others => '1');
						kres <= '0';
					when others => null;
				end case;
			else
				count <= count + 1;
				case device_id is
					when x"6" =>	-- Keyboard
						if count = 1 then
--							if data(0) = '1' then keymatrix(7)(1) <= '0'; end if;	-- E0 Left Control
							if data(1) = '1' then shifts(0) <= '0'; end if;		-- E1 Left Shift (CAPS SHIFT)
							if data(2) = '1' then shifts(2) <= '0'; end if;		-- E2 Left Alt
--							if data(3) = '1' then keymatrix(7)(1) <= '0'; end if;	-- E3 Left Gui
							if data(4) = '1' then shifts(1) <= '0'; end if;		-- E4 CTRL (Symbol Shift)
							if data(5) = '1' then shifts(0) <= '0'; end if;		-- E5 Right Shift (CAPS SHIFT)
							if data(6) = '1' then shifts(2) <= '0'; end if;		-- E6 Right Alt
--							if data(7) = '1' then keymatrix(7)(1) <= '0'; end if;	-- E7 Right Gui
						else
							case data is
								when X"1d" =>	keymatrix(7)(2) <= '0';	-- Z
								when X"1b" =>	keymatrix(7)(0) <= '0';	-- X
								when X"06" =>	keymatrix(4)(3) <= '0';	-- C
								when X"19" =>	keymatrix(6)(6) <= '0';	-- V

								when X"04" =>	keymatrix(4)(1) <= '0';	-- A
								when X"16" =>	keymatrix(6)(3) <= '0';	-- S
								when X"07" =>	keymatrix(4)(4) <= '0';	-- D
								when X"09" =>	keymatrix(4)(6) <= '0';	-- F
								when X"0a" =>	keymatrix(4)(7) <= '0';	-- G

								when X"14" =>	keymatrix(6)(1) <= '0';	-- Q
								when X"1a" =>	keymatrix(6)(7) <= '0';	-- W
								when X"08" =>	keymatrix(4)(5) <= '0';	-- E
								when X"15" =>	keymatrix(6)(2) <= '0';	-- R
								when X"17" =>	keymatrix(6)(4) <= '0';	-- T

								when X"1e" =>	keymatrix(2)(1) <= '0';	-- 1
								when X"1f" =>	keymatrix(2)(2) <= '0';	-- 2
								when X"20" =>	keymatrix(2)(3) <= '0';	-- 3
								when X"21" =>	keymatrix(2)(4) <= '0';	-- 4
								when X"22" =>	keymatrix(2)(5) <= '0';	-- 5

								when X"27" =>	keymatrix(2)(0) <= '0';	-- 0
								when X"26" =>	keymatrix(3)(1) <= '0';	-- 9
								when X"25" =>	keymatrix(3)(0) <= '0';	-- 8
								when X"24" =>	keymatrix(2)(7) <= '0';	-- 7
								when X"23" =>	keymatrix(2)(6) <= '0';	-- 6

								when X"13" =>	keymatrix(6)(0) <= '0';	-- P
								when X"12" =>	keymatrix(5)(7) <= '0';	-- O
								when X"0c" =>	keymatrix(5)(1) <= '0';	-- I
								when X"18" =>	keymatrix(6)(5) <= '0';	-- U
								when X"1c" =>	keymatrix(7)(1) <= '0';	-- Y

								when X"28" =>	keymatrix(1)(2) <= '0';	-- ENTER (ВК)
								when X"0f" =>	keymatrix(5)(4) <= '0';	-- L
								when X"0e" =>	keymatrix(5)(3) <= '0';	-- K
								when X"0d" =>	keymatrix(5)(2) <= '0';	-- J
								when X"0b" =>	keymatrix(5)(0) <= '0';	-- H

								when X"2c" =>	keymatrix(7)(7) <= '0';	-- SPACE
								when X"10" =>	keymatrix(5)(5) <= '0';	-- M
								when X"11" =>	keymatrix(5)(6) <= '0';	-- N
								when X"05" =>	keymatrix(4)(2) <= '0';	-- B

								-- Cursor keys
								when X"50" =>	keymatrix(1)(4) <= '0';	-- Left
								when X"51" =>	keymatrix(1)(7) <= '0';	-- Down
								when X"52" =>	keymatrix(1)(5) <= '0';	-- Up
								when X"4f" =>	keymatrix(1)(6) <= '0';	-- Right

								-- Other special keys sent to the ULA as key combinations
								when X"2a" =>	keymatrix(1)(3) <= '0';	-- Backspace (ЗБ)
								when X"39" =>	keymatrix(7)(2) <= '0'; -- Caps lock
								when X"2b" =>	keymatrix(1)(0) <= '0';	-- Tab (ТАБ)
								when X"37" =>	keymatrix(3)(6) <= '0';	-- .
								when X"2d" =>	keymatrix(3)(5) <= '0';	-- -
								when X"35" =>	keymatrix(7)(6) <= '0';	-- `
								when X"36" =>	keymatrix(3)(4) <= '0';	-- ,
--								when X"33" =>	keymatrix(5)(1) <= '0';	-- ;
--								when X"34" =>	keymatrix(5)(0) <= '0';	-- "
--								when X"31" =>	keymatrix(0)(1) <= '0';	-- :
								when X"2e" =>	keymatrix(3)(2) <= '0';	-- =
--								when X"2f" =>	keymatrix(4)(2) <= '0';	-- (
--								when X"30" =>	keymatrix(4)(1) <= '0';	-- )
--								when X"38" =>	keymatrix(0)(3) <= '0';	-- ?
										
								-- Num keys
								when X"5e" =>	keymatrix(1)(6) <= '0';	-- [6] (Right)
								when X"5c" =>	keymatrix(1)(4) <= '0';	-- [4] (Left)
								when X"5a" =>	keymatrix(1)(7) <= '0';	-- [2] (Down)
								when X"60" =>	keymatrix(1)(5) <= '0';	-- [8] (Up)
--								when X"62" =>	keymatrix(7)(4) <= '0';	-- [0]
	
								-- Fx keys
								when X"3a" =>	keymatrix(0)(3) <= '0';	-- F1
								when X"3b" =>	keymatrix(0)(4) <= '0';	-- F2
								when X"3c" =>	keymatrix(0)(5) <= '0';	-- F3
								when X"3d" =>	keymatrix(0)(6) <= '0';	-- F4
								when X"3e" =>	keymatrix(0)(7) <= '0';	-- F5
--								when X"3f" =>	keymatrix(7)(1) <= '0';	-- F6
--								when X"40" =>	keymatrix(7)(1) <= '0';	-- F7
--								when X"41" =>	keymatrix(7)(1) <= '0';	-- F8
--								when X"42" =>	keymatrix(7)(1) <= '0';	-- F9
--								when X"43" =>	keymatrix(7)(1) <= '0';	-- F10
--								when X"44" =>	keymatrix(7)(1) <= '0';	-- F11
								when X"45" =>	kres <= '1';		-- F12 (Reset)
				 
								-- Soft keys
--								when X"46" =>	keymatrix(7)(2) <= '0';	-- PrtScr
								when X"47" =>	keymatrix(1)(1) <= '0';	-- Scroll Lock (ПС)
--								when X"48" =>	keymatrix(7)(4) <= '0';	-- Pause
--								when X"65" =>	keymatrix(7)(1) <= '0';	-- WinMenu
								when X"29" =>	keymatrix(0)(2) <= '0';	-- Esc (АР2)
--								when X"49" =>	keymatrix(7)(1) <= '0';	-- Insert
								when X"4a" =>	keymatrix(0)(0) <= '0';	-- Home (Курсор в начало экрана)
--								when X"4b" =>	keymatrix(7)(1) <= '0';	-- Page Up
								when X"4c" =>	keymatrix(0)(1) <= '0';	-- Delete (СТР)
--								when X"4d" =>	keymatrix(7)(1) <= '0';	-- End
--								when X"4e" =>	keymatrix(7)(1) <= '0';	-- Page Down
		
								when others => null;
							end case;
						end if;
					
					when others => null;
				end case;
			end if;
		end if;
	end process;

end architecture;
