-------------------------------------------------------------------[13.08.2016]
-- VGA
-------------------------------------------------------------------------------
-- Engineer: MVV <mvvproject@gmail.com>

library IEEE; 
	use IEEE.std_logic_1164.all; 
	use IEEE.std_logic_unsigned.all;
	use IEEE.numeric_std.all;
	
entity vga is
port (
	I_CLK		: in std_logic;
	I_CLK_VGA	: in std_logic;
	I_COLOR		: in std_logic_vector(5 downto 0);
	I_HCNT		: in std_logic_vector(8 downto 0);
	I_VCNT		: in std_logic_vector(8 downto 0);
	O_HSYNC		: out std_logic;
	O_VSYNC		: out std_logic;
	O_RED		: out std_logic_vector(7 downto 0);
	O_GREEN		: out std_logic_vector(7 downto 0);
	O_BLUE		: out std_logic_vector(7 downto 0);
	O_HCNT		: out std_logic_vector(9 downto 0);
	O_VCNT		: out std_logic_vector(9 downto 0);
	O_H		: out std_logic_vector(9 downto 0);
	O_BLANK		: out std_logic);
end vga;

architecture rtl of vga is
	signal rgb		: std_logic_vector(23 downto 0);
	signal pixel_out	: std_logic_vector(5 downto 0);
	signal addr_rd		: std_logic_vector(15 downto 0);
	signal addr_wr		: std_logic_vector(15 downto 0);
	signal wren		: std_logic;
	signal picture		: std_logic;
	signal window_hcnt	: std_logic_vector(8 downto 0) := "000000000";
	signal hcnt		: std_logic_vector(9 downto 0) := "0000000000";
	signal h		: std_logic_vector(9 downto 0) := "0000000000";
	signal vcnt		: std_logic_vector(9 downto 0) := "0000000000";
	signal hsync		: std_logic;
	signal vsync		: std_logic;
	signal blank		: std_logic;

-- ModeLine "640x480@60Hz"  25,175  640  656  752  800 480 490 492 525 -HSync -VSync
	-- Horizontal Timing constants  
	constant h_pixels_across	: integer := 640 - 1;
	constant h_sync_on		: integer := 656 - 1;
	constant h_sync_off		: integer := 752 - 1;
	constant h_end_count		: integer := 800 - 1;
	-- Vertical Timing constants
	constant v_pixels_down		: integer := 480 - 1;
	constant v_sync_on		: integer := 490 - 1;
	constant v_sync_off		: integer := 492 - 1;
	constant v_end_count		: integer := 525 - 1;
	
begin
	
	altsram: entity work.framebuffer
	port map(
		clock_a		=> I_CLK,
		data_a		=> I_COLOR,
		address_a	=> addr_wr,
		wren_a		=> wren,
		q_a		=> open,
		--
		clock_b		=> I_CLK_VGA,
		data_b		=> (others => '0'),
		address_b	=> addr_rd,
		wren_b		=> '0',
		q_b		=> pixel_out);

	-- NES Palette -> RGB888 conversion (http://www.thealmightyguru.com/Games/Hacking/Wiki/index.php?title=NES_Palette)
	process (pixel_out)
	begin
		case pixel_out is
			when "000000" => rgb <= X"7C7C7C";
			when "000001" => rgb <= X"0000FC";
			when "000010" => rgb <= X"0000BC";
			when "000011" => rgb <= X"4428BC";
			when "000100" => rgb <= X"940084";
			when "000101" => rgb <= X"A80020";
			when "000110" => rgb <= X"A81000";
			when "000111" => rgb <= X"881400";
			when "001000" => rgb <= X"503000";
			when "001001" => rgb <= X"007800";
			when "001010" => rgb <= X"006800";
			when "001011" => rgb <= X"005800";
			when "001100" => rgb <= X"004058";
			when "001101" => rgb <= X"000000";
			when "001110" => rgb <= X"000000";
			when "001111" => rgb <= X"000000";
			when "010000" => rgb <= X"BCBCBC";
			when "010001" => rgb <= X"0078F8";
			when "010010" => rgb <= X"0058F8";
			when "010011" => rgb <= X"6844FC";
			when "010100" => rgb <= X"D800CC";
			when "010101" => rgb <= X"E40058";
			when "010110" => rgb <= X"F83800";
			when "010111" => rgb <= X"E45C10";
			when "011000" => rgb <= X"AC7C00";
			when "011001" => rgb <= X"00B800";
			when "011010" => rgb <= X"00A800";
			when "011011" => rgb <= X"00A844";
			when "011100" => rgb <= X"008888";
			when "011101" => rgb <= X"000000";
			when "011110" => rgb <= X"000000";
			when "011111" => rgb <= X"000000";
			when "100000" => rgb <= X"F8F8F8";
			when "100001" => rgb <= X"3CBCFC";
			when "100010" => rgb <= X"6888FC";
			when "100011" => rgb <= X"9878F8";
			when "100100" => rgb <= X"F878F8";
			when "100101" => rgb <= X"F85898";
			when "100110" => rgb <= X"F87858";
			when "100111" => rgb <= X"FCA044";
			when "101000" => rgb <= X"F8B800";
			when "101001" => rgb <= X"B8F818";
			when "101010" => rgb <= X"58D854";
			when "101011" => rgb <= X"58F898";
			when "101100" => rgb <= X"00E8D8";
			when "101101" => rgb <= X"787878";
			when "101110" => rgb <= X"000000";
			when "101111" => rgb <= X"000000";
			when "110000" => rgb <= X"FCFCFC";
			when "110001" => rgb <= X"A4E4FC";
			when "110010" => rgb <= X"B8B8F8";
			when "110011" => rgb <= X"D8B8F8";
			when "110100" => rgb <= X"F8B8F8";
			when "110101" => rgb <= X"F8A4C0";
			when "110110" => rgb <= X"F0D0B0";
			when "110111" => rgb <= X"FCE0A8";
			when "111000" => rgb <= X"F8D878";
			when "111001" => rgb <= X"D8F878";
			when "111010" => rgb <= X"B8F8B8";
			when "111011" => rgb <= X"B8F8D8";
			when "111100" => rgb <= X"00FCFC";
			when "111101" => rgb <= X"F8D8F8";
			when "111110" => rgb <= X"000000";
			when "111111" => rgb <= X"000000";
		end case;
	end process;

	process (I_CLK_VGA)
	begin
		if I_CLK_VGA'event and I_CLK_VGA = '1' then
			if h = h_end_count then
				h <= (others => '0');
			else
				h <= h + 1;
			end if;
		
			if h = 7 then
				hcnt <= (others => '0');
			else
				hcnt <= hcnt + 1;
				if hcnt = 63 then
					window_hcnt <= (others => '0');
				else
					window_hcnt <= window_hcnt + 1;
				end if;
			end if;
			if hcnt = h_sync_on then
				if vcnt = v_end_count then
					vcnt <= (others => '0');
				else
					vcnt <= vcnt + 1;
				end if;
			end if;
		end if;
	end process;
	
	wren	<= '1' when (I_HCNT < 256) and (I_VCNT < 240) else '0';
	addr_wr	<= I_VCNT(7 downto 0) & I_HCNT(7 downto 0);
	addr_rd	<= vcnt(8 downto 1) & window_hcnt(8 downto 1);
	blank	<= '1' when (hcnt > h_pixels_across) or (vcnt > v_pixels_down) else '0';
	picture	<= '1' when (blank = '0') and (hcnt > 64 and hcnt < 576) else '0';

	O_HSYNC	<= '1' when (hcnt <= h_sync_on) or (hcnt > h_sync_off) else '0';
	O_VSYNC	<= '1' when (vcnt <= v_sync_on) or (vcnt > v_sync_off) else '0';
	O_RED	<= rgb(23 downto 16) when picture = '1' else (others => '0');
	O_GREEN	<= rgb(15 downto  8) when picture = '1' else (others => '0');
	O_BLUE	<= rgb( 7 downto  0) when picture = '1' else (others => '0');
	O_BLANK	<= blank;
	O_HCNT	<= hcnt;
	O_VCNT	<= vcnt;
	O_H	<= h;
	
end rtl;
