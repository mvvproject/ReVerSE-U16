-------------------------------------------------------------------[01.09.2013]
-- SPI Master
-------------------------------------------------------------------------------
-- Engineer: 	MVV
--
-- 31.01.2011	Первая версия
-- 31.08.2013	Полностью переписан. Независимая работа от системного клока
-- 01.09.2013	Изменения в интерфейсе


library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

entity spi is
	port (
		RESET		: in std_logic;				-- 1 = сброс контроллера
		CLK		: in std_logic;				-- Системная тактовая частота
		SCK		: in std_logic;				-- SPI частота синхронизации передачи данных
		A       	: in std_logic;				-- Адрес: 0 = регистр данных; 1 = регистр управления 
		DI		: in std_logic_vector(7 downto 0);	-- Шина данных 8 бит, ввод
		DO		: out std_logic_vector(7 downto 0);	-- Шина данных 8 бит, вывод
		WR		: in std_logic;				-- 1 = разрешение записи в регистр данных или регистр управления
		BUSY		: out std_logic;			-- 1 = занято идет передача; 0 = свободно
		CS_n		: out std_logic;			-- Выход выбора подчиненного (выбор микросхемы)
		SCLK		: out std_logic;			-- Выход синхронизации передачи данных
		MOSI		: out std_logic;			-- Выход последовательной передачи данных
		MISO		: in std_logic );			-- Вход последовательного приема данных 
end;

architecture rtl of spi is
	signal cnt		: std_logic_vector(2 downto 0) := "000";	-- Счетчик передаваемых/принимаемых бит
	signal shift_reg	: std_logic_vector(7 downto 0) := "11111111";	-- Сдвиговый регистр
	signal cs		: std_logic := '1';
	signal buffer_reg	: std_logic_vector(7 downto 0) := "11111111";
	signal state		: std_logic := '0';
	signal start		: std_logic := '0';
begin
	-- SD CS
	process (RESET, CLK, A, WR, DI)
	begin
		if (RESET = '1') then
			cs <= '1';
		elsif (CLK'event and CLK = '1') then
			if (WR = '1' and A = '1') then
				cs <= DI(0);
			end if;
		end if;
	end process;
	
	-- buffer_reg
	process (RESET, CLK, A, WR, DI)
	begin
		if (RESET = '1') then
			buffer_reg <= (others => '1');
		elsif (CLK'event and CLK = '1') then
			if (WR = '1' and A = '0') then
				buffer_reg <= DI;
			end if;
		end if;
	end process;

	-- start
	process (RESET, CLK, A, WR, state)
	begin
		if (RESET = '1' or state = '1') then
			start <= '0';
		elsif (CLK'event and CLK = '1') then
			if (WR = '1' and A = '0') then
				start <= '1';
			end if;
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
DO 	 <= shift_reg;
CS_n <= cs;
MOSI <= shift_reg(7);
SCLK <= SCK when state = '1' else '0';

end rtl;