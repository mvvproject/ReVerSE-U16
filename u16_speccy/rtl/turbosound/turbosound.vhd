-------------------------------------------------------------------[07.09.2013]
-- TurboSound
-------------------------------------------------------------------------------
-- V0.1 	15.10.2011	первая версия

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
 
entity turbosound is
port( 
	RESET	: in std_logic;
	CLK		: in std_logic;
	ENA		: in std_logic;
	A		: in std_logic_vector(15 downto 0);
	DI		: in std_logic_vector(7 downto 0);
	WR_n	: in std_logic;
	IORQ_n	: in std_logic;
	M1_n	: in std_logic;
	SEL		: out std_logic;
	CN0_DO	: out std_logic_vector(7 downto 0);
	CN0_A	: out std_logic_vector(7 downto 0);
	CN0_B	: out std_logic_vector(7 downto 0);
	CN0_C	: out std_logic_vector(7 downto 0);
	CN1_DO	: out std_logic_vector(7 downto 0);
	CN1_A	: out std_logic_vector(7 downto 0);
	CN1_B	: out std_logic_vector(7 downto 0);
	CN1_C	: out std_logic_vector(7 downto 0));
end turbosound;
 
architecture turbosound_arch of turbosound is
	signal bc1	: std_logic;
	signal bdir	: std_logic;
	signal ssg	: std_logic;
begin
	bc1	 <= '1' when (IORQ_n = '0' and A(15) = '1' and A(1) = '0' and M1_n = '1' and A(14) = '1') else '0';
	bdir <= '1' when (IORQ_n = '0' and A(15) = '1' and A(1) = '0' and M1_n = '1' and WR_n = '0') else '0';
	SEL  <= ssg;
	
	process(CLK, RESET)
	begin
		if (RESET = '1') then
			ssg <= '0';
		elsif (CLK'event and CLK = '1') then
			if (DI(7 downto 1) = "1111111" and bdir = '1' and bc1 = '1') then
				ssg <= DI(0);
			end if;
		end if;
	end process;

ssg0_unit: entity work.ay8910(rtl)
		port map(
			RESET 		=> RESET,
			CLK     	=> CLK,
			DI    		=> DI,
			DO    		=> CN0_DO,
			ENA			=> ENA,
			CS			=> not ssg,
			BDIR		=> bdir,
			BC			=> bc1,
			OUT_A		=> CN0_A,
			OUT_B		=> CN0_B,
			OUT_C		=> CN0_C);

ssg1_unit: entity work.ay8910(rtl)
		port map(
			RESET 		=> RESET,
			CLK     	=> CLK,
			DI    		=> DI,
			DO    		=> CN1_DO,
			ENA			=> ENA,
			CS			=> ssg,
			BDIR		=> bdir,
			BC			=> bc1,
			OUT_A		=> CN1_A,
			OUT_B		=> CN1_B,
			OUT_C		=> CN1_C);
end turbosound_arch;