//-----------------------------------------------------------------[24.06.2018]
// NES (build 20180624)
// FPGA SoftCore for ReVerSE-U16 Rev.C
//-----------------------------------------------------------------------------
// Engineer: MVV <mvvproject@gmail.com>
// https://github.com/mvvproject/ReVerSE-U16/tree/master/u16_nes
//
// Copyright (c) 2012-2013 Ludvig Strigeus
// This program is GPL Licensed. See COPYING for the full license.

module u16_nes(	
	// Clock (50MHz)
	input		CLOCK_50MHZ, // 50 MHz
	// SDRAM (32MB 16x16bit)
	inout  [15:0]	DRAM_DQ,	// SDRAM Data bus 16 Bits
	output [12:0]	DRAM_A,		// SDRAM Address bus 13 Bits
	output [1:0]	DRAM_BA,	// SDRAM Bank Address
	output		DRAM_CLK,	// SDRAM Clock
	output		DRAM_DQML,	// SDRAM Low-byte Data Mask
	output		DRAM_DQMH,	// SDRAM High-byte Data Mask
	output		DRAM_NWE,	// SDRAM Write Enable
	output		DRAM_NCAS,	// SDRAM Column Address Strobe
	output		DRAM_NRAS,	// SDRAM Row Address Strobe
	// I2C (HDMI/RTC)
//	inout		I2C_SCL,
//	inout		I2C_SDA,
	// RTC (DS1338Z-33+)
//	input		SQW,
	// SPI FLASH (W25Q64)
	input		DATA0,
	output		NCSO,
	output		DCLK,
	output		ASDO,
	// HDMI
//	inout		HDMI_CEC,
//	input		HDMI_NDET,
	output [7:0]	HDMI,
	// Memory Card (SD/MMC)
//	input		SD_NDET,
	output		SD_SI,
	input		SD_SO,
	output		SD_CLK,
	output		SD_NCS,
	// Ethernet (ENC424J600)
//	input		ETH_SO,
//	input		ETH_NINT,
//	output		ETH_NCS,
	// USB Host (VNC2-32)
	input		USB_NRESET,
	input		USB_IO1,
//	input		USB_IO3,
	input		USB_TX,
//	output		USB_RX,
//	output		USB_CLK,
//	output		USB_SI,
//	input		USB_SO,
//	output		USB_NCS,
	// uBUS+
//	inout		AP,
//	inout		AN,
//	input		BP,
//	input		BN,
//	input		CP,
//	input		CN,
	output		DP,		// Audio Left
	output		DN);		// Audio Right


	// VGA
	wire [7:0]	vga_red;
	wire [7:0]	vga_green;
	wire [7:0]	vga_blue;
	wire		vga_hs;
	wire		vga_vs;
	wire [9:0]	vga_hc;
	wire [9:0]	vga_h;
	wire [9:0]	vga_vc;
	wire		vga_blank;
	// OSD
	wire [7:0]	osd_red;
	wire [7:0]	osd_green;
	wire [7:0]	osd_blue;
	wire [7:0]	tmds;
	// buttons
	wire [7:0]	joy0;
	wire [7:0]	joy1;
	wire [1:0]	key;
	// spi
	wire		spi1_clk;
	wire		spi1_do;
	wire		spi1_di;
	wire		spi2_cs_n;
	wire		spi3_cs_n;
	wire		spi4_cs_n;

	wire		reset_nes = (init_reset || key[0] || !USB_NRESET || downloading);
	wire		run_nes = (nes_ce == 3) && !reset_nes;
	reg		init_reset;

	wire		clock_locked;
	wire		clk_sdram;
	wire		clk_dvi;
	wire		clk_vga;
	wire		clk_nes;
	wire		clk_bus;
	
	// Loader
	wire [7:0] 	loader_input;
	wire		loader_clk;
	reg [7:0]	loader_btn, loader_btn_2;
	wire [21:0]	loader_addr;
	wire [7:0]	loader_write_data;
	wire		loader_reset = !downloading; //loader_conf[0];
	wire		loader_write;
	wire [31:0]	mapper_flags;
	wire		loader_done;
	reg		loader_write_mem;
	reg [7:0]	loader_write_data_mem;
	reg [21:0]	loader_addr_mem;
	reg		loader_write_triggered;
	wire		downloading;

	wire [8:0]	cycle;
	wire [8:0]	scanline;
	wire [15:0]	sample;
	wire [5:0]	color;
	wire		joypad_strobe;
	wire [1:0]	joypad_clock;
	wire [21:0] 	memory_addr;
	wire		memory_read_cpu, memory_read_ppu;
	wire		memory_write;
	wire [7:0]	memory_din_cpu, memory_din_ppu;
	wire [7:0]	memory_dout;
	wire		joypad_bits, joypad_bits2;
	reg [1:0]	last_joypad_clock;
	reg [1:0]	nes_ce;
	wire		audio;


	clk U1(
		.inclk0		(CLOCK_50MHZ),	//640x480:      720x480:
		.c0		(clk_sdram),	// 84.000000MHz  85.858586MHz
		.c1		(clk_nes),	// 21.000000MHz  21.464646MHz
		.c2		(clk_bus),	// 42.000000MHz  42.929293MHz
		.c3		(clk_vga),	// 25.200000MHz  26.984127MHz
		.c4		(clk_dvi),	//126.000000MHz 134.920635MHz
		.locked		(clock_locked));

	vga U2(
		.I_CLK		(clk_nes),
		.I_CLK_VGA	(clk_vga),
		.I_COLOR	(color),
		.I_HCNT		(cycle),
		.I_VCNT		(scanline),
		.O_HSYNC	(vga_hs),
		.O_VSYNC	(vga_vs),
		.O_RED		(vga_red),
		.O_GREEN	(vga_green),
		.O_BLUE		(vga_blue),
		.O_HCNT		(vga_hc),
		.O_VCNT		(vga_vc),
		.O_H		(vga_h),
		.O_BLANK	(vga_blank));
		
	osd U3(
		.I_RESET	(!USB_NRESET),
		.I_CLK_VGA	(clk_vga),
		.I_CLK_CPU	(clk_nes),
		.I_CLK_BUS	(clk_bus),
		.I_JOY0		(joy0),
		.I_JOY1		(joy1),
		.I_KEY		(key[1]),
		.I_SPI_MISO	(DATA0),
		.I_SD_MISO	(SD_SO),
		.I_RED		(vga_red),
		.I_GREEN	(vga_green),
		.I_BLUE		(vga_blue),
		.I_HCNT		(vga_hc),
		.I_VCNT		(vga_vc),
		.I_H		(vga_h),
		.I_DOWNLOAD_OK	(loader_done),
		.O_RED		(osd_red),
		.O_GREEN	(osd_green),
		.O_BLUE		(osd_blue),
		.O_SPI_CLK	(DCLK),
		.O_SPI_MOSI	(ASDO),
		.O_SPI_CS_N	(NCSO),	// SPI FLASH
		.O_SD_CLK	(SD_CLK),
		.O_SD_MOSI	(SD_SI),
		.O_SD_CS_N	(SD_NCS),	// SD Card
		.O_DOWNLOAD_DO	(loader_input),
		.O_DOWNLOAD_WR	(loader_clk),
		.O_DOWNLOAD_ON	(downloading));

	hdmi #(25200000, 48000, 25200, 6144) U4 (
		.I_CLK_VGA	(clk_vga),
		.I_CLK_TMDS	(clk_dvi),
		.I_HSYNC	(vga_hs),
		.I_VSYNC	(vga_vs),
		.I_BLANK	(vga_blank),
		.I_RED		(osd_red),
		.I_GREEN	(osd_green),
		.I_BLUE		(osd_blue),
		.I_AUDIO_PCM_L	({sample[15:8],4'b0000}),
		.I_AUDIO_PCM_R	({sample[15:8],4'b0000}),
		.O_TMDS		(HDMI));

	hid U5(
		.I_CLK		(CLOCK_50MHZ),
		.I_RESET	(!USB_NRESET),
		.I_RX		(USB_TX),
		.I_NEWFRAME	(USB_IO1),
		.I_JOYPAD_CLK1	(joypad_clock[0]),
		.I_JOYPAD_CLK2	(joypad_clock[1]),
		.I_JOYPAD_LATCH	(joypad_strobe),
		.O_JOYPAD_DATA1	(joypad_bits),
		.O_JOYPAD_DATA2	(joypad_bits2),
		.O_JOY0		(joy0),
		.O_JOY1		(joy1),
		.O_KEY		(key));

	GameLoader U6(
		.clk		(clk_nes),
		.reset		(loader_reset),
		.indata		(loader_input),
		.indata_clk	(loader_clk),
		.mem_addr	(loader_addr),
		.mem_data	(loader_write_data),
		.mem_write	(loader_write),
		.mapper_flags	(mapper_flags),
		.done		(loader_done));
		
	NES U7(
		.clk		(clk_nes),
		.reset		(reset_nes),
		.ce		(run_nes),
		.mapper_flags	(mapper_flags),
		.sample		(sample),
		.color		(color),
		.joypad_strobe	(joypad_strobe),
		.joypad_clock	(joypad_clock),
		.joypad_data	({joypad_bits2, joypad_bits}),
		.audio_channels	(5'b11111),	// enable all channels
		.memory_addr	(memory_addr),
		.memory_read_cpu(memory_read_cpu),
		.memory_din_cpu	(memory_din_cpu),
		.memory_read_ppu(memory_read_ppu),
		.memory_din_ppu	(memory_din_ppu),
		.memory_write	(memory_write),
		.memory_dout	(memory_dout),
		.cycle		(cycle),
		.scanline	(scanline));

	sdram U8(
		// interface to the MT48LC16M16 chip
		.sd_data	(DRAM_DQ),
		.sd_addr	(DRAM_A),
		.sd_dqm		({DRAM_DQMH, DRAM_DQML}),
		.sd_cs		(),
		.sd_ba		(DRAM_BA),
		.sd_we		(DRAM_NWE),
		.sd_ras		(DRAM_NRAS),
		.sd_cas		(DRAM_NCAS),
		// system interface
		.clk		(clk_sdram),
		.clkref		(nes_ce[1]),
		.init		(!clock_locked),
		// cpu/chipset interface
		.addr		(downloading ? {3'b000, loader_addr_mem} : {3'b000, memory_addr}),
		.we		(memory_write || loader_write_mem),
		.din		(downloading ? loader_write_data_mem : memory_dout),
		.oeA		(memory_read_cpu),
		.doutA		(memory_din_cpu),
		.oeB		(memory_read_ppu),
		.doutB		(memory_din_ppu));
	
	sigma_delta_dac U9(
		.DACout		(audio),
		.DACin		(sample[15:8]),
		.CLK		(clk_sdram),
		.RESET		(reset_nes));

	// hold machine in reset until first download starts
	always @(posedge CLOCK_50MHZ) begin
	if(!clock_locked)
		init_reset <= 1'b1;
	else if(downloading)
		init_reset <= 1'b0;
	end

	// NES is clocked at every 4th cycle.
	always @(posedge clk_nes)
		nes_ce <= nes_ce + 2'b1;

	// loader_write -> clock when data available
	always @(posedge clk_nes) begin
		if(loader_write) begin
			loader_write_triggered	<= 1'b1;
			loader_addr_mem		<= loader_addr;
			loader_write_data_mem	<= loader_write_data;
		end
	
		if(nes_ce == 3) begin
			loader_write_mem <= loader_write_triggered;
			if(loader_write_triggered)
				loader_write_triggered <= 1'b0;
		end
	end

	
	// assignments	
	assign DRAM_CLK = clk_sdram;
	assign DN = audio;
	assign DP = audio;
	
	//Test
	//assign AN = USB_TX;
	
endmodule
