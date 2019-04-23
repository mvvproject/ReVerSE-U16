
// This module generates video for DAC
// MVV corrected 24bpp 24.08.2014

module video_out (

// clocks
	input wire clk, f0, c3,

// video controls
	input wire vga_on,
	input wire tv_blank,
	input wire vga_blank,
	input wire vga_line,
	input wire frame,
	input wire [1:0] plex_sel_in,

// mode controls
	input wire tv_hires,
	input wire vga_hires,
	input wire [3:0] palsel,

// Z80 pins
	input  wire [14:0] cram_data_in,
	input  wire [7:0]  cram_addr_in,
	input  wire cram_we,

// video data
	input wire  [7:0] vplex_in,	//<====== INPUT
	input wire  [7:0] vgaplex,	//<====== INPUT VGA

	output wire [7:0] vred,     
	output wire [7:0] vgrn,
	output wire [7:0] vblu,
	//---------------------
	output wire [3:0] tst
);

	assign tst[0] = clk;     ////phase[0];
	assign tst[1] = cram_we;  //phase[1];
	assign tst[2] = cram_addr_in[0]; //
	assign tst[3] = cram_data_in[0]; //pwm[3][{phase, 1'b0}];  //!pwm[igrn][{phase, 1'b1}];

   
	// TV/VGA mux
	reg [7:0] vplex;
	always @(posedge clk) if (c3)
		vplex <= vplex_in;

	wire [7:0] plex = vga_on ? vgaplex : vplex;
	wire plex_sel = vga_on ? plex_sel_in[0] : plex_sel_in[1];
	wire hires = vga_on ? vga_hires : tv_hires;
	wire [7:0] vdata = hires ? {palsel, plex_sel ? plex[3:0] : plex[7:4]} : plex;
	// CRAM =====================================================================
	wire [14:0] vpixel;

	video_cram video_cram(
		.clock		(clk),
		.wraddress	(cram_addr_in),
		.data		(cram_data_in),
		.wren		(cram_we),
		.rdaddress	(vdata), //-<INPUT
		.q		(vpixel)
	);
	//=============VPIXEL=================================
	wire [14:0] vpix = blank1 ? 15'b0 : vpixel; //OK for Spectrum mode // 5 bits for every color 
	wire blank = vga_on ? vga_blank : tv_blank;
	reg blank1;         // GOVNOKOD!!!!!!!!!!!!!!!!!!!!!!!

	always @(posedge clk)
	begin
		blank1 <= blank;
	end


//	assign vred = vpix[14:10];	// NO PWM
//	assign vgrn = vpix[ 9: 5];	// NO PWM
//	assign vblu = vpix[ 4: 0];	// NO PWM

// Video DAC v3	Added By MVV
    wire mode = 1'b1;

    lut lut_r (.mode(mode), .data(vpix[14:10]), .q(vred));
    lut lut_g (.mode(mode), .data(vpix[ 9: 5]), .q(vgrn));
    lut lut_b (.mode(mode), .data(vpix[ 4: 0]), .q(vblu));

endmodule
