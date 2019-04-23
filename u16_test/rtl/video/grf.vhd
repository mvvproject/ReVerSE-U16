-------------------------------------------------------------------[16.08.2014]
-- Grafics
-------------------------------------------------------------------------------
-- Author:	MVV
-- Description:	VGA 640 x 480
-- Versions:
-- V1.0		16.08.2014	Initial release.

library IEEE; 
use IEEE.std_logic_1164.all; 
use IEEE.std_logic_unsigned.all;

entity grf is
	port (
	CLK		: in std_logic;
	CLKEN		: in std_logic;
	PIXEL_DI	: in std_logic_vector(23 downto 0);
	HCNT		: in std_logic_vector(9 downto 0);
	VCNT		: in std_logic_vector(9 downto 0);
	BLANK		: in std_logic;
	INT		: in std_logic;
	PIXEL_ADDR	: out std_logic_vector(18 downto 0);
	R		: out std_logic_vector(7 downto 0);
	G		: out std_logic_vector(7 downto 0);
	B		: out std_logic_vector(7 downto 0));
end entity;

architecture rtl of grf is
	signal h_count		: std_logic_vector(9 downto 0) := "0000000000";
	signal v_count		: std_logic_vector(9 downto 0) := "0000000000";
	signal h_sync		: std_logic;
	signal v_sync		: std_logic;
	signal rgb_temp		: std_logic_vector(23 downto 0);
	signal addr_reg		: std_logic_vector(18 downto 0) := "0000000000000000000";
	signal addr_count	: std_logic_vector(18 downto 0) := "0000000000000000000";

begin

	process (CLK)
	begin
		if CLK'event and CLK = '1' then
			if CLKEN = '1' then
				addr_reg <= addr_count;
			end if;
		end if;
	end process;

	rgb_temp <= (others => '0') when BLANK = '1' else PIXEL_DI;
	addr_count <= (others => '0') when INT = '1' else addr_reg + 1 when BLANK = '0' else addr_reg;
	PIXEL_ADDR <= addr_reg;
	R <= rgb_temp( 7 downto  0);
	G <= rgb_temp(15 downto  8);
	B <= rgb_temp(23 downto 16);

end architecture;