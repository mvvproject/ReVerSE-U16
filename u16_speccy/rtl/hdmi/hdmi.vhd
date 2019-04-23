-- Adapted By MVV

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity hdmi is
port (
	CLK_DVI		: in std_logic;
	CLK_PIXEL	: in std_logic;
	R			: in std_logic_vector(7 downto 0);
	G			: in std_logic_vector(7 downto 0);
	B			: in std_logic_vector(7 downto 0);
	BLANK		: in std_logic;
	HSYNC		: in std_logic;
	VSYNC		: in std_logic;
	TMDS_D0		: out std_logic;
	TMDS_D1		: out std_logic;
	TMDS_D2		: out std_logic;
	TMDS_CLK	: out std_logic);
end entity;

architecture rtl of hdmi is
	signal red		: std_logic_vector(9 downto 0);
	signal green	: std_logic_vector(9 downto 0);
	signal blue		: std_logic_vector(9 downto 0);		
	signal tx_in	: std_logic_vector(29 downto 0);
	signal tmds_d	: std_logic_vector(2 downto 0);
	
begin

enc0: entity work.encoder
port map (
	CLK		=> CLK_PIXEL,
	DATA	=> B,
	C		=> VSYNC & HSYNC,
	BLANK	=> BLANK,
	ENCODED	=> blue);

enc1: entity work.encoder
port map (
	CLK		=> CLK_PIXEL,
	DATA	=> G,
	C		=> "00",
	BLANK	=> BLANK,
	ENCODED	=> green);

enc2: entity work.encoder
port map (
	CLK		=> CLK_PIXEL,
	DATA	=> R,
	C		=> "00",
	BLANK	=> BLANK,
	ENCODED	=> red);

serializer_inst: entity work.serializer
PORT MAP (
	tx_in	 		=> tx_in,
	tx_inclock	 	=> CLK_DVI,
	tx_syncclock	=> CLK_PIXEL,
	tx_out	 		=> tmds_d);
	
tx_in <= red(0) & red(1) & red(2) & red(3) & red(4) & red(5) & red(6) & red(7) & red(8) & red(9) &
		 green(0) & green(1) & green(2) & green(3) & green(4) & green(5) & green(6) & green(7) & green(8) & green(9) &
		 blue(0) & blue(1) & blue(2) & blue(3) & blue(4) & blue(5) & blue(6) & blue(7) & blue(8) & blue(9);

TMDS_D0	 <= tmds_d(0);
TMDS_D1	 <= tmds_d(1);
TMDS_D2	 <= tmds_d(2);
TMDS_CLK <= CLK_PIXEL;

end rtl;