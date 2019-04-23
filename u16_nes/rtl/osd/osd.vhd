-------------------------------------------------------------------[13.08.2016]
-- OSD
-------------------------------------------------------------------------------
-- Engineer: MVV <mvvproject@gmail.com>

library IEEE; 
use IEEE.std_logic_1164.all; 
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;

entity osd is
port (
	I_RESET		: in std_logic;
	I_CLK_VGA	: in std_logic;
	I_CLK_CPU	: in std_logic;
	I_CLK_BUS	: in std_logic;
	I_JOY0		: in std_logic_vector(7 downto 0);
	I_JOY1		: in std_logic_vector(7 downto 0);
	I_KEY		: in std_logic;
	I_SPI_MISO	: in std_logic;
	I_SD_MISO	: in std_logic;
	I_RED		: in std_logic_vector(7 downto 0);
	I_GREEN		: in std_logic_vector(7 downto 0);
	I_BLUE		: in std_logic_vector(7 downto 0);
	I_HCNT		: in std_logic_vector(9 downto 0);
	I_VCNT		: in std_logic_vector(9 downto 0);
	I_H		: in std_logic_vector(9 downto 0);
	I_DOWNLOAD_OK	: in std_logic;
	O_RED		: out std_logic_vector(7 downto 0);
	O_GREEN		: out std_logic_vector(7 downto 0);
	O_BLUE		: out std_logic_vector(7 downto 0);
	O_SPI_CLK	: out std_logic;
	O_SPI_MOSI	: out std_logic;
	O_SPI_CS_N	: out std_logic;	-- SPI FLASH
	O_SD_CLK	: out std_logic;
	O_SD_MOSI	: out std_logic;
	O_SD_CS_N	: out std_logic;	-- SD Card
	O_DOWNLOAD_DO	: out std_logic_vector(7 downto 0);
	O_DOWNLOAD_WR	: out std_logic;
	O_DOWNLOAD_ON	: out std_logic);
end osd;

architecture rtl of osd is

signal spi_busy		: std_logic;
signal spi_do		: std_logic_vector(7 downto 0);
signal spi_wr		: std_logic;
signal sd_busy		: std_logic;
signal sd_do		: std_logic_vector(7 downto 0);
signal sd_wr		: std_logic;
signal cpu_di		: std_logic_vector(7 downto 0);
signal cpu_do		: std_logic_vector(7 downto 0);
signal cpu_addr		: std_logic_vector(15 downto 0);
signal cpu_mreq		: std_logic;
signal cpu_iorq		: std_logic;
signal cpu_wr		: std_logic;
signal m1		: std_logic;
signal ram_wr		: std_logic;
signal ram_do		: std_logic_vector(7 downto 0);
signal reg_0		: std_logic_vector(7 downto 0) := "11111111";
signal osd_addr		: std_logic_vector(9 downto 0);
signal osd_byte		: std_logic_vector(7 downto 0);
signal osd_pixel	: std_logic;
signal osd_de		: std_logic;
signal osd_wr		: std_logic;
signal osd_vcnt		: std_logic_vector(9 downto 0);
signal osd_hcnt		: std_logic_vector(9 downto 0);
signal osd_h_active	: std_logic;
signal osd_v_active	: std_logic;
signal osd_cursor	: std_logic;
signal cursor		: std_logic := '1';
signal int		: std_logic;
signal char_addr	: std_logic_vector(7 downto 0);
signal font_addr	: std_logic_vector(9 downto 0);
signal font_data	: std_logic_vector(7 downto 0);

constant OSD_INK	: std_logic_vector(2 downto 0) := "111";	-- RGB
constant OSD_PAPER	: std_logic_vector(2 downto 0) := "011";	-- RGB
constant OSD_H_ON	: std_logic_vector(9 downto 0) := "0011000000";	-- OSD hstart = 192
constant OSD_H_OFF	: std_logic_vector(9 downto 0) := "0111000000";	-- OSD hend   = 448
constant OSD_V_ON	: std_logic_vector(9 downto 0) := "0011010000";	-- OSD vstart = 208
constant OSD_V_OFF	: std_logic_vector(9 downto 0) := "0100010000";	-- OSD vend   = 272

begin

u0: entity work.spi
port map(
	RESET		=> I_RESET,
	CLK		=> I_CLK_CPU,
	SCK		=> I_CLK_BUS,
	DI		=> cpu_do,
	DO		=> spi_do,
	WR		=> spi_wr,
	BUSY		=> spi_busy,
	SCLK		=> O_SPI_CLK,
	MOSI		=> O_SPI_MOSI,
	MISO		=> I_SPI_MISO);

u1: entity work.nz80cpu
port map(
	CLK		=> I_CLK_CPU,
	CLKEN		=> '1',
	RESET		=> I_RESET,
	NMI		=> '0',
	INT		=> int,
	DI		=> cpu_di,
	DO		=> cpu_do,
	ADDR		=> cpu_addr,
	WR		=> cpu_wr,
	MREQ		=> cpu_mreq,
	IORQ		=> cpu_iorq,
	HALT		=> open,
	M1		=> m1);
	
u2: entity work.ram
port map(
	address_a 	=> cpu_addr(12 downto 0),
	address_b	=> "11" & osd_vcnt(6 downto 4) & osd_hcnt(7 downto 0),
	clock_a	 	=> I_CLK_BUS,
	clock_b		=> I_CLK_VGA,
	data_a	 	=> cpu_do,
	data_b		=> (others => '0'),
	wren_a	 	=> ram_wr,
	wren_b		=> '0',
	q_a	 	=> ram_do,
	q_b		=> open);

u3: entity work.spi
port map(
	RESET		=> I_RESET,
	CLK		=> I_CLK_CPU,
	SCK		=> I_CLK_BUS,
	DI		=> cpu_do,
	DO		=> sd_do,
	WR		=> sd_wr,
	BUSY		=> sd_busy,
	SCLK		=> O_SD_CLK,
	MOSI		=> O_SD_MOSI,
	MISO		=> I_SD_MISO);
-------------------------------------------------------------------------------
-- CPU
process (I_CLK_BUS, I_RESET, cpu_addr, cpu_iorq, cpu_wr)
begin
	if (I_RESET = '1') then
		reg_0 <= (others => '1');
	elsif (I_CLK_BUS'event and I_CLK_BUS = '1') then
		if cpu_addr(7 downto 0) = X"00" and cpu_iorq = '1' and cpu_wr = '1' then reg_0 <= cpu_do; end if;
	end if;
end process;

-- 00 - SPI SC#
-- 01 - SPI0 DATA I/O
-- 02 - SPI0 STATUS
-- 03 - BUTTONS
-- 04 - DJOY1
-- 05 - DOWNLOAD DATA/STATUS
-- 06 - SD
-- 0F - DJOY2

cpu_di <=	ram_do when cpu_addr(15) = '0' and cpu_mreq = '1' and cpu_wr = '0' else
		reg_0 when cpu_addr(7 downto 0) = X"00" and cpu_iorq = '1' and cpu_wr = '0' else
		spi_do when cpu_addr(7 downto 0) = X"01" and cpu_iorq = '1' and cpu_wr = '0' else
		spi_busy & "000000" & sd_busy when cpu_addr(7 downto 0) = X"02" and cpu_iorq = '1' and cpu_wr = '0' else
		I_DOWNLOAD_OK & "0000000" when cpu_addr(7 downto 0) = X"05" and cpu_iorq = '1' and cpu_wr = '0' else
		sd_do when  cpu_addr(7 downto 0) = X"06" and cpu_iorq = '1' and cpu_wr = '0' else
		I_JOY0 when cpu_addr(7 downto 0) = X"04" and cpu_iorq = '1' and cpu_wr = '0' else
		I_JOY1 when cpu_addr(7 downto 0) = X"0F" and cpu_iorq = '1' and cpu_wr = '0' else
		"1111111" & I_KEY when cpu_addr(7 downto 0) = X"03" and cpu_iorq = '1' and cpu_wr = '0' else
		X"FF";

ram_wr <= '1' when cpu_addr(15) = '0' and cpu_mreq = '1' and cpu_wr = '1' else '0';
spi_wr <= '1' when cpu_addr(7 downto 0) = X"01" and cpu_iorq = '1' and cpu_wr = '1' else '0';
sd_wr <= '1' when cpu_addr(7 downto 0) = X"06" and cpu_iorq = '1' and cpu_wr = '1' else '0';

-- INT
process (I_CLK_BUS, cpu_iorq, m1, I_VCNT)
begin
	if (cpu_iorq = '1' and m1 = '1') then
		int <= '0';
	elsif (I_CLK_BUS'event and I_CLK_BUS = '1') then
		if (I_VCNT = "0000000000") then
			int <= '1';
		end if;
	end if;
end process;

O_SPI_CS_N  <= reg_0(0);
O_SD_CS_N <= reg_0(1);

O_DOWNLOAD_WR <= '1' when cpu_addr(7 downto 0) = X"05" and cpu_iorq = '1' and cpu_wr = '1' else '0';
O_DOWNLOAD_ON <= not reg_0(2);
O_DOWNLOAD_DO <= cpu_do;

-------------------------------------------------------------------------------
-- OSD

u4: entity work.osdram
port map(
	address_a	=> "11" & cpu_addr(7 downto 0),
	address_b	=> osd_addr,
	clock_a	 	=> I_CLK_CPU,
	clock_b		=> I_CLK_VGA,
	data_a	 	=> cpu_do,
	data_b		=> (others => '0'),
	wren_a	 	=> osd_wr,
	wren_b		=> '0',
	q_a	 	=> open,
	q_b		=> osd_byte);

osd_wr <= '1' when cpu_addr(15 downto 8) = "11111111" and cpu_mreq = '1' and cpu_wr = '1' else '0';
	
process (I_CLK_VGA, osd_hcnt, font_data)
begin
	if (I_CLK_VGA'event and I_CLK_VGA = '1') then
		if osd_hcnt(2 downto 0) = "011" then osd_addr <= "11" & osd_vcnt(5 downto 3) & osd_hcnt(7 downto 3); end if;
		if osd_hcnt(2 downto 0) = "101" then osd_addr <= osd_byte(6 downto 0) & osd_vcnt(2 downto 0); end if;
		if osd_hcnt(2 downto 0) = "111" then font_data <= osd_byte; end if;		
	end if;
	case osd_hcnt(2 downto 0) is
		when "000" => osd_pixel <= font_data(7);
		when "001" => osd_pixel <= font_data(6);
		when "010" => osd_pixel <= font_data(5);
		when "011" => osd_pixel <= font_data(4);
		when "100" => osd_pixel <= font_data(3);
		when "101" => osd_pixel <= font_data(2);
		when "110" => osd_pixel <= font_data(1);
		when "111" => osd_pixel <= font_data(0);
		when others => null;
	end case;
end process;

osd_h_active <= '1' when (I_HCNT >= OSD_H_ON) and (I_HCNT < OSD_H_OFF) else '0';
osd_v_active <= '1' when (I_VCNT >= OSD_V_ON) and (I_VCNT < OSD_V_OFF) else '0';
osd_de <= I_KEY and osd_h_active and osd_v_active;
osd_hcnt <= I_H - OSD_H_ON;
osd_vcnt <= I_VCNT - OSD_V_ON;
osd_cursor <= '1' when cursor = '1' and (osd_hcnt <= 263) and osd_vcnt(5 downto 3) = "110" else '0';

O_RED <= (others => OSD_INK(2)) when osd_pixel = '1' and osd_de = '1' else '0' & OSD_PAPER(2) & I_RED(4 downto 0) & '0' when osd_de = '1' else I_RED;
O_GREEN <= (others => OSD_INK(1)) when osd_pixel = '1' and osd_de = '1' else '0' & OSD_PAPER(1) & I_GREEN(4 downto 0) & '0' when osd_de = '1' else I_GREEN;
O_BLUE <= (others => OSD_INK(0)) when osd_pixel = '1' and osd_de = '1' else osd_cursor & OSD_PAPER(0) & I_BLUE(4 downto 0) & '0' when osd_de = '1' else I_BLUE;

end rtl;