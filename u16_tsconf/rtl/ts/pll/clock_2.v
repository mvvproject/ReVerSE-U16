// This module receives 28 MHz as input clock
// and strobes strobes for all clocked parts

// clk	|?__??__??__??__?|	period = 28		duty = 50%		phase = 0
// cnt	|< 0>< 1>< 2>< 3>|
// f0	|????____????____|	period = 14		duty = 50%		phase = 0
// f1	|____????____????|	period = 14		duty = 50%		phase = 180
// h0	|????????________|	period = 7		duty = 50%		phase = 0
// h1	|________????????|	period = 7		duty = 50%		phase = 180
// c0	|????____________|	period = 7		duty = 25%		phase = 0
// c1	|____????________|	period = 7		duty = 25%		phase = 90
// c2	|________????____|	period = 7		duty = 25%		phase = 180
// c3	|____________????|	period = 7		duty = 25%		phase = 270

module clock_2 (

	input wire clk,
   output reg	c0
);

	always @(posedge clk)
	begin
		c0 <= clk;
	end

endmodule
