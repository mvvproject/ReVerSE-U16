-------------------------------------------------------------------[09.05.2016]
-- HDMI
-------------------------------------------------------------------------------
-- Engineer: MVV

library ieee;
	use ieee.std_logic_1164.all;
	use ieee.std_logic_unsigned.all;

entity hdmi is
port (
	I_CLK_PIXEL	: in std_logic;		-- pixelclock
	I_CLK_TMDS	: in std_logic;		-- pixelclock*5
	I_HSYNC		: in std_logic;
	I_VSYNC		: in std_logic;
	I_BLANK		: in std_logic;
	I_RED		: in std_logic_vector(7 downto 0);
	I_GREEN		: in std_logic_vector(7 downto 0);
	I_BLUE		: in std_logic_vector(7 downto 0);
	O_TMDS		: out std_logic_vector(7 downto 0));
end entity hdmi;

architecture rtl of hdmi is
   
	signal r	: std_logic_vector(9 downto 0);
	signal g	: std_logic_vector(9 downto 0);
	signal b	: std_logic_vector(9 downto 0);
	signal mod5	: std_logic_vector(2 downto 0) := "000";	-- modulus 5 counter
	signal shift_r	: std_logic_vector(9 downto 0) := "0000000000";
	signal shift_g	: std_logic_vector(9 downto 0) := "0000000000";
	signal shift_b	: std_logic_vector(9 downto 0) := "0000000000";

begin

	encode_r : entity work.encoder
	port map (
		I_CLK	=> I_CLK_PIXEL,
		I_VD	=> I_RED,
		I_CD	=> "00",
		I_VDE	=> not(I_BLANK),
		O_TMDS	=> r);

	encode_g : entity work.encoder
	port map (
		I_CLK   => I_CLK_PIXEL,
		I_VD    => I_GREEN,
		I_CD    => "00",
		I_VDE   => not(I_BLANK),
		O_TMDS  => g);

	encode_b : entity work.encoder
	port map (
		I_CLK   => I_CLK_PIXEL,
		I_VD    => I_BLUE,
		I_CD    => (I_VSYNC & I_HSYNC),
		I_VDE   => not(I_BLANK),
		O_TMDS  => b);

	process (I_CLK_TMDS)
	begin
		if (I_CLK_TMDS'event and I_CLK_TMDS = '1') then
			if mod5(2) = '1' then
				mod5 <= "000";
				shift_r <= r;
				shift_g <= g;
				shift_b <= b;
			else
				mod5 <= mod5 + "001";
				shift_r <= "00" & shift_r(9 downto 2);
				shift_g <= "00" & shift_g(9 downto 2);
				shift_b <= "00" & shift_b(9 downto 2);
			end if;
		end if;
	end process;
	
	ddio_inst : entity work.altddio_out1
	port map (
		datain_h => shift_r(0) & not(shift_r(0)) & shift_g(0) & not(shift_g(0)) & shift_b(0) & not(shift_b(0)) & I_CLK_PIXEL & not(I_CLK_PIXEL),
		datain_l => shift_r(1) & not(shift_r(1)) & shift_g(1) & not(shift_g(1)) & shift_b(1) & not(shift_b(1)) & I_CLK_PIXEL & not(I_CLK_PIXEL),
		outclock => I_CLK_TMDS,
		dataout  => O_TMDS);

end architecture rtl;


