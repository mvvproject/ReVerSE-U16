-------------------------------------------------------------------[09.09.2014]
-- IDE Video-DAC 8bpp
-------------------------------------------------------------------------------
-- V0.1 	25.08.2014	������ ������
-- V0.2		09.09.2014	������� 5bpp -> 8bpp

library IEEE; 
use IEEE.std_logic_1164.all; 
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all; 


entity lut is
port (
	mode	: in std_logic;
	data	: in std_logic_vector(4 downto 0);
	q	: out std_logic_vector(7 downto 0));
end lut;

architecture rtl of lut is

signal sig 	: std_logic_vector(7 downto 0);

begin
	q <= data & "000" when mode = '0' else sig;

	process (data)
	begin
		case data is
			when b"00000"	=> sig <= x"00";
			when b"00001"	=> sig <= x"08";
			when b"00010"	=> sig <= x"10";
			when b"00011"	=> sig <= x"18";
			when b"00100"	=> sig <= x"20";
			when b"00101"	=> sig <= x"28";
			when b"00110"	=> sig <= x"30";
			when b"00111"	=> sig <= x"38";

			when b"01000"	=> sig <= x"40";
			when b"01001"	=> sig <= x"48";
			when b"01010"	=> sig <= x"50";
			when b"01011"	=> sig <= x"58";
			when b"01100"	=> sig <= x"60";
			when b"01101"	=> sig <= x"68";
			when b"01110"	=> sig <= x"70";
			when b"01111"	=> sig <= x"78";

			when b"10000"	=> sig <= x"80";
			when b"10001"	=> sig <= x"88";
			when b"10010"	=> sig <= x"90";
			when b"10011"	=> sig <= x"98";
			when b"10100"	=> sig <= x"a0";
			when b"10101"	=> sig <= x"a8";
			when b"10110"	=> sig <= x"b0";
			when b"10111"	=> sig <= x"b8";

			when b"11000"	=> sig <= x"c0";
			when b"11001"	=> sig <= x"c8";
			when b"11010"	=> sig <= x"d0";
			when b"11011"	=> sig <= x"d8";
			when b"11100"	=> sig <= x"e0";
			when b"11101"	=> sig <= x"e8";
			when b"11110"	=> sig <= x"f0";
			when b"11111"	=> sig <= x"ff";

			when others 	=> null;

--			when b"00000"	=> sig <= x"00";	--0
--			when b"00001"	=> sig <= x"0A";	--1
--			when b"00010"	=> sig <= x"15";	--2
--			when b"00011"	=> sig <= x"1F";	--3
--			when b"00100"	=> sig <= x"2A";	--4
--			when b"00101"	=> sig <= x"35";	--5
--			when b"00110"	=> sig <= x"3F";	--6
--			when b"00111"	=> sig <= x"4A";	--7
--                                                        	
--			when b"01000"	=> sig <= x"55";	--8
--			when b"01001"	=> sig <= x"5F";	--9
--			when b"01010"	=> sig <= x"6A";	--10
--			when b"01011"	=> sig <= x"75";	--11
--			when b"01100"	=> sig <= x"7F";	--12
--			when b"01101"	=> sig <= x"8A";	--13
--			when b"01110"	=> sig <= x"95";	--14
--			when b"01111"	=> sig <= x"9F";	--15
--                                                        	
--			when b"10000"	=> sig <= x"AA";        --16
--			when b"10001"	=> sig <= x"B5";	--17
--			when b"10010"	=> sig <= x"BF";	--18
--			when b"10011"	=> sig <= x"CA";	--19
--			when b"10100"	=> sig <= x"D5";	--20
--			when b"10101"	=> sig <= x"DF";	--21
--			when b"10110"	=> sig <= x"EA";	--22
--			when b"10111"	=> sig <= x"F5";	--23
--                      when b"11000"	=> sig <= x"FF";      	--24
--	
--			when others 	=> sig <= x"FF";
		end case;
	end process;
end rtl;