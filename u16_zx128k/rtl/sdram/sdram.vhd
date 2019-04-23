-------------------------------------------------------------------[04.06.2014]
-- SDRAM Controller
-------------------------------------------------------------------------------
-- Engineer: MVV

-- CLK		= 84 MHz	= 11,9047619047619 ns
-- WR/RD	= 6T		= 71,42857142857143 ns
-- RFSH		= 6T		= 71,42857142857143 ns

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity sdram is
port (
	CLK_I		: in std_logic;
	-- Memory port
	ADDR_I		: in std_logic_vector(24 downto 0);
	DATA_I		: in std_logic_vector(7 downto 0);
	DATA_O		: out std_logic_vector(7 downto 0);
	WR_I		: in std_logic;
	RD_I		: in std_logic;
	RFSH_I		: in std_logic;
	IDLE_O		: out std_logic;
	-- SDRAM Pin
	CLK_O		: out std_logic;
	RAS_O		: out std_logic;
	CAS_O		: out std_logic;
	WE_O		: out std_logic;
	DQM_O		: out std_logic_vector(1 downto 0);
	BA_O		: out std_logic_vector(1 downto 0);
	MA_O		: out std_logic_vector(12 downto 0);
	DQ_IO		: inout std_logic_vector(15 downto 0) );
end sdram;

architecture rtl of sdram is
	signal state 		: unsigned(4 downto 0) := "00000";
	signal address 		: std_logic_vector(24 downto 0);
	signal data_reg		: std_logic_vector(7 downto 0);
	signal data		: std_logic_vector(7 downto 0);	
	signal idle1		: std_logic;
	
	-- SD-RAM control signals
	signal sdr_cmd		: std_logic_vector(2 downto 0);
	signal sdr_ba		: std_logic_vector(1 downto 0);
	signal sdr_dqm		: std_logic_vector(1 downto 0);
	signal sdr_a		: std_logic_vector(12 downto 0);
	signal sdr_dq		: std_logic_vector(15 downto 0);

	constant SdrCmd_xx 	: std_logic_vector(2 downto 0) := "111"; -- no operation
	constant SdrCmd_ac 	: std_logic_vector(2 downto 0) := "011"; -- activate
	constant SdrCmd_rd 	: std_logic_vector(2 downto 0) := "101"; -- read
	constant SdrCmd_wr 	: std_logic_vector(2 downto 0) := "100"; -- write		
	constant SdrCmd_pr 	: std_logic_vector(2 downto 0) := "010"; -- precharge all
	constant SdrCmd_re 	: std_logic_vector(2 downto 0) := "001"; -- refresh
	constant SdrCmd_ms 	: std_logic_vector(2 downto 0) := "000"; -- mode regiser set

-- Init----------------------------------------------------------  Idle      Read----------  Write---------  Refresh-------
-- 00 01 02 03 04 05 06 07 08 09 0A 0B 0C 0D 0E 0F 10 11 12 13 14  15        16 17 12 13 14  18 19 12 13 14  10 11 12 13 14
-- pr xx xx re xx xx xx xx xx re xx xx xx xx xx ms xx xx xx xx xx  xx/ac/re  xx rd xx xx xx  xx wr xx xx xx  xx xx xx xx xx

begin
	process (CLK_I)
	begin
		if (CLK_I'event and CLK_I = '0') then
			case state is
				-- Init
				when "00000" =>					-- s00
					sdr_cmd <= SdrCmd_pr;			-- PRECHARGE
					sdr_a <= "1111111111111";
					sdr_ba <= "00";
					sdr_dqm <= "11";
					state <= state + 1;
				when "00011" | "01001" =>			-- s03 s09
					sdr_cmd <= SdrCmd_re;			-- REFRESH
					state <= state + 1;
				when "01111" =>					-- s0F
					sdr_cmd <= SdrCmd_ms;			-- LOAD MODE REGISTER
					sdr_a <= "000" & "1" & "00" & "010" & "0" & "000";				
					state <= state + 1;
				
				-- Idle
				when "10101" =>					-- s15
					sdr_cmd <= SdrCmd_xx;			-- NOP
					sdr_dq <= (others => 'Z');
					idle1 <= '1';
					if (RD_I = '1') then
						idle1 <= '0';
						address <= ADDR_I;
						sdr_cmd <= SdrCmd_ac;		-- ACTIVE
						sdr_ba <= ADDR_I(11 downto 10);
						sdr_a <= ADDR_I(24 downto 12);					 
						state <= "10110";		-- s16 Read
					elsif (WR_I = '1') then
						idle1 <= '0';
						address <= ADDR_I;
						data <= DATA_I;
						sdr_cmd <= SdrCmd_ac;		-- ACTIVE
						sdr_ba <= ADDR_I(11 downto 10);
						sdr_a <= ADDR_I(24 downto 12);
						state <= "11000";		-- s18 Write
					elsif (RFSH_I = '1') then
						idle1 <= '0';
						sdr_cmd <= SdrCmd_re;		-- REFRESH
						state <= "10000";		-- s10
					end if;

				-- A24 A23 A22 A21 A20 A19 A18 A17 A16 A15 A14 A13 A12 A11 A10 A9 A8 A7 A6 A5 A4 A3 A2 A1 A0
				-- -----------------------ROW------------------------- BA1 BA0 ----------COLUMN---------- HL		

				-- Single read - with auto precharge
				when "10111" =>					-- s17
					sdr_cmd <= SdrCmd_rd;			-- READ (A10 = 1 enable auto precharge; A8..0 = column)
					sdr_a <= "0010" & address(9 downto 1);
					sdr_dqm <= "00";
					state <= "10010";			-- s12
				-- Single write - with auto precharge
				when "11001" =>					-- s19
					sdr_cmd <= SdrCmd_wr;			-- WRITE (A10 = 1 enable auto precharge; A8..0 = column)
					sdr_a <= "0010" & address(9 downto 1);
					sdr_dq <= data & data;
					sdr_dqm <= not address(0) & address(0);
					state <= "10010";			-- s12
				when others =>
					sdr_dq <= (others => 'Z');
					sdr_cmd <= SdrCmd_xx;			-- NOP
					state <= state + 1;
			end case;
		end if;
	end process;
	
	process (CLK_I, state, DQ_IO, data_reg, idle1)
	begin
		if (CLK_I'event and CLK_I = '1' and idle1 = '0') then
			if (state = "10100") then				-- s14
				if (address(0) = '0') then
					data_reg <= DQ_IO(7 downto 0);
				else
					data_reg <= DQ_IO(15 downto 8);
				end if;
			end if;
		end if;
	end process;
	
	IDLE_O	<= idle1;
	DATA_O 	<= data_reg;
	CLK_O 	<= CLK_I;
	RAS_O 	<= sdr_cmd(2);
	CAS_O 	<= sdr_cmd(1);
	WE_O 	<= sdr_cmd(0);
	DQM_O 	<= sdr_dqm;
	BA_O	<= sdr_ba;
	MA_O 	<= sdr_a;
	DQ_IO 	<= sdr_dq;

end rtl;