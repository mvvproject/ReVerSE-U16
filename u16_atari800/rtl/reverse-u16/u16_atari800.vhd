-------------------------------------------------------------------[24.06.2018]
-- Atari800 (build 20180624)
-- FPGA SoftCore for ReVerSE-U16 Rev.C
-------------------------------------------------------------------------------
-- Engineer: MVV <mvvproject@gmail.com>
-- https://github.com/mvvproject/ReVerSE-U16/tree/master/u16_atari800
--
-- Modified for ReVerSE-U16 By alsp'2015 <https://github.com/fintros/atari800-u16>
-- (c) 2013-14 Mark Watson
-- I am happy for anyone to use these for non-commercial use.
-- If my vhdl files are used commercially or sold please contact me for explicit permission at scrameta@gmail.com.
-- This applies for source and binary form and derived works.
-- http://www.scrameta.net/atarixlfpga_svn/trunk/

library IEEE; 
use IEEE.std_logic_1164.all; 
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all; 


entity u16_atari800 is
generic
(
	TV			: integer := 1	-- 1 = PAL, 0=NTSC
);
port (
	-- Clock (50MHz)
	CLK_50MHZ		: in std_logic;
	-- SDRAM (32MB 16x16bit)
	DRAM_DQ			: inout std_logic_vector(15 downto 0);
	DRAM_A			: out std_logic_vector(12 downto 0);
	DRAM_BA			: out std_logic_vector(1 downto 0);
	DRAM_CLK		: out std_logic;
	DRAM_DQML		: out std_logic;
	DRAM_DQMH		: out std_logic;
	DRAM_NWE		: out std_logic;
	DRAM_NCAS		: out std_logic;
	DRAM_NRAS		: out std_logic;
	-- I2C (HDMI/RTC)
--	I2C_SCL			: inout std_logic;
--	I2C_SDA			: inout std_logic;
	-- RTC (DS1338Z-33+)
--	SQW			: in std_logic;
	-- SPI FLASH (W25Q64FV)
	DATA0			: in std_logic;
	NCSO			: out std_logic;
	DCLK			: out std_logic;
	ASDO			: out std_logic;
	-- HDMI
--	HDMI_CEC		: inout std_logic;
--	HDMI_NDET		: in std_logic;
	HDMI			: out std_logic_vector(7 downto 0);
	-- Memory Card (SD/MMC)
--	SD_NDET			: in std_logic;
	SD_SO			: in std_logic;
	SD_SI			: out std_logic;
	SD_CLK			: out std_logic;
	SD_NCS			: out std_logic;
	-- Ethernet (ENC424J600)
--	ETH_SO			: in std_logic;
--	ETH_NINT		: in std_logic;
--	ETH_NCS			: out std_logic;
	-- USB Host (VNC2-32)
	USB_NRESET		: in std_logic;
	USB_IO1			: in std_logic;
--	USB_IO3			: in std_logic;
	USB_TX			: in std_logic;
--	USB_RX			: out std_logic;
--	USB_CLK			: out std_logic;
--	USB_SI			: out std_logic;
--	USB_SO			: in std_logic;
--	USB_NCS			: out std_logic;
	-- uBUS+
--	AP			: out std_logic;
--	AN			: out std_logic;
--	BP			: in std_logic;
--	BN			: in std_logic;
--	CP			: in std_logic;
--	CN			: in std_logic;
	DP			: out std_logic;
	DN			: out std_logic);
end u16_atari800;

architecture rtl of u16_atari800 is

	signal ATARI_CLK		: std_logic;
	signal CLK_SDRAM_IN		: std_logic;
	signal CLK_HDMI_IN		: std_logic;
	signal CLK_PIXEL_IN		: std_logic;
	signal PLL_LOCKED		: std_logic;
	signal reset			: std_logic;
	signal areset			: std_logic;
	signal cpu_reset		: std_logic;
	-- Video
	signal VIDEO_R			: std_logic_vector(7 downto 0);
	signal VIDEO_G			: std_logic_vector(7 downto 0);
	signal VIDEO_B			: std_logic_vector(7 downto 0);
	signal VIDEO_VS			: std_logic;
	signal VIDEO_HS			: std_logic;
	signal VIDEO_BLANK		: std_logic;
	signal VIDEO_COLOR		: std_logic_vector(7 downto 0);
	signal VIDEO_VS_RAW		: std_logic;
	signal VIDEO_HS_RAW		: std_logic;
	signal VIDEO_BLANK_RAW		: std_logic;
	signal PAL			: std_logic := '0';
	-- Audio
	signal AUDIO_L_PCM		: std_logic_vector(15 downto 0);
	signal AUDIO_R_PCM		: std_logic_vector(15 downto 0); 
	-- Gamepads
	signal JOY1_n			: std_logic_vector(4 downto 0);
	signal JOY2_n			: std_logic_vector(4 downto 0);
	-- Pokey Keyboard
	signal KEYBOARD_SCAN		: std_logic_vector(5 downto 0);
	signal KEYBOARD_RESPONSE	: std_logic_vector(1 downto 0);
	-- GTIA Consol Keys
	signal CONSOL_START		: std_logic;
	signal CONSOL_SELECT		: std_logic;
	signal CONSOL_OPTION		: std_logic;
	-- SDRAM (SRAM)
	signal SDRAM_REQUEST		: std_logic;
	signal SDRAM_REQUEST_COMPLETE	: std_logic;
	signal SDRAM_WRITE_ENABLE	: std_logic;
	signal SDRAM_READ_ENABLE	: std_logic;
	signal SDRAM_REFRESH		: std_logic;
	signal SDRAM_ADDR		: std_logic_vector(22 DOWNTO 0);
	signal SDRAM_DO			: std_logic_vector(31 DOWNTO 0);
	signal SDRAM_DI         	: std_logic_vector(31 DOWNTO 0);
	signal SDRAM_WIDTH_8BIT_ACCESS 	: std_logic;
	signal SDRAM_WIDTH_16BIT_ACCESS	: std_logic;
	signal SDRAM_WIDTH_32BIT_ACCESS	: std_logic;
	signal SDRAM_RESET_N 		: std_logic;
	-- DMA/Virtual Drive
	signal DMA_ADDR_FETCH		: std_logic_vector(23 downto 0);
	signal DMA_WRITE_DATA		: std_logic_vector(31 downto 0);
	signal DMA_FETCH		: std_logic;
	signal DMA_32BIT_WRITE_ENABLE 	: std_logic;
	signal DMA_16BIT_WRITE_ENABLE 	: std_logic;
	signal DMA_8BIT_WRITE_ENABLE 	: std_logic;
	signal DMA_READ_ENABLE    	: std_logic;
	signal DMA_MEMORY_READY    	: std_logic;
	signal DMA_MEMORY_DATA     	: std_logic_vector(31 downto 0);

	signal ZPU_ADDR_ROM        	: std_logic_vector(15 downto 0);
	signal ZPU_ROM_DATA        	: std_logic_vector(31 downto 0);
	signal ZPU_OUT1            	: std_logic_vector(31 downto 0);
	-- System Control from ZPU
	signal ZPU_POKEY_ENABLE    	: std_logic;
	signal ZPU_SIO_TXD        	: std_logic;
	signal ZPU_SIO_RXD        	: std_logic;
	signal ZPU_SIO_COMMAND    	: std_logic;
	
	signal KEYBOARD_RESET		: std_logic;
	signal FKEYS 			: std_logic_vector(11 downto 0);
	signal CTL_KEYS			: std_logic_vector(8 downto 0);		-- SCRLOCK(8) & LGUI (7) & LALT (6) & ESC (5) & RET (4) & Right (3) & Left (2) & Down (1) & Up (0)
	signal CTL_KEYS_prev		: std_logic_vector(8 downto 0);
	-- scandoubler
	signal half_scandouble_enable_reg 	: std_logic;
	signal half_scandouble_enable_next 	: std_logic;
	signal scanlines_reg 			: std_logic;
	signal scanlines_next 			: std_logic;
	
	alias  PAUSE_ATARI         		: std_logic                    is ZPU_OUT1(0);
	alias  RESET_ATARI         		: std_logic                    is ZPU_OUT1(1);
	alias  SPEED_6502          		: std_logic_vector(5 downto 0) is ZPU_OUT1(7 downto 2);
	alias  EMULATED_CARTRIDGE_SELECT 	: std_logic_vector(5 downto 0) is ZPU_OUT1(22 downto 17);
	alias  FREEZER_ENABLE      		: std_logic                    is ZPU_OUT1(25);
	alias  RAM_SELECT          		: std_logic_vector(2 downto 0) is ZPU_OUT1(10 downto 8);
	
	--signal debug1: std_logic;
	--signal debug2: std_logic;
	
begin 

-- choose mode of target atari
PAL <= '1' when TV=1 else '0';

areset		<= not USB_NRESET;			  				-- global reset
reset		<= areset or RESET_ATARI or not PLL_LOCKED or not SDRAM_RESET_N;	-- hot reset
cpu_reset	<= reset or KEYBOARD_RESET; 					   	-- cpu reset

-- do not use FLASH for a while
NCSO <= 'Z';
DCLK <= 'Z';
ASDO <= 'Z';

-- for Debug
--AP <= debug1;
--AN <= debug2;

pll_pal: if TV=1 generate
main_pll: entity work.pal_pll 
port map(
	inclk0 	=> CLK_50MHZ,
	c0	=> ATARI_CLK,		-- 56.64 (1.77 * 32)
	c1	=> CLK_SDRAM_IN,	-- 113.28
	c2	=> DRAM_CLK,		-- 113.28 (shifted)
	c3	=> CLK_HDMI_IN,		-- 141.6 (pixel clock * 5)
	c4	=> CLK_PIXEL_IN,	-- 28.32
	locked	=> PLL_LOCKED
);

-- HDMI
inst_dvid: entity work.hdmi
generic map (
-- Recommended params:
-- N=6144 CTS=28333 (28.333MHz pixel clock -> 48KHz audio clock)
-- N=4096 CTS=28333 (28.333MHz pixel clock -> 32KHz audio clock)
	FREQ 		=> 28333333,
	FS 		=> 32000,
	N 		=> 4096,
	CTS 		=> 28333)
port map(
	I_CLK_VGA	=> CLK_PIXEL_IN,
	I_CLK_TMDS	=> CLK_HDMI_IN,
	I_HSYNC		=> not VIDEO_HS,
	I_VSYNC		=> not VIDEO_VS,
	I_BLANK		=> VIDEO_BLANK,
	I_RED		=> VIDEO_R,
	I_GREEN		=> VIDEO_G,
	I_BLUE		=> VIDEO_B,
	I_AUDIO_PCM_L 	=> AUDIO_L_PCM,
	I_AUDIO_PCM_R	=> AUDIO_L_PCM,
	O_TMDS		=> HDMI);
end generate;

pll_ntsc: if TV=0 generate
main_pll: entity work.ntsc_pll 
port map(
	inclk0 	=> CLK_50MHZ,
	c0	=> ATARI_CLK,		-- 57.28 (1.79 * 32)
	c1	=> CLK_SDRAM_IN,	-- 114.56
	c2	=> DRAM_CLK,		-- 113.56 (shifted)
	c3	=> CLK_HDMI_IN,		-- 143.2 (pixel clock * 5)
	c4	=> CLK_PIXEL_IN,	-- 28.64
	locked	=> PLL_LOCKED
);

-- HDMI
inst_dvid: entity work.hdmi
generic map (
	FREQ 		=> 28625000,
	FS 		=> 32000,
	N 		=> 4096,
	CTS 		=> 28625)
port map(
	I_CLK_VGA	=> CLK_PIXEL_IN,
	I_CLK_TMDS	=> CLK_HDMI_IN,
	I_HSYNC		=> not VIDEO_HS,
	I_VSYNC		=> not VIDEO_VS,
	I_BLANK		=> VIDEO_BLANK,
	I_RED		=> VIDEO_R,
	I_GREEN		=> VIDEO_G,
	I_BLUE		=> VIDEO_B,
	I_AUDIO_PCM_L 	=> AUDIO_L_PCM,
	I_AUDIO_PCM_R	=> AUDIO_L_PCM,
	O_TMDS		=> HDMI);
end generate;

hid: entity work.vnc2hid
port map(
	CLK			=> CLK_50MHZ, 
	RESET			=> areset,
	USB_TX			=> USB_TX,
	KEYBOARD_SCAN		=> KEYBOARD_SCAN,
	KEYBOARD_RESPONSE	=> KEYBOARD_RESPONSE,
	CONSOL_START		=> CONSOL_START,
	CONSOL_SELECT		=> CONSOL_SELECT,
	CONSOL_OPTION		=> CONSOL_OPTION,
	RESET_BUTTON		=> KEYBOARD_RESET,
	FKEYS			=> FKEYS,
	JOY1_n			=> JOY1_n,
	JOY2_n			=> JOY2_n,
	CTL_KEYS		=> CTL_KEYS,
	CTL_KEYS_PREV		=> OPEN,
	NEW_FRAME		=> USB_IO1
--	DEBUG1			=> debug1,
--	DEBUG2			=> debug2
	);

-- SCANDOUBLER	
process(ATARI_CLK,reset)
begin
	if (reset = '1') then
		half_scandouble_enable_reg <= '0';
		scanlines_reg <= '0';
		CTL_KEYS_PREV <= (others=>'0');
	elsif (ATARI_CLK'event and ATARI_CLK='1') then
		half_scandouble_enable_reg <= half_scandouble_enable_next;
		scanlines_reg <= scanlines_reg xor (CTL_KEYS(6) and not(CTL_KEYS_PREV(6))); -- left alt
		--PAL <= PAL xor (CTL_KEYS(7) and not(CTL_KEYS_PREV(7))); -- left GUI
		CTL_KEYS_PREV <= CTL_KEYS;
	end if;
end process;

half_scandouble_enable_next <= not(half_scandouble_enable_reg);
--scanlines_next <= scanlines_reg xor (CTL_KEYS(6) and not(CTL_KEYS_PREV(6))); -- left alt
--scandouble_next <= scandouble_reg xor (CTL_KEYS(7) and not(CTL_KEYS_PREV(7))); -- left gui

scandoubler1: entity work.scandoubler_hdmi
GENERIC MAP
(
	video_bits=>8
)
PORT MAP
( 
	CLK		=> ATARI_CLK,
	RESET_N		=> not reset,
	colour_enable	=> half_scandouble_enable_reg,
	doubled_enable	=> '1', 
	scanlines_on	=> scanlines_reg,
	-- GTIA interface
	pal		=> PAL,
	colour_in	=> VIDEO_COLOR,
	vsync_in	=> VIDEO_VS_RAW,
	hsync_in	=> VIDEO_HS_RAW,
	blank_in	=> VIDEO_BLANK_RAW,
	-- TO TV...
	R		=> VIDEO_R,
	G		=> VIDEO_G,
	B		=> VIDEO_B,
	VSYNC		=> VIDEO_VS,
	HSYNC		=> VIDEO_HS,
	BLANK		=> VIDEO_BLANK
);

-- Delta-Sigma
U19: entity work.dac
port map (
	CLK   		=> CLK_SDRAM_IN,
	RESET 		=> areset,
	DAC_DATA	=> AUDIO_L_PCM,
	DAC_OUT   	=> DP);

-- Delta-Sigma
U20: entity work.dac
port map (
	CLK   		=> CLK_SDRAM_IN,
	RESET 		=> areset,
	DAC_DATA	=> AUDIO_R_PCM,
	DAC_OUT   	=> DN);
	
atari800_core : entity work.atari800core_simple_sdram
generic map(
	CYCLE_LENGTH	=> 32,
	INTERNAL_ROM	=> 1,	-- lets use internal rom to skip sd card rom files
	INTERNAL_RAM	=> 0,	-- 16384
	PALETTE		=> 0,	-- everything in VIDEO_B
	VIDEO_BITS	=> 8)
	
port map(
	CLK				=> ATARI_CLK,
	RESET_N				=> not cpu_reset,
	VIDEO_VS			=> VIDEO_VS_RAW,
	VIDEO_HS			=> VIDEO_HS_RAW,
	VIDEO_CS			=> OPEN,
	VIDEO_B				=> VIDEO_COLOR,
	VIDEO_G				=> OPEN,
	VIDEO_R				=> OPEN,
	VIDEO_BLANK			=> VIDEO_BLANK_RAW,
	VIDEO_BURST			=> OPEN,
	VIDEO_START_OF_FIELD		=> OPEN,
	VIDEO_ODD_LINE			=> OPEN,

	AUDIO_L				=> AUDIO_L_PCM,
	AUDIO_R				=> AUDIO_R_PCM,

	JOY1_n				=> JOY1_n, 
	JOY2_n				=> JOY2_n, 

	KEYBOARD_RESPONSE		=> KEYBOARD_RESPONSE,
	KEYBOARD_SCAN			=> KEYBOARD_SCAN,
	
	SIO_COMMAND			=> ZPU_SIO_COMMAND,
	SIO_RXD				=> ZPU_SIO_TXD,
	SIO_TXD				=> ZPU_SIO_RXD,
	
	CONSOL_OPTION			=> CONSOL_OPTION,
	CONSOL_SELECT			=> CONSOL_SELECT,
	CONSOL_START			=> CONSOL_START,
	
	SDRAM_REQUEST			=> SDRAM_REQUEST,
	SDRAM_REQUEST_COMPLETE		=> SDRAM_REQUEST_COMPLETE,
	SDRAM_READ_ENABLE		=> SDRAM_READ_ENABLE,
	SDRAM_WRITE_ENABLE		=> SDRAM_WRITE_ENABLE,
	SDRAM_ADDR			=> SDRAM_ADDR,
	SDRAM_DO			=> SDRAM_DO,
	SDRAM_DI			=> SDRAM_DI,
	SDRAM_32BIT_WRITE_ENABLE	=> SDRAM_WIDTH_32BIT_ACCESS,
	SDRAM_16BIT_WRITE_ENABLE	=> SDRAM_WIDTH_16BIT_ACCESS,
	SDRAM_8BIT_WRITE_ENABLE		=> SDRAM_WIDTH_8BIT_ACCESS,
	SDRAM_REFRESH			=> SDRAM_REFRESH,
	
	DMA_FETCH			=> DMA_FETCH,
	DMA_READ_ENABLE			=> DMA_READ_ENABLE,
	DMA_32BIT_WRITE_ENABLE		=> DMA_32BIT_WRITE_ENABLE,
	DMA_16BIT_WRITE_ENABLE		=> DMA_16BIT_WRITE_ENABLE,
	DMA_8BIT_WRITE_ENABLE		=> DMA_8BIT_WRITE_ENABLE,
	DMA_ADDR			=> DMA_ADDR_FETCH,
	DMA_WRITE_DATA			=> DMA_WRITE_DATA,
	MEMORY_READY_DMA		=> DMA_MEMORY_READY,
	DMA_MEMORY_DATA			=> DMA_MEMORY_DATA, 
	
	RAM_SELECT			=> RAM_SELECT,
	PAL				=> PAL,
	HALT				=> PAUSE_ATARI,
	THROTTLE_COUNT_6502		=> SPEED_6502,
	EMULATED_CARTRIDGE_SELECT	=> EMULATED_CARTRIDGE_SELECT,
	FREEZER_ENABLE			=> FREEZER_ENABLE,
	FREEZER_ACTIVATE		=> CTL_KEYS(8)); 

	
	
sdram_adaptor : entity work.sdram_statemachine
GENERIC MAP(
	ADDRESS_WIDTH		=> 24,
	AP_BIT			=> 10,
	COLUMN_WIDTH		=> 9,
	ROW_WIDTH		=> 13
)
PORT MAP(
	CLK_SYSTEM		=> ATARI_CLK,
	CLK_SDRAM		=> CLK_SDRAM_IN,
	RESET_N			=> not areset,
	READ_EN			=> SDRAM_READ_ENABLE,
	WRITE_EN		=> SDRAM_WRITE_ENABLE,
	REQUEST			=> SDRAM_REQUEST,
	BYTE_ACCESS		=> SDRAM_WIDTH_8BIT_ACCESS,
	WORD_ACCESS		=> SDRAM_WIDTH_16BIT_ACCESS,
	LONGWORD_ACCESS		=> SDRAM_WIDTH_32BIT_ACCESS,
	REFRESH			=> SDRAM_REFRESH,
	ADDRESS_IN		=> "00"&SDRAM_ADDR,
	DATA_IN			=> SDRAM_DI,
	SDRAM_DQ		=> DRAM_DQ,
	COMPLETE		=> SDRAM_REQUEST_COMPLETE,
	SDRAM_BA0		=> DRAM_BA(0),
	SDRAM_BA1		=> DRAM_BA(1),
	SDRAM_CKE		=> OPEN,
	SDRAM_CS_N		=> OPEN,
	SDRAM_RAS_N		=> DRAM_NRAS,
	SDRAM_CAS_N		=> DRAM_NCAS,
	SDRAM_WE_N		=> DRAM_NWE,
	SDRAM_ldqm		=> DRAM_DQML,
	SDRAM_udqm		=> DRAM_DQMH,
	DATA_OUT		=> SDRAM_DO,
	SDRAM_ADDR		=> DRAM_A(12 downto 0),
	reset_client_n		=> SDRAM_RESET_N
);
		 
--DRAM_A(12) <= '0';

zpu: entity work.zpucore
GENERIC MAP(
	platform		=> 1,
	spi_clock_div		=> 2 -- Recommended by zpu...
)
PORT MAP(
	-- standard...
	CLK			=> ATARI_CLK,
	RESET_N			=> not areset or SDRAM_RESET_N,
	-- dma bus master (with many waitstates...)
	ZPU_ADDR_FETCH		=> DMA_ADDR_FETCH,
	ZPU_DATA_OUT		=> DMA_WRITE_DATA,
	ZPU_FETCH		=> DMA_FETCH,
	ZPU_32BIT_WRITE_ENABLE	=> DMA_32BIT_WRITE_ENABLE,
	ZPU_16BIT_WRITE_ENABLE	=> DMA_16BIT_WRITE_ENABLE,
	ZPU_8BIT_WRITE_ENABLE	=> DMA_8BIT_WRITE_ENABLE,
	ZPU_READ_ENABLE		=> DMA_READ_ENABLE,
	ZPU_MEMORY_READY	=> DMA_MEMORY_READY,
	ZPU_MEMORY_DATA		=> DMA_MEMORY_DATA, 
	-- rom bus master
	-- data on next cycle after addr
	ZPU_ADDR_ROM		=> ZPU_ADDR_ROM,
	ZPU_ROM_DATA		=> ZPU_ROM_DATA,
	ZPU_ROM_WREN		=> open,
	-- spi master
	ZPU_SD_DAT0		=> SD_SO,
	ZPU_SD_CLK		=> SD_CLK,
	ZPU_SD_CMD		=> SD_SI,
	ZPU_SD_DAT3		=> SD_NCS,
	-- SIO
	-- Ditto for speaking to Atari, we have a built in Pokey
	ZPU_POKEY_ENABLE	=> ZPU_POKEY_ENABLE,
	ZPU_SIO_TXD		=> ZPU_SIO_TXD,
	ZPU_SIO_RXD		=> ZPU_SIO_RXD,
	ZPU_SIO_COMMAND		=> ZPU_SIO_COMMAND,
	-- external control
	-- switches etc. sector DMA blah blah.
	ZPU_IN1			=> X"000"& "00" & CTL_KEYS(5 downto 0) & FKEYS,
	ZPU_IN2			=> X"00000000",
	ZPU_IN3			=> X"00000000",
	ZPU_IN4			=> X"00000000",
	-- ouputs - e.g. Atari system control, halt, throttle, rom select
	ZPU_OUT1		=> ZPU_OUT1,
	ZPU_OUT2		=> OPEN,
	ZPU_OUT3		=> OPEN,
	ZPU_OUT4		=> OPEN
);

zpu_rom1: entity work.zpu_rom
port map(
        clock			=> ATARI_CLK,
        address			=> ZPU_ADDR_ROM(13 downto 2),
        q			=> ZPU_ROM_DATA
);

enable_179_clock_div_zpu_pokey : entity work.enable_divider
generic map (
	COUNT			=> 32	-- cycle_length
) 
port map(
	clk			=> ATARI_CLK,
	reset_n			=> not areset,
	enable_in		=> '1',
	enable_out		=> ZPU_POKEY_ENABLE
);

end rtl;

