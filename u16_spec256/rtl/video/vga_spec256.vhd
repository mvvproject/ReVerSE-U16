-------------------------------------------------------------------[09.07.2016]
-- VGA
-------------------------------------------------------------------------------
-- Engineer: MVV <mvvproject@gmail.com>

library IEEE; 
use IEEE.std_logic_1164.all; 
use IEEE.numeric_std.ALL;
use IEEE.std_logic_unsigned.all;

entity vga_spec256 is
port (
	I_CLK		: in std_logic;
	I_DATA		: in std_logic_vector(63 downto 0);
	I_BORDER	: in std_logic_vector(2 downto 0);	-- Биты D0..D2 порта xxFE определяют цвет бордюра
	I_HCNT		: in std_logic_vector(9 downto 0);
	I_VCNT		: in std_logic_vector(9 downto 0);
	I_BLANK		: in std_logic;
	O_ADDR		: out std_logic_vector(12 downto 0);
	O_R		: out std_logic_vector(7 downto 0);	-- Red
	O_G		: out std_logic_vector(7 downto 0);	-- Green
	O_B		: out std_logic_vector(7 downto 0));	-- Blue
end entity;

architecture rtl of vga_spec256 is

-- ZX-Spectum screen
	constant spec_border_left	: natural :=  32;	-- (640 - (spec_screen_h *2)) / 2 
	constant spec_screen_h		: natural := 256;	-- Spectrum Screen h = 256 pixels

	constant spec_border_top	: natural :=  24;	-- (640 - (spec_screen_v * 2)) / 2
	constant spec_screen_v		: natural := 192;	-- Spectrum Screen v = 192 pixels
	constant h_sync_on		: integer := 575;	-- (spec_screen_h * 2) + (spec_border_left * 2) - 1

	signal spec_h_count_reg		: std_logic_vector(9 downto 0);
	signal spec_v_count_reg		: std_logic_vector(9 downto 0);

	signal paper			: std_logic;
	signal paper1			: std_logic;
	signal pixel			: std_logic_vector(7 downto 0);
	signal pixel_reg		: std_logic_vector(55 downto 0);
	signal rgb			: std_logic_vector(23 downto 0);


begin

process (I_CLK, I_HCNT, I_VCNT, pixel)
begin
	if I_CLK'event and I_CLK = '1' then
		if I_HCNT = spec_border_left * 2 then
			spec_h_count_reg <= (others => '0');
		else
			spec_h_count_reg <= spec_h_count_reg + 1;
		end if;

		if I_HCNT = h_sync_on then
			if I_VCNT = spec_border_top * 2 then
				spec_v_count_reg <= (others => '0');
			else
				spec_v_count_reg <= spec_v_count_reg + 1;
			end if;
		end if;
		
		case spec_h_count_reg(3 downto 0) is
			when "0001" =>	pixel <= I_DATA(63) & I_DATA(55) & I_DATA(47) & I_DATA(39) & I_DATA(31) & I_DATA(23) & I_DATA(15) & I_DATA(7);
					pixel_reg <= I_DATA(62 downto 56) & I_DATA(54 downto 48) & I_DATA(46 downto 40) & I_DATA(38 downto 32) & I_DATA(30 downto 24) & I_DATA(22 downto 16) & I_DATA(14 downto 8) & I_DATA(6 downto 0);
					paper1 <= paper;
			when "0011" =>	pixel <= pixel_reg(55) & pixel_reg(48) & pixel_reg(41) & pixel_reg(34) & pixel_reg(27) & pixel_reg(20) & pixel_reg(13) & pixel_reg(6);
			when "0101" =>	pixel <= pixel_reg(54) & pixel_reg(47) & pixel_reg(40) & pixel_reg(33) & pixel_reg(26) & pixel_reg(19) & pixel_reg(12) & pixel_reg(5);
			when "0111" =>	pixel <= pixel_reg(53) & pixel_reg(46) & pixel_reg(39) & pixel_reg(32) & pixel_reg(25) & pixel_reg(18) & pixel_reg(11) & pixel_reg(4);
			when "1001" => 	pixel <= pixel_reg(52) & pixel_reg(45) & pixel_reg(38) & pixel_reg(31) & pixel_reg(24) & pixel_reg(17) & pixel_reg(10) & pixel_reg(3);
			when "1011" =>	pixel <= pixel_reg(51) & pixel_reg(44) & pixel_reg(37) & pixel_reg(30) & pixel_reg(23) & pixel_reg(16) & pixel_reg( 9) & pixel_reg(2);
			when "1101" =>	pixel <= pixel_reg(50) & pixel_reg(43) & pixel_reg(36) & pixel_reg(29) & pixel_reg(22) & pixel_reg(15) & pixel_reg( 8) & pixel_reg(1);
			when "1111" =>	pixel <= pixel_reg(49) & pixel_reg(42) & pixel_reg(35) & pixel_reg(28) & pixel_reg(21) & pixel_reg(14) & pixel_reg( 7) & pixel_reg(0);
			when others =>	null;
		end case;
		
	end if;
	
	-- Spec256 palette
	case pixel is
		when X"00" => rgb <= X"000000";
		when X"01" => rgb <= X"00009b";
		when X"02" => rgb <= X"172fab";
		when X"03" => rgb <= X"3763bb";
		when X"04" => rgb <= X"5b93cb";
		when X"05" => rgb <= X"83bfdb";
		when X"06" => rgb <= X"b3e3eb";
		when X"07" => rgb <= X"e7ffff";
		when X"08" => rgb <= X"b70000";
		when X"09" => rgb <= X"bf1717";
		when X"0a" => rgb <= X"cb3333";
		when X"0b" => rgb <= X"d35353";
		when X"0c" => rgb <= X"df7777";
		when X"0d" => rgb <= X"e79b9b";
		when X"0e" => rgb <= X"f3c3c3";
		when X"0f" => rgb <= X"ffefef";
		                       
		when X"10" => rgb <= X"003723";
		when X"11" => rgb <= X"07533b";
		when X"12" => rgb <= X"176f53";
		when X"13" => rgb <= X"2f8b73";
		when X"14" => rgb <= X"4fa78f";
		when X"15" => rgb <= X"73c3b3";
		when X"16" => rgb <= X"9fdfd3";
		when X"17" => rgb <= X"d3fff7";
		when X"18" => rgb <= X"ff4b00";
		when X"19" => rgb <= X"ff771f";
		when X"1a" => rgb <= X"ff9f3f";
		when X"1b" => rgb <= X"ffbf63";
		when X"1c" => rgb <= X"ffdb83";
		when X"1d" => rgb <= X"ffeba7";
		when X"1e" => rgb <= X"fff7c7";
		when X"1f" => rgb <= X"ffffeb";
                                       
		when X"20" => rgb <= X"672b00";
		when X"21" => rgb <= X"7b3b0b";
		when X"22" => rgb <= X"8f4f23";
		when X"23" => rgb <= X"a7673b";
		when X"24" => rgb <= X"bb835b";
		when X"25" => rgb <= X"d39f7f";
		when X"26" => rgb <= X"e7bfa7";
		when X"27" => rgb <= X"ffe7d7";
		when X"28" => rgb <= X"7f004b";
		when X"29" => rgb <= X"8f135b";
		when X"2a" => rgb <= X"a32b73";
		when X"2b" => rgb <= X"b34b8b";
		when X"2c" => rgb <= X"c76fa3";
		when X"2d" => rgb <= X"d79bbf";
		when X"2e" => rgb <= X"ebcbdf";
		when X"2f" => rgb <= X"ffffff";
                                       
		when X"30" => rgb <= X"0b2373";
		when X"31" => rgb <= X"1b3387";
		when X"32" => rgb <= X"2f479b";
		when X"33" => rgb <= X"4b63af";
		when X"34" => rgb <= X"677fc3";
		when X"35" => rgb <= X"8b9fd7";
		when X"36" => rgb <= X"b3bfeb";
		when X"37" => rgb <= X"dfe7ff";
		when X"38" => rgb <= X"337f23";
		when X"39" => rgb <= X"438f1f";
		when X"3a" => rgb <= X"53a31f";
		when X"3b" => rgb <= X"6bb31b";
		when X"3c" => rgb <= X"87c717";
		when X"3d" => rgb <= X"abd70f";
		when X"3e" => rgb <= X"cfeb07";
		when X"3f" => rgb <= X"ffff00";
                                       
		when X"40" => rgb <= X"c30000";
		when X"41" => rgb <= X"af1700";
		when X"42" => rgb <= X"bb3300";
		when X"43" => rgb <= X"c75300";
		when X"44" => rgb <= X"d77b00";
		when X"45" => rgb <= X"e3a300";
		when X"46" => rgb <= X"efcf00";
		when X"47" => rgb <= X"ffff00";
		when X"48" => rgb <= X"4b4b33";
		when X"49" => rgb <= X"636347";
		when X"4a" => rgb <= X"7b7b5b";
		when X"4b" => rgb <= X"979773";
		when X"4c" => rgb <= X"afaf8b";
		when X"4d" => rgb <= X"cbcba3";
		when X"4e" => rgb <= X"e3e3bf";
		when X"4f" => rgb <= X"ffffdb";
		                       
		when X"50" => rgb <= X"000000";
		when X"51" => rgb <= X"434343";
		when X"52" => rgb <= X"636363";
		when X"53" => rgb <= X"7f7f7f";
		when X"54" => rgb <= X"9f9f9f";
		when X"55" => rgb <= X"bbbbbb";
		when X"56" => rgb <= X"dbdbdb";
		when X"57" => rgb <= X"fbfbfb";
		when X"58" => rgb <= X"a36f57";
		when X"59" => rgb <= X"af7f63";
		when X"5a" => rgb <= X"bb8f6f";
		when X"5b" => rgb <= X"c7a37b";
		when X"5c" => rgb <= X"d7b78b";
		when X"5d" => rgb <= X"e3c79b";
		when X"5e" => rgb <= X"efdbab";
		when X"5f" => rgb <= X"ffefbb";
                                       
		when X"60" => rgb <= X"00abcb";
		when X"61" => rgb <= X"17b3cf";
		when X"62" => rgb <= X"33bbd7";
		when X"63" => rgb <= X"4fc7df";
		when X"64" => rgb <= X"6bcfe3";
		when X"65" => rgb <= X"8bdbeb";
		when X"66" => rgb <= X"afe7f3";
		when X"67" => rgb <= X"d3f3fb";
		when X"68" => rgb <= X"00d300";
		when X"69" => rgb <= X"17d717";
		when X"6a" => rgb <= X"2fdf2f";
		when X"6b" => rgb <= X"4be34b";
		when X"6c" => rgb <= X"67eb67";
		when X"6d" => rgb <= X"83ef83";
		when X"6e" => rgb <= X"a3f7a3";
		when X"6f" => rgb <= X"c3ffc3";
                                       
		when X"70" => rgb <= X"4f4f67";
		when X"71" => rgb <= X"5f5f7b";
		when X"72" => rgb <= X"73738f";
		when X"73" => rgb <= X"8b8ba7";
		when X"74" => rgb <= X"9f9fbb";
		when X"75" => rgb <= X"b7b7d3";
		when X"76" => rgb <= X"cbcbe7";
		when X"77" => rgb <= X"e7e7ff";
		when X"78" => rgb <= X"8b8300";
		when X"79" => rgb <= X"9b930f";
		when X"7a" => rgb <= X"aba323";
		when X"7b" => rgb <= X"bbb33b";
		when X"7c" => rgb <= X"cbc353";
		when X"7d" => rgb <= X"dbd773";
		when X"7e" => rgb <= X"ebe793";
		when X"7f" => rgb <= X"fffbbb";
		                       
		when X"80" => rgb <= X"375757";
		when X"81" => rgb <= X"3b6f6f";
		when X"82" => rgb <= X"3b8787";
		when X"83" => rgb <= X"3b9f9f";
		when X"84" => rgb <= X"33b7b7";
		when X"85" => rgb <= X"27cfcf";
		when X"86" => rgb <= X"17e7e7";
		when X"87" => rgb <= X"07ffff";
		when X"88" => rgb <= X"000000";
		when X"89" => rgb <= X"00001b";
		when X"8a" => rgb <= X"000037";
		when X"8b" => rgb <= X"00004f";
		when X"8c" => rgb <= X"00006b";
		when X"8d" => rgb <= X"000087";
		when X"8e" => rgb <= X"0000a3";
		when X"8f" => rgb <= X"0000bf";
		                       
		when X"90" => rgb <= X"000000";
		when X"91" => rgb <= X"1b0000";
		when X"92" => rgb <= X"370000";
		when X"93" => rgb <= X"4f0000";
		when X"94" => rgb <= X"6b0000";
		when X"95" => rgb <= X"870000";
		when X"96" => rgb <= X"a30000";
		when X"97" => rgb <= X"bf0000";
		when X"98" => rgb <= X"000000";
		when X"99" => rgb <= X"1b001b";
		when X"9a" => rgb <= X"370037";
		when X"9b" => rgb <= X"4f004f";
		when X"9c" => rgb <= X"6b006b";
		when X"9d" => rgb <= X"870087";
		when X"9e" => rgb <= X"a300a3";
		when X"9f" => rgb <= X"bf00bf";
                                       
		when X"a0" => rgb <= X"000000";
		when X"a1" => rgb <= X"001b00";
		when X"a2" => rgb <= X"003700";
		when X"a3" => rgb <= X"004f00";
		when X"a4" => rgb <= X"006b00";
		when X"a5" => rgb <= X"008700";
		when X"a6" => rgb <= X"00a300";
		when X"a7" => rgb <= X"00bf00";
		when X"a8" => rgb <= X"000000";
		when X"a9" => rgb <= X"001b1b";
		when X"aa" => rgb <= X"003737";
		when X"ab" => rgb <= X"004f4f";
		when X"ac" => rgb <= X"006b6b";
		when X"ad" => rgb <= X"008787";
		when X"ae" => rgb <= X"00a3a3";
		when X"af" => rgb <= X"00bfbf";
                                       
		when X"b0" => rgb <= X"000000";
		when X"b1" => rgb <= X"1b1b00";
		when X"b2" => rgb <= X"373700";
		when X"b3" => rgb <= X"4f4f00";
		when X"b4" => rgb <= X"6b6b00";
		when X"b5" => rgb <= X"878700";
		when X"b6" => rgb <= X"a3a300";
		when X"b7" => rgb <= X"bfbf00";
		when X"b8" => rgb <= X"000000";
		when X"b9" => rgb <= X"1b1b1b";
		when X"ba" => rgb <= X"373737";
		when X"bb" => rgb <= X"4f4f4f";
		when X"bc" => rgb <= X"6b6b6b";
		when X"bd" => rgb <= X"878787";
		when X"be" => rgb <= X"a3a3a3";
		when X"bf" => rgb <= X"bfbfbf";
                                       
		when X"c0" => rgb <= X"000000";
		when X"c1" => rgb <= X"000000";
		when X"c2" => rgb <= X"000000";
		when X"c3" => rgb <= X"000000";
		when X"c4" => rgb <= X"000000";
		when X"c5" => rgb <= X"000000";
		when X"c6" => rgb <= X"000000";
		when X"c7" => rgb <= X"000000";
		when X"c8" => rgb <= X"00003f";
		when X"c9" => rgb <= X"000057";
		when X"ca" => rgb <= X"000073";
		when X"cb" => rgb <= X"00008f";
		when X"cc" => rgb <= X"0000ab";
		when X"cd" => rgb <= X"0000c7";
		when X"ce" => rgb <= X"0000e3";
		when X"cf" => rgb <= X"0000ff";
		                       
		when X"d0" => rgb <= X"3f0000";
		when X"d1" => rgb <= X"570000";
		when X"d2" => rgb <= X"730000";
		when X"d3" => rgb <= X"8f0000";
		when X"d4" => rgb <= X"ab0000";
		when X"d5" => rgb <= X"c70000";
		when X"d6" => rgb <= X"e30000";
		when X"d7" => rgb <= X"ff0000";
		when X"d8" => rgb <= X"3f003f";
		when X"d9" => rgb <= X"570057";
		when X"da" => rgb <= X"730073";
		when X"db" => rgb <= X"8f008f";
		when X"dc" => rgb <= X"ab00ab";
		when X"dd" => rgb <= X"c700c7";
		when X"de" => rgb <= X"e300e3";
		when X"df" => rgb <= X"ff00ff";
                                       
		when X"e0" => rgb <= X"003f00";
		when X"e1" => rgb <= X"005700";
		when X"e2" => rgb <= X"007300";
		when X"e3" => rgb <= X"008f00";
		when X"e4" => rgb <= X"00ab00";
		when X"e5" => rgb <= X"00c700";
		when X"e6" => rgb <= X"00e300";
		when X"e7" => rgb <= X"00ff00";
		when X"e8" => rgb <= X"000000";
		when X"e9" => rgb <= X"002323";
		when X"ea" => rgb <= X"004747";
		when X"eb" => rgb <= X"006b6b";
		when X"ec" => rgb <= X"008f8f";
		when X"ed" => rgb <= X"00b3b3";
		when X"ee" => rgb <= X"00dbdb";
		when X"ef" => rgb <= X"00ffff";
                                       
		when X"f0" => rgb <= X"3f3f00";
		when X"f1" => rgb <= X"575700";
		when X"f2" => rgb <= X"737300";
		when X"f3" => rgb <= X"8f8f00";
		when X"f4" => rgb <= X"abab00";
		when X"f5" => rgb <= X"c7c700";
		when X"f6" => rgb <= X"e3e300";
		when X"f7" => rgb <= X"ffff00";
		when X"f8" => rgb <= X"3f3f3f";
		when X"f9" => rgb <= X"575757";
		when X"fa" => rgb <= X"737373";
		when X"fb" => rgb <= X"8f8f8f";
		when X"fc" => rgb <= X"ababab";
		when X"fd" => rgb <= X"c7c7c7";
		when X"fe" => rgb <= X"e3e3e3";
		when X"ff" => rgb <= X"ffffff";
		
		when others => null;
	end case;	
end process;

paper <= '1' when (spec_h_count_reg(9 downto 1) < spec_screen_h and spec_v_count_reg(9 downto 1) < spec_screen_v) else '0';
O_ADDR <= spec_v_count_reg(8 downto 7) & spec_v_count_reg(3 downto 1) & spec_v_count_reg(6 downto 4) & spec_h_count_reg(8 downto 4);

O_R <= (others => '0') when (I_BLANK = '1') else rgb(23 downto 16) when paper1 = '1' else (others => I_BORDER(1));
O_G <= (others => '0') when (I_BLANK = '1') else rgb(15 downto 8) when paper1 = '1' else (others => I_BORDER(2));
O_B <= (others => '0') when (I_BLANK = '1') else rgb(7 downto 0) when paper1 = '1' else (others => I_BORDER(0));

end architecture;
















































































































































































































































































