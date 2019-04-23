
// Pentevo project (c) NedoPC 2011
// integrates sound features: tapeout, beeper and covox

// `include       "../include/tune.v"
// `define SDM		// uncommented - sigma-delta, commented - PWM
// `define SDM


module sound(
	input  wire	clk, f0, reset,
	input  wire [7:0] din,
	input  wire	beeper_wr,
	input  wire	covox_wr,
	input  wire	beeper_mux, // output either tape_out or beeper
	output wire	sound_bit	
);
   reg	sound_bit_SD;
	reg	sound_bit_PWM;
	reg [7:0] val;
//================BEGIN===========================================	
	assign sound_bit = sound_bit_SD;		
	// port writes
	always @(posedge clk)
	   if (reset)
			  val <= 8'h00;
		else if(covox_wr)
				val <= din;
		else if (beeper_wr)
				val <= (beeper_mux ? din[3] : din[4]) ? 8'hFF : 8'h00;
//`ifdef SDM
// SD modulator ================ sigma-delta SD ===================================
	reg [7:0] ctr_SD;	
	wire gte = val >= ctr_SD;
	always @(posedge clk)
	begin
		sound_bit_SD <= gte;
		ctr_SD <= {8{gte}} - val + ctr_SD;
	end
//`else
// PWM generator ============================ PWM =================================
	reg [8:0] ctr_PWM;	
	wire phase = ctr_PWM[8];
	wire [7:0] saw = ctr_PWM[7:0];	
	always @(posedge clk)		// 28 MHz strobes, Fpwm = 54.7 kHz (two semi-periods)
	begin
		sound_bit_PWM <= ((phase ? saw : ~saw) < val);
		ctr_PWM <= ctr_PWM + 9'b1;
	end		
//`endif ===========================================================================
		
endmodule

