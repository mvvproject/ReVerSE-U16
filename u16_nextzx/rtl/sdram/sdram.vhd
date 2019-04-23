-------------------------------------------------------------------[27.03.2016]
-- SDRAM Controller
-------------------------------------------------------------------------------
-- Author:	MVV

-- 24.02.2015	SDRAM 4 Meg x 16 x 4 banks
-------------------------------------------------------------------------------

-- O_CLK	= 126MHz	= 7,936507936507937ns
-- WR		= 8T		= 63,49206349206349ns
-- RD		= 8T		= 63,49206349206349ns
-- RFSH		= 8T		= 63,49206349206349ns

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;

entity sdram is
port (
	I_CLK		: in std_logic;
	I_RESET		: in std_logic;
	I_WR		: in std_logic;
	I_REQ	 	: in std_logic;
	I_ADDR		: in std_logic_vector(24 downto 0);
	I_DATA		: in std_logic_vector(7 downto 0);
	O_DATA	 	: out std_logic_vector(7 downto 0);
	O_ACK	 	: out std_logic;
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
	signal rfsh_cnt		: std_logic_vector(9 downto 0) := "0000000000";
	signal rfsh_req		: std_logic := '0';
	signal ack		: std_logic;
	signal data		: std_logic_vector(7 downto 0);

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

-- Init----------------------------------------------------------------------------  Idle----  Write---------------  Read----------------  Refresh-------------
-- 00 01 02 03 04 05 06 07 08 09 0A 0B 0C 0D 0E 0F 10 11 12 13 14 15 16 17 18 19 1A  1B        1C 1D 16 17 18 19 1A  1F 20 21 22 23 24 25  14 15 16 17 18 19 1A
-- PR xx xx RE xx xx xx xx xx xx xx RE xx xx xx xx xx xx xx MS xx xx xx xx xx xx xx  xx/AC/RE  xx WR xx xx xx xx xx  xx RD xx xx xx xx xx  xx xx xx xx xx xx xx
--                                                                                                B0                                   B0
begin
	process (I_RESET, I_CLK, I_REQ, I_WR)
	begin
		if I_RESET = '1' then
			sdr_cmd <= (others => '1');
			sdr_dqm <= (others => '1');
			sdr_dq  <= (others => 'Z');
			sdr_ba  <= (others => '1');
			sdr_a   <= (others => '1');
			ack	<= '0';
			state   <= (others => '0');
		elsif I_CLK'event and I_CLK = '0' then
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
					sdr_a   <= "000" & "1" & "00" & "011" & "0" & "000";	-- WB=0 programmed burst length, CL=3, OP MODE=00 BT=0 sequential, BURST LENGTH=0
					state   <= state + 1;
				-- Idle
				when "011011" =>			-- s1B
					sdr_cmd <= SdrCmd_xx;		-- NOP
					sdr_dq  <= (others => 'Z');
					
					if rfsh_req = '1' then
						rfsh_req <= '0';
						sdr_cmd  <= SdrCmd_re;	-- REFRESH
						state    <= "010100";	-- s14

					elsif I_REQ = '1' then
						ack	<= '1';
						sdr_cmd <= SdrCmd_ac;	-- ACTIVE
						sdr_ba  <= I_ADDR(24 downto 23);
						sdr_a   <= I_ADDR(22 downto 10);
					
						if I_WR = '1' then
							state   <= state + 1;	-- s1C Write
						else
							state   <= "011111";	-- s1F Read
						end if;
					end if;
					
				-- a24 a23 a22 a21 a20 a19 a18 a17 a16 a15 a14 a13 a12 a11 a10 a9 a8 a7 a6 a5 a4 a3 a2 a1 a0
				-- BA1 BA0 ROW------------------------------------------------ COLUMN-------------------- HL	
				
				-- Write - with auto precharge
				when "011101" =>			-- s1D
					sdr_cmd <= SdrCmd_wr;		-- WRITE
					sdr_a   <= "0010" & I_ADDR(9 downto 1);	--  A10 = 1 enable auto precharge; A8..0 = column
					sdr_dq  <= I_DATA & I_DATA;
					sdr_dqm <= not I_ADDR(0) & I_ADDR(0);
					ack	<= '0';
					state   <= "010110";		-- s16

				-- Read - with auto precharge
				when "100000" =>			-- s20
					sdr_cmd <= SdrCmd_rd;		-- READ
					sdr_a   <= "0010" & I_ADDR(9 downto 1);	--  A10 = 1 enable auto precharge; A8..0 = column
					sdr_dqm <= (others => '0');
					state   <= state + 1;
					
				when "100101" =>			-- s25
					ack	<= '0';
					sdr_dq  <= (others => 'Z');
					sdr_cmd <= SdrCmd_xx;		-- NOP
					state   <= "011011";		-- s1B

				when others =>
					sdr_dq  <= (others => 'Z');
					sdr_cmd <= SdrCmd_xx;		-- NOP
					state   <= state + 1;
			end case;
			
			-- Providing a distributed AUTO REFRESH command every 7.81us
			if rfsh_cnt = "1111011000" then		-- (O_CLK MHz * 1000 * 64 / 8192) = 984
				rfsh_cnt <= (others => '0');
				rfsh_req <= '1';
			else
				rfsh_cnt <= rfsh_cnt + 1;
			end if;
		end if;
	end process;

	process (I_CLK, state)
	begin
		if I_CLK'event and I_CLK = '1' then
			if state = "100101" then	-- s25
				if I_ADDR(0) = '0' then
					data <= IO_DQ(7 downto 0);
				else
					data <= IO_DQ(15 downto 8);
				end if;
			end if;
		end if;
	end process;

	O_DATA	<= data;
	O_ACK	<= ack;
	
	O_CLK	<= I_CLK;
	O_RAS_N	<= sdr_cmd(2);
	O_CAS_N	<= sdr_cmd(1);
	O_WE_N	<= sdr_cmd(0);
	O_DQM	<= sdr_dqm;
	O_BA	<= sdr_ba;
	O_MA	<= sdr_a;
	IO_DQ	<= sdr_dq;

end rtl;
	