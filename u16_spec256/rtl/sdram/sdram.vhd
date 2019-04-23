-------------------------------------------------------------------[17.06.2016]
-- SDRAM Controller
-------------------------------------------------------------------------------
-- Engineer: MVV <mvvproject@gmail.com>

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;

entity sdram is
port (
	I_CLK		: in std_logic;
	I_RESET		: in std_logic;
	I_WR		: in std_logic;
	I_RD		: in std_logic;
	I_DQM		: in std_logic_vector(7 downto 0);
	I_ADDR		: in std_logic_vector(21 downto 0);
	I_DATA		: in std_logic_vector(63 downto 0);
	O_DATA	 	: out std_logic_vector(63 downto 0);
	O_ENA		: out std_logic;
	-- SDRAM Pin
	O_CLK		: out std_logic;
	O_RAS_N		: out std_logic;
	O_CAS_N		: out std_logic;
	O_WE_N		: out std_logic;
	O_DQM		: out std_logic_vector(1 downto 0);
	O_BA		: out std_logic_vector(1 downto 0);
	O_MA		: out std_logic_vector(12 downto 0);
	IO_DQ		: inout std_logic_vector(15 downto 0));
end sdram;

architecture rtl of sdram is
	signal state		: std_logic_vector(5 downto 0) := "000000";
	signal data_out		: std_logic_vector(47 downto 0);
	signal addr		: std_logic_vector(6 downto 0);
	signal en		: std_logic;
	
	-- SD-RAM control signals
	signal sdr_cmd		: std_logic_vector(2 downto 0);
	signal sdr_ba		: std_logic_vector(1 downto 0);
	signal sdr_dqm		: std_logic_vector(1 downto 0);
	signal sdr_a		: std_logic_vector(12 downto 0);
	signal sdr_dq		: std_logic_vector(15 downto 0);

	constant SdrCmd_xx	: std_logic_vector(2 downto 0) := "111"; -- no operation
	constant SdrCmd_ac	: std_logic_vector(2 downto 0) := "011"; -- activate
	constant SdrCmd_rd	: std_logic_vector(2 downto 0) := "101"; -- read
	constant SdrCmd_wr	: std_logic_vector(2 downto 0) := "100"; -- write		
	constant SdrCmd_pr	: std_logic_vector(2 downto 0) := "010"; -- precharge all
	constant SdrCmd_re	: std_logic_vector(2 downto 0) := "001"; -- refresh
	constant SdrCmd_ms	: std_logic_vector(2 downto 0) := "000"; -- mode regiser set

-- Init----------------------------------------------------------------------------  Idle----  Write---------------  Read----------------     Refresh-------------
-- 00 01 02 03 04 05 06 07 08 09 0A 0B 0C 0D 0E 0F 10 11 12 13 14 15 16 17 18 19 1A  1B        1C 1D 1E 1F 20 19 1A  21 22 23 24 25 26 27     14 15 16 17 18 19 1A
-- PR xx xx RE xx xx xx xx xx xx xx RE xx xx xx xx xx xx xx MS xx xx xx xx xx xx xx  xx/AC/RE  xx WR xx xx xx xx xx  xx RD xx xx xx xx xx     xx xx xx xx xx xx xx
--                                                                                                B0 B1 B2 B3                    B0 B1 B2 B3
-- CLK		= 56MHz	=  17,8571428571429ns
-- WR		= 8T	= 142,8571428571429ns
-- RD		= 8T	= 142,8571428571429ns
-- RFSH		= 8T	= 142,8571428571429ns

begin
	process (I_RESET, I_CLK, I_RD, I_WR)
	begin
		if I_RESET = '1' then
			sdr_cmd <= (others => '1');
			sdr_dqm <= (others => '1');
			sdr_dq  <= (others => 'Z');
			sdr_ba  <= (others => '1');
			sdr_a   <= (others => '1');
			state   <= (others => '0');
		elsif I_CLK'event and I_CLK = '0' then
			O_ENA <= '0';
			case state is
				-- Init
				when "000000" =>
					sdr_cmd <= SdrCmd_pr;		-- PRECHARGE
					sdr_dqm <= (others => '1');
					sdr_dq  <= (others => 'Z');
					sdr_ba  <= (others => '0');
					sdr_a   <= (others => '1');
					state   <= state + 1;
				when "000011" | "001011" =>	 	-- s03 s0B
					sdr_cmd <= SdrCmd_re;		-- REFRESH
					state   <= state + 1;
				when "010011" =>			-- s13
					sdr_cmd <= SdrCmd_ms;		-- LOAD MODE REGISTER
					sdr_a   <= "000" & "0" & "00" & "010" & "0" & "010";	-- WB=0 programmed burst length, CL=2, OP MODE=00 BT=0 sequential, BURST LENGTH=4
					state   <= state + 1;
				-- Idle
				when "011011" =>			-- s1B
					sdr_cmd <= SdrCmd_xx;		-- NOP
					sdr_dq  <= (others => 'Z');
					if I_WR = '1' then
						sdr_cmd <= SdrCmd_ac;	-- ACTIVE
						sdr_ba  <= I_ADDR(21 downto 20);
						sdr_a   <= I_ADDR(19 downto 7);
						state   <= state + 1;	-- s1C Write
					elsif I_RD = '1' then
						sdr_cmd <= SdrCmd_ac;	-- ACTIVE
						sdr_ba  <= I_ADDR(21 downto 20);
						sdr_a   <= I_ADDR(19 downto 7);
						state   <= "100001";	-- s21 Read
					else
						sdr_cmd  <= SdrCmd_re;	-- REFRESH
						state    <= "010100";	-- s14
					end if;
				when "011010" =>			-- s1A
					sdr_dq  <= (others => 'Z');
					sdr_cmd <= SdrCmd_xx;		-- NOP
					state   <= state + 1;
					en	<= not en;
					O_ENA	<= en;
		
				-- Write - with auto precharge
				when "011101" =>			-- s1D
					sdr_cmd <= SdrCmd_wr;		-- WRITE
					sdr_a   <= "0010" & I_ADDR(6 downto 0) & "00";	--  A10 = 1 enable auto precharge; A8..0 = column
					sdr_dq  <= I_DATA(15 downto 0);
					sdr_dqm <= I_DQM(1 downto 0);
					state   <= state + 1;
				when "011110" =>			-- s1E
					sdr_dq  <= I_DATA(31 downto 16);
					sdr_dqm <= I_DQM(3 downto 2);
					sdr_cmd <= SdrCmd_xx;		-- NOP
					state   <= state + 1;
				when "011111" =>			-- s1F
					sdr_dq  <= I_DATA(47 downto 32);
					sdr_dqm <= I_DQM(5 downto 4);
					sdr_cmd <= SdrCmd_xx;		-- NOP
					state   <= state + 1;
				when "100000" =>			-- s20
					sdr_dq  <= I_DATA(63 downto 48);
					sdr_dqm <= I_DQM(7 downto 6);
					sdr_cmd <= SdrCmd_xx;		-- NOP
					state   <= "011001";		-- s19
				-- Read - with auto precharge
				when "100010" =>			-- s22
					sdr_cmd <= SdrCmd_rd;		-- READ
					sdr_a   <= "0010" & I_ADDR(6 downto 0) & "00";	--  A10 = 1 enable auto precharge; A8..0 = column
					sdr_dqm <= "00";
					state   <= state + 1;
				when "100111" =>			-- s27
					sdr_dq  <= (others => 'Z');
					sdr_cmd <= SdrCmd_xx;		-- NOP
					state   <= "011011";		-- s1B
					en	<= not en;
					O_ENA	<= en;
				when others =>
					sdr_dq  <= (others => 'Z');
					sdr_cmd <= SdrCmd_xx;		-- NOP
					state   <= state + 1;
			end case;
		end if;
	end process;

	process (I_CLK, state)
	begin
		if I_CLK'event and I_CLK = '1' then
			case state is
				when "100101" => data_out(15 downto  0) <= IO_DQ;
				when "100110" => data_out(31 downto 16) <= IO_DQ;
				when "100111" => data_out(47 downto 32) <= IO_DQ;
				when others => null;
			end case;
		end if;
	end process;

	O_DATA	<= IO_DQ & data_out;
	O_CLK	<= I_CLK;
	O_RAS_N	<= sdr_cmd(2);
	O_CAS_N	<= sdr_cmd(1);
	O_WE_N	<= sdr_cmd(0);
	O_DQM	<= sdr_dqm;
	O_BA	<= sdr_ba;
	O_MA	<= sdr_a;
	IO_DQ	<= sdr_dq;

end rtl;
	