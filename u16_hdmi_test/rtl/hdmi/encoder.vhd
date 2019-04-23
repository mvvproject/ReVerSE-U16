-------------------------------------------------------------------[21.06.2016]
-- Encoder
-------------------------------------------------------------------------------
-- Engineer: MVV

library ieee;
	use ieee.std_logic_1164.all;
	use ieee.std_logic_unsigned.all;


entity encoder is
port (
	I_CLK		: in std_logic;
	I_VD		: in std_logic_vector(7 downto 0);	-- video data (RED, GREEN or BLUE)
	I_CD		: in std_logic_vector(1 downto 0);	-- control data
	I_VDE		: in std_logic;				-- video data enable, to choose between CD (when VDE=0) and VD (when VDE=1)
	O_TMDS		: out std_logic_vector(9 downto 0));
end entity encoder;

architecture rtl of encoder is
   
	signal nb1s		: std_logic_vector(3 downto 0);
	signal x_nor		: std_logic;
	signal balance_acc	: std_logic_vector(3 downto 0) := "0000";
	signal balance		: std_logic_vector(3 downto 0);
	signal balance_sign_eq	: std_logic;
	signal invert_q_m	: std_logic;
	signal balance_acc_inc	: std_logic_vector(3 downto 0);
	signal balance_acc_new	: std_logic_vector(3 downto 0);
	signal data		: std_logic_vector(9 downto 0);
	signal code		: std_logic_vector(9 downto 0);
	signal q_m		: std_logic_vector(8 downto 0);

begin
	
	process (I_CLK)
	begin
		if (I_CLK'event and I_CLK = '1') then
			if (I_VDE = '1') then 
				O_TMDS <= data;
				balance_acc <= balance_acc_new;
			else
				O_TMDS <= code;
				balance_acc <= "0000";
			end if;
		end if;
		
		case I_CD is            
			when "00"   => code <= "1101010100";
			when "01"   => code <= "0010101011";
			when "10"   => code <= "0101010100";
			when others => code <= "1010101011";
		end case;

	end process;

	nb1s		<= "000" & I_VD(0) + I_VD(1) + I_VD(2) + I_VD(3) + I_VD(4) + I_VD(5) + I_VD(6) + I_VD(7);
	x_nor		<= '1' when (nb1s > "0100") or (nb1s = "0100" and I_VD(0) = '0') else '0';
	q_m		<= not(x_nor) & (q_m(6 downto 0) xor I_VD(7 downto 1) xor (x_nor & x_nor & x_nor & x_nor & x_nor & x_nor & x_nor)) & I_VD(0);
	balance		<= ("000" & q_m(0) + q_m(1) + q_m(2) + q_m(3) + q_m(4) + q_m(5) + q_m(6) + q_m(7)) - "0100";
	data		<= invert_q_m & q_m(8) & q_m(7 downto 0) xor invert_q_m & invert_q_m & invert_q_m & invert_q_m & invert_q_m & invert_q_m & invert_q_m & invert_q_m;
	balance_sign_eq	<= '1' when balance(3) = balance_acc(3) else '0';
	invert_q_m	<= not(q_m(8)) when balance = "0000" or balance_acc = "0000" else balance_sign_eq;
	balance_acc_inc	<= balance - ("000" & ((q_m(8) xor not(balance_sign_eq)) and (not((balance(3) or balance(2) or balance(1) or balance(0) or balance_acc(3) or balance_acc(2) or balance_acc(1) or balance_acc(0))))));
	balance_acc_new	<= balance_acc - balance_acc_inc when invert_q_m = '1' else balance_acc + balance_acc_inc;
	
end architecture rtl;
