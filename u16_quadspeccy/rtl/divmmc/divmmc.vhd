-------------------------------------------------------------------[11.09.2015]
-- DivMMC
-------------------------------------------------------------------------------
-- Engineer: 	MVV <mvvproject@gmail.com>, shurik-ua
--
-- 27.03.2014	Первая версия
-- 30.03.2014	Исправление в генерации automap, не учитывалось моментальное переключение по 3Dxx
-- 01.04.2014	Исправление в переключении после чтения опкода (автор shurik-ua)

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity divmmc is
port (
	I_CLK			: in std_logic;
	I_ENA			: in std_logic;
	I_RESET			: in std_logic;
	I_ADDR			: in std_logic_vector(15 downto 0);
	I_DATA			: in std_logic_vector(7 downto 0);
	O_DATA			: out std_logic_vector(7 downto 0);
	I_WR_N			: in std_logic;
	I_RD_N			: in std_logic;
	I_IORQ_N		: in std_logic;
	I_MREQ_N		: in std_logic;
	I_M1_N			: in std_logic;
	O_E3REG			: out std_logic_vector(7 downto 0);
	O_AMAP			: out std_logic;
	O_CS_N			: out std_logic;
	O_SCLK			: out std_logic;
	O_MOSI			: out std_logic;
	I_MISO			: in std_logic);
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

process (I_RESET, I_CLK, I_WR_N, I_ADDR, I_IORQ_N, I_ENA, I_DATA)
begin
	if (I_RESET = '1') then
		cs <= '1';
--		reg_e3(5 downto 0) <= (others => '0');
--		reg_e3(7) <= '0';
		reg_e3 <= (others => '0');
	elsif (I_CLK'event and I_CLK = '1') then
--		if (I_IORQ_N = '0' and I_WR_N = '0' and I_ENA = '1' and I_ADDR(7 downto 0) = X"E3") then	reg_e3 <= I_DATA(7) & (reg_e3(6) or I_DATA(6)) & I_DATA(5 downto 0); end if;	-- #E3
		if (I_IORQ_N = '0' and I_WR_N = '0' and I_ENA = '1' and I_ADDR(7 downto 0) = X"E3") then	reg_e3 <= I_DATA; end if;	-- #E3
		if (I_IORQ_N = '0' and I_WR_N = '0' and I_ENA = '1' and I_ADDR(7 downto 0) = X"E7") then cs <= I_DATA(0); end if;	-- #E7
	end if;
end process;

process (I_CLK, I_M1_N, I_MREQ_N, I_ADDR, I_ENA, detect, automap)
begin
	if (I_CLK'event and I_CLK = '1') then
		if (I_M1_N = '0' and I_MREQ_N = '0' and I_ENA = '1' and (I_ADDR = X"0000" or I_ADDR = X"0008" or I_ADDR = X"0038" or I_ADDR = X"0066" or I_ADDR = X"04C6" or I_ADDR = X"0562" or I_ADDR(15 downto 8) = X"3D")) then
			detect <= '1';	-- ������������ ��� ���������� ���� ������� � �1 ����� ��� ���������� �������� �������
		elsif (I_M1_N = '0' and I_MREQ_N = '0' and I_ENA = '1' and I_ADDR(15 downto 3) = "0001111111111") then
			detect <= '0';	-- �������������� ��� ���������� ���� ������� � �1 ��� ���������� ������� 0x1FF8-0x1FFF
		end if;
		if (I_M1_N = '0' and I_IORQ_N = '1' and I_ENA = '1' and I_ADDR(15 downto 8) = X"3D") then
			automap <= '1';	-- ������������ ������������ ��� �������� ������ ������
		elsif (I_MREQ_N = '0' and I_ENA = '1' and I_WR_N = '1' and I_RD_N = '1') then
			automap <= detect;	-- ������������ ����� ������ ������
		end if;
	end if;
end process;

-------------------------------------------------------------------------------
-- SPI Interface
process(I_CLK, I_RESET, I_ADDR, I_IORQ_N, I_WR_N)
begin
	if I_RESET = '1' then
		shift_reg <= (others => '1');
		in_reg <= (others => '1');
		counter <= "1111"; -- Idle
	elsif (I_CLK'event and I_CLK = '1') then
		if counter = "1111" then
			in_reg <= shift_reg(7 downto 0);
			if I_IORQ_N = '0' and I_ADDR(7 downto 0) = X"EB" and I_ENA = '1' then
				if I_WR_N = '1' then
					shift_reg <= (others => '1');
				else
					shift_reg <= I_DATA & '1';
				end if;
				counter <= "0000";
			end if;
		else
			counter <= counter + 1;
			if counter(0) = '0' then
				shift_reg(0) <= I_MISO;
			else
				shift_reg <= shift_reg(7 downto 0) & '1';
			end if;
		end if;
	end if;
end process;
	
O_DATA    <= in_reg;
O_CS_N  <= cs;
O_MOSI  <= shift_reg(8);
O_SCLK  <= counter(0);
O_E3REG <= reg_e3;
O_AMAP  <= automap;

end rtl;