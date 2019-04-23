-------------------------------------------------------------------[25.06.2018]
-- TS-Conf (build 20180625)
-- FPGA SoftCore for ReVerSE-U16 Rev.C
-------------------------------------------------------------------------------
-- Engineer: MVV <mvvproject@gmail.com>
-- https://github.com/mvvproject/ReVerSE-U16/tree/master/u16_tsconf
--
-- http://tslabs.info/forum/viewtopic.php?f=31&t=401
-- http://zx-pk.ru/showthread.php?t=23528
--
-- Copyright (c) 2014-2018 MVV, TS-Labs, dsp, waybester, palsw
--
-- All rights reserved
--
-- Redistribution and use in source and synthezised forms, with or without
-- modification, are permitted provided that the following conditions are met:
--
-- * Redistributions of source code must retain the above copyright notice,
--   this list of conditions and the following disclaimer.
--
-- * Redistributions in synthesized form must reproduce the above copyright
--   notice, this list of conditions and the following disclaimer in the
--   documentation and/or other materials provided with the distribution.
--
-- * Neither the name of the author nor the names of other contributors may
--   be used to endorse or promote products derived from this software without
--   specific prior written agreement from the author.
--
-- * License is granted for non-commercial use only.  A fee may not be charged
--   for redistributions as source code or in synthesized/hardware form without 
--   specific prior written agreement from the author.
--
-- THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
-- AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
-- THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
-- PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE
-- LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
-- CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
-- SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
-- INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
-- CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
-- ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
-- POSSIBILITY OF SUCH DAMAGE.

library IEEE; 
use IEEE.std_logic_1164.all; 
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all; 


entity u16_tsconf is
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
	-- I2C 
	I2C_SCL			: inout std_logic;
	I2C_SDA			: inout std_logic;
	-- RTC (DS1338Z-33+)
--	RTC_SQW			: in std_logic;
	-- SPI FLASH (W25Q64)
	DATA0			: in std_logic;
	NCSO			: out std_logic;
	DCLK			: out std_logic;
	ASDO			: out std_logic;
	-- HDMI
	HDMI			: out std_logic_vector(7 downto 0);
--	HDMI_CEC		: inout std_logic;
--	HDMI_NDET		: in std_logic;
	-- SD/MMC Card
--	SD_NDET			: in std_logic;
	SD_SO			: in std_logic;
	SD_SI			: out std_logic;
	SD_CLK			: out std_logic;
	SD_NCS			: out std_logic;
	-- Ethernet (ENC424J600)
	ETH_SO			: in std_logic;
	ETH_NINT		: in std_logic;
	ETH_NCS			: out std_logic;
	-- USB Host (VNC2-32)
	USB_NRESET		: in std_logic;
	USB_TX			: in std_logic;
--	USB_RX			: out std_logic;
	USB_IO1			: in std_logic;
--	USB_IO3			: in std_logic;
--	USB_CLK			: out std_logic;
--	USB_NCS			: inout std_logic;
--	USB_SI			: inout std_logic;
--	USB_SO			: in std_logic;
	-- uBUS+
--	AP			: out std_logic;
--	AN			: out std_logic;
--	BP			: in std_logic;
--	BN			: in std_logic;
--	CP			: in std_logic;
--	CN			: in std_logic;
	DP			: out std_logic;
	DN			: out std_logic);
end u16_tsconf;

architecture rtl of u16_tsconf is
-- CLOCK
signal clk_84mhz		: std_logic;
signal clk_28mhz		: std_logic;
signal clk_psg			: std_logic;
signal clk_saa			: std_logic;
-- CPU0
signal cpu_a_bus		: std_logic_vector(15 downto 0);
signal cpu_do_bus		: std_logic_vector(7 downto 0);
signal cpu_di_bus		: std_logic_vector(7 downto 0);
signal cpu_mreq_n		: std_logic;
signal cpu_iorq_n		: std_logic;
signal cpu_wr_n			: std_logic;
signal cpu_rd_n			: std_logic;
signal cpu_int_n_TS		: std_logic;
signal cpu_m1_n			: std_logic;
signal cpu_rfsh_n		: std_logic;
signal turbo			: std_logic_vector(1 downto 0);
signal im2vect			: std_logic_vector(7 downto 0);
-- zsignal
signal cpu_stall		: std_logic; -- zmem -> zclock
signal cpu_req			: std_logic; -- zmem -> arbiter
signal cpu_wrbsel		: std_logic; -- zmem -> arbiter
signal cpu_next			: std_logic; -- arbiter -> zmem
signal cpu_current		: std_logic; -- arbiter -> zmem
signal cpu_strobe		: std_logic; -- arbiter -> zmem
signal cpu_latch		: std_logic; -- arbiter -> zmem
signal cpu_addr      		: std_logic_vector(23 downto 0);
signal cpu_addr_20   		: std_logic_vector(20 downto 0);
signal cpu_addr_ext  		: std_logic_vector(2 downto 0);
signal csvrom        		: std_logic;
signal curr_cpu      		: std_logic;
-- Memory
signal rom_do_bus		: std_logic_vector(7 downto 0);
signal cacheconf		: std_logic_vector(3 downto 0);
-- SDRAM
signal sdr_do_bus		: std_logic_vector(7 downto 0);
signal sdr2cpu_do_bus_16	: std_logic_vector(15 downto 0);
signal sdr_wr			: std_logic;
signal sdr_rd			: std_logic;
signal req           		: std_logic;
signal rnw           		: std_logic;
signal dram_addr		: std_logic_vector(23 downto 0);
signal dram_bsel		: std_logic_vector(1 downto 0);
signal dram_wrdata  		: std_logic_vector(15 downto 0);
signal dram_req			: std_logic;
signal dram_rnw			: std_logic;
signal dram_cpusel		: std_logic;
-- Port
signal port_xxfe_reg		: std_logic_vector(7 downto 0);
signal port_xx01_reg		: std_logic_vector(7 downto 0) := "00000000";
signal ena_1_75mhz		: std_logic;
signal ena_3m5hz		: std_logic;
--signal ena_7m0hz		: std_logic;
signal ena_cnt			: std_logic_vector(5 downto 0);
-- System
signal reset			: std_logic;
signal areset			: std_logic;
--signal key_reset		: std_logic;
signal locked			: std_logic;
signal loader			: std_logic := '1';
signal dos			: std_logic := '1';
--signal xtpage_0     	 	: std_logic_vector(7 downto 0);
-- PS/2 Keyboard
signal kb_do_bus		: std_logic_vector(4 downto 0);
signal kb_fn_bus			: std_logic_vector(4 downto 0);
signal kb_joy_bus		: std_logic_vector(4 downto 0);
signal key_scancode  		: std_logic_vector(7 downto 0);
signal kb_report		: std_logic_vector(55 downto 0);
-- UART
--signal uart_do_bus		: std_logic_vector(7 downto 0);
--signal uart_tx_empty		: std_logic;
--signal uart_tx_fifo_empty	: std_logic;
--signal uart_rx_avail		: std_logic;
--signal uart_rx_error		: std_logic;
-- MC146818A
signal mc146818a_wr		: std_logic;
--signal mc146818a_rd		: std_logic;
signal mc146818a_do_bus		: std_logic_vector(7 downto 0);
signal port_bff7		: std_logic;
signal port_eff7_reg		: std_logic_vector(7 downto 0);
signal ena_0_4375mhz		: std_logic;
signal gluclock_addr		: std_logic_vector(7 downto 0);
-- Soundrive
signal covox_a			: std_logic_vector(7 downto 0);
signal covox_b			: std_logic_vector(7 downto 0);
signal covox_c			: std_logic_vector(7 downto 0);
signal covox_d			: std_logic_vector(7 downto 0);
-- TurboSound
signal ssg_sel			: std_logic;
signal ssg0_do_bus		: std_logic_vector(7 downto 0);
signal ssg0_a			: std_logic_vector(7 downto 0);
signal ssg0_b			: std_logic_vector(7 downto 0);
signal ssg0_c			: std_logic_vector(7 downto 0);
signal ssg1_do_bus		: std_logic_vector(7 downto 0);
signal ssg1_a			: std_logic_vector(7 downto 0);
signal ssg1_b			: std_logic_vector(7 downto 0);
signal ssg1_c			: std_logic_vector(7 downto 0);
signal psg_do_bus		: std_logic_vector(7 downto 0);
signal psg_ch_l			: std_logic_vector(9 downto 0);
signal psg_ch_r			: std_logic_vector(9 downto 0);
-- AUDIO
signal sound_left		: std_logic_vector(15 downto 0);
signal sound_right		: std_logic_vector(15 downto 0);
signal beeper			: std_logic_vector(7 downto 0);
-- clock
signal f0 			: std_logic;
signal f1 			: std_logic;
signal h0 			: std_logic;
signal h1 			: std_logic;
signal c0 			: std_logic;
signal c1 			: std_logic;
signal c2 			: std_logic;
signal c3 			: std_logic;
signal ay_clk        	   	: std_logic;
signal zclk           		: std_logic;
signal zpos           		: std_logic;
signal zneg	        	: std_logic;
signal vdos			: std_logic;
signal pre_vdos			: std_logic;
signal vdos_off			: std_logic;
signal vdos_on			: std_logic;
signal dos_change		: std_logic;
-- out zsignals
signal m1			: std_logic;
signal rd			: std_logic;
signal wr			: std_logic;
signal iorq			: std_logic;
signal mreq			: std_logic;
signal rdwr			: std_logic;
signal iord			: std_logic;
signal iowr			: std_logic;
signal iorw			: std_logic;
signal memrd			: std_logic;
signal memwr			: std_logic;
signal opfetch			: std_logic;
signal intack			: std_logic;
-- strobre
signal iorq_s			: std_logic;
signal iord_s			: std_logic;
signal iowr_s			: std_logic;
signal iorw_s			: std_logic;
signal memwr_s			: std_logic;
signal opfetch_s		: std_logic;
-- zports OUT
signal dout_ports  		: std_logic_vector(7 downto 0);
signal ena_ports		: std_logic;
signal xt_page	  		: std_logic_vector(31 downto 0);
signal fmaddr			: std_logic_vector(4 downto 0);
signal sysconf			: std_logic_vector(7 downto 0);
signal memconf			: std_logic_vector(7 downto 0);
signal intmask			: std_logic_vector(7 downto 0);
signal dmaport_wr		: std_logic_vector(8 downto 0);
-- VIDEO_TS
signal go			: std_logic;
signal go_arbiter 		: std_logic;
-- z80
signal zmd			: std_logic_vector(15 downto 0);
signal zma			: std_logic_vector(7 downto 0);
signal cram_we			: std_logic;
signal sfile_we 		: std_logic;
signal zborder_wr		: std_logic; 
signal border_wr		: std_logic;
signal zvpage_wr		: std_logic;
signal vpage_wr			: std_logic;
signal vconf_wr			: std_logic;
signal gx_offsl_wr		: std_logic;
signal gx_offsh_wr		: std_logic;
signal gy_offsl_wr		: std_logic;
signal gy_offsh_wr		: std_logic;
signal t0x_offsl_wr		: std_logic;
signal t0x_offsh_wr		: std_logic;
signal t0y_offsl_wr		: std_logic;
signal t0y_offsh_wr		: std_logic;
signal t1x_offsl_wr		: std_logic;
signal t1x_offsh_wr		: std_logic;
signal t1y_offsl_wr		: std_logic;
signal t1y_offsh_wr		: std_logic;
signal tsconf_wr		: std_logic;
signal palsel_wr		: std_logic;
signal tmpage_wr		: std_logic;
signal t0gpage_wr		: std_logic;
signal t1gpage_wr		: std_logic;
signal sgpage_wr		: std_logic;
signal hint_beg_wr 		: std_logic;
signal vint_begl_wr		: std_logic;
signal vint_begh_wr		: std_logic;
-- ZX controls
signal res			: std_logic;
signal int_start_frm		: std_logic;
signal int_start_lin		: std_logic;
-- DRAM interface
signal video_addr		: std_logic_vector(20 downto 0);
signal video_bw			: std_logic_vector(4 downto 0);
signal video_go			: std_logic;
signal dram_rdata     		: std_logic_vector(15 downto 0);  -- raw, should be latched by c2 (video_next)
signal video_next		: std_logic;
signal video_pre_next		: std_logic; 
signal next_video		: std_logic;
signal video_strobe		: std_logic;
-- TS
signal ts_addr			: std_logic_vector(20 downto 0);
signal ts_req			: std_logic;
signal ts_z80_lp		: std_logic;
-- IN
signal ts_pre_next		: std_logic;
signal ts_next			: std_logic;
-- TM
signal tm_addr			: std_logic_vector(20 downto 0);
signal tm_req			: std_logic;
-- Video
signal tm_next			: std_logic;
signal vred_ts			: std_logic_vector(7 downto 0);
signal vgrn_ts			: std_logic_vector(7 downto 0);
signal vblu_ts			: std_logic_vector(7 downto 0);	
signal hsync_ts 		: std_logic;
signal vsync_ts 		: std_logic;
-- DMA
signal dma_rnw			: std_logic;
signal dma_req			: std_logic;
signal dma_z80_lp		: std_logic;
signal dma_wrdata		: std_logic_vector(15 downto 0);
signal dma_addr			: std_logic_vector(20 downto 0);	
signal dma_next			: std_logic;
signal dma_act			: std_logic;
signal dma_cram_we		: std_logic;
signal dma_sfile_we		: std_logic;
-- zmap
signal dma_data			: std_logic_vector(15 downto 0);
signal dma_wraddr		: std_logic_vector(7 downto 0);
signal int_start_dma		: std_logic;
-- SPI
signal spi_stb			: std_logic;
signal spi_start		: std_logic;
signal dma_spi_req		: std_logic;
signal dma_spi_din 		: std_logic_vector(7 downto 0);	
signal cpu_spi_req		: std_logic;
signal cpu_spi_din		: std_logic_vector(7 downto 0);
signal spi_dout			: std_logic_vector(7 downto 0);
-- Keys
signal key_f			: std_logic_vector(4 downto 0);
signal key			: std_logic_vector(4 downto 0) := "00000";
-- SPI
signal spi_wr			: std_logic;
signal spi_do_bus		: std_logic_vector(7 downto 0);
signal spi_busy			: std_logic;
signal spi_cs_n			: std_logic;
signal spi_miso			: std_logic;
-- HDMI
signal clk_hdmi			: std_logic;
signal csync_ts			: std_logic;
signal hdmi_d1_sig		: std_logic;
-- I2C
signal i2c_do_bus		: std_logic_vector(7 downto 0);
signal i2c_wr			: std_logic;
-- Mouse
signal ms0_x			: std_logic_vector(7 downto 0);
signal ms0_y			: std_logic_vector(7 downto 0);
signal ms0_z			: std_logic_vector(7 downto 0);
signal ms0_b			: std_logic_vector(7 downto 0);
signal ms1_x			: std_logic_vector(7 downto 0);
signal ms1_y			: std_logic_vector(7 downto 0);
signal ms1_z			: std_logic_vector(7 downto 0);
signal ms1_b			: std_logic_vector(7 downto 0);
-- SAA1099
signal saa_wr_n			: std_logic;
signal saa_out_l		: std_logic_vector(7 downto 0);
signal saa_out_r		: std_logic_vector(7 downto 0);

-------------------------------------------------------------------------------
-- COMPONENTS TS Lab
-------------------------------------------------------------------------------
component clock is
port (
	clk 			: in std_logic;
	ay_mod   		: in std_logic_vector(1 downto 0);
	f0       		: out std_logic; 
	f1      		: out std_logic; 
	h0     	 		: out std_logic; 
	h1     			: out std_logic;
	c0       		: out std_logic;
	c1       		: out std_logic; 
	c2       		: out std_logic; 
	c3       		: out std_logic;
	ay_clk   		: out std_logic);
end component;

component zclock is
port (
	clk 			: in std_logic;
	zclk_out 		: out std_logic;
	c1       		: in std_logic;
	c3       		: in std_logic; 
	c14Mhz         		: in std_logic; 
	iorq_s 			: in std_logic;
	external_port		: in std_logic;
	zpos 			: out std_logic;
	zneg 			: out std_logic;
	dos_stall_o		: out std_logic;
	cpu_stall		: in std_logic;
	ide_stall		: in std_logic;
	dos_on			: in std_logic;
	vdos_off  		: in std_logic;
	turbo			: in std_logic_vector(1 downto 0));	-- input [1:0] turbo  2'b00 -  3.5 MHz, 2'b01 -  7.0 MHz, 2'b1x - 14.0 MHz
end component;

component tv80s is
port (
	reset_n 		: in std_logic;
	clk			: in std_logic;
	wait_n 			: in std_logic;
	int_n			: in std_logic;
	nmi_n			: in std_logic;
	busrq_n			: in std_logic;
	m1_n			: out std_logic;
	mreq_n			: out std_logic;
	iorq_n			: out std_logic;
	rd_n			: out std_logic;
	wr_n			: out std_logic;
	rfsh_n			: out std_logic;
	halt_n			: out std_logic;
	busak_n			: out std_logic;
	A			: out std_logic_vector(15 downto 0);
	di			: in  std_logic_vector(7 downto 0);
	dout			: out std_logic_vector(7 downto 0));
end component; 

component zsignals is
port (
	clk			: in std_logic;
	zpos			: in std_logic;
	iorq_n			: in std_logic;
	mreq_n			: in std_logic;
	m1_n			: in std_logic;
	rfsh_n			: in std_logic;
	rd_n			: in std_logic;
	wr_n			: in std_logic;
	m1			: out std_logic;
	rfsh			: out std_logic;
	rd			: out std_logic;
	wr			: out std_logic;
	iorq			: out std_logic;
	mreq			: out std_logic;
	rdwr			: out std_logic;
	iord			: out std_logic;
	iowr			: out std_logic;
	iorw			: out std_logic;
	memrd			: out std_logic;
	memwr			: out std_logic;
	memrw			: out std_logic;
	opfetch			: out std_logic;
	intack			: out std_logic;
	iorq_s			: out std_logic;
	mreq_s			: out std_logic;
	iord_s			: out std_logic;
	iowr_s			: out std_logic;
	iorw_s			: out std_logic;
	memrd_s			: out std_logic;
	memwr_s			: out std_logic;
	memrw_s			: out std_logic;
	opfetch_s		: out std_logic);
end component;

component zports is
port (
	zclk    		: in std_logic;
	clk			: in std_logic;
	din			: in std_logic_vector(7 downto 0);
	dout			: out std_logic_vector(7 downto 0);
	dataout			: out std_logic;
	a			: in std_logic_vector(15 downto 0);
	rst			: in std_logic;
	loader			: in std_logic;
	opfetch			: in std_logic;
	rd			: in std_logic;
	wr			: in std_logic;
	rdwr			: in std_logic;
	iorq			: in std_logic;
	iorq_s			: in std_logic;
	iord			: in std_logic;
	iord_s			: in std_logic;
	iowr			: in std_logic;
	iowr_s			: in std_logic;
	iorw			: in std_logic;
	iorw_s			: in std_logic;
	porthit			: out std_logic; -- when internal port hit occurs, this is 1, else 0; used for iorq1_n iorq2_n on zxbus
	external_port		: out std_logic; -- asserts for AY and VG93 accesses
	zborder_wr  		: out std_logic;
	border_wr		: out std_logic;
	zvpage_wr		: out std_logic;
	vpage_wr		: out std_logic;
	vconf_wr		: out std_logic;	
	gx_offsl_wr		: out std_logic;	
	gx_offsh_wr		: out std_logic;	
	gy_offsl_wr		: out std_logic;	
	gy_offsh_wr		: out std_logic;	
	t0x_offsl_wr		: out std_logic;
	t0x_offsh_wr		: out std_logic;
	t0y_offsl_wr		: out std_logic;
	t0y_offsh_wr		: out std_logic;
	t1x_offsl_wr		: out std_logic;
	t1x_offsh_wr		: out std_logic;
	t1y_offsl_wr		: out std_logic;
	t1y_offsh_wr		: out std_logic;
	tsconf_wr		: out std_logic;	
	palsel_wr		: out std_logic;	
	tmpage_wr		: out std_logic;	
	t0gpage_wr		: out std_logic;	
	t1gpage_wr		: out std_logic;	
	sgpage_wr		: out std_logic;	
	hint_beg_wr		: out std_logic; 
	vint_begl_wr		: out std_logic;
	vint_begh_wr		: out std_logic;
	xt_page 		: out std_logic_vector(31 downto 0);
	fmaddr			: out std_logic_vector(4 downto 0);
	sysconf			: out std_logic_vector(7 downto 0);
	memconf			: out std_logic_vector(7 downto 0);
	cacheconf  		: out std_logic_vector(3 downto 0);
	fddvirt			: out std_logic_vector(3 downto 0);
	intmask			: out std_logic_vector(7 downto 0);
	dmaport_wr		: out std_logic_vector(8 downto 0);
	dma_act			: in std_logic;
	dos			: in std_logic;
	vdos			: in std_logic;
	vdos_on  		: out std_logic;
	vdos_off		: out std_logic;
	ay_bdir			: out std_logic;
	ay_bc1			: out std_logic;
	covox_wr		: out std_logic;
	beeper_wr		: out std_logic; 
	rstrom			: in std_logic_vector(1 downto 0);
	tape_read		: in std_logic;
	keys_in			: in std_logic_vector(4 downto 0);	-- keys (port FE)
	mus_in			: in std_logic_vector(7 downto 0); 	-- mouse (xxDF)
	kj_in			: in std_logic_vector(4 downto 0);
	vg_intrq		: in std_logic;
	vg_drq			: in std_logic;  			-- from vg93 module - drq + irq read
	vg_cs_n			: out std_logic;
	vg_wrFF			: out std_logic;
	drive_sel		: out std_logic_vector(1 downto 0); 	-- disk drive selection
	sdcs_n			: out std_logic;
	sd_start		: out std_logic;
	sd_datain		: out std_logic_vector(7 downto 0);
	sd_dataout		: in std_logic_vector(7 downto 0);
	gluclock_addr		: out std_logic_vector(7 downto 0);
	comport_addr		: out std_logic_vector(2 downto 0);
	wait_start_gluclock	: out std_logic; 			-- begin wait from some ports
	wait_start_comport	: out std_logic;  
	wait_write		: out std_logic_vector(7 downto 0);
	wait_read		: in std_logic_vector(7 downto 0) ;
	com_data_rx 		: in std_logic_vector(7 downto 0);
	com_status		: in std_logic_vector(7 downto 0);
	TST			: out std_logic_vector(7 downto 0);
	lock_conf   		: in std_logic);
end component;

component zmem is
port (
	clk			: in std_logic;
	c0			: in std_logic;
	c1 			: in std_logic;
	c2 			: in std_logic;
	c3			: in std_logic;
	zneg			: in std_logic;
	zpos			: in std_logic;
	rst			: in std_logic;
	za			: in std_logic_vector(15 downto 0);
	zd_out			: out std_logic_vector(7 downto 0); 	-- output to Z80 bus
	zd_ena			: out std_logic; 			-- output to Z80 bus enable
	opfetch			: in std_logic;
	opfetch_s		: in std_logic; 
	mreq			: in std_logic; 
	memrd 			: in std_logic; 
	memwr			: in std_logic; 
	memwr_s			: in std_logic; 
	turbo			: in std_logic_vector(1 downto 0);
	cache_en		: in std_logic_vector(3 downto 0);		
	memconf			: in std_logic_vector(3 downto 0);
	xt_page			: in std_logic_vector(31 downto 0);
	xtpage_0		: out std_logic_vector(7 downto 0);
	rompg			: out std_logic_vector(4 downto 0);	-- 32page = 512kB
	csrom			: out std_logic;
	romoe_n			: out std_logic;
	romwe_n			: out std_logic;
	csvrom			: out std_logic;
	dos			: out std_logic; 			-- DOS
	dos_on			: out std_logic;
	dos_off			: out std_logic;
	dos_change  		: out std_logic; 			-- state is shanging
	vdos			: out std_logic; 			-- Virtual DOS
	pre_vdos		: out std_logic; 			-- Virtual DOS
	vdos_on 		: in std_logic;
	vdos_off		: in std_logic;
	cpu_req			: out std_logic; 
	cpu_addr		: out std_logic_vector(20 downto 0);
	cpu_wrbsel		: out std_logic; 			-- for 16bit data
	cpu_rddata		: in std_logic_vector(15 downto 0); 	-- RD
	cpu_next		: in std_logic;
	cpu_strobe		: in std_logic;				-- from ARBITER
	cpu_latch		: in std_logic;				-- from ARBITER
	cpu_stall		: out std_logic; 			-- for Zclock if HI-> SRALL (ZCLK)
	loader			: in std_logic;	
	testkey			: in std_logic;
	intt			: in std_logic;
	tst			: out std_logic_vector(3 downto 0));
end component;

component arbiter is
port (
	clk			: in std_logic;
	c0			: in std_logic;
	c1 			: in std_logic;
	c2 			: in std_logic;
	c3			: in std_logic;
	dram_addr 		: out std_logic_vector(23 downto 0); 	-- address for dram access
	dram_req		: out std_logic; 			-- dram request
	dram_rnw		: out std_logic; 			-- Read-NotWrite
	dram_bsel		: out std_logic_vector(1 downto 0); 	-- byte select: bsel[1] for wrdata[15:8], bsel[0] for wrdata[7:0]
	dram_wrdata 		: out std_logic_vector(15 downto 0); 	-- data to be written
	dram_cpusel		: out std_logic;
	video_addr		: in std_logic_vector(23 downto 0); 	-- during access block, only when video_strobe==1
	go			: in std_logic; 			-- start video access blocks
	video_bw		: in std_logic_vector(4 downto 0);  	-- [4:3] -total cycles: 11 = 8 / 01 = 4 / 00 = 2
	video_pre_next		: out std_logic; 			-- (c1)
	video_next		: out std_logic; 			-- (c2) at this signal video_addr may be changed; it is one clock leading the video_strobe
	video_strobe		: out std_logic; 			-- (c3) one-cycle strobe meaning that video_data is available
	next_vid		: out std_logic; 			-- used for TM prefetch
	cpu_addr		: in std_logic_vector(23 downto 0);
	cpu_wrdata		: in std_logic_vector(7 downto 0);
	cpu_req			: in std_logic;
	cpu_rnw			: in std_logic;
	cpu_wrbsel		: in std_logic;
	cpu_next		: out std_logic; 			-- next cycle is allowed to be used by CPU
	cpu_strobe		: out std_logic; 			-- c2 strobe
	cpu_latch      		: out std_logic; 			-- c2-c3 strobe
	dma_addr		: in std_logic_vector(23 downto 0);
	dma_wrdata		: in std_logic_vector(15 downto 0);
	dma_req			: in std_logic;
	dma_z80_lp		: in std_logic;
	dma_rnw			: in std_logic;
	dma_next		: out std_logic;
	ts_addr			: in std_logic_vector(23 downto 0);
	ts_req			: in std_logic; 
	ts_z80_lp		: in std_logic; 
	ts_pre_next		: out std_logic;
	ts_next			: out std_logic;
	tm_addr			: in std_logic_vector(23 downto 0); 
	tm_req			: in std_logic; 
	tm_next			: out std_logic);
end component;

component video_top is
port (
	clk			: in std_logic;
	f0			: in std_logic;
	f1 			: in std_logic;
	h0 			: in std_logic;
	h1			: in std_logic;
	c0			: in std_logic;
	c1 			: in std_logic;
	c2 			: in std_logic;
	c3			: in std_logic;
	vred			: out std_logic_vector(7 downto 0); 
	vgrn			: out std_logic_vector(7 downto 0);
	vblu			: out std_logic_vector(7 downto 0);
	hsync 			: out std_logic;
	vsync 			: out std_logic;
	csync			: out std_logic;
	vga_blank 		: out std_logic;
	a 			: in std_logic_vector(15 downto 0);
	d			: in std_logic_vector(7 downto 0);		
	zmd			: in std_logic_vector(15 downto 0);
	zma			: in std_logic_vector(7 downto 0);
	cram_we			: in std_logic;
	sfile_we 		: in std_logic;
	zborder_wr		: in std_logic; 
	border_wr		: in std_logic;
	zvpage_wr		: in std_logic;
	vpage_wr		: in std_logic;
	vconf_wr		: in std_logic;
	gx_offsl_wr		: in std_logic;
	gx_offsh_wr		: in std_logic;
	gy_offsl_wr		: in std_logic;
	gy_offsh_wr		: in std_logic;
	t0x_offsl_wr		: in std_logic;
	t0x_offsh_wr		: in std_logic;
	t0y_offsl_wr		: in std_logic;
	t0y_offsh_wr		: in std_logic;
	t1x_offsl_wr		: in std_logic;
	t1x_offsh_wr		: in std_logic;
	t1y_offsl_wr		: in std_logic;
	t1y_offsh_wr		: in std_logic;
	tsconf_wr		: in std_logic;
	palsel_wr		: in std_logic;
	tmpage_wr		: in std_logic;
	t0gpage_wr		: in std_logic;
	t1gpage_wr		: in std_logic;
	sgpage_wr		: in std_logic;
	hint_beg_wr 		: in std_logic;
	vint_begl_wr		: in std_logic;
	vint_begh_wr		: in std_logic;
	res			: in std_logic;
	int_start		: out std_logic;
	line_start_s		: out std_logic;
	video_addr		: out std_logic_vector(20 downto 0);
	video_bw		: out std_logic_vector(4 downto 0);
	video_go		: out std_logic;
	dram_rdata		: in std_logic_vector(15 downto 0);  -- raw, should be latched by c2 (video_next)
	video_next		: in std_logic;
	video_pre_next		: in std_logic; 
	next_video		: in std_logic;
	video_strobe		: in std_logic;
	ts_addr			: out std_logic_vector(20 downto 0);
	ts_req			: out std_logic;
	ts_z80_lp		: out std_logic;
	ts_pre_next		: in std_logic;
	ts_next			: in std_logic;
	tm_addr			: out std_logic_vector(20 downto 0);
	tm_req			: out std_logic;
	tm_next			: in std_logic;
	cfg_60hz		: in std_logic;
	sync_pol		: in std_logic;
	vga_on			: in std_logic;
	tst            		: out std_logic_vector(3 downto 0));
end component;

component dma is
port (
	clk 			: in std_logic;
	c2			: in std_logic;
	reset			: in std_logic;
	dmaport_wr 		: in std_logic_vector(8 downto 0);
	dma_act 		: out std_logic;
	data 			: out std_logic_vector(15 downto 0);
	wraddr 			: out std_logic_vector(7 downto 0);
	int_start		: out std_logic;
	zdata 			: in std_logic_vector(7 downto 0);
	dram_addr		: out std_logic_vector(20 downto 0);
	dram_rddata		: in std_logic_vector(15 downto 0);
	dram_wrdata		: out std_logic_vector(15 downto 0);
	dram_req		: out std_logic;
	dma_z80_lp		: out std_logic;
	dram_rnw		: out std_logic;
	dram_next		: in std_logic;
	spi_rddata 		: in std_logic_vector(7 downto 0);
	spi_wrdata		: out std_logic_vector(7 downto 0);
	spi_req			: out std_logic;
	spi_stb			: in std_logic;
	spi_start		: in std_logic;
	ide_in 			: in std_logic_vector(15 downto 0);
	ide_out 		: out std_logic_vector(15 downto 0);
	ide_req			: out std_logic;
	ide_rnw			: out std_logic;
	ide_stb			: in std_logic;
	cram_we			: out std_logic;
	sfile_we		: out std_logic;
	TST			: out std_logic_vector(3 downto 0));
end component;

component zmaps is
port (
	clk			: in std_logic;
	memwr_s			: in std_logic;
	a			: in std_logic_vector(15 downto 0);
	d			: in std_logic_vector(7 downto 0);
	fmaddr			: in std_logic_vector(4 downto 0);
	zmd			: out std_logic_vector(15 downto 0);
	zma			: out std_logic_vector(7 downto 0);
	dma_data		: in std_logic_vector(15 downto 0);
	dma_wraddr 		: in std_logic_vector(7 downto 0);
	dma_cram_we		: in std_logic;
	dma_sfile_we		: in std_logic;
	cram_we			: out std_logic;
	sfile_we		: out std_logic);
end component;

component spi is
port (
	clk			: in std_logic; -- system clk
	sck      		: out std_logic; -- SPI bus pins...
	sdo			: out std_logic; 
	sdi			: in std_logic; 
	stb			: out std_logic; -- ready strobe, 1 clock length
	start			: out std_logic; -- start strobe, 1 clock length
	bsync			: out std_logic; -- for vs1001	
	dma_req			: in std_logic; 
	dma_din 		: in std_logic_vector(7 downto 0);
	cpu_req			: in std_logic; 
	cpu_din			: in std_logic_vector(7 downto 0);
	dout			: out std_logic_vector(7 downto 0);	
	speed			: in std_logic_vector(1 downto 0);   
	tst 			: out std_logic_vector(2 downto 0));
end component;

component zint is
port (
	clk 			: in std_logic; 
	zpos 			: in std_logic; 
	res 			: in std_logic; 
	int_start_frm 		: in std_logic;
	int_start_lin 		: in std_logic;
	int_start_dma 		: in std_logic;
	vdos			: in std_logic; 
	intack			: in std_logic; 
	intmask			: in std_logic_vector(7 downto 0);  
	im2vect			: out std_logic_vector(7 downto 0); 	
	int_n			: out std_logic);
end component;

component saa1099
port (
	clk_sys		: in std_logic;
	ce		: in std_logic;		--8 MHz
	rst_n		: in std_logic;
	cs_n		: in std_logic;
	a0		: in std_logic;		--0=data, 1=address
	wr_n		: in std_logic;
	din		: in std_logic_vector(7 downto 0);
	out_l		: out std_logic_vector(7 downto 0);
	out_r		: out std_logic_vector(7 downto 0));
end component;

component turbosound_fm
port (
	RESET		: in std_logic;
	CLK		: in std_logic;
	CE_CPU		: in std_logic;
	CE_YM		: in std_logic;
	BDIR		: in std_logic;
	BC		: in std_logic;
	DI		: in std_logic_vector(7 downto 0);
	DO		: out std_logic_vector(7 downto 0);
	CHANNEL_L	: out std_logic_vector(12 downto 0);
	CHANNEL_R	: out std_logic_vector(12 downto 0));
end component;
	

-------------------------------------------------------------------------------

begin

-- PLL
SE0: entity work.altpll0
port map (
	areset			=> areset,
	inclk0			=> CLK_50MHZ, -- 50Mhz
	locked			=> locked,
	c0			=> clk_84mhz,
	c1			=> clk_28mhz,
	c2			=> clk_hdmi,
	c3			=> clk_saa,
	c4			=> clk_psg);

TS01: clock
port map (
	clk			=> clk_28mhz,
	ay_mod 			=> "00",
	f0			=> f0,
	f1			=> f1,
	h0			=> h0,
	h1			=> h1,
	c0			=> c0,
	c1			=> c1,
	c2			=> c2,
	c3			=> c3,
	ay_clk			=> open);	

TS02: zclock
port map (
	clk			=> clk_28mhz,
	c1			=> c1,
	c3			=> c3,
	c14Mhz			=> c1,
	zclk_out		=> zclk,
	zpos			=> zpos,
	zneg			=> zneg,
	dos_stall_o 		=> open,
	iorq_s			=> iorq_s,
	dos_on  		=> dos_change,
	vdos_off 		=> vdos_off,
	cpu_stall		=> cpu_stall,
	ide_stall		=> '0',
	external_port 		=> '0',
	turbo			=> turbo);

-- Zilog Z80A CPU
TS03: tv80s
port map (
	reset_n			=> not reset,
	clk			=> zclk,
	wait_n			=> '1',
	int_n			=> cpu_int_n_TS,
	nmi_n			=> '1',
	busrq_n			=> '1',
	m1_n			=> cpu_m1_n,
	mreq_n			=> cpu_mreq_n,
	iorq_n			=> cpu_iorq_n,
   	rd_n			=> cpu_rd_n,
	wr_n			=> cpu_wr_n,
	rfsh_n			=> cpu_rfsh_n,
	halt_n			=> open,
	busak_n			=> open,
	A			=> cpu_a_bus,
	DI			=> cpu_di_bus,
	DOUT			=> cpu_do_bus);

TS04: zsignals
port map (
	clk			=> clk_28mhz,
	zpos			=> zpos,
	iorq_n			=> cpu_iorq_n,
	mreq_n			=> cpu_mreq_n,
	m1_n			=> cpu_m1_n,
	rfsh_n			=> cpu_rfsh_n,
	rd_n			=> cpu_rd_n,
	wr_n			=> cpu_wr_n,
	m1			=> open,
	rfsh			=> open,
	rd			=> rd,
	wr			=> wr,
	iorq			=> iorq,
	mreq			=> mreq,
	rdwr			=> rdwr,
	iord			=> iord,
	iowr			=> iowr,
	iorw			=> iorw,
	memrd			=> memrd,
	memwr			=> memwr,
	memrw			=> open,
	opfetch			=> opfetch,
	intack			=> intack,
	iorq_s			=> iorq_s,
	mreq_s			=> open,
	iord_s			=> iord_s,
	iowr_s			=> iowr_s,
	iorw_s			=> iorw_s,
	memrd_s			=> open,
	memwr_s			=> memwr_s,
	memrw_s			=> open,
	opfetch_s		=> opfetch_s);

TS05: zports
port map (
	zclk    		=> zclk,
	clk			=> clk_28mhz,
	din			=> cpu_do_bus,
	dout			=> dout_ports,
	dataout			=> ena_ports,
	a			=> cpu_a_bus,
	rst			=> reset,
	loader   		=> '0',			-- for load ROM, SPI should be enable 
	opfetch			=> opfetch, 		-- from zsignals
	rd			=> rd,
	wr			=> wr,
	rdwr			=> rdwr,
	iorq			=> iorq,
	iorq_s			=> iorq_s,
	iord			=> iord,
	iord_s			=> iord_s,
	iowr			=> iowr,
	iowr_s			=> iowr_s,
	iorw			=> iorw,
	iorw_s			=> iorw_s,
	porthit			=> open,		-- when internal port hit occurs, this is 1, else 0; used for iorq1_n iorq2_n on zxbus
	external_port		=> open, 		-- asserts for AY and VG93 accesses
	zborder_wr  		=> zborder_wr,  
	border_wr   		=> border_wr,   
	zvpage_wr		=> zvpage_wr,   
	vpage_wr		=> vpage_wr,    
	vconf_wr		=> vconf_wr,    
	gx_offsl_wr		=> gx_offsl_wr, 
	gx_offsh_wr		=> gx_offsh_wr, 
	gy_offsl_wr		=> gy_offsl_wr, 
	gy_offsh_wr		=> gy_offsh_wr,  
	t0x_offsl_wr		=> t0x_offsl_wr, 
	t0x_offsh_wr		=> t0x_offsh_wr, 
	t0y_offsl_wr		=> t0y_offsl_wr, 
	t0y_offsh_wr		=> t0y_offsh_wr, 
	t1x_offsl_wr		=> t1x_offsl_wr, 
	t1x_offsh_wr		=> t1x_offsh_wr, 
	t1y_offsl_wr		=> t1y_offsl_wr, 
	t1y_offsh_wr		=> t1y_offsh_wr, 
	tsconf_wr		=> tsconf_wr, 
	palsel_wr		=> palsel_wr, 
	tmpage_wr		=> tmpage_wr, 
	t0gpage_wr		=> t0gpage_wr, 
	t1gpage_wr		=> t1gpage_wr, 
	sgpage_wr		=> sgpage_wr, 
	hint_beg_wr		=> hint_beg_wr, 
	vint_begl_wr		=> vint_begl_wr, 
	vint_begh_wr		=> vint_begh_wr, 
	xt_page 		=> xt_page,
	fmaddr			=> fmaddr,
	sysconf			=> sysconf,
	memconf			=> memconf,
	cacheconf     		=> cacheconf,
	fddvirt			=> open,
	intmask			=> intmask,
	dmaport_wr		=> dmaport_wr, 		-- dmaport_wr
	dma_act			=> dma_act, 		-- from DMA (status of DMA) 
	dos			=> dos,
	vdos			=> vdos,
	vdos_on  		=> vdos_on,
	vdos_off		=> vdos_off,
	ay_bdir			=> open,
	ay_bc1			=> open,
	covox_wr		=> open,
	beeper_wr		=> open,
	rstrom			=> "11",
	tape_read		=> '1',
	keys_in			=> kb_do_bus,  		-- keys (port FE)
	mus_in			=> "11111111",		-- mouse (xxDF)
	kj_in			=> kb_joy_bus,
	vg_intrq		=> '0',
	vg_drq			=> '0',			-- from vg93 module - drq + irq read
	vg_cs_n			=> open,
	vg_wrFF			=> open,
	drive_sel		=> open,		-- disk drive selection
	sdcs_n			=> SD_NCS,	   	-- to SD card
	sd_start		=> cpu_spi_req, 	-- to SPI
	sd_datain		=> cpu_spi_din,	 	-- to SPI(7 downto 0);
	sd_dataout		=> spi_dout, 		-- from SPI(7 downto 0); 
	gluclock_addr		=> gluclock_addr,
	comport_addr		=> open,
	wait_start_gluclock	=> open, 		-- begin wait from some ports
	wait_start_comport	=> open,
	wait_write		=> open,
	wait_read		=> mc146818a_do_bus,
	com_data_rx		=> "11111111",		--uart_do_bus,
	com_status		=> "10010000",		--'1' & uart_tx_empty & uart_tx_fifo_empty & "1000" & uart_rx_avail,
	--com_status		=> '0' & uart_tx_empty & uart_tx_fifo_empty & "0000" & '1',
	TST  			=> open,
	lock_conf 		=> '1');

TS06: zmem
port map (
	clk			=> clk_28mhz,
	c0			=> c0,
	c1 			=> c1,
	c2 			=> c2,
	c3			=> c3,
	zneg			=> zneg,
	zpos			=> zpos,
	rst			=> reset,     		-- PLL locked
	za			=> cpu_a_bus,		-- from CPU
	zd_out 			=> sdr_do_bus,		-- output to Z80 bus 8bit ==>
	zd_ena			=> open,      		-- output to Z80 bus enable
	opfetch			=> opfetch,   		-- from zsignals
	opfetch_s		=> opfetch_s, 		-- from zsignals
	mreq			=> mreq,      		-- from zsignals
	memrd 			=> memrd,     		-- from zsignals
	memwr			=> memwr,     		-- from zsignals
	memwr_s			=> memwr_s,   		-- from zsignals 
	turbo			=> turbo,
	cache_en		=> cacheconf,  		-- from zport
	memconf			=> memconf(3 downto 0),
	xt_page			=> xt_page,
	xtpage_0    		=> open,
	rompg			=> open, 		-- 32page = 512kB
	csrom			=> open,
	romoe_n			=> open,
	romwe_n			=> open,
	csvrom			=> csvrom,
	dos			=> dos,
	dos_on			=> open,
	dos_off			=> open,
	dos_change  		=> dos_change,
	vdos			=> vdos,
	pre_vdos	   	=> pre_vdos,
	vdos_on 		=> vdos_on,
	vdos_off		=> vdos_off,
	cpu_req			=> cpu_req,
	cpu_addr		=> cpu_addr_20,
	cpu_wrbsel		=> cpu_wrbsel,		-- for 16bit data
--	cpu_rddata		=> dram_rdata, 		-- RD from SDRAM (cpu_strobe=HI and clk)
	cpu_rddata		=> sdr2cpu_do_bus_16,
	cpu_next		=> cpu_next,
	cpu_strobe		=> cpu_strobe,		-- from ARBITER ACTIVE=HI 	
	cpu_latch		=> cpu_latch,
	cpu_stall		=> cpu_stall, 		-- for Zclock if HI-> STALL (ZCLK)
	loader			=> loader, 		-- ROM for loader active
	testkey			=> '1',
	intt			=> '0',
	tst			=> open);

TS07: arbiter
port map (
	clk			=> clk_28mhz,
	c0			=> c0,
	c1 			=> c1,
	c2 			=> c2,
	c3			=> c3,
	dram_addr 		=> dram_addr,
	dram_req	 	=> dram_req,
	dram_rnw	 	=> dram_rnw,
	dram_bsel 		=> dram_bsel,
	dram_wrdata 		=> dram_wrdata,		-- data to be written
	dram_cpusel		=> dram_cpusel,
	video_addr		=> "000" & video_addr,	-- during access block, only when video_strobe==1
	go			=> go_arbiter,		-- start video access blocks
	video_bw		=> video_bw, 		-- ZX="11001", [4:3] -total cycles: 11 = 8 / 01 = 4 / 00 = 2
	video_pre_next		=> video_pre_next,
	video_next		=> video_next, 		-- (c2) at this signal video_addr may be changed; it is one clock leading the video_strobe
	video_strobe		=> video_strobe, 	-- (c3) one-cycle strobe meaning that video_data is available
	next_vid		=> next_video, 		-- used for TM prefetch
	cpu_addr		=> cpu_addr_ext & cpu_addr_20,
	cpu_wrdata		=> cpu_do_bus,
	cpu_req			=> cpu_req,
	cpu_rnw			=> rd,
	cpu_wrbsel		=> cpu_wrbsel,
	cpu_next		=> cpu_next, 		-- next cycle is allowed to be used by CPU
	cpu_strobe		=> cpu_strobe, 		-- c2 strobe
	cpu_latch   		=> cpu_latch, 		-- c2-c3 strobe

	dma_addr		=> "000" & dma_addr,
	dma_wrdata		=> dma_wrdata,
	dma_req			=> dma_req,
	dma_z80_lp		=> dma_z80_lp,
	dma_rnw			=> dma_rnw,
	dma_next		=> dma_next,
	ts_addr			=> "000" & ts_addr,
	ts_req			=> ts_req,
	ts_z80_lp		=> ts_z80_lp,
	ts_pre_next		=> ts_pre_next,
	ts_next			=> ts_next,
	tm_addr			=> "000" & tm_addr,
	tm_req			=> tm_req,
	tm_next			=> tm_next);

TS08: video_top
port map (
	clk			=> clk_28mhz,
	f0			=> f0,
	f1 			=> f1,
	h0 			=> h0,
	h1			=> h1,
	c0			=> c0,
	c1 			=> c1,
	c2 			=> c2,
	c3			=> c3,
	vred			=> vred_ts,
	vgrn			=> vgrn_ts,
	vblu			=> vblu_ts,
	hsync			=> hsync_ts,
	vsync 			=> vsync_ts,
	csync			=> open,
	vga_blank 		=> csync_ts, 
	a 			=> cpu_a_bus,
	d			=> cpu_do_bus,
	zmd			=> zmd,
	zma			=> zma,
	cram_we			=> cram_we,
	sfile_we 		=> sfile_we,
	zborder_wr 		=> zborder_wr,
	border_wr 		=> border_wr,
	zvpage_wr 		=> zvpage_wr,
	vpage_wr 		=> vpage_wr,
	vconf_wr 		=> vconf_wr,
	gx_offsl_wr 		=> gx_offsl_wr,
	gx_offsh_wr 		=> gx_offsh_wr,
	gy_offsl_wr 		=> gy_offsl_wr,
	gy_offsh_wr	 	=> gy_offsh_wr,
	t0x_offsl_wr 		=> t0x_offsl_wr,
	t0x_offsh_wr 		=> t0x_offsh_wr,
	t0y_offsl_wr 		=> t0y_offsl_wr,
	t0y_offsh_wr 		=> t0y_offsh_wr,
	t1x_offsl_wr 		=> t1x_offsl_wr,
	t1x_offsh_wr 		=> t1x_offsh_wr,
	t1y_offsl_wr 		=> t1y_offsl_wr,
	t1y_offsh_wr 		=> t1y_offsh_wr,
	tsconf_wr	 	=> tsconf_wr,
	palsel_wr	 	=> palsel_wr,
	tmpage_wr	 	=> tmpage_wr,
	t0gpage_wr	 	=> t0gpage_wr,
	t1gpage_wr	 	=> t1gpage_wr,
	sgpage_wr	 	=> sgpage_wr,
	hint_beg_wr  		=> hint_beg_wr,
	vint_begl_wr 		=> vint_begl_wr,
	vint_begh_wr 		=> vint_begh_wr,
	res			=> reset,
	int_start		=> int_start_frm,
	line_start_s		=> int_start_lin,
	video_addr		=> video_addr,
	video_bw		=> video_bw,
	video_go		=> go,
	dram_rdata     		=> dram_rdata,  -- raw, should be latched by c2 (video_next)
	video_next		=> video_next,
	video_pre_next		=> video_pre_next, 
	next_video		=> next_video,
	video_strobe		=> video_strobe,
	ts_addr			=> ts_addr,
	ts_req			=> ts_req,
	ts_z80_lp		=> ts_z80_lp,
	ts_pre_next		=> ts_pre_next,
	ts_next			=> ts_next,
	tm_addr			=> tm_addr,
	tm_req			=> tm_req,
	tm_next			=> tm_next, 
	cfg_60hz		=> not key_f(2),	-- 0-60Hz, 1-48Hz
	sync_pol		=> '1',			-- 0-positive, 1-negative
	vga_on			=> '1',         	-- 1-31kHZ
	tst            		=> open);

TS09: dma
port map (
	clk 			=> clk_28mhz, 
	c2			=> c2,
	reset			=> reset,
	dmaport_wr 		=> dmaport_wr,
	dma_act 		=> dma_act,
	data 			=> dma_data,
	wraddr 			=> dma_wraddr,
	int_start		=> int_start_dma,
	zdata 			=> cpu_do_bus,
	dram_addr		=> dma_addr,
	dram_rddata		=> dram_rdata,
	dram_wrdata		=> dma_wrdata,
	dram_req		=> dma_req,
	dma_z80_lp		=> dma_z80_lp,
	dram_rnw		=> dma_rnw,
	dram_next		=> dma_next,
	spi_rddata 		=> spi_dout,
	spi_wrdata		=> dma_spi_din,
	spi_req			=> dma_spi_req,
	spi_stb			=> spi_stb,
	spi_start		=> spi_start,
	ide_in 			=> "0000000000000000",
	ide_out 		=> open,
	ide_req			=> open,
	ide_rnw			=> open,
	ide_stb			=> '0',
	cram_we			=> dma_cram_we,
	sfile_we		=> dma_sfile_we, 
	TST 			=> open);

TS10: zmaps
port map (
	clk			=> clk_28mhz,
	memwr_s			=> memwr_s,
	a			=> cpu_a_bus,
	d			=> cpu_do_bus,
	fmaddr			=> fmaddr,
	zmd			=> zmd,
	zma			=> zma,
	dma_data		=> dma_data,
	dma_wraddr 		=> dma_wraddr,
	dma_cram_we		=> dma_cram_we,
	dma_sfile_we		=> dma_sfile_we,
	cram_we			=> cram_we,
	sfile_we		=> sfile_we);

TS11: spi
port map (
	clk			=> clk_28mhz,
	sck   			=> SD_CLK,
	sdo			=> SD_SI,
	sdi			=> SD_SO,
	stb			=> spi_stb,
	start			=> spi_start,
	bsync			=> open,
	dma_req			=> dma_spi_req,
	dma_din 		=> dma_spi_din,
	cpu_req			=> cpu_spi_req,
	cpu_din			=> cpu_spi_din,
	dout			=> spi_dout,
	speed			=> "00",
	tst 			=> open);

TS13: zint
port map (
	clk 			=> clk_28mhz,
	zpos 			=> zpos, 
	res 			=> reset,
	int_start_frm 		=> int_start_frm,	--< N1 VIDEO
	int_start_lin 		=> int_start_lin,	--< N2 VIDEO
	int_start_dma 		=> int_start_dma,	--< N3 DMA
	vdos			=> pre_vdos, 		-- vdos,--pre_vdos
	intack			=> intack, 		--< zsignals  === (intack ? im2vect : 8'hFF)));
	intmask			=> intmask, 		--< ZPORT (7 downto 0);
	im2vect			=> im2vect, 		--> CPU Din (2 downto 0); 	
	int_n			=> cpu_int_n_TS);
	 
-- ROM
SE1: entity work.rom
port map (
	address	 		=> cpu_a_bus(12 downto 0),
	clock	 		=> clk_28mhz,
	q	 		=> rom_do_bus);

-- SDRAM Controller
SE4: entity work.sdram
port map (
	CLK		 	=> clk_84mhz,
	clk_28MHz 		=> clk_28mhz,	
	c0			=> c0,
	c3			=> c3,
	curr_cpu 		=> dram_cpusel,	-- from arbiter for luch DO_cpu
	loader  		=> loader,    -- loader = 1: wr to ROM 
	bsel     		=> dram_bsel,
	A			=> dram_addr,
	DI			=> dram_wrdata,
	DO			=> dram_rdata,
	DO_cpu   		=> sdr2cpu_do_bus_16,
	REQ      		=> dram_req,
	RNW			=> dram_rnw,

	CK			=> DRAM_CLK,
	RAS_n			=> DRAM_NRAS,
	CAS_n			=> DRAM_NCAS,
	WE_n			=> DRAM_NWE,
	BA1			=> DRAM_BA(1),
	BA0			=> DRAM_BA(0),
	MA			=> DRAM_A,
	DQ			=> DRAM_DQ(15 downto 0),
	DQML     		=> DRAM_DQML,
	DQMH     		=> DRAM_DQMH,
	dram_stb 		=> open);
	
-- USB HID
SE5: entity work.deserializer
generic map (
	divisor			=> 434)		-- divisor = 50MHz / 115200 Baud = 434
port map(
	I_CLK			=> CLK_50MHZ,
	I_RESET			=> areset,
	I_RX			=> USB_TX,
	I_NEWFRAME		=> USB_IO1,
	I_ADDR			=> cpu_a_bus(15 downto 8),
	O_MOUSE0_X		=> ms0_x,
	O_MOUSE0_Y		=> ms0_y,
	O_MOUSE0_Z		=> ms0_z,
	O_MOUSE0_BUTTONS	=> ms0_b,
	O_MOUSE1_X		=> ms1_x,
	O_MOUSE1_Y		=> ms1_y,
	O_MOUSE1_Z		=> ms1_z,
	O_MOUSE1_BUTTONS	=> ms1_b,
	O_KEYBOARD_REPORT	=> kb_report,
	O_KEYBOARD_SCAN		=> kb_do_bus,
	O_KEYBOARD_SCANCODE	=> key_scancode,
	O_KEYBOARD_FKEYS	=> kb_fn_bus,
	O_KEYBOARD_JOYKEYS	=> kb_joy_bus);

SE9: entity work.mc146818a
port map (
	RESET			=> reset,
	CLK			=> clk_28mhz,
	ENA			=> ena_0_4375mhz,
	CS			=> '1',
	KEYSCANCODE 		=> key_scancode,
	WR			=> mc146818a_wr,
	A			=> gluclock_addr(7 downto 0),
	DI			=> cpu_do_bus,
	DO			=> mc146818a_do_bus);

-- Soundrive
SE10: entity work.soundrive
port map (
	I_RESET			=> reset,
	I_CLK			=> clk_28mhz,
	I_CS			=> '1',
	I_WR_N			=> cpu_wr_n,
	I_ADDR			=> cpu_a_bus(7 downto 0),
	I_DATA			=> cpu_do_bus,
	I_IORQ_N		=> cpu_iorq_n,
	I_DOS			=> dos,
	O_COVOX_A		=> covox_a,
	O_COVOX_B		=> covox_b,
	O_COVOX_C		=> covox_c,
	O_COVOX_D		=> covox_d);
	
-- TurboSound
SE12: entity work.turbosound
port map (
	-- System Bus
	I_RESET			=> reset,
	I_CLK			=> clk_28mhz,
	I_ADDR			=> cpu_a_bus,
	I_DATA			=> cpu_do_bus,
	I_IORQ_N		=> cpu_iorq_n,
	I_WR_N			=> cpu_wr_n,
	I_M1_N			=> cpu_m1_n,
	O_DATA			=> psg_do_bus,
	-- Device Bus
	I_ENA			=> ena_1_75mhz,
	I_MODE			=> '0',	-- 0=YM, 1=AY
	I_IOA0			=> "11111111",
	I_IOB0			=> "11111111",
	I_IOA1			=> "11111111",
	I_IOB1			=> "11111111",
	O_IOA0			=> open,
	O_IOB0			=> open,
	O_IOA1			=> open,
	O_IOB1			=> open,
	O_CH_L			=> psg_ch_l,
	O_CH_R			=> psg_ch_r);
	
-- SPI FLASH
U8: entity work.spi_flash
port map (
	-- System Bus
	I_RESET			=> reset,
	I_CLK			=> clk_28mhz,
	I_ADDR			=> cpu_a_bus(0),
	I_DATA			=> cpu_do_bus,
	I_WR			=> spi_wr,
	O_DATA			=> spi_do_bus,
	-- Device Bus
	I_SCK			=> f0,		-- Max 20MHz
	O_BUSY			=> spi_busy,
	O_CS_n			=> spi_cs_n,
	O_SCLK			=> DCLK,
	O_MOSI			=> ASDO,
	I_MISO			=> spi_miso);
	
-- Delta-Sigma
U19: entity work.dac
generic map (
	msbi_g			=> 15)
port map (
	I_CLK  			=> clk_84mhz,
	I_RESET			=> areset,
	I_DATA			=> sound_left,
	O_DAC			=> DP);

-- Delta-Sigma
U20: entity work.dac
generic map (
	msbi_g			=> 15)
port map (
	I_CLK  			=> clk_84mhz,
	I_RESET 		=> areset,
	I_DATA			=> sound_right,
	O_DAC   		=> DN);

-- HDMI
inst_dvid: entity work.hdmi
generic map (
	FREQ 			=> 28000000,
	FS 			=> 32000,
	N 			=> 4096,
	CTS 			=> 28000)
port map(
	I_CLK_VGA		=> clk_28mhz,
	I_CLK_TMDS		=> clk_hdmi,
	I_RED			=> vred_ts,
	I_GREEN			=> vgrn_ts,
	I_BLUE			=> vblu_ts,
	I_BLANK			=> csync_ts,
	I_HSYNC			=> hsync_ts,
	I_VSYNC			=> vsync_ts,
	I_AUDIO_PCM_L 		=> sound_left,
	I_AUDIO_PCM_R		=> sound_right,
	O_TMDS			=> HDMI);
	
-- I2C Controller
U12: entity work.i2c
port map (
	I_RESET			=> reset,
	I_CLK			=> clk_28mhz,
	I_ENA			=> ena_0_4375mhz,
	I_ADDR			=> cpu_a_bus(4),
	I_DATA			=> cpu_do_bus,
	O_DATA			=> i2c_do_bus,
	I_WR			=> i2c_wr,
	IO_I2C_SCL		=> I2C_SCL,
	IO_I2C_SDA		=> I2C_SDA);

U21: saa1099
port map(
	clk_sys			=> clk_saa,
	ce			=> '1',			--8 MHz
	rst_n			=> not reset,
	cs_n			=> '0',
	a0			=> cpu_a_bus(8),	--0=data, 1=address
	wr_n			=> saa_wr_n,
	din			=> cpu_do_bus,
	out_l			=> saa_out_l,
	out_r			=> saa_out_r);
	
-------------------------------------------------------------------------------
-- Global
-------------------------------------------------------------------------------
areset <= not USB_NRESET;
reset <= areset or not locked or (kb_fn_bus(0));	-- Reset
go_arbiter <= go;

process (clk_28mhz)
begin
	if clk_28mhz' event and clk_28mhz = '0' then
		ena_cnt <= ena_cnt + 1;
--		ena_7m0hz <= ena_cnt(1) and ena_cnt(0);
	end if;
end process;

ena_3m5hz <= ena_cnt(2) and ena_cnt(1) and ena_cnt(0);
ena_1_75mhz <= ena_cnt(3) and ena_cnt(2) and ena_cnt(1) and ena_cnt(0);
ena_0_4375mhz <= ena_cnt(5) and ena_cnt(4) and ena_cnt(3) and ena_cnt(2) and ena_cnt(1) and ena_cnt(0);

-- CPU interface
cpu_addr_ext <= "100" when (loader = '1' and cpu_a_bus(15) = '1') else csvrom & "00"; --- ROM csrom (only for BANK0)

cpu_di_bus <=	rom_do_bus when (loader = '1' and cpu_mreq_n = '0' and cpu_rd_n = '0' and cpu_a_bus(15 downto 13) = "000") else
		sdr_do_bus when (cpu_mreq_n = '0' and cpu_rd_n = '0') else 	-- SDRAM
		im2vect	when intack = '1' else
		spi_do_bus when (cpu_iorq_n = '0' and cpu_rd_n = '0' and cpu_a_bus( 7 downto 0) = X"02") else
		spi_busy & ETH_NINT & "111111" when (cpu_iorq_n = '0' and cpu_rd_n = '0' and cpu_a_bus( 7 downto 0) = X"03") else
		mc146818a_do_bus when (cpu_iorq_n = '0' and cpu_rd_n = '0' and port_bff7 = '1' and port_eff7_reg(7) = '1') else		-- MC146818A
		psg_do_bus when (cpu_iorq_n = '0' and cpu_rd_n = '0' and cpu_a_bus = X"FFFD") else	-- Turbosound
		key_scancode when (cpu_iorq_n = '0' and cpu_rd_n = '0' and cpu_a_bus = X"0001") else
		kb_report( 7 downto  0) when (cpu_iorq_n = '0' and cpu_rd_n = '0' and cpu_a_bus = X"0004") else
		kb_report(15 downto  8) when (cpu_iorq_n = '0' and cpu_rd_n = '0' and cpu_a_bus = X"0104") else
		kb_report(23 downto 16) when (cpu_iorq_n = '0' and cpu_rd_n = '0' and cpu_a_bus = X"0204") else
		kb_report(31 downto 24) when (cpu_iorq_n = '0' and cpu_rd_n = '0' and cpu_a_bus = X"0304") else
		kb_report(39 downto 32) when (cpu_iorq_n = '0' and cpu_rd_n = '0' and cpu_a_bus = X"0404") else
		kb_report(47 downto 40) when (cpu_iorq_n = '0' and cpu_rd_n = '0' and cpu_a_bus = X"0504") else
		kb_report(55 downto 48) when (cpu_iorq_n = '0' and cpu_rd_n = '0' and cpu_a_bus = X"0604") else
		i2c_do_bus when (cpu_iorq_n = '0' and cpu_rd_n = '0' and cpu_a_bus( 7 downto 5) = "100" and cpu_a_bus(3 downto 0) = "1100") else -- RTC
		ms0_z(3 downto 0) & '1' & not ms0_b(2) & not ms0_b(0) & not ms0_b(1) when (cpu_iorq_n = '0' and cpu_rd_n = '0' and cpu_a_bus = x"FADF")  else	-- Mouse0
		ms0_x when (cpu_iorq_n = '0' and cpu_rd_n = '0' and cpu_a_bus = x"FBDF")  else
		not ms0_y when (cpu_iorq_n = '0' and cpu_rd_n = '0' and cpu_a_bus = x"FFDF") else
		ms1_z(3 downto 0) & '1' & not ms1_b(2) & not ms1_b(0) & not ms1_b(1) when (cpu_iorq_n = '0' and cpu_rd_n = '0' and cpu_a_bus(15) = '0' and cpu_a_bus(10) = '0' and cpu_a_bus(8) = '0' and cpu_a_bus(7 downto 0) = X"DF") else	-- Mouse1
		ms1_x when (cpu_iorq_n = '0' and cpu_rd_n = '0' and cpu_a_bus(15) = '0' and cpu_a_bus(10) = '0' and cpu_a_bus(8) = '1' and cpu_a_bus(7 downto 0) = X"DF") else
		not ms1_y when (cpu_iorq_n = '0' and cpu_rd_n = '0' and cpu_a_bus(15) = '0' and cpu_a_bus(10) = '1' and cpu_a_bus(8) = '1' and cpu_a_bus(7 downto 0) = X"DF") else
		dout_ports when ena_ports = '1' else
		"11111111";

process (areset, clk_28mhz, cpu_a_bus, cpu_mreq_n, cpu_wr_n, cpu_do_bus, port_xx01_reg)
begin
	if areset = '1' then
		port_xx01_reg <= "00000000";	-- bit2 = (0:Loader ON, 1:Loader OFF); bit0 = (0:ETH, 1:FLASH)
		loader <= '1';
	elsif clk_28mhz'event and clk_28mhz = '1' then
		if cpu_iorq_n = '0' and cpu_wr_n = '0' and cpu_a_bus(7 downto 0) = "00000001" then port_xx01_reg <= cpu_do_bus; end if;
		if cpu_m1_n = '0' and cpu_mreq_n = '0' and cpu_a_bus = X"0000" and port_xx01_reg(2) = '1' then loader <= '0'; end if;
	end if;
end process;

process (reset, clk_28mhz)
begin
	if reset = '1' then
		port_xxfe_reg <= "00000000";
		port_eff7_reg <= "00000000";
	elsif clk_28mhz'event and clk_28mhz = '1' then
		if cpu_iorq_n = '0' and cpu_wr_n = '0' and cpu_a_bus(7 downto 0) = "11111110" then port_xxfe_reg <= cpu_do_bus; end if;
		if cpu_iorq_n = '0' and cpu_wr_n = '0' and cpu_a_bus = "1110111111110111" then port_eff7_reg <= cpu_do_bus; end if; --for RTC
	end if;	
end process;
				
-- TURBO
turbo <= "11" when loader = '1' else sysconf(1 downto 0); 

-- Fx Keys
process (clk_28mhz, key, kb_fn_bus, key_f)
begin
	if (clk_28mhz'event and clk_28mhz = '1') then
		key <= kb_fn_bus;
		if (kb_fn_bus /= key) then
			key_f <= key_f xor key;
		end if;
	end if;
end process;

-- RTC
mc146818a_wr <= '1' when (port_bff7 = '1' and cpu_wr_n = '0') else '0';
--mc146818a_rd <= '1' when (port_bff7 = '1' and cpu_rd_n = '0') else '0';
port_bff7 <= '1' when (cpu_iorq_n = '0' and cpu_a_bus = X"BFF7" and cpu_m1_n = '1' and port_eff7_reg(7) = '1') else '0';

-- SPI ENC424J600/M25P16
spi_wr <= '1' when (cpu_iorq_n = '0' and cpu_wr_n = '0' and cpu_a_bus(7 downto 1) = "0000001") else '0';
NCSO <= spi_cs_n when port_xx01_reg(0) = '0' else '1';
spi_miso <= DATA0 when port_xx01_reg(0) = '0' else ETH_SO;
ETH_NCS <= '1' when port_xx01_reg(0) = '0' else spi_cs_n;

-- I2C
i2c_wr <= '1' when (cpu_a_bus(7 downto 5) = "100" and cpu_a_bus(3 downto 0) = "1100" and cpu_wr_n = '0' and cpu_iorq_n = '0') else '0';	-- Port xx8C/xx9C[xxxxxxxx_100n1100]

-- Audio
beeper <= (others => port_xxfe_reg(4));
sound_left  <= ("0000" & beeper & "0000") + ("0000" & psg_ch_l & "00") + ("0000" & covox_a & "0000") + ("0000" & covox_b & "0000") + ("0000" & saa_out_l & "0000");
sound_right <= ("0000" & beeper & "0000") + ("0000" & psg_ch_r & "00") + ("0000" & covox_c & "0000") + ("0000" & covox_d & "0000") + ("0000" & saa_out_r & "0000");

-- SAA1099
saa_wr_n <= '0' when (cpu_iorq_n = '0' and cpu_wr_n = '0' and cpu_a_bus(7 downto 0) = "11111111") else '1';

end rtl;