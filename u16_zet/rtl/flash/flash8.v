/*
 *  Wishbone Flash RAM core for Altera DE1 board
 *  Copyright (c) 2009  Zeus Gomez Marmolejo <zeus@opencores.org>
 *
 *  This file is part of the Zet processor. This processor is free
 *  hardware; you can redistribute it and/or modify it under the terms of
 *  the GNU General Public License as published by the Free Software
 *  Foundation; either version 3, or (at your option) any later version.
 *
 *  Zet is distrubuted in the hope that it will be useful, but WITHOUT
 *  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
 *  or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public
 *  License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with Zet; see the file COPYING. If not, see
 *  <http://www.gnu.org/licenses/>.
 */

module flash8 (
    // Wishbone slave interface
    input         wb_clk_i, //-----12.5 Mhz;
    input         wb_rst_i,
    input  [15:0] wb_dat_i,
    output [15:0] wb_dat_o,
    input         wb_we_i,
    input         wb_adr_i,
    input  [ 1:0] wb_sel_i,
    input         wb_stb_i,
    input         wb_cyc_i,
    output        wb_ack_o,

    // Pad signals 		
	 output NCSO,
	 output DCLK,
	 output ASDO,
	 input  DATA0
  );
  
  wire [19:0] flash_addr_; // (1 GB)
  wire [15:0] flash_data_;
  reg         flash_rd_;
  wire        flash_busy_;

  // Registers and nets
  wire        op;
  wire        wr_command;
  reg  [21:0] address;

  wire        word;
  wire        op_word;
  reg         st;
  reg  [ 7:0] lb;
  reg  [ 7:0] lb_r;

  
  wire  [15:0] wb_dat_o1;
  wire  [15:0] wb_dat_o2;
  
  ////=======================================================
  // Net declarations
  reg  [15:0] rom[0:4095];  // Instantiate the ROM 16bit, 4k-word
  wire [11:0] rom_addr;     //  0x7FF = adr: 11bit //FFF =12bit
  assign rom_addr = address[11: 0];
  initial $readmemh("exec_rom.dat", rom);
  //--------
  //reg  [15:0] bios[0:16383]; // Instantiate the ROM 16bit, 16k-word
  //wire [13:0] bios_addr;
  //assign bios_addr = address[13: 0];
  //initial $readmemh("VGABIOS.dat", bios);
  //==========================================================

  // Combinatorial logic
  assign op      = wb_stb_i & wb_cyc_i;
  assign word    = wb_sel_i==2'b11;
  assign op_word = op & word & !wb_we_i;

  assign flash_addr_[19:1] = address[18:0];  
  assign flash_addr_[0] = 1'b0;

  assign wr_command  = op & wb_we_i;  // Wishbone write access Signal
  //assign wb_ack_o = op & (op_word ? st : 1'b1);
  assign wb_ack_o = op & (wr_command ? 1'b1 : flash_ready);
    //////////////////////////////////////////////////////////////////////////
  // DISK A FLASH ADDR = 1 0000 - 9 3FFF (size 8 3FFF) //SIZE = 167FFF byte
  //                         0x0000   - 0x7FFF - ZET VGA BIOS 32k
  //                         0x8000   - 0xFFFF - ZET BIOS    -32k
  //                         0x100000 - 0x183FFF - DISK A: 1.4 M
  //                         0x200000 - Cyclone RAM 
  assign wb_dat_o =  address[21] ? wb_dat_o1 : wb_dat_o2;	
  assign wb_dat_o1 =	rom[rom_addr];                       // Cyclon Memory
  //assign wb_dat_o2 = bios[bios_addr];  					    // Cyclon Memory
  //assign wb_dat_o2 = wb_sel_i[1] ? { flash_data_, lb }  // ROM  Memory
  //                             : { 8'h0, flash_data_ };  										 
  assign wb_dat_o2 = flash_data_;                         // SPI FLASH

  // Behaviour
  // st - state
  always @(posedge wb_clk_i)
    st <= wb_rst_i ? 1'b0 : op_word;
	 
  // lb - low byte
  always @(posedge wb_clk_i)
    lb <= wb_rst_i ? 8'h0 : (op_word ? flash_data_ : 8'h0);

  // --------------------------------------------------------------------
  // Register addresses and defaults
  // --------------------------------------------------------------------
  `define FLASH_ALO   1'h0    // Lower 16 bits of address lines
  `define FLASH_AHI   1'h1    // Upper  6 bits of address lines
  always @(posedge wb_clk_i)  // Synchrounous
    if(wb_rst_i)
      address <= 22'h000000;  // 
    else
	 begin
      if(wr_command)          // If a write was requested
        case(wb_adr_i)        // Determine which register was writen to
            `FLASH_ALO: 
				 begin
					address[15: 0] <= wb_dat_i;
					flash_rd_ <= 1'b1;
				 end	
            `FLASH_AHI: address[21:16] <= wb_dat_i[5:0];
            default:    ;      // Default
			endcase               // End of case
		else
			flash_rd_ <= 1'b0;
   end
//=======================================================================

spi_flash spi_flash (
		.RESET		(wb_rst_i),
		.CLK	   	(wb_clk_i),	
		.SCK			(wb_clk_i),
		.spi_addr   ({4'b0001, flash_addr_}), // START from 1MB, (FLASH SIZE -2MB)
		.spi_data   (flash_data_),
		.spi_rd		(flash_rd_),
		.READY	   (flash_ready),
		//---------------------------------------------------------
		.CS_n		   (NCSO),
		.SCLK		   (DCLK),
		.MOSI		   (ASDO),
		.MISO		   (DATA0)	  
);

//assign DCLK = flash_rd_;
//assign NCSO = 1'b1;

endmodule
