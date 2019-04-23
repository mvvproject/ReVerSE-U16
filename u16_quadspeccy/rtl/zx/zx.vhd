-------------------------------------------------------------------[24.06.2018]
-- zx
-------------------------------------------------------------------------------
-- Engineer: 	MVV <mvvproject@gmail.com>
--
-- 12.02.2011	первая версия
-- 14.03.2015	DMA Sound
-- 10.09.2015	Добавлена Kempston Mouse
-- 24.06.2018	Замена модуля ym2149, общий RTC

library IEEE; 
use IEEE.std_logic_1164.all; 
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all; 

entity zx is
generic (
	Loader		: std_logic := '0';
	CPU		: std_logic_vector(1 downto 0) := "00" );
port (
	I_RESET		: in  std_logic;
	I_CLK		: in  std_logic;
	I_SEL		: in  std_logic;
	I_ENA_1_75MHZ	: in  std_logic;
	-- CPU
	O_CPU_DATA	: out std_logic_vector(7 downto 0);
	O_CPU_ADDR	: out std_logic_vector(15 downto 0);
	I_CPU_INT	: in  std_logic;
	I_CPU_CLK	: in  std_logic;
	I_CPU_ENA	: in  std_logic;
	O_CPU_RFSH	: out std_logic;
	O_CPU_RD_N	: out std_logic;
	O_CPU_WR_N	: out std_logic;
	O_CPU_IORQ_N	: out std_logic;
	O_CPU_INTA	: out std_logic;
	-- ROM
	I_ROM_DATA	: in  std_logic_vector(7 downto 0);
	-- RAM
	O_RAM_ADDR	: out std_logic_vector(11 downto 0);
	I_RAM_DATA	: in  std_logic_vector(7 downto 0);
	O_RAM_WR	: out std_logic;
	O_RAM_RD	: out std_logic;
	-- Video
	I_VIDEO_CLK	: in  std_logic;
	I_VIDEO_ADDR	: in  std_logic_vector(12 downto 0);
	O_VIDEO_DATA	: out std_logic_vector(7 downto 0);
	I_VIDEO_ATTR	: in std_logic_vector(7 downto 0);
	I_VIDEO_BORDER	: in std_logic;
	-- Port
	O_PORT_XXFE	: out std_logic_vector(7 downto 0);
	O_PORT_0001	: out std_logic_vector(7 downto 0);
	-- Keyboard
	I_KEYBOARD_DATA	: in  std_logic_vector(4 downto 0);
	I_KEYBOARD_FN	: in  std_logic_vector(12 downto 1);
	I_KEYBOARD_JOY	: in  std_logic_vector(4 downto 0);
	I_KEYBOARD_SOFT	: in  std_logic_vector(2 downto 0);
	I_KEY0		: in std_logic_vector(7 downto 0);
	I_KEY1		: in std_logic_vector(7 downto 0);
	I_KEY2		: in std_logic_vector(7 downto 0);
	I_KEY3		: in std_logic_vector(7 downto 0);
	I_KEY4		: in std_logic_vector(7 downto 0);
	I_KEY5		: in std_logic_vector(7 downto 0);
	I_KEY6		: in std_logic_vector(7 downto 0);
	-- Mouse
	I_MOUSE_X	: in  std_logic_vector(7 downto 0);
	I_MOUSE_Y	: in  std_logic_vector(7 downto 0);
	I_MOUSE_Z	: in  std_logic_vector(3 downto 0);
	I_MOUSE_BUTTONS	: in  std_logic_vector(2 downto 0);
	-- Z Controller
	I_ZC_DATA	: in  std_logic_vector(7 downto 0);
	O_ZC_RD		: out std_logic;
	O_ZC_WR		: out std_logic;
	-- SPI Controller
	I_SPI_DATA	: in  std_logic_vector(7 downto 0);
	O_SPI_WR	: out std_logic;
	I_SPI_BUSY	: in  std_logic;
	-- I2C Controller
	I_I2C_DATA	: in  std_logic_vector(7 downto 0);
	O_I2C_WR	: out std_logic;
	-- DivMMC
	O_DIVMMC_SC	: out std_logic;
	O_DIVMMC_SCLK	: out std_logic;
	O_DIVMMC_MOSI	: out std_logic;
	I_DIVMMC_MISO	: in  std_logic;
	O_DIVMMC_SEL	: out std_logic;
	-- RTC
	O_RTC_WR	: out std_logic;
	O_RTC_ADDR	: out std_logic_vector(5 downto 0);
	I_RTC_DATA	: in std_logic_vector(7 downto 0);
	-- TurboSound
	O_SSG0_A	: out std_logic_vector(7 downto 0);
	O_SSG0_B	: out std_logic_vector(7 downto 0);
	O_SSG0_C	: out std_logic_vector(7 downto 0);
	O_SSG1_A	: out std_logic_vector(7 downto 0);
	O_SSG1_B	: out std_logic_vector(7 downto 0);
	O_SSG1_C	: out std_logic_vector(7 downto 0);
	-- SounDrive
	O_COVOX_A	: out std_logic_vector(7 downto 0);
	O_COVOX_B	: out std_logic_vector(7 downto 0);
	O_COVOX_C	: out std_logic_vector(7 downto 0);
	O_COVOX_D	: out std_logic_vector(7 downto 0);
	-- DMA Sound
	I_DMASOUND_DATA	: in  std_logic_vector(7 downto 0);
	I_DMASOUND_INT	: in  std_logic );

end zx;

architecture rtl of zx is

-- CPU
signal cpu_reset_n	: std_logic;
signal cpu_a_bus	: std_logic_vector(15 downto 0);
signal cpu_do_bus	: std_logic_vector(7 downto 0);
signal cpu_di_bus	: std_logic_vector(7 downto 0);
signal cpu_mreq_n	: std_logic;
signal cpu_iorq_n	: std_logic;
signal cpu_wr_n		: std_logic;
signal cpu_rd_n		: std_logic;
signal cpu_rfsh_n	: std_logic;
signal cpu_int_n	: std_logic;
signal cpu_inta		: std_logic;
signal cpu_m1_n		: std_logic;
signal cpu_nmi_n	: std_logic;
-- Memory
signal ram_a_bus	: std_logic_vector(11 downto 0);
-- Port
signal port_xxfe_reg	: std_logic_vector(7 downto 0) := "00000000";
signal port_1ffd_reg	: std_logic_vector(7 downto 0);
signal port_7ffd_reg	: std_logic_vector(7 downto 0);
signal port_dffd_reg	: std_logic_vector(7 downto 0);
signal port_0000_reg	: std_logic_vector(7 downto 0) := "00011111";
signal port_0001_reg	: std_logic_vector(7 downto 0) := "00000000";
-- Keyboard
signal kb_f_bus		: std_logic_vector(12 downto 1);
signal kb_fn		: std_logic_vector(12 downto 1);
signal key		: std_logic_vector(12 downto 1) := "000000000000";
-- Video
signal vid_wr		: std_logic;
signal vid_scr		: std_logic;
-- MC146818A
signal mc146818_wr	: std_logic;
signal mc146818_a_bus	: std_logic_vector(5 downto 0);
signal port_bff7	: std_logic;
signal port_eff7_reg	: std_logic_vector(7 downto 0);
-- TurboSound
signal ssg_sel		: std_logic;
signal ssg_cn0_bus	: std_logic_vector(7 downto 0);
signal ssg_cn1_bus	: std_logic_vector(7 downto 0);
-- System
signal reset		: std_logic;
signal loader_act	: std_logic := Loader;
signal dos_act		: std_logic := '1';
signal selector		: std_logic_vector(4 downto 0);
signal mux		: std_logic_vector(3 downto 0);
-- divmmc
signal divmmc_do	: std_logic_vector(7 downto 0);
signal divmmc_amap	: std_logic;
signal divmmc_e3reg	: std_logic_vector(7 downto 0);	


begin

-- CPU
Z1: entity work.T80s
generic map (
	Mode		=> 0,	-- 0 => Z80, 1 => Fast Z80, 2 => 8080, 3 => GB
	T2Write		=> 1,	-- 0 => WR_n active in T3, 1 => WR_n active in T2
	IOWait		=> 1)	-- 0 => Single cycle I/O, 1 => Std I/O cycle
port map(
	RESET_n		=> cpu_reset_n,
	CLK_n		=> I_CPU_CLK and I_CPU_ENA, --I_CLK and I_CPU_ENA,
	WAIT_n		=> '1',
	INT_n		=> cpu_int_n,
	NMI_n		=> cpu_nmi_n,
	BUSRQ_n		=> '1',
	M1_n		=> cpu_m1_n,
	MREQ_n		=> cpu_mreq_n,
	IORQ_n		=> cpu_iorq_n,
	RD_n		=> cpu_rd_n,
	WR_n		=> cpu_wr_n,
	RFSH_n		=> cpu_rfsh_n,
	HALT_n		=> open,
	BUSAK_n		=> open,
	A		=> cpu_a_bus,
	DI		=> cpu_di_bus,
	DO		=> cpu_do_bus,
	SavePC      	=> open,
	SaveINT     	=> open,
	RestorePC   	=> (others => '1'),
	RestoreINT  	=> (others => '1'),
	RestorePC_n 	=> '1');

-- Video memory
Z2: entity work.altram1
port map (
	clock_a		=> I_CPU_CLK,
	clock_b		=> not I_VIDEO_CLK,
	address_a	=> vid_scr & cpu_a_bus(12 downto 0),
	address_b	=> port_7ffd_reg(3) & I_VIDEO_ADDR,
	data_a		=> cpu_do_bus,
	data_b		=> (others => '1'),
	q_a		=> open,
	q_b		=> O_VIDEO_DATA,
	wren_a		=> vid_wr,
	wren_b		=> '0');
	
-- TurboSound
Z3: entity work.turbosound
port map (
	I_CLK		=> I_CLK,
	I_ENA		=> I_ENA_1_75MHZ,
	I_ADDR		=> cpu_a_bus,
	I_DATA		=> cpu_do_bus,
	I_WR_N		=> cpu_wr_n,
	I_IORQ_N	=> cpu_iorq_n,
	I_M1_N		=> cpu_m1_n,
	I_RESET_N	=> not(I_RESET or reset),
	O_SEL		=> ssg_sel,
	-- ssg0
	I_SSG0_IOA	=> "11111111",
	O_SSG0_IOA	=> open,
	I_SSG0_IOB	=> "11111111",
	O_SSG0_IOB	=> open,
	O_SSG0_DA	=> ssg_cn0_bus,
	O_SSG0_AUDIO	=> open,
	O_SSG0_AUDIO_A	=> O_SSG0_A,
	O_SSG0_AUDIO_B	=> O_SSG0_B,
	O_SSG0_AUDIO_C	=> O_SSG0_C,
	-- ssg1
	I_SSG1_IOA	=> "11111111",
	O_SSG1_IOA	=> open,
	I_SSG1_IOB	=> "11111111",
	O_SSG1_IOB	=> open,
	O_SSG1_DA	=> ssg_cn1_bus,
	O_SSG1_AUDIO	=> open,
	O_SSG1_AUDIO_A	=> O_SSG1_A,
	O_SSG1_AUDIO_B	=> O_SSG1_B,
	O_SSG1_AUDIO_C	=> O_SSG1_C );	
	
-- Soundrive
U14: entity work.soundrive
port map (
	I_RESET		=> I_RESET or reset,
	I_CLK		=> I_CPU_CLK,
	I_CS		=> not kb_fn(7),
	I_WR_N		=> cpu_wr_n,
	I_ADDR		=> cpu_a_bus(7 downto 0),
	I_DATA		=> cpu_do_bus,
	I_IORQ_N	=> cpu_iorq_n,
	I_DOS		=> dos_act,
	O_COVOX_A	=> O_COVOX_A,
	O_COVOX_B	=> O_COVOX_B,
	O_COVOX_C	=> O_COVOX_C,
	O_COVOX_D	=> O_COVOX_D);

-- DivMMC
U18: entity work.divmmc
port map (
	I_CLK		=> I_CLK,
	I_ENA		=> kb_fn(6),
	I_RESET		=> I_RESET or reset,
	I_ADDR		=> cpu_a_bus,
	I_DATA		=> cpu_do_bus,
	O_DATA		=> divmmc_do,
	I_WR_N		=> cpu_wr_n,
	I_RD_N		=> cpu_rd_n,
	I_IORQ_N	=> cpu_iorq_n,
	I_MREQ_N	=> cpu_mreq_n,
	I_M1_N		=> cpu_m1_n,
	O_E3REG		=> divmmc_e3reg,
	O_AMAP		=> divmmc_amap,
	O_CS_N		=> O_DIVMMC_SC,
	O_SCLK		=> O_DIVMMC_SCLK,
	O_MOSI		=> O_DIVMMC_MOSI,
	I_MISO		=> I_DIVMMC_MISO);

-------------------------------------------------------------------------------
-- Регистры
process (I_RESET, I_CPU_CLK, cpu_a_bus, port_0000_reg, cpu_mreq_n, cpu_wr_n, cpu_do_bus, port_0001_reg)
begin
	if (I_RESET = '1') then
		port_0000_reg <= "00011111";		-- маска по AND порта #DFFD (4MB)
		port_0001_reg <= "00000" & not Loader & "00";	-- bit2 = (0:Loader ON, 1:Loader OFF); bit1 = (0:SRAM<->cpu, 1:SRAM<->GS); bit0 = (0:M25P16, 1:ENC424J600)
		loader_act <= Loader;
	elsif (I_CPU_CLK'event and I_CPU_CLK = '1') then
		if cpu_iorq_n = '0' and cpu_wr_n = '0' and cpu_a_bus(15 downto 0) = X"0000" then port_0000_reg <= cpu_do_bus; end if;
		if cpu_iorq_n = '0' and cpu_wr_n = '0' and cpu_a_bus(15 downto 0) = X"0001" then port_0001_reg <= cpu_do_bus; end if;
		if cpu_m1_n = '0' and cpu_mreq_n = '0' and cpu_a_bus = X"0000" and port_0001_reg(2) = '1' then loader_act <= '0'; end if;
	end if;
end process;

process (I_RESET, I_CPU_CLK, reset, cpu_a_bus, dos_act, port_1ffd_reg, port_7ffd_reg, port_dffd_reg, cpu_mreq_n, cpu_wr_n, cpu_do_bus)
begin
	if (I_RESET = '1' or reset = '1') then
		port_eff7_reg <= (others => '0');
		port_1ffd_reg <= (others => '0');
		port_7ffd_reg <= (others => '0');
		port_dffd_reg <= (others => '0');
		dos_act <= '1';
	elsif (I_CPU_CLK'event and I_CPU_CLK = '1') then
		if cpu_iorq_n =  '0' and cpu_wr_n =   '0' and cpu_a_bus(7 downto 0) = X"FE" then port_xxfe_reg <= cpu_do_bus; end if;
		if cpu_iorq_n =  '0' and cpu_wr_n =   '0' and cpu_a_bus = X"EFF7" then port_eff7_reg <= cpu_do_bus; end if;
		if cpu_iorq_n =  '0' and cpu_wr_n =   '0' and cpu_a_bus = X"1FFD" then port_1ffd_reg <= cpu_do_bus; end if;
		if cpu_iorq_n =  '0' and cpu_wr_n =   '0' and cpu_a_bus = X"7FFD" and port_7ffd_reg(5) = '0' then port_7ffd_reg <= cpu_do_bus; end if;
		if cpu_iorq_n =  '0' and cpu_wr_n =   '0' and cpu_a_bus = X"DFFD" and port_7ffd_reg(5) = '0' then port_dffd_reg <= cpu_do_bus; end if;
		if cpu_iorq_n =  '0' and cpu_wr_n =   '0' and cpu_a_bus = X"DFF7" and port_eff7_reg(7) = '1' then mc146818_a_bus <= cpu_do_bus(5 downto 0); end if;
		if cpu_m1_n =    '0' and cpu_mreq_n = '0' and cpu_a_bus(15 downto 8) = X"3D" and port_7ffd_reg(4) = '1' then dos_act <= '1';
		elsif cpu_m1_n = '0' and cpu_mreq_n = '0' and cpu_a_bus(15 downto 14) /= "00" then dos_act <= '0'; end if;
	end if;
end process;

------------------------------------------------------------------------------
-- Селектор
mux <= ((divmmc_amap or divmmc_e3reg(7)) and kb_fn(6)) & cpu_a_bus(15 downto 13);

-- SDRAM 32M:
-- 0000000-1FFFFFF

-- 2 2222 1111 1111 1100 0000 0000
-- 4 3210 9876 5432 1098 7654 3210

-- 0 00xx_xxxx xxxx_xxxx xxxx_xxxx	0000000-03FFFFF		CPU0 RAM	4MB
-- 0 0100_0xxx xxxx_xxxx xxxx_xxxx	0400000-047FFFF		CPU0 divMMC	512K

-- 0 0100_1000 00xx_xxxx xxxx_xxxx	0480000-0483FFF		GLUK		16K
-- 0 0100_1000 01xx_xxxx xxxx_xxxx	0484000-0487FFF		TR-DOS		16K
-- 0 0100_1000 10xx_xxxx xxxx_xxxx	0488000-048BFFF		ROM'86		16K
-- 0 0100_1000 11xx_xxxx xxxx_xxxx	048C000-048FFFF		ROM'82		16K
-- 0 0100_1001 000x_xxxx xxxx_xxxx	0490000-0491FFF		divMMC	 	 8K
-- 0 0xxx_xxxx xxxx_xxxx xxxx_xxxx	0492000-07FFFFF		FREE

-- 0 10xx_xxxx xxxx_xxxx xxxx_xxxx	0800000-0BFFFFF		CPU1 RAM	4MB
-- 0 1100_0xxx xxxx_xxxx xxxx_xxxx	0C00000-0C7FFFF		CPU1 divMMC	512K
-- 0 1xxx_xxxx xxxx_xxxx xxxx_xxxx	0C80000-0FFFFFF		FREE

-- 1 00xx_xxxx xxxx_xxxx xxxx_xxxx	1000000-13FFFFF		CPU2 RAM	4MB
-- 1 0100_0xxx xxxx_xxxx xxxx_xxxx	1400000-147FFFF		CPU2 divMMC	512K
-- 1 0xxx_xxxx xxxx_xxxx xxxx_xxxx	1480000-17FFFFF		FREE

-- 1 10xx_xxxx xxxx_xxxx xxxx_xxxx	1800000-1BFFFFF		CPU3 RAM	4MB
-- 1 1100_0xxx xxxx_xxxx xxxx_xxxx	1C00000-1C7FFFF		CPU3 divMMC	512K
-- 1 1xxx_xxxx xxxx_xxxx xxxx_xxxx	1C80000-1FFFFFF		FREE

process (mux, port_7ffd_reg, port_dffd_reg, port_0000_reg, ram_a_bus, cpu_a_bus, dos_act, port_1ffd_reg, divmmc_e3reg, kb_fn)
begin
	case mux is
--		when "1000" 	   => ram_a_bus <= "10000" & not(divmmc_e3reg(6)) & "00" & not(divmmc_e3reg(6)) & '0' & divmmc_e3reg(6) & divmmc_e3reg(6);			-- ESXDOS ROM 0000-1FFF
		when "0000" 	   => ram_a_bus <= "001001000" & ((not(dos_act) and not(port_1ffd_reg(1))) or kb_fn(6)) & (port_7ffd_reg(4) and not(port_1ffd_reg(1))) & '0';	-- Seg0 ROM 0000-1FFF
		when "0001" 	   => ram_a_bus <= "001001000" & ((not(dos_act) and not(port_1ffd_reg(1))) or kb_fn(6)) & (port_7ffd_reg(4) and not(port_1ffd_reg(1))) & '1';	-- Seg0 ROM 2000-3FFF
		when "1000" 	   => ram_a_bus <= "001001001000";														-- ESXDOS ROM 0000-1FFF
		
		when "1001" 	   => ram_a_bus <= CPU & "1000" & divmmc_e3reg(5 downto 0);											-- ESXDOS RAM 2000-3FFF
		when "0010"|"1010" => ram_a_bus <= CPU & "0000001010";														-- Seg1 RAM 4000-5FFF
		when "0011"|"1011" => ram_a_bus <= CPU & "0000001011";														-- Seg1 RAM 6000-7FFF
		when "0100"|"1100" => ram_a_bus <= CPU & "0000000100";														-- Seg2 RAM 8000-9FFF
		when "0101"|"1101" => ram_a_bus <= CPU & "0000000101";														-- Seg2 RAM A000-BFFF
		when "0110"|"1110" => ram_a_bus <= CPU & (port_dffd_reg(5 downto 0) and port_0000_reg(5 downto 0)) & port_7ffd_reg(2 downto 0) & '0';				-- Seg3 RAM C000-DFFF
		when "0111"|"1111" => ram_a_bus <= CPU & (port_dffd_reg(5 downto 0) and port_0000_reg(5 downto 0)) & port_7ffd_reg(2 downto 0) & '1';				-- Seg3 RAM E000-FFFF
		when others => null;
	end case;
end process;

-------------------------------------------------------------------------------
-- SDRAM
--O_RAM_WR <= '1' when cpu_mreq_n = '0' and cpu_wr_n = '0' and ((mux = "1001" and (divmmc_e3reg(1 downto 0) /= "11" and divmmc_e3reg(6) /= '1')) or mux(3 downto 2) = "11" or mux(3 downto 2) = "01" or mux(3 downto 1) = "101" or mux(3 downto 1) = "001") else '0';
O_RAM_WR <= '1' when cpu_mreq_n = '0' and cpu_wr_n = '0' and (mux = "1001" or mux(3 downto 2) = "11" or mux(3 downto 2) = "01" or mux(3 downto 1) = "101" or mux(3 downto 1) = "001") else '0';
O_RAM_RD <= not (cpu_mreq_n or cpu_rd_n);

-------------------------------------------------------------------------------
-- Port I/O
O_I2C_WR	<= '1' when (cpu_a_bus(7 downto 5) = "100" and cpu_a_bus(3 downto 0) = "1100" and cpu_wr_n = '0' and cpu_iorq_n = '0') else '0';	-- Port xx8C/xx9C[xxxxxxxx_100n1100]
mc146818_wr 	<= '1' when (port_bff7 = '1' and cpu_wr_n = '0') else '0';
O_RTC_WR	<= mc146818_wr;
O_RTC_ADDR	<= mc146818_a_bus;
port_bff7 	<= '1' when (cpu_iorq_n = '0' and cpu_a_bus = X"BFF7" and cpu_m1_n = '1' and port_eff7_reg(7) = '1') else '0';
O_SPI_WR 	<= '1' when (cpu_iorq_n = '0' and cpu_wr_n = '0' and cpu_a_bus(7 downto 1) = "0000001") else '0';
O_ZC_WR 	<= '1' when (cpu_iorq_n = '0' and cpu_wr_n = '0' and cpu_a_bus(7 downto 6) = "01" and cpu_a_bus(4 downto 0) = "10111") else '0';
O_ZC_RD 	<= '1' when (cpu_iorq_n = '0' and cpu_rd_n = '0' and cpu_a_bus(7 downto 6) = "01" and cpu_a_bus(4 downto 0) = "10111") else '0';
O_PORT_XXFE	<= port_xxfe_reg;
O_PORT_0001	<= port_0001_reg;

-------------------------------------------------------------------------------
-- Функциональные клавиши Fx

-- F1 = CPU0, F2 = CPU1, F3 = CPU2, F4 = CPU4, F5 = NMI, F6 = Z-Controller/DivMMC, F7 = SounDrive, F12 = CPU_RESET, Scroll = HARD_RESET, Pause = ZX_RESET
process (I_CLK, I_SEL, key, I_KEYBOARD_FN, kb_fn)
begin
	if (I_CLK'event and I_CLK = '1' and I_SEL = '1') then
		key <= I_KEYBOARD_FN;
		if (I_KEYBOARD_FN /= key) then
			kb_fn <= kb_fn xor key;
		end if;
	end if;
end process;

-------------------------------------------------------------------------------
-- Шина данных cpu
process (selector, I_ROM_DATA, I_RAM_DATA, I_SPI_DATA, I_SPI_BUSY, I_I2C_DATA, I_RTC_DATA, I_KEYBOARD_DATA, I_ZC_DATA, I_KEYBOARD_JOY, ssg_cn0_bus, ssg_cn1_bus, divmmc_do, port_7ffd_reg, port_dffd_reg, I_VIDEO_ATTR, I_DMASOUND_DATA, I_MOUSE_BUTTONS, I_MOUSE_X, I_MOUSE_Y, I_MOUSE_Z, I_KEY0, I_KEY1, I_KEY2, I_KEY3, I_KEY4, I_KEY5, I_KEY6)
begin
	case selector is
		when "00000" => cpu_di_bus <= I_ROM_DATA;
		when "00001" => cpu_di_bus <= I_RAM_DATA;
		when "00010" => cpu_di_bus <= I_SPI_DATA;
		when "00011" => cpu_di_bus <= I_SPI_BUSY & "1111111";
		when "00100" => cpu_di_bus <= I_I2C_DATA;
		when "00101" => cpu_di_bus <= I_RTC_DATA;
		when "00110" => cpu_di_bus <= "111" & I_KEYBOARD_DATA;
		when "00111" => cpu_di_bus <= I_ZC_DATA;
		when "01000" => cpu_di_bus <= "000" & I_KEYBOARD_JOY;
		when "01001" => cpu_di_bus <= ssg_cn0_bus;
		when "01010" => cpu_di_bus <= ssg_cn1_bus;
		when "01011" => cpu_di_bus <= divmmc_do;
		when "01100" => cpu_di_bus <= port_7ffd_reg;
		when "01101" => cpu_di_bus <= port_dffd_reg;
		when "01110" => cpu_di_bus <= I_VIDEO_ATTR;
		when "01111" => cpu_di_bus <= I_DMASOUND_DATA;
		when "10000" => cpu_di_bus <= I_MOUSE_Z & '1' & not I_MOUSE_BUTTONS;
		when "10001" => cpu_di_bus <= I_MOUSE_X;
		when "10010" => cpu_di_bus <= not I_MOUSE_Y;
		when "10011" => cpu_di_bus <= I_KEY0;
		when "10100" => cpu_di_bus <= I_KEY1;
		when "10101" => cpu_di_bus <= I_KEY2;
		when "10110" => cpu_di_bus <= I_KEY3;
		when "10111" => cpu_di_bus <= I_KEY4;
		when "11000" => cpu_di_bus <= I_KEY5;
		when "11001" => cpu_di_bus <= I_KEY6;
		when others  => cpu_di_bus <= (others => '1');
	end case;
end process;

selector <= 	"00000" when (cpu_mreq_n = '0' and cpu_rd_n = '0' and cpu_a_bus(15 downto 14) = "00" and loader_act = '1') else					-- ROM
		"00001" when (cpu_mreq_n = '0' and cpu_rd_n = '0') else 											-- RAM
		"00010" when (cpu_iorq_n = '0' and cpu_rd_n = '0' and cpu_a_bus(7 downto 0) = X"02" and I_SEL = '1') else					-- SPI
		"00011" when (cpu_iorq_n = '0' and cpu_rd_n = '0' and cpu_a_bus(7 downto 0) = X"03" and I_SEL = '1') else					-- SPI
		"00100" when (cpu_iorq_n = '0' and cpu_rd_n = '0' and cpu_a_bus(7 downto 5) = "100" and cpu_a_bus(3 downto 0) = "1100" and I_SEL = '1') else 	-- I2C
		"00101" when (cpu_iorq_n = '0' and cpu_rd_n = '0' and port_bff7 = '1' and port_eff7_reg(7) = '1') else 						-- MC146818A
		"00110" when (cpu_iorq_n = '0' and cpu_rd_n = '0' and cpu_a_bus(7 downto 0) = X"FE" and I_SEL = '1') else 					-- Клавиатура, порт xxFE
		"00111" when (cpu_iorq_n = '0' and cpu_rd_n = '0' and cpu_a_bus(7 downto 6) = "01" and cpu_a_bus(4 downto 0) = "10111" and I_SEL = '1') else 	-- Z-Controller
		"01000" when (cpu_iorq_n = '0' and cpu_rd_n = '0' and cpu_a_bus(7 downto 0) = X"1F" and dos_act = '0') else 					-- Joystick, порт xx1F
		"01001" when (cpu_iorq_n = '0' and cpu_rd_n = '0' and cpu_a_bus = X"FFFD" and ssg_sel = '0') else 						-- TurboSound
		"01010" when (cpu_iorq_n = '0' and cpu_rd_n = '0' and cpu_a_bus = X"FFFD" and ssg_sel = '1') else						-- TurboSound
		"01011" when (cpu_iorq_n = '0' and cpu_rd_n = '0' and cpu_a_bus(7 downto 0) = X"EB" and kb_fn(6) = '1') else					-- DivMMC
		"01100" when (cpu_iorq_n = '0' and cpu_rd_n = '0' and cpu_a_bus = X"7FFD") else									-- чтение порта 7FFD
		"01101" when (cpu_iorq_n = '0' and cpu_rd_n = '0' and cpu_a_bus = X"DFFD") else									-- чтение порта DFFD
		"01110" when (cpu_iorq_n = '0' and cpu_rd_n = '0' and cpu_a_bus(7 downto 0) = X"FF" and dos_act = '0' and I_VIDEO_BORDER = '1') else		-- порт атрибутов #FF
		"01111" when (cpu_iorq_n = '0' and cpu_rd_n = '0' and cpu_a_bus(7 downto 0) = X"50") else							-- DMA Sound
		"10000" when (cpu_iorq_n = '0' and cpu_rd_n = '0' and cpu_a_bus = X"FADF" and I_SEL = '1') else							-- Mouse Buttons
		"10001" when (cpu_iorq_n = '0' and cpu_rd_n = '0' and cpu_a_bus = X"FBDF" and I_SEL = '1') else							-- Mouse X
		"10010" when (cpu_iorq_n = '0' and cpu_rd_n = '0' and cpu_a_bus = X"FFDF" and I_SEL = '1') else							-- Mouse Y
		"10011" when (cpu_iorq_n = '0' and cpu_rd_n = '0' and cpu_a_bus = X"0007" and loader_act = '1' and I_SEL = '1') else				-- Key0
		"10100" when (cpu_iorq_n = '0' and cpu_rd_n = '0' and cpu_a_bus = X"0107" and loader_act = '1' and I_SEL = '1') else				-- Key1
		"10101" when (cpu_iorq_n = '0' and cpu_rd_n = '0' and cpu_a_bus = X"0207" and loader_act = '1' and I_SEL = '1') else				-- Key2
		"10110" when (cpu_iorq_n = '0' and cpu_rd_n = '0' and cpu_a_bus = X"0307" and loader_act = '1' and I_SEL = '1') else				-- Key3
		"10111" when (cpu_iorq_n = '0' and cpu_rd_n = '0' and cpu_a_bus = X"0407" and loader_act = '1' and I_SEL = '1') else				-- Key4
		"11000" when (cpu_iorq_n = '0' and cpu_rd_n = '0' and cpu_a_bus = X"0507" and loader_act = '1' and I_SEL = '1') else				-- Key5
		"11001" when (cpu_iorq_n = '0' and cpu_rd_n = '0' and cpu_a_bus = X"0607" and loader_act = '1' and I_SEL = '1') else				-- Key6		
		(others => '1');

cpu_reset_n 	<= '0' when (I_RESET = '1' or reset = '1' or (I_KEYBOARD_FN(12) = '1' and I_SEL = '1')) else '1';	-- CPU сброс
cpu_nmi_n 	<= '0' when (I_KEYBOARD_FN(5) = '1' and I_SEL = '1') else '1';		-- NMI
cpu_int_n	<= not (I_DMASOUND_INT or I_CPU_INT);
cpu_inta	<= not (cpu_iorq_n or cpu_m1_n);
reset 		<= '1' when (I_KEYBOARD_SOFT(2) = '1' and I_SEL = '1') else '0';	-- HARD_RESET

O_DIVMMC_SEL	<= kb_fn(6);	-- DivMMC/Z-Controller
O_CPU_DATA	<= cpu_do_bus;
O_CPU_ADDR 	<= cpu_a_bus;
O_RAM_ADDR 	<= ram_a_bus;

O_CPU_RFSH	<= not (cpu_rfsh_n or cpu_mreq_n);
O_CPU_RD_N	<= cpu_rd_n;
O_CPU_WR_N	<= cpu_wr_n;
O_CPU_IORQ_N	<= cpu_iorq_n;
O_CPU_INTA	<= cpu_inta;

-------------------------------------------------------------------------------
-- Video
vid_wr	<= '1' when cpu_mreq_n = '0' and cpu_wr_n = '0' and ((ram_a_bus = CPU & "0000001010") or (ram_a_bus = CPU & "0000001110")) else '0'; 
vid_scr	<= '1' when (ram_a_bus = CPU & "0000001110") else '0';


end rtl;