-------------------------------------------------------------------[20.12.2017]
-- SDRAM Controller
-------------------------------------------------------------------------------

-- CLK		= 84 MHz	= 11.9 ns
-- WR/RD	= 6T		= 71.4 ns  
-- RFSH		= 6T		= 71.4 ns

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity sdram is
	port(
		CLK			: in std_logic;
		clk_28MHz		: in std_logic;
		c0 			: in std_logic;
		c3 			: in std_logic;
		curr_cpu		: in std_logic;
		-- Memory port
		loader			: in std_logic;
		bsel  			: in std_logic_vector(1 downto 0); -- Active HI
		A			: in std_logic_vector(23 downto 0);
		DI			: in std_logic_vector(15 downto 0);
		DO			: out std_logic_vector(15 downto 0);
		DO_cpu	   		: out std_logic_vector(15 downto 0);
		dram_stb		: out std_logic;

		REQ	 		: in std_logic;
		RNW			: in std_logic;

		-- SDRAM Pin
		CK			: out std_logic;
		RAS_n			: out std_logic;
		CAS_n			: out std_logic;
		WE_n			: out std_logic;
		BA1			: out std_logic;
		BA0			: out std_logic;
		MA			: out std_logic_vector(12 downto 0);
		DQ			: inout std_logic_vector(15 downto 0);
		DQML        		: out std_logic;
		DQMH        		: out std_logic);
end sdram;

architecture rtl of sdram is
	signal state 		: unsigned(4 downto 0) := "00000";
	signal address		: std_logic_vector(8 downto 0);
	signal bsel_int 	: std_logic_vector(1 downto 0);
	signal data_reg		: std_logic_vector(15 downto 0);
	signal cpu_reg		: std_logic_vector(15 downto 0);
	signal data_in		: std_logic_vector(15 downto 0);
	signal WR_in		: std_logic;
	signal RD_in		: std_logic;
	signal rd_op		: std_logic;
	signal RFSH_in		: std_logic;
	-- SD-RAM control signals
	signal sdr_cmd		: std_logic_vector(2 downto 0);
	signal sdr_ba0		: std_logic;
	signal sdr_ba1		: std_logic;
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

-- Init----------------------------------------------------------  Idle----  Read----------  Write--------  Refresh-------
-- 00 01 02 03 04 05 06 07 08 09 0A 0B 0C 0D 0E 0F 10 11 12 13 14  15        16 17 12 13 14  18 19 12 13 14  10 11 12 13 14
-- pr xx xx re xx xx xx xx xx re xx xx xx xx xx ms xx xx xx xx xx  xx/ac/re  xx rd xx xx xx  xx wr xx xx xx  xx xx xx xx xx


begin

	process (clk_28MHz, c3, c0)
	begin 
		if rising_edge (clk_28MHz) and (c3 = '1') then	-- next_cycle
			if (REQ = '1' and RNW = '1') then 
				RD_in <= '1';
			elsif (REQ = '1' and RNW = '0') then
				WR_in <= '1';
			else
				RFSH_in <= '1';
			end if;
		end if;
		if rising_edge (clk_28MHz) and (c0 = '1') then	-- NOT WORK
			RD_in <= '0';
			WR_in <= '0';
			RFSH_in <= '0';
		end if;
	end process;
	
	process (CLK)
	begin
		if CLK'event and CLK = '0' then
			case state is
				-- Init
				when "00000" =>					-- s00
					sdr_cmd <= SdrCmd_pr;			-- PRECHARGE
					sdr_a <= "1111111111111";
					sdr_ba1 <= '0';
					sdr_ba0 <= '0';
					sdr_dqml <= '1';
					sdr_dqmh <= '1';
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
					sdr_dq <= (others => 'Z');
					if RD_in = '1' then
						bsel_int <= bsel;  
						address <= A(8 downto 0);		-- LOCK ADDR
						sdr_cmd <= SdrCmd_ac;		-- ACTIVE
						sdr_ba1 <= A(10);		-- A(11)
						sdr_ba0 <= A(9);		-- A(10)
						sdr_a <= A(23 downto 11);	-- RAW_ADDR(12..0) 				 
						state <= "10110";		-- s16 Read
					elsif WR_in = '1' and (loader = '1' or A(23) = '0') then	-- Rising UP
						rd_op <= '0';
						bsel_int <= bsel;
						address <= A(8 downto 0);
						data_in <= DI;
						sdr_cmd <= SdrCmd_ac;		-- ACTIVE
						sdr_ba1 <= A(10);
						sdr_ba0 <= A(9);
						sdr_a <= A(23 downto 11);
						state <= "11000";		-- s18 Write
					elsif RFSH_in = '1' then
						rd_op <= '0';
						sdr_cmd <= SdrCmd_re;		-- REFRESH
						state <= "10000";		-- s10
					else
						sdr_cmd <= SdrCmd_xx;		-- NOP
						rd_op <= '0';
					end if;

				-- A24 A23 A22 A21 A20 A19 A18 A17 A16 A15 A14 A13 A12 A11 A10 A9 A8 A7 A6 A5 A4 A3 A2 A1 A0
				-- -----------------------ROW------------------------- BA1 BA0 -----------COLUMN------------		
				-- Single read - with auto precharge
				when "10111" =>					-- s17
					sdr_cmd <= SdrCmd_rd;			-- READ (A10 = 1 enable auto precharge; A9..0 = column)
					sdr_a <= "0010" & address;
					sdr_dqml <= '0';
					sdr_dqmh <= '0';
					state <= "10010";			-- s12
					rd_op <= '1';
				-- Single write - with auto precharge
				when "11001" =>					-- s19
					sdr_cmd <= SdrCmd_wr;			-- WRITE (A10 = 1 enable auto precharge; A9..0 = column)
					sdr_a <= "0010" & address; 
					sdr_dqml <= not bsel_int(0);
					sdr_dqmh <= not bsel_int(1);	
					sdr_dq <= data_in;
					state <= "10010";			-- s12
					
				when others =>
					sdr_dq <= (others => 'Z');
					sdr_cmd <= SdrCmd_xx;			-- NOP
					state <= state + 1;
			end case;

		end if;
	end process;
	
	process (CLK, rd_op)
	begin
		if CLK'event and CLK = '1' and rd_op = '1' then
			if state = "10101" then					-- s15
				data_reg <= DQ;
				if curr_cpu = '1' then
					cpu_reg <= DQ;
				end if;
			end if;
		end if;
	end process;
	
	DO 	<= data_reg;
	DO_cpu  <= cpu_reg;
	CK 	<= CLK;
	RAS_n 	<= sdr_cmd(2);
	CAS_n 	<= sdr_cmd(1);
	WE_n 	<= sdr_cmd(0);
	DQML 	<= sdr_dqml;
	DQMH 	<= sdr_dqmh;
	BA1 	<= sdr_ba1;
	BA0 	<= sdr_ba0;
	MA 	<= sdr_a;
	DQ 	<= sdr_dq;
	dram_stb <= rd_op;

end rtl;