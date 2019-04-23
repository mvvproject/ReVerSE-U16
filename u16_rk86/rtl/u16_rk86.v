//-----------------------------------------------------------------[25.06.2018]
// Radio-86RK (build 20180625)
// FPGA SoftCore for ReVerSE-U16 Rev.C
//-----------------------------------------------------------------------------
// Engineer: MVV <mvvproject@gmail.com>
// https://github.com/mvvproject/ReVerSE-U16/tree/master/u16_rk86
//
// ====================================================================
//                Radio-86RK FPGA REPLICA
//
//            Copyright (C) 2011 Dmitry Tselikov
//
// This core is distributed under modified BSD license. 
// For complete licensing information see LICENSE.TXT.
// -------------------------------------------------------------------- 
//
// An open implementation of Radio-86RK home computer
//
// Author: Dmitry Tselikov   http://bashkiria-2m.narod.ru/
// 
// Minor changes for adaptation to SDRAM: Ivan Gorodetsky, 2014
// 
// Port to Reverse-U16: Andy Karpov, 2016
//
// Design File: u16_rk86.v
//
// Top level design file.

module u16_rk86(
	// Clock (50MHz)
	input		CLK_50MHZ,
	// SDRAM (32MB 16x16bit)
	inout	[15:0] 	DRAM_DQ,	// SDRAM Data bus 16 Bits
	output	[12:0] 	DRAM_A,		// SDRAM Address bus 12 Bits
	output	[1:0]	DRAM_BA,	// SDRAM Bank Address 0
	output		DRAM_CLK,	// SDRAM Clock
	output		DRAM_DQML,	// SDRAM Low-byte Data Mask 
	output		DRAM_DQMH,	// SDRAM High-byte Data Mask
	output		DRAM_NWE,	// SDRAM Write Enable
	output		DRAM_NCAS,	// SDRAM Column Address Strobe
	output		DRAM_NRAS,	// SDRAM Row Address Strobe
	// I2C
//	inout		I2C_SCL,
//	inout		I2C_SDA,
	// RTC (DS1338Z-33+)
//	input		RTC_SQW,
	// SPI FLASH (W25Q64)
//	input 		DATA0,
//	output		NCSO,
//	output		DCLK,
//	output		ASDO,
	// HDMI
//	inout		HDMI_CEC,
//	input		HDMI_NDET,
	output [7:0]	HDMI,
	// SD/MMC Card
//	input		SD_NDET,
	input		SD_SO,		// SD Card Data 		(MISO)
	output		SD_SI,		// SD Card Command Signal 	(MOSI)
	output		SD_CLK,		// SD Card Clock 		(SCK)
	output		SD_NCS,		// SD Card Data 3 		(CSn)
	// Ethernet (ENC424J600)
//	input		ETH_SO,
//	input		ETH_NINT,
//	output		ETH_NCS,
	// USB HOST (VNC2-32)
	input		USB_NRESET,
	input		USB_TX,
//	output		USB_RX,
	input		USB_IO1,
//	input		USB_IO3,
//	output		USB_CLK,
//	inout		USB_NCS,
//	inout		USB_SI,
//	input		USB_SO,
	// uBUS+
//	output		AP,
//	output		AN,
//	input		BP,
//	input		BN,
//	input		CP,
//	input		CN,
	output		DP,
	output		DN
);

// CLOCK
wire clk50mhz;
wire clk250mhz;
wire clock_locked;

clk clock(
	.inclk0		(CLK_50MHZ),
	.c0		(clk250mhz),
	.c1		(clk50mhz),
	.locked		(clock_locked));

wire VGA_HS;
wire VGA_VS;
wire VGA_R;
wire VGA_G;
wire VGA_B;
wire BEEP;

assign DP = BEEP;
assign DN = BEEP;

// RESET
wire reset = !clock_locked || !USB_NRESET || k_reset;

// MEMORY
wire[7:0] rom_o;

assign DRAM_CLK = clk50mhz;		// SDRAM Clock
wire[15:0] dramout;

SDRAM_Controller ramd(
	.clk50mhz	(clk50mhz),	// Clock 50MHz
	.reset		(reset),	// System reset
	.DRAM_DQ	(DRAM_DQ),	// SDRAM Data bus 16 Bits
	.DRAM_ADDR	(DRAM_A),	// SDRAM Address bus 12 Bits
	.DRAM_LDQM	(DRAM_DQML),	// SDRAM Low-byte Data Mask 
	.DRAM_UDQM	(DRAM_DQMH),	// SDRAM High-byte Data Mask
	.DRAM_WE_N	(DRAM_NWE),	// SDRAM Write Enable
	.DRAM_CAS_N	(DRAM_NCAS),	// SDRAM Column Address Strobe
	.DRAM_RAS_N	(DRAM_NRAS),	// SDRAM Row Address Strobe
	.DRAM_CS_N	(),		// SDRAM Chip Select
	.DRAM_BA_0	(DRAM_BA[0]),	// SDRAM Bank Address 0
	.DRAM_BA_1	(DRAM_BA[1]),	// SDRAM Bank Address 1
	.iaddr		(vid_rd ? {3'b000,vid_addr[14:0]} : {3'b000,addrbus[14:0]}),
	.idata		(cpu_o),
	.rd		(vid_rd ? 1'b1 : cpu_rd&(!addrbus[15])),
	.we_n		(vid_rd? 1'b1 : cpu_wr_n|addrbus[15]),
	.odata		(dramout)
);
wire[7:0] mem_o = dramout[7:0];

biossd rom(
	.address	({addrbus[11]|startup,addrbus[10:0]}),
	.clock		(clk50mhz),
	.q		(rom_o));

// CPU
wire[15:0] addrbus;
wire[7:0] cpu_o;
wire cpu_sync;
wire cpu_rd;
wire cpu_wr_n;
wire cpu_int;
wire cpu_inta_n;
wire inte;
reg[7:0] cpu_i;
reg startup;

always @(*)
	casex (addrbus[15:13])
	3'b0xx: cpu_i = startup ? rom_o : mem_o;
	3'b100: cpu_i = ppa1_o;
	3'b101: cpu_i = sd_o;
	3'b110: cpu_i = crt_o;
	3'b111: cpu_i = rom_o;
	endcase

wire ppa1_we_n = addrbus[15:13]!=3'b100|cpu_wr_n;
wire ppa2_we_n = addrbus[15:13]!=3'b101|cpu_wr_n;
wire crt_we_n  = addrbus[15:13]!=3'b110|cpu_wr_n;
wire crt_rd_n  = addrbus[15:13]!=3'b110|~cpu_rd;
wire dma_we_n  = addrbus[15:13]!=3'b111|cpu_wr_n;

reg[4:0] cpu_cnt;
reg cpu_ce2;
reg[10:0] hldareg;
wire cpu_ce = cpu_ce2;

always @(posedge clk50mhz) begin
	if(reset) begin cpu_cnt<=0; cpu_ce2<=0; hldareg=11'd0; end
	else
   if((hldareg[10:9] == 2'b01) && ((cpu_rd == 1) || (cpu_wr_n == 0))) begin cpu_cnt <= 0; cpu_ce2 <= 1; end
	else
	if(cpu_cnt < 27) begin cpu_cnt <= cpu_cnt + 5'd1; cpu_ce2 <= 0; end
	else begin cpu_cnt <= 0; cpu_ce2 <= ~hlda; end
	hldareg <= {hldareg[9:0],hlda};
	startup <= reset|(startup&~addrbus[15]);
end

k580wm80a CPU(
	.clk		(clk50mhz),
	.ce		(cpu_ce),
	.reset		(reset),
	.idata		(cpu_i),
	.addr		(addrbus),
	.sync		(cpu_sync),
	.rd		(cpu_rd),
	.wr_n		(cpu_wr_n),
	.intr		(cpu_int),
	.inta_n		(cpu_inta_n),
	.odata		(cpu_o),
	.inte_o		(inte));

// VIDEO
wire[7:0] crt_o;
wire[3:0] vid_line;
wire[6:0] vid_char;
wire[15:0] vid_addr;
wire[3:0] dma_dack;
wire[7:0] dma_o;
wire[1:0] vid_lattr;
wire[1:0] vid_gattr;
wire vid_cce,vid_drq,vid_irq,hlda;
wire vid_lten,vid_vsp,vid_rvv,vid_hilight;
wire dma_owe_n,dma_ord_n,dma_oiowe_n,dma_oiord_n;
wire vid_hr, vid_vr;
wire vid_rd = ~dma_oiord_n;
wire[10:0] vga_counter_x;
wire[10:0] vga_counter_y;
wire vga_blank;

k580wt57 dma(
	.clk		(clk50mhz),
	.ce		(vid_cce),
	.reset		(reset),
	.iaddr		(addrbus[3:0]),
	.idata		(cpu_o),
	.drq		({1'b0,vid_drq,2'b00}),
	.iwe_n		(dma_we_n),
	.ird_n		(1'b1),
	.hlda		(hlda),
	.hrq		(hlda),
	.dack		(dma_dack),
	.odata		(dma_o),
	.oaddr		(vid_addr),
	.owe_n		(dma_owe_n),
	.ord_n		(dma_ord_n),
	.oiowe_n	(dma_oiowe_n),
	.oiord_n	(dma_oiord_n));

k580wg75 crt(
	.clk		(clk50mhz),
	.ce		(vid_cce),
	.iaddr		(addrbus[0]),
	.idata		(cpu_o),
	.iwe_n		(crt_we_n),
	.ird_n		(crt_rd_n),
	.vrtc		(vid_vr), 
	.hrtc		(vid_hr),
	.dack		(dma_dack[2]),
	.ichar		(mem_o),
	.drq		(vid_drq),
	.irq		(vid_irq),
	.odata		(crt_o),
	.line		(vid_line),
	.ochar		(vid_char),
	.lten		(vid_lten),
	.vsp		(vid_vsp),
	.rvv		(vid_rvv),
	.hilight	(vid_hilight),
	.lattr		(vid_lattr),
	.gattr		(vid_gattr));
	
rk_video vid(
	.clk		(clk50mhz), 
	.hr		(VGA_HS),
	.vr		(VGA_VS), 
	.r		(VGA_R),
	.g		(VGA_G),
	.b		(VGA_B),
	.hr_wg75	(vid_hr),
	.vr_wg75	(vid_vr),
	.cce		(vid_cce),
	.line		(vid_line),
	.ichar		(vid_char),
	.vsp		(vid_vsp),
	.lten		(vid_lten),
	.rvv		(vid_rvv),
	.counter_x	(vga_counter_x),
	.counter_y	(vga_counter_y),
	.blank		(vga_blank));

// KBD
wire[7:0] kbd_o;
wire[2:0] kbd_shift;
wire k_reset;

deserializer kbd(
	.I_CLK		(clk50mhz),
	.I_RESET	(!USB_NRESET),
	.I_RX		(USB_TX),
	.I_NEWFRAME	(USB_IO1),
	.I_ADDR		(ppa1_a),
	.O_DATA		(kbd_o),
	.O_SHIFT	(kbd_shift),
	.O_K_RESET	(k_reset));

// SYS PPA
wire[7:0] ppa1_o;
wire[7:0] ppa1_a;
wire[7:0] ppa1_b;
wire[7:0] ppa1_c;

k580ww55 ppa1(
	.clk		(clk50mhz),
	.reset		(reset),
	.addr		(addrbus[1:0]),
	.we_n		(ppa1_we_n),
	.idata		(cpu_o),
	.odata		(ppa1_o),
	.ipa		(ppa1_a),
	.opa		(ppa1_a),
	.ipb		(kbd_o),
	.opb		(ppa1_b),
	.ipc		({kbd_shift,tapein,ppa1_c[3:0]}),
	.opc		(ppa1_c));

// SOUND
reg tapein;

soundcodec sound(
	.clk		(clk50mhz),
	.pulse		(ppa1_c[0]^inte),
	.o_pwm		(BEEP));

// SD CARD
reg sdcs;
reg sdclk;
reg sdcmd;
reg[6:0] sddata;
wire[7:0] sd_o = {sddata, SD_SO};

assign SD_NCS = ~sdcs;
assign SD_SI = sdcmd;
assign SD_CLK = sdclk;

always @(posedge clk50mhz or posedge reset) begin
	if (reset) begin
		sdcs <= 1'b0;
		sdclk <= 1'b0;
		sdcmd <= 1'h1;
	end else begin
		if (addrbus[0]==1'b0 && ~ppa2_we_n) sdcs <= cpu_o[0];
		if (addrbus[0]==1'b1 && ~ppa2_we_n) begin
			if (sdclk) sddata <= {sddata[5:0],SD_SO};
			sdcmd <= cpu_o[7];
			sdclk <= 1'b0;
		end
		if (cpu_rd) sdclk <= 1'b1;
	end
end

// HDMI
hdmi #(50000000, 48000, 50000, 6144) U4 (
	.I_CLK_VGA	(clk50mhz),
	.I_CLK_TMDS	(clk250mhz),
	.I_HSYNC	(VGA_HS),
	.I_VSYNC	(VGA_VS),
	.I_BLANK	(vga_blank),
	.I_RED		({VGA_R,7'b0000000}),
	.I_GREEN	({VGA_G,7'b0000000}),
	.I_BLUE		({VGA_B,7'b0000000}),
	.I_AUDIO_PCM_L	({ppa1_c[0]^inte,15'b000000000000000}),
	.I_AUDIO_PCM_R	({ppa1_c[0]^inte,15'b000000000000000}),
	.O_TMDS		(HDMI));    

endmodule
