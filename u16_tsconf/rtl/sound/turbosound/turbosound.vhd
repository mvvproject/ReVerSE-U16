-------------------------------------------------------------------[20.06.2018]
-- TurboSound
-------------------------------------------------------------------------------
library IEEE; 
use IEEE.std_logic_1164.all; 
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all; 


entity turbosound is
	port (
		-- System Bus
		I_RESET		: in std_logic;				-- Global RESET (set all Registers to '0', active hi)
		I_CLK		: in std_logic;				-- Global CLOCK
		I_ADDR		: in std_logic_vector(15 downto 0);	-- Bus Address
		I_DATA		: in std_logic_vector(7 downto 0);	-- Bus Data In
		I_IORQ_N	: in std_logic;				-- Bus IORQ_N
		I_WR_N		: in std_logic;				-- Bus WR_N
		I_M1_N		: in std_logic;				-- Bus M1_N
		O_DATA		: out std_logic_vector(7 downto 0);	-- Bus Data Out
		-- Device Bus
		I_ENA		: in std_logic;				-- Clock enable
		I_MODE		: in std_logic;				-- 0=YM, 1=AY
		I_IOA0		: in std_logic_vector(7 downto 0);
		I_IOB0		: in std_logic_vector(7 downto 0);
		I_IOA1		: in std_logic_vector(7 downto 0);
		I_IOB1		: in std_logic_vector(7 downto 0);
		O_IOA0		: out std_logic_vector(7 downto 0);
		O_IOB0		: out std_logic_vector(7 downto 0);
		O_IOA1		: out std_logic_vector(7 downto 0);
		O_IOB1		: out std_logic_vector(7 downto 0);
		O_CH_L		: out std_logic_vector(9 downto 0);	-- Output channel Left
		O_CH_R		: out std_logic_vector(9 downto 0)	-- Output channel Right
	);
end turbosound;
		

architecture rtl of turbosound is
	signal bc1		: std_logic;
	signal bdir		: std_logic;
	signal ssg		: std_logic;
	signal ssg0_do		: std_logic_vector(7 downto 0);
	signal ssg1_do		: std_logic_vector(7 downto 0);
	signal ssg0_ch_a	: std_logic_vector(7 downto 0);
	signal ssg0_ch_b	: std_logic_vector(7 downto 0);
	signal ssg0_ch_c	: std_logic_vector(7 downto 0);
	signal ssg1_ch_a	: std_logic_vector(7 downto 0);
	signal ssg1_ch_b	: std_logic_vector(7 downto 0);
	signal ssg1_ch_c	: std_logic_vector(7 downto 0);
	
component ym2149 is
port (
	CLK		: in std_logic;				-- Global clock
	CE		: in std_logic;				-- PSG Clock enable
	RESET		: in std_logic;				-- Chip RESET (set all Registers to '0', active hi)
	BDIR		: in std_logic;				-- Bus Direction (0 - read , 1 - write)
	BC		: in std_logic;				-- Bus control
	DI		: in std_logic_vector(7 downto 0);	-- Data In
	DO		: out std_logic_vector(7 downto 0);	-- Data Out
	CHANNEL_A	: out std_logic_vector(7 downto 0);	-- PSG Output channel A
	CHANNEL_B	: out std_logic_vector(7 downto 0);	-- PSG Output channel B
	CHANNEL_C	: out std_logic_vector(7 downto 0);	-- PSG Output channel C
	ACTIVE		: out std_logic_vector(5 downto 0);
	SEL		: in std_logic;				-- When SEL = '0', the input clock is taken as the master clock, When the SEL = '1', the input clock is didided by 2
	A8		: in std_logic;				-- Address A8 set has '1'
	MODE		: in std_logic;				-- 0=YM, 1=AY
	IOA_in		: in std_logic_vector(7 downto 0);
	IOA_out		: out std_logic_vector(7 downto 0);
	IOB_in		: in std_logic_vector(7 downto 0);
	IOB_out		: out std_logic_vector(7 downto 0)
);
end component;


	
begin
	bdir	<= '1' when (I_M1_N = '1' and I_IORQ_N = '0' and I_WR_N = '0' and I_ADDR(15) = '1' and I_ADDR(1) = '0') else '0';
	bc1	<= '1' when (I_M1_N = '1' and I_IORQ_N = '0' and I_ADDR(15) = '1' and I_ADDR(14) = '1' and I_ADDR(1) = '0') else '0';

	O_DATA	<= ssg0_do when ssg = '0' else ssg1_do;
	O_CH_L	<= ("00" & ssg0_ch_a) + ("00" & ssg0_ch_b) + ("00" & ssg1_ch_a) + ("00" & ssg1_ch_b);
	O_CH_R	<= ("00" & ssg0_ch_c) + ("00" & ssg0_ch_b) + ("00" & ssg1_ch_c) + ("00" & ssg1_ch_b);

	process(I_CLK, I_RESET)
	begin
		if (I_RESET = '1') then
			ssg <= '0';
		elsif (I_CLK'event and I_CLK = '1') then
			if (I_DATA(7 downto 1) = "1111111" and bdir = '1' and bc1 = '1') then
				ssg <= I_DATA(0);
			end if;
		end if;
	end process;

ssg0: ym2149
port map (
	CLK		=> I_CLK,
	CE		=> I_ENA,
	RESET		=> I_RESET,
	BDIR		=> bdir,
	BC		=> bc1,
	DI		=> I_DATA,
	DO		=> ssg0_do,
	CHANNEL_A	=> ssg0_ch_a,
	CHANNEL_B	=> ssg0_ch_b,
	CHANNEL_C	=> ssg0_ch_c,
	ACTIVE		=> open,
	SEL		=> '0',
	A8		=> not ssg,
	MODE		=> I_MODE,
	IOA_in		=> I_IOA0,
	IOA_out		=> O_IOA0,
	IOB_in		=> I_IOB0,
	IOB_out		=> O_IOB0);
	
ssg1: ym2149
port map (
	CLK		=> I_CLK,
	CE		=> I_ENA,
	RESET		=> I_RESET,
	BDIR		=> bdir,
	BC		=> bc1,
	DI		=> I_DATA,
	DO		=> ssg1_do,
	CHANNEL_A	=> ssg1_ch_a,
	CHANNEL_B	=> ssg1_ch_b,
	CHANNEL_C	=> ssg1_ch_c,
	ACTIVE		=> open,
	SEL		=> '0',
	A8		=> ssg,
	MODE		=> I_MODE,
	IOA_in		=> I_IOA1,
	IOA_out		=> O_IOA1,
	IOB_in		=> I_IOB1,
	IOB_out		=> O_IOB1);

end rtl;	