module SDRAM_Controller(
	input			clk50mhz,				//  Clock 50MHz
	input			reset,					//  System reset
	inout	[15:0]	DRAM_DQ,				//	SDRAM Data bus 16 Bits
	output	reg[12:0]	DRAM_ADDR,			//	SDRAM Address bus 12 Bits
	output			DRAM_LDQM,				//	SDRAM Low-byte Data Mask 
	output			DRAM_UDQM,				//	SDRAM High-byte Data Mask
	output	reg		DRAM_WE_N,				//	SDRAM Write Enable
	output	reg		DRAM_CAS_N,				//	SDRAM Column Address Strobe
	output	reg		DRAM_RAS_N,				//	SDRAM Row Address Strobe
	output			DRAM_CS_N,				//	SDRAM Chip Select
	output			DRAM_BA_0,				//	SDRAM Bank Address 0
	output			DRAM_BA_1,				//	SDRAM Bank Address 0
	input	[21:0]	iaddr,
	input	[15:0]	idata,
	input			rd,
	input			we_n,
	output	reg [15:0]	odata
);

parameter ST_RESET0 = 4'd0;
parameter ST_RESET1 = 4'd1;
parameter ST_IDLE   = 4'd2;
parameter ST_RAS0   = 4'd3;
parameter ST_RAS1   = 4'd4;
parameter ST_READ0  = 4'd5;
parameter ST_READ1  = 4'd6;
parameter ST_READ2  = 4'd7;
parameter ST_WRITE0 = 4'd8;
parameter ST_WRITE1 = 4'd9;
parameter ST_WRITE2 = 4'd10;
parameter ST_REFRESH0 = 4'd11;
parameter ST_REFRESH1 = 4'd12;

reg[3:0] state = ST_RESET0;
reg[9:0] refreshcnt;
reg[21:0] addr;
reg[15:0] data;
reg refreshflg,exrd = 0,exwen = 1'b1;

assign DRAM_DQ = state == ST_WRITE0 ? data : 16'bZZZZZZZZZZZZZZZZ;
assign DRAM_LDQM = 0;
assign DRAM_UDQM = 0;
assign DRAM_CS_N = reset;
assign DRAM_BA_0 = addr[20];
assign DRAM_BA_1 = addr[21];

always @(*) begin
	case (state)
	ST_RESET0: DRAM_ADDR = 13'b100000;
	ST_RAS0:   DRAM_ADDR = {1'b0,addr[19:8]};
	default:   DRAM_ADDR = {4'b0100,addr[7:0]};
	endcase
	case (state)
	ST_RESET0:   {DRAM_RAS_N,DRAM_CAS_N,DRAM_WE_N} = 3'b000;
	ST_RAS0:     {DRAM_RAS_N,DRAM_CAS_N,DRAM_WE_N} = 3'b011;
	ST_READ0:    {DRAM_RAS_N,DRAM_CAS_N,DRAM_WE_N} = 3'b101;
	ST_WRITE0:   {DRAM_RAS_N,DRAM_CAS_N,DRAM_WE_N} = 3'b100;
	ST_REFRESH0: {DRAM_RAS_N,DRAM_CAS_N,DRAM_WE_N} = 3'b001;
	default:     {DRAM_RAS_N,DRAM_CAS_N,DRAM_WE_N} = 3'b111;
	endcase
end

always @(posedge clk50mhz) begin
	refreshcnt <= refreshcnt + 10'b1;
	if (reset) begin
		state <= ST_RESET0; exrd <= 0; exwen <= 1'b1;
	end else begin
		case (state)
		ST_RESET0: state <= ST_RESET1;
		ST_RESET1: state <= ST_IDLE;
		ST_IDLE: if (refreshcnt[9]!=refreshflg) state <= ST_REFRESH0; else begin
			exrd <= rd; exwen <= we_n; addr <= iaddr; data <= idata;
			casex ({rd,exrd,we_n,exwen})
			4'b1011: state <= ST_RAS0;
			4'b0001: state <= ST_RAS0;
			default: state <= ST_IDLE;
			endcase
		end
		ST_RAS0: state <= ST_RAS1;
		ST_RAS1:
			casex ({exrd,exwen})
			2'b11: state <= ST_READ0;
			2'b00: state <= ST_WRITE0;
			default: state <= ST_IDLE;
			endcase
		ST_READ0: state <= ST_READ1;
		ST_READ1: state <= ST_READ2;
		ST_READ2: {state,odata} <= {ST_IDLE,DRAM_DQ};
		ST_WRITE0: state <= ST_WRITE1;
		ST_WRITE1: state <= ST_WRITE2;
		ST_WRITE2: state <= ST_IDLE;
		ST_REFRESH0: {state,refreshflg} <= {ST_REFRESH1,refreshcnt[9]};
		ST_REFRESH1: state <= ST_IDLE;
		default: state <= ST_IDLE;
		endcase
	end
end
	
endmodule
