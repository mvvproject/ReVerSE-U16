-------------------------------------------------------------------[06.05.2013]
-- UART Controller for FT232R
-------------------------------------------------------------------------------
-- Engineer: 	MVV
-- Description: 
--
-- Versions:
-- V1.0		05.05.2013	Initial release.
-- V1.1		06.05.2013
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity clock_1 is
	port (
		clk		: in  std_logic;
		c0			: out std_logic );
end clock_1;

architecture rtl of clock_1 is
	signal send		: std_logic := '0';
begin
c0 <= clk;   

end rtl;