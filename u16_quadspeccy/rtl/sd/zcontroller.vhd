-------------------------------------------------------------------[19.03.2011]
-- Z-Controller
-------------------------------------------------------------------------------
-- Engineer: 	MVV <mvvproject@gmail.com>
--
-- 05.11.2011	первая версия

-- Порт конфигурации 77h
-- На запись:
-- 	bit 0 	= питание SD-карты (0 – выключено, 1 -включено)
-- 	bit 1 	= управление сигналом CS
-- 	bit 2-7	= не используются
-- На чтение:
-- 	bit 0	= если 0 – SD-карта установлена, 1 – SD-карта отсутствует
-- 	bit 1	= если 1 – то на карте включен режим Read only, если 0 – режим Read only не включен
-- 	bit 2-6	= не используются
--	bit 7	= если 1 - буферный регистр содержит новые данные, если 0 - идет загрузка.
--
-- Порт данных 57h
--	Используется как на запись, так и на чтение для обмена данными по SPI-интерфейсу.
--	Тактирование осуществляется автоматически при записи какого-либо значения в порт 57h. При
--	этом формируются 8 тактовых импульсов на выходе SDCLK, на выход SDDI поступают данные
--	последовательно от старшего бита к младшему с каждым фронтом сигнала SDCLK. Период
--	следования тактовых импульсов составляет 125 нс для оригинального ZC.
--	При чтении из порта 57h также автоматически производится тактирование. Буферный регистр
--	порта 57h, используемый при чтении, заполняется данными со входа SDIN последовательно от
--	старшего бита к младшему с каждым фронтом сигнала SDCLK.

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

entity zcontroller is
	port (
		I_RESET		: in std_logic;
		I_CLK     	: in std_logic;
		I_ADDR       	: in std_logic;
		I_DATA		: in std_logic_vector(7 downto 0);
		O_DATA		: out std_logic_vector(7 downto 0);
		I_RD		: in std_logic;
		I_WR		: in std_logic;
		I_SDDET		: in std_logic;
		I_SDPROT	: in std_logic;
		O_CS_N		: out std_logic;
		O_SCLK		: out std_logic;
		O_MOSI		: out std_logic;
		I_MISO		: in std_logic );
end;

architecture rtl of zcontroller is
	signal cnt		: std_logic_vector(3 downto 0);
	signal shift_in		: std_logic_vector(7 downto 0);
	signal shift_out	: std_logic_vector(7 downto 0);
	signal cnt_en		: std_logic;
	signal csn		: std_logic;
	
begin

	process (I_RESET, I_CLK, I_ADDR, I_WR, I_DATA)
	begin
		if I_RESET = '1' then
			csn <= '1';
		elsif (I_CLK'event and I_CLK = '1') then
			if (I_ADDR = '1' and I_WR = '1') then
				csn <= I_DATA(1);
			end if;
		end if;
	end process;

	cnt_en <= not cnt(3) or cnt(2) or cnt(1) or cnt(0);
	
	process (I_CLK, cnt_en, I_ADDR, I_RD, I_WR, I_SDPROT)
	begin
		if (I_ADDR = '0' and (I_WR = '1' or I_RD = '1')) then
			cnt <= "1110";
		else 
			if (I_CLK'event and I_CLK = '0') then			
				if cnt_en = '1' then
					cnt <= cnt + 1;
				end if;
			end if;
		end if;
	end process;

	process (I_CLK)
	begin
		if (I_CLK'event and I_CLK = '0') then			
			if (I_ADDR = '0' and I_WR = '1') then
				shift_out <= I_DATA;
			else
				if cnt(3) = '0' then
					shift_out(7 downto 0) <= shift_out(6 downto 0) & '1';
				end if;
			end if;
		end if;
	end process;
	
	process (I_CLK)
	begin
		if (I_CLK'event and I_CLK = '0') then			
			if cnt(3) = '0' then
				shift_in <= shift_in(6 downto 0) & I_MISO;
			end if;
		end if;
	end process;
	
	O_SCLK  <= I_CLK and not cnt(3);
	O_MOSI  <= shift_out(7);
	O_CS_N  <= csn;
	O_DATA    <= cnt(3) & "11111" & I_SDPROT & I_SDDET when I_ADDR = '1' else shift_in;
	
end rtl;