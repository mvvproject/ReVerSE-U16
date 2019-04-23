-------------------------------------------------------------------[06.04.2015]
-- SDRAM Controller SDRAM 4 Meg x 16 x 4 banks
-------------------------------------------------------------------------------
-- Engineer: 	MVV
--
-- 27.02.2015	4-Channal

-- CLK		= 84 MHz	= 11,9047619047619 ns
-- WR/RD	= 6T		= 71,42857142857143 ns
-- RFSH		= 6T		= 71,42857142857143 ns

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity sdram is
	port(
		RST_I		: in  std_logic;
		CLK_I		: in  std_logic;
		ENA_O		: out std_logic;
		-- Channal 0
		CH0_ADR_I	: in  std_logic_vector(24 downto 0);
		CH0_DAT_I	: in  std_logic_vector( 7 downto 0);
		CH0_DAT_O	: out std_logic_vector( 7 downto 0);
		CH0_WR_I	: in  std_logic;
		CH0_RD_I	: in  std_logic;
		CH0_RFSH_I	: in  std_logic;
		-- Channal 1
		CH1_ADR_I	: in  std_logic_vector(24 downto 0);
		CH1_DAT_I	: in  std_logic_vector( 7 downto 0);
		CH1_DAT_O	: out std_logic_vector( 7 downto 0);
		CH1_WR_I	: in  std_logic;
		CH1_RD_I	: in  std_logic;
		CH1_RFSH_I	: in  std_logic;
		-- Channal 2
		CH2_ADR_I	: in  std_logic_vector(24 downto 0);
		CH2_DAT_I	: in  std_logic_vector( 7 downto 0);
		CH2_DAT_O	: out std_logic_vector( 7 downto 0);
		CH2_WR_I	: in  std_logic;
		CH2_RD_I	: in  std_logic;
		CH2_RFSH_I	: in  std_logic;
		-- Channal 3
		CH3_ADR_I	: in  std_logic_vector(24 downto 0);
		CH3_DAT_I	: in  std_logic_vector( 7 downto 0);
		CH3_DAT_O	: out std_logic_vector( 7 downto 0);
		CH3_WR_I	: in  std_logic;
		CH3_RD_I	: in  std_logic;
		CH3_RFSH_I	: in  std_logic;
		-- SDRAM Pin
		CK		: out std_logic;
		RAS_n		: out std_logic;
		CAS_n		: out std_logic;
		WE_n		: out std_logic;
		DQML		: out std_logic;
		DQMH		: out std_logic;
		BA		: out std_logic_vector( 1 downto 0);
		MA		: out std_logic_vector(12 downto 0);
		DQ		: inout std_logic_vector(15 downto 0) );
end sdram;

architecture rtl of sdram is
	signal state 		: unsigned(4 downto 0) := "00000";
	signal address 		: std_logic_vector(24 downto 0);
	signal data		: std_logic_vector(7 downto 0);	
	signal idle1		: std_logic;
	signal channal		: unsigned(1 downto 0) := "00";
	signal ch0_data		: std_logic_vector(7 downto 0);
	signal ch1_data		: std_logic_vector(7 downto 0);
	signal ch2_data		: std_logic_vector(7 downto 0);
	signal ch3_data		: std_logic_vector(7 downto 0);
	
	-- SD-RAM control signals
	signal sdr_cmd		: std_logic_vector(2 downto 0);
	signal sdr_ba		: std_logic_vector(1 downto 0);
	signal sdr_dqml		: std_logic;
	signal sdr_dqmh		: std_logic;
	signal sdr_a		: std_logic_vector(12 downto 0);
	signal sdr_dq		: std_logic_vector(15 downto 0);

	constant SdrCmd_xx 	: std_logic_vector(2 downto 0) := "111"; -- no operation
	constant SdrCmd_ac 	: std_logic_vector(2 downto 0) := "011"; -- activate
	constant SdrCmd_rd 	: std_logic_vector(2 downto 0) := "101"; -- read
	constant SdrCmd_wr 	: std_logic_vector(2 downto 0) := "100"; -- write		
	constant SdrCmd_pr 	: std_logic_vector(2 downto 0) := "010"; -- precharge all
	constant SdrCmd_re 	: std_logic_vector(2 downto 0) := "001"; -- refresh
	constant SdrCmd_ms 	: std_logic_vector(2 downto 0) := "000"; -- mode regiser set

-- Init----------------------------------------------------------  Idle----  Read----------  Write---------  Refresh-------
-- 00 01 02 03 04 05 06 07 08 09 0A 0B 0C 0D 0E 0F 10 11 12 13 14  15        16 17 12 13 14  18 19 12 13 14  10 11 12 13 14
-- pr xx xx re xx xx xx xx xx re xx xx xx xx xx ms xx xx xx xx xx  xx/ac/re  xx rd xx xx xx  xx wr xx xx xx  xx xx xx xx xx

begin
	process (RST_I, CLK_I)
	begin
		if (RST_I = '1') then
			sdr_cmd  <= (others => '1');
			sdr_a    <= (others => '1');
			sdr_ba   <= (others => '1');
			sdr_dq   <= (others => 'Z');
			state    <= (others => '0');
			channal  <= (others => '0');
			sdr_dqml <= '1';
			sdr_dqmh <= '1';

		elsif (CLK_I'event and CLK_I = '0') then
			ENA_O <= '0';
			case state is
				-- Init
				when "00000" =>					-- s00
					sdr_cmd  <= SdrCmd_pr;			-- PRECHARGE
					sdr_a    <= "1111111111111";
					sdr_ba   <= "00";
					sdr_dqml <= '1';
					sdr_dqmh <= '1';
					state    <= state + 1;
				when "00011" | "01001" =>			-- s03 s09
					sdr_cmd  <= SdrCmd_re;			-- REFRESH
					state    <= state + 1;
				when "01111" =>					-- s0F
					sdr_cmd  <= SdrCmd_ms;			-- LOAD MODE REGISTER
					sdr_a    <= "000" & "1" & "00" & "010" & "0" & "000";				
					state    <= state + 1;
				-- Idle
				when "10101" =>					-- s15
					sdr_cmd  <= SdrCmd_xx;			-- NOP
					sdr_dq   <= (others => 'Z');
					idle1    <= '1';
					channal  <= channal + 1;
					case channal is
						-- Channal 0
						when "00" =>
							if (CH0_RD_I = '1') then
								idle1   <= '0';
								address <= CH0_ADR_I;
								sdr_cmd <= SdrCmd_ac;		-- ACTIVE
								sdr_ba  <= CH0_ADR_I(24 downto 23);
								sdr_a   <= CH0_ADR_I(22 downto 10);
								state   <= "10110";		-- s16 Read
							elsif (CH0_WR_I = '1') then
								idle1   <= '0';
								address <= CH0_ADR_I;
								data    <= CH0_DAT_I;
								sdr_cmd <= SdrCmd_ac;		-- ACTIVE
								sdr_ba  <= CH0_ADR_I(24 downto 23);
								sdr_a   <= CH0_ADR_I(22 downto 10);
								state   <= "11000";		-- s18 Write
							else
								sdr_cmd <= SdrCmd_re;		-- REFRESH
								state   <= "10000";		-- s10
							end if;
						-- Channal 1
						when "01" =>
							if (CH1_RD_I = '1') then
								idle1   <= '0';
								address <= CH1_ADR_I;
								sdr_cmd <= SdrCmd_ac;		-- ACTIVE
								sdr_ba  <= CH1_ADR_I(24 downto 23);
								sdr_a   <= CH1_ADR_I(22 downto 10);
								state   <= "10110";		-- s16 Read
							elsif (CH1_WR_I = '1') then
								idle1   <= '0';
								address <= CH1_ADR_I;
								data    <= CH1_DAT_I;
								sdr_cmd <= SdrCmd_ac;		-- ACTIVE
								sdr_ba  <= CH1_ADR_I(24 downto 23);
								sdr_a   <= CH1_ADR_I(22 downto 10);
								state   <= "11000";		-- s18 Write
							else
								sdr_cmd <= SdrCmd_re;		-- REFRESH
								state   <= "10000";		-- s10
							end if;
						-- Channal 2
						when "10" =>
							if (CH2_RD_I = '1') then
								idle1   <= '0';
								address <= CH2_ADR_I;
								sdr_cmd <= SdrCmd_ac;		-- ACTIVE
								sdr_ba  <= CH2_ADR_I(24 downto 23);
								sdr_a   <= CH2_ADR_I(22 downto 10);
								state   <= "10110";		-- s16 Read
							elsif (CH2_WR_I = '1') then
								idle1   <= '0';
								address <= CH2_ADR_I;
								data    <= CH2_DAT_I;
								sdr_cmd <= SdrCmd_ac;		-- ACTIVE
								sdr_ba  <= CH2_ADR_I(24 downto 23);
								sdr_a   <= CH2_ADR_I(22 downto 10);
								state   <= "11000";		-- s18 Write
							else
								sdr_cmd <= SdrCmd_re;		-- REFRESH
								state   <= "10000";		-- s10
							end if;
						-- Channal 3
						when "11" =>
							if (CH3_RD_I = '1') then
								idle1   <= '0';
								address <= CH3_ADR_I;
								sdr_cmd <= SdrCmd_ac;		-- ACTIVE
								sdr_ba  <= CH3_ADR_I(24 downto 23);
								sdr_a   <= CH3_ADR_I(22 downto 10);
								state   <= "10110";		-- s16 Read
							elsif (CH3_WR_I = '1') then
								idle1   <= '0';
								address <= CH3_ADR_I;
								data    <= CH3_DAT_I;
								sdr_cmd <= SdrCmd_ac;		-- ACTIVE
								sdr_ba  <= CH3_ADR_I(24 downto 23);
								sdr_a   <= CH3_ADR_I(22 downto 10);
								state   <= "11000";		-- s18 Write
							else
								sdr_cmd <= SdrCmd_re;		-- REFRESH
								state   <= "10000";		-- s10
							end if;
						when others => null;
					end case;
				when "10100" =>					-- s14
					if (channal = "11") then
						ENA_O <= '1';
					end if;	  
					sdr_dq  <= (others => 'Z');
					sdr_cmd <= SdrCmd_xx;			-- NOP
					state   <= state + 1;

				-- A24 A23 A22 A21 A20 A19 A18 A17 A16 A15 A14 A13 A12 A11 A10 A9 A8 A7 A6 A5 A4 A3 A2 A1 A0
				-- BA1 BA0 -----------------------ROW------------------------- ----------COLUMN---------- HL

				-- Single read - with auto precharge
				when "10111" =>					-- s17
					sdr_cmd  <= SdrCmd_rd;			-- READ (A10 = 1 enable auto precharge; A8..0 = column)
					sdr_a    <= "0010" & address(9 downto 1);
					sdr_dqml <= '0';
					sdr_dqmh <= '0';
					state    <= "10010";			-- s12
				-- Single write - with auto precharge
				when "11001" =>					-- s19
					sdr_cmd <= SdrCmd_wr;			-- WRITE (A10 = 1 enable auto precharge; A8..0 = column)
					sdr_a <= "0010" & address(9 downto 1);
					sdr_dq <= data & data;
					sdr_dqml <= address(0);
					sdr_dqmh <= not address(0);
					state <= "10010";			-- s12
				when others =>
					sdr_dq <= (others => 'Z');
					sdr_cmd <= SdrCmd_xx;			-- NOP
					state <= state + 1;
			end case;

		end if;
	end process;
	
	process (CLK_I, state, DQ, ch0_data, ch1_data, ch2_data, ch3_data, idle1, address)
	begin
		if (CLK_I'event and CLK_I = '1') then
			if (state = "10101" and idle1 = '0') then		-- s15
				if (address(0) = '0') then
					case channal is
						when "00" => ch3_data <= DQ(7 downto 0);
						when "01" => ch0_data <= DQ(7 downto 0);
						when "10" => ch1_data <= DQ(7 downto 0);
--						when "11" => ch2_data <= DQ(7 downto 0);
						when others => null;
					end case;
				else
					case channal is
						when "00" => ch3_data <= DQ(15 downto 8);
						when "01" => ch0_data <= DQ(15 downto 8);
						when "10" => ch1_data <= DQ(15 downto 8);
--						when "11" => ch2_data <= DQ(15 downto 8);
						when others => null;
					end case;
				end if;
			end if;
		end if;
		if (address(0) = '0') then
			ch2_data <= DQ(7 downto 0);
		else
			ch2_data <= DQ(15 downto 8);
		end if;
	end process;
	
	CH0_DAT_O <= ch0_data;
	CH1_DAT_O <= ch1_data;
	CH2_DAT_O <= ch2_data;
	CH3_DAT_O <= ch3_data;
	
	CK 	<= CLK_I;
	RAS_n 	<= sdr_cmd(2);
	CAS_n 	<= sdr_cmd(1);
	WE_n 	<= sdr_cmd(0);
	DQML 	<= sdr_dqml;
	DQMH 	<= sdr_dqmh;
	BA	<= sdr_ba;
	MA 	<= sdr_a;
	DQ 	<= sdr_dq;

end rtl;
