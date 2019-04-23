-------------------------------------------------------------------[01.11.2014]
-- SPI Master
-------------------------------------------------------------------------------
-- Engineer: MVV <mvvproject@gmail.com>

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

entity spi is
	port (
		RESET		: in std_logic;
		CLK		: in std_logic;
		SCK		: in std_logic;
		DI		: in std_logic_vector(7 downto 0);
		DO		: out std_logic_vector(7 downto 0);
		WR		: in std_logic;
		BUSY		: out std_logic;
		SCLK		: out std_logic;
		MOSI		: out std_logic;
		MISO		: in std_logic);
end;

architecture rtl of spi is
	signal cnt		: std_logic_vector(2 downto 0) := "000";
	signal shift_reg	: std_logic_vector(7 downto 0) := "11111111";
	signal buffer_reg	: std_logic_vector(7 downto 0) := "11111111";
	signal state		: std_logic := '0';
	signal start		: std_logic := '0';
begin
	-- buffer_reg
	process (RESET, CLK, WR, DI)
	begin
		if (RESET = '1') then
			buffer_reg <= (others => '1');
		elsif (CLK'event and CLK = '1' and WR = '1') then
			buffer_reg <= DI;
		end if;
	end process;

	-- start
	process (RESET, CLK, WR, state)
	begin
		if (RESET = '1' or state = '1') then
			start <= '0';
		elsif (CLK'event and CLK = '1' and WR = '1') then
			start <= '1';
		end if;
	end process;

	process (RESET, SCK, start, buffer_reg)
	begin
		if (RESET = '1') then
			state <= '0';
			cnt <= "000";
			shift_reg <= "11111111";
		elsif (SCK'event and SCK = '0') then
			case state is
				when '0' =>
					if (start = '1') then
						shift_reg <= buffer_reg;
						cnt <= "000";
						state <= '1';
					end if;
				when '1' =>
					if (cnt	= "111") then state <= '0'; end if;
					shift_reg <= shift_reg(6 downto 0) & MISO;
					cnt <= cnt + 1;
				when others => null;
			end case;
		end if;
	end process;
	
BUSY <= state;
DO   <= shift_reg;
MOSI <= shift_reg(7);
SCLK <= SCK when state = '1' else '0';

end rtl;