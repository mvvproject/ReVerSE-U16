-------------------------------------------------------------------[27.10.2011]
-- Soundrive 1.05
-------------------------------------------------------------------------------
-- V0.1 	05.10.2011	первая версия

-- SOUNDRIVE 1.05 PORTS mode 1
-- #0F = left channel A (stereo covox channel 1)
-- #1F = left channel B
-- #4F = right channel C (stereo covox channel 2)
-- #5F = right channel D

-- #FB = right channel D

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
 
entity soundrive is
	Port ( 
		RESET	: in std_logic;
		CLK		: in std_logic;
		CS		: in std_logic;
		A		: in std_logic_vector(7 downto 0);
		DI		: in std_logic_vector(7 downto 0);
		WR_n	: in std_logic;
		IORQ_n	: in std_logic;
		DOS		: in std_logic;
		OUTA	: out std_logic_vector(7 downto 0);
		OUTB	: out std_logic_vector(7 downto 0);
		OUTC	: out std_logic_vector(7 downto 0);
		OUTD	: out std_logic_vector(7 downto 0));
end soundrive;
 
architecture soundrive_unit of soundrive is
	signal outa_reg : std_logic_vector (7 downto 0);
	signal outb_reg : std_logic_vector (7 downto 0);
	signal outc_reg : std_logic_vector (7 downto 0);
	signal outd_reg : std_logic_vector (7 downto 0);
begin
	process (CLK, RESET, CS)
	begin
		if RESET = '1' or CS = '0' then
			outa <= (others => '0');
			outb <= (others => '0');
			outc <= (others => '0');
			outd <= (others => '0');
		elsif CLK'event and CLK = '1' then
			if A = X"0F" and IORQ_n = '0' and WR_n = '0' and DOS = '0' then
				outa <= DI;
			elsif A = X"1F" and IORQ_n = '0' and WR_n = '0' and DOS = '0' then
				outb <= DI;
			elsif A = X"4F" and IORQ_n = '0' and WR_n = '0' and DOS = '0' then
				outc <= DI;
			elsif A = X"5F" and IORQ_n = '0' and WR_n = '0' and DOS = '0' then
				outd <= DI;
			elsif A = X"FB" and IORQ_n = '0' and WR_n = '0' and DOS = '0' then
				outd <= DI;
			end if;
		end if;
	end process;
	
end soundrive_unit;