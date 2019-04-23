-------------------------------------------------------------------[26.10.2014]
-- VGA Text
-------------------------------------------------------------------------------
-- Engineer: 	MVV
-- Description: Text Mode 80x30, 4800 bytes, Font 8x16 4096 bytes
--
-- Versions:
-- V1.0		16.08.2014	Initial release.
-- V1.1		23.08.2014	Добавил палитру, аппаратный курсор
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use IEEE.STD_LOGIC_ARITH.all;

entity txt is port (
	CLK			: in std_logic; 			-- VGA dot clock 25MHz
	CLKEN			: in std_logic;
	CHAR_DI			: in std_logic_vector(15 downto 0);
	FONT_DI			: in std_logic_vector(7 downto 0);
	HCNT			: in std_logic_vector(9 downto 0);
	HCNT_REG		: in std_logic_vector(9 downto 0);
	VCNT			: in std_logic_vector(9 downto 0);
	BLANK			: in std_logic;
	CURSOR_X		: in std_logic_vector(6 downto 0);	-- 0..79
	CURSOR_Y		: in std_logic_vector(4 downto 0);	-- 0..29
	CURSOR_COLOR		: in std_logic_vector(7 downto 0);	-- 7=type 0:big;1:small, 6..4=Paper(RGB), 3=Bright, 2..0=Ink(RGB)
	CHAR_ADDR		: out std_logic_vector(11 downto 0);
	FONT_ADDR		: out std_logic_vector(11 downto 0);
	R			: out std_logic_vector(7 downto 0); 	-- red
	G			: out std_logic_vector(7 downto 0); 	-- green
	B			: out std_logic_vector(7 downto 0)); 	-- blue
end entity;

architecture rtl of txt is
	signal pixel		: std_logic;
	signal color		: std_logic_vector(3 downto 0);
	signal rgb		: std_logic_vector(23 downto 0);
	signal tmp		: std_logic_vector(1 downto 0);
	signal cursor		: std_logic;
	signal counter		: std_logic_vector(23 downto 0);
begin
	process (CLK, CLKEN, FONT_DI, HCNT_REG)
	begin
		case HCNT_REG(2 downto 0) is
			when "000" => pixel <= FONT_DI(7);
			when "001" => pixel <= FONT_DI(6);
			when "010" => pixel <= FONT_DI(5);
			when "011" => pixel <= FONT_DI(4);
			when "100" => pixel <= FONT_DI(3);
			when "101" => pixel <= FONT_DI(2);
			when "110" => pixel <= FONT_DI(1);
			when "111" => pixel <= FONT_DI(0);
			when  others => null;
		end case;
	end process;

	-- 7=Bright Paper, 6..4=Paper(RGB), 3=Bright Ink, 2..0=Ink(RGB)
	process (tmp, CHAR_DI, CURSOR_COLOR)
	begin
		case tmp is
			when "00" => color <= CHAR_DI(15 downto 12);
			when "01" => color <= CHAR_DI(11 downto 8);
			when "10" => color <= CURSOR_COLOR(7 downto 4);
			when "11" => color <= CURSOR_COLOR(3 downto 0);
			when  others => null;
		end case;
	end process;

	-- Hardware Cursor
	cursor <= '1' when ((HCNT(9 downto 3) = CURSOR_X) and (VCNT(8 downto 4) = CURSOR_Y) and counter(23) = '1') and ((CURSOR_COLOR(7) = '0') or (CURSOR_COLOR(7) = '1' and VCNT(3 downto 0) > 13)) else '0';
	tmp <= cursor & pixel;

	process (CLK)
	begin
		if CLK'event and CLK = '1' then
			counter <= counter + 1;
		end if;
	end process;

	-- Make an 24 colors table specifying the color values for each of the basic named set of 16 colors.
	process (color)
	begin
		case color is
			when "0000" => rgb <= x"000000";	-- Black
			when "0001" => rgb <= x"000080";	-- Navy
			when "0010" => rgb <= x"009900";	-- Green
			when "0011" => rgb <= x"009999";	-- Teal
			when "0100" => rgb <= x"800000";	-- Maroon
			when "0101" => rgb <= x"800080";	-- Purple
			when "0110" => rgb <= x"999900";	-- Olive
			when "0111" => rgb <= x"cccccc";	-- Silver
			when "1000" => rgb <= x"808080";	-- Gray
			when "1001" => rgb <= x"0000ff";	-- Blue
			when "1010" => rgb <= x"00ff00";	-- Lime
			when "1011" => rgb <= x"00ffff";	-- Aqua
			when "1100" => rgb <= x"ff0000";	-- Red
			when "1101" => rgb <= x"ff00ff";	-- Fuchsia
			when "1110" => rgb <= x"ffff00";	-- Yellow
			when "1111" => rgb <= x"ffffff";	-- White
			when  others => null;
		end case;
	end process;

	R <= rgb(23 downto 16);
	G <= rgb(15 downto 8);
	B <= rgb(7 downto 0);

	CHAR_ADDR <= VCNT(8 downto 4) * conv_std_logic_vector(80,7) + HCNT(9 downto 3);
	FONT_ADDR <= CHAR_DI(7 downto 0) & VCNT(3 downto 0);

end architecture;