-------------------------------------------------------------------[11.09.2015]
-- SDRAM Controller SDRAM 4 Meg x 16 x 4 banks
-------------------------------------------------------------------------------
-- Engineer: 	MVV <mvvproject@gmail.com>
--
-- 27.02.2015	4-Channal
-- 14.03.2015	CH0 DMA

-- CLK		= 84 MHz	= 11,9047619047619 ns
-- WR/RD	= 6T		= 71,42857142857143 ns
-- RFSH		= 6T		= 71,42857142857143 ns

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity sdram is
	port(
		I_RESET		: in  std_logic;
		I_CLK		: in  std_logic;
		O_ENA		: out std_logic;
		-- Channal 0
		I_CH0_ADDR	: in  std_logic_vector(24 downto 0);
		I_CH0_DATA	: in  std_logic_vector( 7 downto 0);
		O_CH0_DATA	: out std_logic_vector( 7 downto 0);
		I_CH0_WR	: in  std_logic;
		I_CH0_RD	: in  std_logic;
		I_CH0_RFSH	: in  std_logic;
		I_CH0_DMA_ADDR	: in  std_logic_vector(24 downto 0);
		I_CH0_DMA_RD	: in  std_logic;
		O_CH0_DMA_ACK	: out std_logic;
		-- Channal 1
		I_CH1_ADDR	: in  std_logic_vector(24 downto 0);
		I_CH1_DATA	: in  std_logic_vector( 7 downto 0);
		O_CH1_DATA	: out std_logic_vector( 7 downto 0);
		I_CH1_WR	: in  std_logic;
		I_CH1_RD	: in  std_logic;
		I_CH1_RFSH	: in  std_logic;
		-- Channal 2
		I_CH2_ADDR	: in  std_logic_vector(24 downto 0);
		I_CH2_DATA	: in  std_logic_vector( 7 downto 0);
		O_CH2_DATA	: out std_logic_vector( 7 downto 0);
		I_CH2_WR	: in  std_logic;
		I_CH2_RD	: in  std_logic;
		I_CH2_RFSH	: in  std_logic;
		-- Channal 3
		I_CH3_ADDR	: in  std_logic_vector(24 downto 0);
		I_CH3_DATA	: in  std_logic_vector( 7 downto 0);
		O_CH3_DATA	: out std_logic_vector( 7 downto 0);
		I_CH3_WR	: in  std_logic;
		I_CH3_RD	: in  std_logic;
		I_CH3_RFSH	: in  std_logic;
		-- SDRAM Pin
		O_CLK		: out std_logic;
		O_RAS_N		: out std_logic;
		O_CAS_N		: out std_logic;
		O_WE_N		: out std_logic;
		O_DQML		: out std_logic;
		O_DQMH		: out std_logic;
		O_BA		: out std_logic_vector( 1 downto 0);
		O_MA		: out std_logic_vector(12 downto 0);
		IO_DQ		: inout std_logic_vector(15 downto 0) );
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
	
	signal ch0_dma_data	: std_logic_vector(7 downto 0);
	signal ch0_dma_ack	: std_logic := '0';
	signal ch0_dma_req	: std_logic := '0';
	
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
	process (I_RESET, I_CLK)
	begin
		if (I_RESET = '1') then
			sdr_cmd  <= (others => '1');
			sdr_a    <= (others => '1');
			sdr_ba   <= (others => '1');
			sdr_dq   <= (others => 'Z');
			state    <= (others => '0');
			channal  <= (others => '0');
			sdr_dqml <= '1';
			sdr_dqmh <= '1';

		elsif (I_CLK'event and I_CLK = '0') then
			O_ENA <= '0';
			if (I_CH0_DMA_RD = '0') then ch0_dma_req <= '0'; end if;

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
							if (I_CH0_RD = '1') then
								idle1   <= '0';
								address <= I_CH0_ADDR;
								sdr_cmd <= SdrCmd_ac;		-- ACTIVE
								sdr_ba  <= I_CH0_ADDR(24 downto 23);
								sdr_a   <= I_CH0_ADDR(22 downto 10);
								state   <= "10110";		-- s16 Read
							elsif (I_CH0_WR = '1') then
								idle1   <= '0';
								address <= I_CH0_ADDR;
								data    <= I_CH0_DATA;
								sdr_cmd <= SdrCmd_ac;		-- ACTIVE
								sdr_ba  <= I_CH0_ADDR(24 downto 23);
								sdr_a   <= I_CH0_ADDR(22 downto 10);
								state   <= "11000";		-- s18 Write
							elsif (I_CH0_DMA_RD = '1') then
								ch0_dma_req <= '1';
								idle1   <= '0';
								address <= I_CH0_DMA_ADDR;
								sdr_cmd <= SdrCmd_ac;		-- ACTIVE
								sdr_ba  <= I_CH0_DMA_ADDR(24 downto 23);
								sdr_a   <= I_CH0_DMA_ADDR(22 downto 10);
								state   <= "10110";		-- s16 Read
							else
								sdr_cmd <= SdrCmd_re;		-- REFRESH
								state   <= "10000";		-- s10
							end if;
						-- Channal 1
						when "01" =>
							if (I_CH1_RD = '1') then
								idle1   <= '0';
								address <= I_CH1_ADDR;
								sdr_cmd <= SdrCmd_ac;		-- ACTIVE
								sdr_ba  <= I_CH1_ADDR(24 downto 23);
								sdr_a   <= I_CH1_ADDR(22 downto 10);
								state   <= "10110";		-- s16 Read
							elsif (I_CH1_WR = '1') then
								idle1   <= '0';
								address <= I_CH1_ADDR;
								data    <= I_CH1_DATA;
								sdr_cmd <= SdrCmd_ac;		-- ACTIVE
								sdr_ba  <= I_CH1_ADDR(24 downto 23);
								sdr_a   <= I_CH1_ADDR(22 downto 10);
								state   <= "11000";		-- s18 Write
							else
								sdr_cmd <= SdrCmd_re;		-- REFRESH
								state   <= "10000";		-- s10
							end if;
						-- Channal 2
						when "10" =>
							if (I_CH2_RD = '1') then
								idle1   <= '0';
								address <= I_CH2_ADDR;
								sdr_cmd <= SdrCmd_ac;		-- ACTIVE
								sdr_ba  <= I_CH2_ADDR(24 downto 23);
								sdr_a   <= I_CH2_ADDR(22 downto 10);
								state   <= "10110";		-- s16 Read
							elsif (I_CH2_WR = '1') then
								idle1   <= '0';
								address <= I_CH2_ADDR;
								data    <= I_CH2_DATA;
								sdr_cmd <= SdrCmd_ac;		-- ACTIVE
								sdr_ba  <= I_CH2_ADDR(24 downto 23);
								sdr_a   <= I_CH2_ADDR(22 downto 10);
								state   <= "11000";		-- s18 Write
							else
								sdr_cmd <= SdrCmd_re;		-- REFRESH
								state   <= "10000";		-- s10
							end if;
						-- Channal 3
						when "11" =>
							if (I_CH3_RD = '1') then
								idle1   <= '0';
								address <= I_CH3_ADDR;
								sdr_cmd <= SdrCmd_ac;		-- ACTIVE
								sdr_ba  <= I_CH3_ADDR(24 downto 23);
								sdr_a   <= I_CH3_ADDR(22 downto 10);
								state   <= "10110";		-- s16 Read
							elsif (I_CH3_WR = '1') then
								idle1   <= '0';
								address <= I_CH3_ADDR;
								data    <= I_CH3_DATA;
								sdr_cmd <= SdrCmd_ac;		-- ACTIVE
								sdr_ba  <= I_CH3_ADDR(24 downto 23);
								sdr_a   <= I_CH3_ADDR(22 downto 10);
								state   <= "11000";		-- s18 Write
							else
								sdr_cmd <= SdrCmd_re;		-- REFRESH
								state   <= "10000";		-- s10
							end if;
						when others => null;
					end case;
				when "10100" =>					-- s14
					if (channal = "11") then
						O_ENA <= '1';
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
	
	process (I_CLK, state, IO_DQ, ch0_data, ch1_data, ch2_data, ch3_data, idle1, address, ch0_dma_ack, ch0_dma_req)
	begin
		if (I_CLK'event and I_CLK = '1') then
			if (I_CH0_DMA_RD = '0') then ch0_dma_ack <= '0'; end if;
			if (state = "10101" and idle1 = '0') then		-- s15
				if (address(0) = '0') then
					case channal is
						when "00" => ch3_data <= IO_DQ(7 downto 0);
						when "01" => ch0_data <= IO_DQ(7 downto 0); if (ch0_dma_req = '1') then ch0_dma_ack <= '1'; end if;
						when "10" => ch1_data <= IO_DQ(7 downto 0);
--						when "11" => ch2_data <= IO_DQ(7 downto 0);
						when others => null;
					end case;
				else
					case channal is
						when "00" => ch3_data <= IO_DQ(15 downto 8);
						when "01" => ch0_data <= IO_DQ(15 downto 8); if (ch0_dma_req = '1') then ch0_dma_ack <= '1'; end if;
						when "10" => ch1_data <= IO_DQ(15 downto 8);
--						when "11" => ch2_data <= IO_DQ(15 downto 8);
						when others => null;
					end case;
				end if;
			end if;
		end if;
		if (address(0) = '0') then
			ch2_data <= IO_DQ(7 downto 0);
		else
			ch2_data <= IO_DQ(15 downto 8);
		end if;
	end process;
	
	O_CH0_DATA <= ch0_data;
	O_CH1_DATA <= ch1_data;
	O_CH2_DATA <= ch2_data;
	O_CH3_DATA <= ch3_data;
	
	O_CH0_DMA_ACK <= ch0_dma_ack;
	
	O_CLK 	<= I_CLK;
	O_RAS_N 	<= sdr_cmd(2);
	O_CAS_N 	<= sdr_cmd(1);
	O_WE_N 	<= sdr_cmd(0);
	O_DQML 	<= sdr_dqml;
	O_DQMH 	<= sdr_dqmh;
	O_BA	<= sdr_ba;
	O_MA 	<= sdr_a;
	IO_DQ 	<= sdr_dq;

end rtl;
