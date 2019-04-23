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

entity spi_flash is
	port (
		I_RESET		: in std_logic;				-- 1 = сброс контроллера
		I_CLK		: in std_logic;				-- Системная тактовая частота
		I_SCK		: in std_logic;				-- SPI частота синхронизации передачи данных
		I_ADDR       	: in std_logic;				-- Адрес: 0 = регистр данных; 1 = регистр управления 
		I_DATA		: in std_logic_vector(7 downto 0);	-- Шина данных 8 бит, ввод
		O_DATA		: out std_logic_vector(7 downto 0);	-- Шина данных 8 бит, вывод
		I_WR		: in std_logic;				-- 1 = разрешение записи в регистр данных или регистр управления
		O_BUSY		: out std_logic;			-- 1 = занято идет передача; 0 = свободно
		O_CS_N		: out std_logic;			-- Выход выбора подчиненного (выбор микросхемы)
		O_SCLK		: out std_logic;			-- Выход синхронизации передачи данных
		O_MOSI		: out std_logic;			-- Выход последовательной передачи данных
		I_MISO		: in std_logic );			-- Вход последовательного приема данных 
end;

architecture rtl of spi_flash is
	signal cnt		: std_logic_vector(2 downto 0) := "000";	-- Счетчик передаваемых/принимаемых бит
	signal shift_reg	: std_logic_vector(7 downto 0) := "11111111";	-- Сдвиговый регистр
	signal cs		: std_logic := '1';
	signal buffer_reg	: std_logic_vector(7 downto 0) := "11111111";
	signal state		: std_logic := '0';
	signal start		: std_logic := '0';
begin
	-- SD CS
	process (I_RESET, I_CLK, I_ADDR, I_WR, I_DATA)
	begin
		if (I_RESET = '1') then
			cs <= '1';
		elsif (I_CLK'event and I_CLK = '1') then
			if (I_WR = '1' and I_ADDR = '1') then
				cs <= I_DATA(0);
			end if;
		end if;
	end process;
	
	-- buffer_reg
	process (I_RESET, I_CLK, I_ADDR, I_WR, I_DATA)
	begin
		if (I_RESET = '1') then
			buffer_reg <= (others => '1');
		elsif (I_CLK'event and I_CLK = '1') then
			if (I_WR = '1' and I_ADDR = '0') then
				buffer_reg <= I_DATA;
			end if;
		end if;
	end process;

	-- start
	process (I_RESET, I_CLK, I_ADDR, I_WR, state)
	begin
		if (I_RESET = '1' or state = '1') then
			start <= '0';
		elsif (I_CLK'event and I_CLK = '1') then
			if (I_WR = '1' and I_ADDR = '0') then
				start <= '1';
			end if;
		end if;
	end process;

	process (I_RESET, I_SCK, start, buffer_reg)
	begin
		if (I_RESET = '1') then
			state <= '0';
			cnt <= "000";
			shift_reg <= "11111111";
		elsif (I_SCK'event and I_SCK = '0') then
			case state is
				when '0' =>
					if (start = '1') then
						shift_reg <= buffer_reg;
						cnt <= "000";
						state <= '1';
					end if;
				when '1' =>
					if (cnt	= "111") then state <= '0'; end if;
					shift_reg <= shift_reg(6 downto 0) & I_MISO;
					cnt <= cnt + 1;
				when others => null;
			end case;
		end if;
	end process;
	
O_BUSY <= state;
O_DATA 	 <= shift_reg;
O_CS_N <= cs;
O_MOSI <= shift_reg(7);
O_SCLK <= I_SCK when state = '1' else '0';

end rtl;