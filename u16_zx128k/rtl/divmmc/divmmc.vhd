-------------------------------------------------------------------[04.06.2015]
-- DivMMC
-------------------------------------------------------------------------------
-- 27.03.2014	Первая версия
-- 30.03.2014	Исправление в генерации automap, не учитывалось моментальное переключение по 3Dxx
-- 01.04.2014	Исправление в переключении после чтения опкода (автор shurik-ua)

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity divmmc is
port (
	CLK_I			: in std_logic;
	EN_I			: in std_logic;
	RESET_I			: in std_logic;
	ADDR_I			: in std_logic_vector(15 downto 0);
	DATA_I			: in std_logic_vector(7 downto 0);
	DATA_O			: out std_logic_vector(7 downto 0);
	WR_N_I			: in std_logic;
	RD_N_I			: in std_logic;
	IORQ_N_I		: in std_logic;
	MREQ_N_I		: in std_logic;
	M1_N_I			: in std_logic;
	E3REG_O			: out std_logic_vector(7 downto 0);
	AMAP_O			: out std_logic;
	CS_N_O			: out std_logic;
	SCLK_O			: out std_logic;
	MOSI_O			: out std_logic;
	MISO_I			: in std_logic);
end divmmc;

architecture rtl of divmmc is
	signal counter		: std_logic_vector(3 downto 0);
	signal shift_reg	: std_logic_vector(8 downto 0);
	signal in_reg		: std_logic_vector(7 downto 0);	
	signal cs		: std_logic := '1';
	signal reg_e7		: std_logic := '0';
	signal automap		: std_logic := '0';
	signal detect		: std_logic := '0';
	signal reg_e3		: std_logic_vector(7 downto 0) := "00000000";
	
begin

process (RESET_I, CLK_I, WR_N_I, ADDR_I, IORQ_N_I, EN_I, DATA_I)
begin
	if (RESET_I = '1') then
		cs <= '1';
--		reg_e3(5 downto 0) <= (others => '0');
--		reg_e3(7) <= '0';
		reg_e3 <= (others => '0');
	elsif (CLK_I'event and CLK_I = '1') then
--		if (IORQ_N_I = '0' and WR_N_I = '0' and EN_I = '1' and ADDR_I(7 downto 0) = X"E3") then	reg_e3 <= DATA_I(7) & (reg_e3(6) or DATA_I(6)) & DATA_I(5 downto 0); end if;	-- #E3
		if (IORQ_N_I = '0' and WR_N_I = '0' and EN_I = '1' and ADDR_I(7 downto 0) = X"E3") then	reg_e3 <= DATA_I; end if;	-- #E3
		if (IORQ_N_I = '0' and WR_N_I = '0' and EN_I = '1' and ADDR_I(7 downto 0) = X"E7") then cs <= DATA_I(0); end if;	-- #E7
	end if;
end process;

process (CLK_I, M1_N_I, MREQ_N_I, ADDR_I, EN_I, detect, automap)
begin
	if (CLK_I'event and CLK_I = '1') then
		if (M1_N_I = '0' and MREQ_N_I = '0' and EN_I = '1' and (ADDR_I = X"0000" or ADDR_I = X"0008" or ADDR_I = X"0038" or ADDR_I = X"0066" or ADDR_I = X"04C6" or ADDR_I = X"0562" or ADDR_I(15 downto 8) = X"3D")) then
			detect <= '1';	-- активируется при извлечении кода команды в М1 цикле при совпадении заданных адресов
		elsif (M1_N_I = '0' and MREQ_N_I = '0' and EN_I = '1' and ADDR_I(15 downto 3) = "0001111111111") then
			detect <= '0';	-- деактивируется при извлечении кода команды в М1 при совпадении адресов 0x1FF8-0x1FFF
		end if;
		if (M1_N_I = '0' and IORQ_N_I = '1' and EN_I = '1' and ADDR_I(15 downto 8) = X"3D") then
			automap <= '1';	-- моментальное переключение без ожидания чтения опкода
		elsif (MREQ_N_I = '0' and EN_I = '1' and WR_N_I = '1' and RD_N_I = '1') then
			automap <= detect;	-- переключение после чтения опкода
		end if;
	end if;
end process;

-------------------------------------------------------------------------------
-- SPI Interface
process(CLK_I, RESET_I, ADDR_I, IORQ_N_I, WR_N_I)
begin
	if (RESET_I = '1') then
		shift_reg <= (others => '1');
		in_reg <= (others => '1');
		counter <= "1111"; -- Idle
	elsif (CLK_I'event and CLK_I = '1') then
		if (counter = "1111") then
			in_reg <= shift_reg(7 downto 0);
			if (IORQ_N_I = '0' and ADDR_I(7 downto 0) = X"EB" and EN_I = '1') then
				if (WR_N_I = '1') then
					shift_reg <= (others => '1');
				else
					shift_reg <= DATA_I & '1';
				end if;
				counter <= "0000";
			end if;
		else
			counter <= counter + 1;
			if (counter(0) = '0') then
				shift_reg(0) <= MISO_I;
			else
				shift_reg <= shift_reg(7 downto 0) & '1';
			end if;
		end if;
	end if;
end process;
	
DATA_O  <= in_reg;
CS_N_O  <= cs;
MOSI_O  <= shift_reg(8);
SCLK_O  <= counter(0);
E3REG_O <= reg_e3;
AMAP_O  <= automap;

end rtl;