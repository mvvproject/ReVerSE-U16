-------------------------------------------------------------------[28.10.2014]
-- VGA
-------------------------------------------------------------------------------
-- Author:	MVV
-- Description:	VGA 640 x 480
-- Versions:
-- V1.0		16.08.2014	Initial release.
-- V1.0.1	23.08.2014	Синхронизация HSYNC, VSYNC, BLANK, INT
-------------------------------------------------------------------------------

library IEEE; 
use IEEE.std_logic_1164.all; 
use IEEE.std_logic_unsigned.all;

entity vga is
	port (
	CLK		: in std_logic;
	CLKEN		: in std_logic;
	MODE		: in std_logic_vector(1 downto 0);
	PIXEL_DI	: in std_logic_vector(23 downto 0);
	CHAR_DI		: in std_logic_vector(15 downto 0);
	CURSOR_X	: in std_logic_vector(6 downto 0);	-- 0..79
	CURSOR_Y	: in std_logic_vector(4 downto 0);	-- 0..29
	CURSOR_COLOR	: in std_logic_vector(7 downto 0);	-- 7=type 0:big;1:small, 6..4=Paper(RGB), 3=Bright, 2..0=Ink(RGB)
	INT		: out std_logic;
	PIXEL_ADDR	: out std_logic_vector(18 downto 0);
	CHAR_ADDR	: out std_logic_vector(11 downto 0);
	HSYNC		: out std_logic;
	VSYNC		: out std_logic;
	BLANK		: out std_logic;
	R		: out std_logic_vector(7 downto 0);
	G		: out std_logic_vector(7 downto 0);
	B		: out std_logic_vector(7 downto 0));
end entity;

architecture rtl of vga is
	signal sync_hcnt	: std_logic_vector(9 downto 0);
	signal sync_hcnt_reg	: std_logic_vector(9 downto 0);
	signal sync_vcnt	: std_logic_vector(9 downto 0);
	signal sync_hsync	: std_logic;
	signal sync_vsync	: std_logic;
	signal sync_blank	: std_logic;
	signal sync_int		: std_logic;
	signal font_addr	: std_logic_vector(11 downto 0);
	signal font_data	: std_logic_vector(7 downto 0);
	signal txt_red		: std_logic_vector(7 downto 0);
	signal txt_green	: std_logic_vector(7 downto 0);
	signal txt_blue		: std_logic_vector(7 downto 0);
	signal grf_red		: std_logic_vector(7 downto 0);
	signal grf_green	: std_logic_vector(7 downto 0);
	signal grf_blue		: std_logic_vector(7 downto 0);

begin

vga_sync: entity work.sync
port map (
	CLK		=> CLK,
	CLKEN		=> CLKEN,
	-- out
	HCNT		=> sync_hcnt,
	HCNT_REG	=> sync_hcnt_reg,
	VCNT		=> sync_vcnt,
	INT		=> sync_int,
	BLANK		=> sync_blank,
	HSYNC		=> sync_hsync,	-- horizontal (line) sync
	VSYNC		=> sync_vsync);	-- vertical (frame) sync

-- Video Text Mode 80x30, 4800 bytes, Font 8x16 4096 bytes
vga_txt: entity work.txt
port map (
	CLK		=> CLK,		-- VGA dot clock
	CLKEN		=> CLKEN,
	CHAR_DI		=> CHAR_DI,
	FONT_DI		=> font_data,
	HCNT		=> sync_hcnt,
	HCNT_REG	=> sync_hcnt_reg,
	VCNT		=> sync_vcnt,
	BLANK		=> sync_blank,
	CURSOR_X	=> CURSOR_X,
	CURSOR_Y	=> CURSOR_Y,
	CURSOR_COLOR	=> CURSOR_COLOR,
	-- out
	CHAR_ADDR	=> CHAR_ADDR,
	FONT_ADDR	=> font_addr,
	R		=> txt_red,
	G		=> txt_green,
	B		=> txt_blue);

-- Font 4K
font_inst: entity work.m9k2
port map (
	clock	 	=> not CLK,	-- инвертировано для устранения смещения paper относительно ink
	clken		=> CLKEN,
	address	 	=> font_addr,
	-- out
	q	 	=> font_data);

-- Video Graphics Mode 640x480 24bpp, 307200 bytes x 3
vga_grf: entity work.grf
port map (
	CLK		=> CLK,
	CLKEN		=> CLKEN,
	PIXEL_DI	=> PIXEL_DI,
	HCNT		=> sync_hcnt,
	VCNT		=> sync_vcnt,
	BLANK		=> sync_blank,
	INT		=> sync_int,
	-- out
	PIXEL_ADDR	=> PIXEL_ADDR,
	R		=> grf_red,
	G		=> grf_green,
	B		=> grf_blue);

-- Video buffer 2K x 3
--vga_rbuf: entity work.m9k3
--port map (
--	WRCLOCK		=>,
--	WRADDRESS	=> not(buffer_page) & buffer_write_address,
--	WREN		=>,
--	DATA		=>,
--	RDCLOCK		=>,
--	RDADDRESS	=> buffer_page & buffer_read_addr,
--	-- out
--	Q		=>);
--
--vga_gbuf: entity work.m9k3
--port map (
--	WRCLOCK		=>,
--	WRADDRESS	=>,
--	WREN		=>,
--	DATA		=>,
--	RDCLOCK		=>,
--	RDADDRESS	=> buf_page & buf_addr,
--	-- out
--	Q		=>);
--
--vga_bbuf: entity work.m9k3
--port map (
--	WRCLOCK		=>,
--	WRADDRESS	=>,
--	WREN		=>,
--	DATA		=>,
--	RDCLOCK		=>,
--	RDADDRESS	=> buf_page & buf_addr,
--	-- out
--	Q		=>);














	process (CLK)
	begin
		if CLK'event and CLK = '1' then
			if CLKEN = '1' then
				case MODE is
					when "00" => R <= txt_red; G <= txt_green; B <= txt_blue;
					when "01" => R <= grf_red; G <= grf_green; B <= grf_blue;
					when "10" =>
						if txt_red = "00000000" and txt_green = "00000000" and txt_blue = "00000000" then
							R <= grf_red; G <= grf_green; B <= grf_blue;
						else
							R <= txt_red; G <= txt_green; B <= txt_blue;
						end if;
					when others => null;
				end case;
					HSYNC <= sync_hsync;
					VSYNC <= sync_vsync;
					BLANK <= sync_blank;
					INT <= sync_int;
			end if;
		end if;
	end process;

end architecture;