/*
// PROTOTYPE - bootrom
 */

//0xFE000 --- 8kB/////


module exec_rom (
    input clk,
    input rst,

    // Wishbone slave interface
    input  [15:0] wb_dat_i,
    output [15:0] wb_dat_o,
    input  [19:1] wb_adr_i,
    input         wb_we_i,
    input         wb_tga_i,
    input         wb_stb_i,
    input         wb_cyc_i,
    input  [ 1:0] wb_sel_i,
    output        wb_ack_o
  );


  // RAM  
  reg  [7:0] rom_low[0:4095];  // Instantiate the ROM 4096 Byte
  reg  [7:0] rom_hi [0:4095];  // Instantiate the ROM 4096 Byte
  wire [11:0] rom_addr;
  wire        stb;

  // Combinatorial logic
  assign rom_addr = wb_adr_i[12:1];
  assign stb      = wb_stb_i & wb_cyc_i;
  assign wb_ack_o = stb;
  
  assign wb_dat_o = {rom_hi[rom_addr],rom_low[rom_addr]};
  always @(posedge clk) begin
    rom_low[rom_addr] <= 
  				((stb & wb_we_i & wb_sel_i[0]) ? wb_dat_i[7:0] : rom_low[rom_addr]);
   rom_hi[rom_addr] <= 
					((stb & wb_we_i & wb_sel_i[1]) ? wb_dat_i[15:8] : rom_hi[rom_addr]);
  end
  
endmodule
