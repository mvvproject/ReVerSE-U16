-------------------------------------------------------------------[16.07.2014]
-- Receiver
-------------------------------------------------------------------------------
-- Engineer: 	MVV
-- Description: 
--
-- Versions:
-- V1.0		15.07.2014	Initial release
-------------------------------------------------------------------------------

-- The keyboard firmware expects to receive 8 bytes formatted as a Keyboard HID report. The format is as follows:
-- Byte 0	Modifier keys:
-- 		Bit 0 - Left CTRL
-- 		Bit 1 - Left SHIFT
-- 		Bit 2 - Left ALT
-- 		Bit 3 - Left GUI
-- 		Bit 4 - Right CTRL
-- 		Bit 5 - Right SHIFT
-- 		Bit 6 - Right ALT
-- 		Bit 7 - Right GUI
-- Byte 1	Not used
-- Byte 2-7	HID active key usage codes. This represents up to 6 keys currently being pressed.

library ieee;
use ieee.std_logic_1164.all;

entity receiver is
	generic (
		divisor		: integer := 2916 );	-- divisor = 28MHz / 9600 Baud = 2916
	port (
		CLK			: in  std_logic;
		nRESET		: in  std_logic;
		RX			: in  std_logic;
		DATA		: out std_logic_vector(7 downto 0));
end receiver;

architecture rtl of receiver is
	constant halfbit : integer := divisor / 2; 
	signal rx_buffer	: std_logic_vector(7 downto 0);
	signal rx_bit_count	: integer range 0 to 10;
	signal rx_count		: integer range 0 to divisor;
	signal rx_avail		: std_logic;
	signal rx_shift_reg	: std_logic_vector(7 downto 0);
	signal rx_bit		: std_logic;

	signal buffer0, buffer1, buffer2, buffer3, buffer4, buffer5, buffer6, buffer7	: std_logic_vector(7 downto 0);
	signal buffer_count : integer range 0 to 7;
	signal count		: integer range 0 to 15;
	
begin

process(CLK, nRESET) is
begin
	if nRESET = '0' then
		rx_buffer		<= (others => '0');
		rx_bit_count 	<= 0;
		rx_count 		<= 0;
		rx_avail 		<= '0';
		buffer0			<= (others => '0');
		buffer1 		<= (others => '0');
		buffer2 		<= (others => '0');
		buffer3 		<= (others => '0');
		buffer4 		<= (others => '0');
		buffer5 		<= (others => '0');
		buffer6 		<= (others => '0');
		buffer7 		<= (others => '0');
		buffer_count	<= 0;
		count 			<= 0;
		
     elsif CLK'event and CLK = '1' then
-- Receiver	 
		if rx_count /= 0 then 
			rx_count <= rx_count - 1;
        else
			if rx_bit_count = 0 then		-- wait for startbit
				if rx_bit = '0' then		-- FOUND
					rx_count <= halfbit;
					rx_bit_count <= rx_bit_count + 1;                                               
				end if;
			elsif rx_bit_count = 1 then		-- sample mid of startbit
				if rx_bit = '0' then		-- OK
					rx_count <= divisor;
					rx_bit_count <= rx_bit_count + 1;
					rx_shift_reg <= "00000000";
				else						-- ERROR
					rx_bit_count <= 0;
				end if;
			elsif rx_bit_count = 10 then	-- stopbit
				if rx_bit = '1' then		-- OK
					rx_count <= 0;
					rx_bit_count <= 0;
					buffer_count <= buffer_count + 1;
					case buffer_count is
						when 0 => buffer0 <= rx_shift_reg;
						when 1 => buffer1 <= rx_shift_reg;
						when 2 => buffer2 <= rx_shift_reg;
						when 3 => buffer3 <= rx_shift_reg;
						when 4 => buffer4 <= rx_shift_reg;
						when 5 => buffer5 <= rx_shift_reg;
						when 6 => buffer6 <= rx_shift_reg;
						when 7 => buffer7 <= rx_shift_reg; rx_avail <= '1';
						when others => null;
					end case;
				else						-- ERROR
					rx_count <= divisor;
					rx_bit_count <= 0;
				end if;
			else
				rx_shift_reg(6 downto 0) <= rx_shift_reg(7 downto 1);
				rx_shift_reg(7)	<= rx_bit;
				rx_count <= divisor;
				rx_bit_count <= rx_bit_count + 1;
			end if;
        end if;

		rx_buffer <= (others => '0');
		if rx_avail = '1' then
			count <= count + 1;
			case count is
				when 0 => rx_buffer <= X"02";	-- Reload
				-- Modifier keys:
				when 1 => if buffer0(0) = '1' then rx_buffer <= X"E0"; end if;
				when 2 => if buffer0(1) = '1' then rx_buffer <= X"E1"; end if;
				when 3 => if buffer0(2) = '1' then rx_buffer <= X"E2"; end if;
				when 4 => if buffer0(3) = '1' then rx_buffer <= X"E3"; end if;
				when 5 => if buffer0(4) = '1' then rx_buffer <= X"E4"; end if;
				when 6 => if buffer0(5) = '1' then rx_buffer <= X"E5"; end if;
				when 7 => if buffer0(6) = '1' then rx_buffer <= X"E6"; end if;
				when 8 => if buffer0(7) = '1' then rx_buffer <= X"E7"; end if;
				-- HID active key usage codes. This represents up to 6 keys currently being pressed.
				when 9 => rx_buffer <= buffer1;
				when 10 => rx_buffer <= buffer2;
				when 11 => rx_buffer <= buffer3;
				when 12 => rx_buffer <= buffer4;
				when 13 => rx_buffer <= buffer5;
				when 14 => rx_buffer <= buffer6;
				when 15 => rx_buffer <= buffer7; rx_avail <= '0';
				when others => null;
			end case;
		end if;

	end if;
end process;

-- Sync incoming RXD (anti metastable)
syncproc: process (nRESET, CLK) is
begin
	if nRESET = '0' then
		rx_bit <= '1';
	elsif CLK'event and CLK = '0' then
		rx_bit <= RX;
	end if;
end process;

DATA  <= rx_buffer;

end rtl;