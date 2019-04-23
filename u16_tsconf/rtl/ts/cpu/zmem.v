
// PentEvo project (c) NedoPC 2008-2009
//


module zmem(

	input  wire clk,
	input  wire c0, c1, c2, c3,
	input  wire zneg, // strobes which show positive and negative edges of zclk
	input  wire zpos,

// Z80
	input  wire rst,
	input  wire [15:0] za,
	output wire [ 7:0] zd_out,  // output to Z80 bus
	output wire zd_ena,         // output to Z80 bus enable

	input  wire opfetch,
	input  wire opfetch_s,
	input  wire mreq,
   input  wire memrd,
   input  wire memwr,
	input  wire memwr_s,

	input  wire [ 1:0] turbo, 	   // 2'b00 - 3.5,
	                              // 2'b01 - 7.0,
	                              // 2'b1x - 14.0
	input wire [3:0] cache_en,
	input wire [3:0] memconf,
	input wire [31:0] xt_page,
	output wire [7:0] xtpage_0, 

	output wire [4:0] rompg,
	output wire csrom,
	output wire romoe_n,
	output wire romwe_n,
	
	output wire csvrom,
	output wire dos,
  	output wire dos_on,
	output wire dos_off,
	output wire dos_change,
	
	output wire vdos,
	output reg pre_vdos,
	input wire vdos_on,
	input wire vdos_off,

// DRAM
	output wire        cpu_req,
	output wire [20:0] cpu_addr,
	output wire        cpu_wrbsel,
	input  wire [15:0] cpu_rddata,
	input  wire        cpu_next,
	input  wire        cpu_strobe,
	input  wire        cpu_latch,
	output wire        cpu_stall,    // for zclock
	
	input  wire        loader,

	input wire testkey,		// DEBUG!!!
	input wire intt,		   // DEBUG!!!
	output wire [3:0] tst
	
);

  assign tst[0]  = memwr && win0; 
  assign tst[1]  = rw_en;
  assign tst[2]  = ramwr;
  assign tst[3]  = 1'b0;
      
  assign xtpage_0 = xtpage[0];
  //assign xtpage_0 = { 4'b0, vdos, memconf[2], ~dos, memconf[0]};
  
  
  //---SELECT ROM PAGE0---------
	//localparam   DOS_RESET = 1'h1;         //DOS-ON  
	localparam   DOS_RESET = 1'h0;           //DOS-OFF 

// pager
    wire [1:0] win = za[15:14];
    wire win0 = ~|win; // PAGE 1,2,3 (not PAGE0) 
	 // loader = 1 : при выборе Bank3 - ВСЕГДА ПОДКЛЮЧЕНА ВЕРХНЯЯ ПАМЯТЬ - vROM 
	 // загружаю RОМ через Bank3, запись всегда разрешена 
    wire rw_en = !win0 || memconf[1] || vdos; // =1 : WRITE ENABLE for PAGE0 when memconf[1]=1 or vDOS
	                     //memconf[1] = 1 BANK0 WR_EN, 0 - DIS    
	 //wire rw_en = !win0 || memconf[3] || memconf[1] || vdos;   // WRITE EN for ALL Win if -RAM
	 
	 wire [7:0] page = xtpage[win];

	 assign rompg = xtpage[0][4:0];
	 assign csrom  = 1'b0; // csvrom  && !loader; // 1'b0;  //- сигнал ЗАПРЕЩЕНИЯ ЗАПИСИ в ВИРУАЛЬНОЕ ПЗУ 
	  
    assign csvrom = win0 && !memconf[3] && !vdos; //- сигнал ДОСТУПА К ВИРУТАЛЬНОМУ ПЗУ 
									// memconf[3] = 1-RAM, =0-ROM
	 //assign csvrom = win0 && !memconf[3] && !vdos && !(memconf [1] && memwr); // - если WR EN - to RAM ???	
	 
  
    wire [7:0] xtpage[0:3];
    assign xtpage[0] = vdos ? 8'hFF : {xt_page[7:2], memconf[2] ? xt_page[1:0] : {~dos, memconf[0]}};
    assign xtpage[1] = xt_page[15:8];
    assign xtpage[2] = xt_page[23:16];
    assign xtpage[3] = xt_page[31:24]; //rampage[3]                   


// DOS signal control
	assign dos_on = win0 && opfetch_s && (za[13:8]==6'h3D) && memconf[0] && !memconf[2];
	//assign dos_on = win0 && opfetch_s && (za[13:8]==6'h3D) && memconf[0];
	assign dos_off = !win0 && opfetch_s && !vdos;
	//assign dos_off = !win0 && opfetch_s;
	assign dos_change = (dos_off && dos_r) || (dos_on && !dos_r);

	//assign dos = (dos_on || dos_off) ^^ dos_r;		// to make dos appear 1 clock earlier than dos_r
	//assign dos = (dos_on || dos_r);
	assign dos = (dos_on || dos_r) && !dos_off;
	
   reg dos_r;
	always @(posedge clk)
	if (rst)
		//dos_r <= 1'b0;
		dos_r <= DOS_RESET; //=1 ON

	else if (dos_off)
			dos_r <= 1'b0;
	else if (dos_on)
			dos_r <= 1'b1;


// VDOS signal control
    // vdos turn on/off is delayed till next opfetch due to INIR that writes right after iord cycle
	assign vdos = opfetch ? pre_vdos : vdos_r;	// vdos appears as soon as first opfetch

   reg vdos_r;
	always @(posedge clk)
	if (rst || vdos_off)
	begin
		pre_vdos <= 1'b0;
		vdos_r <= 1'b0;
	end
	else if (vdos_on)
		pre_vdos <= 1'b1;
	else if (opfetch_s)
		vdos_r <= pre_vdos;

// ===========================================================================

// Z80 controls
	assign romoe_n = !memrd;
	assign romwe_n = !(memwr && rw_en);

	wire ramreq = mreq && !csrom;
	wire ramrd = memrd && !csrom;
	wire ramwr = memwr && !csrom && rw_en;
	
	wire ramwr_s = memwr_s && !csrom && rw_en;
	assign zd_ena = memrd && !csrom;
	
	assign cpu_req = turbo14 ? cpureq_14 : cpureq_357;
	assign cpu_stall = turbo14 ? stall14 : stall357;

	wire turbo14 = turbo[1];
		
// 7/3.5MHz support =========================================
	wire cpureq_357 = (ramrd_zs && !cache_hit_en) || ramwr_zs;
	wire stall357 = cpureq_357 && !cpu_next;

	wire ramwr_zs = ramwr && !ramwr_zr;
	wire ramrd_zs = ramrd && !ramrd_zr;

	reg ramrd_zr, ramwr_zr;
	always @(posedge clk)
		if (c3 && !cpu_stall) 
		begin                 
			ramrd_zr <= ramrd;
			ramwr_zr <= ramwr;
		end

// 14MHz support ============================================
	// wait tables:
	//
	// M1 opcode fetch, dram_beg concurs with:
	// c3:      +3
	// c2:      +4
	// c1:      +5
	// c0:      +6
	//
	// memory read, dram_beg concurs with:
	// c3:      +2
	// c2:      +3
	// c1:      +4
	// c0:      +5
	//
	// memory write: no wait
	//
	// special case: if dram_beg pulses 1 when cpu_next is 0,
	// unconditional wait has to be performed until cpu_next is 1, and
	// then wait as if dram_beg would concur with c0

	// memrd, opfetch - wait till c3 && cpu_next,
	// memwr - wait till cpu_next
	
	wire cpureq_14 = dram_beg || pending_cpu_req;
	//wire stall14 = stall14_ini || stall14_cyc || stall14_fin; //- not work
	wire stall14 = stall14_ini || stall14_cyc; //WORK
	
	//wire dram_beg = (!cache_hit_en || ramwr) && zpos && ramreq_s_n;                                //modif N1 
	wire dram_beg = (!cache_hit_en && ( memconf[3] ? 1'b1 : ramrd ) || ramwr) && zpos && ramreq_s_n;  //--   N2
	                                  //if BANK0-RAM, WR enable all time for 14 MHz
	wire ramreq_s_n = ramreq_r_n && ramreq;
	reg ramreq_r_n;
	//always @(posedge clk) if (zneg)
	always @(posedge clk) if (zpos)
		ramreq_r_n <= !mreq;

	reg pending_cpu_req;
	always @(posedge clk)
	if (rst)
		pending_cpu_req <= 1'b0;
	else if (cpu_next && c3)
		pending_cpu_req <= 1'b0;
	else if (dram_beg)
		pending_cpu_req <= 1'b1;

	wire stall14_ini = dram_beg && (!cpu_next || opfetch || memrd);	// no wait at all in write cycles, if next dram cycle is available
	wire stall14_cyc = memrd ? stall14_cycrd : !cpu_next;


	reg stall14_cycrd;
	always @(posedge clk)
	if (rst)
		stall14_cycrd <= 1'b0;
	else if (cpu_next && c3)
		stall14_cycrd <= 1'b0;
	else if (dram_beg && (!c3 || !cpu_next) && (opfetch || memrd))
		stall14_cycrd <= 1'b1;

	reg stall14_fin;
	always @(posedge clk)
	if (rst)
		stall14_fin <= 1'b0;
	else if (stall14_fin && ((opfetch && cc[0]) || (memrd && cc[1])))
		stall14_fin <= 1'b0;
	else if (cpu_next && c3 && cpu_req && (opfetch || memrd))
		stall14_fin <= 1'b1;

    wire [1:0] cc = turbo[0] ? {c1, c0} : {c2, c1};	// normal or overclock

// address, data in and data out =============================================
	assign cpu_wrbsel = za[0];
	assign cpu_addr[20:0] = {page, za[13:1]};
	wire [15:0] mem_d = cpu_latch ? cpu_rddata : cache_d;
	assign zd_out = ~cpu_wrbsel ? mem_d[7:0] : mem_d[15:8];	 

//=================================================================
// CACHE ==INPUT:ramwr,csvrom,cpu_addr,cpu_rddata =================
	
	wire [7:0]  ch_addr1 	 = cpu_addr[7:0];
	wire [12:0] cpu_hi_addr1 = cpu_addr[20:8];
	wire csvrom1  			    = csvrom;	
	
	reg [7:0]  ch_addr2;
	reg [12:0] cpu_hi_addr2;
	reg csvrom2;
	always @(posedge clk) //-              !clk
	if (c0) // ready for cx      ------------c1 -not stable
		begin                   //------------c0 -0k 
			ch_addr2     <= cpu_addr[7:0]; //--c3 -not stable
	      cpu_hi_addr2 <= cpu_addr[20:8];
			csvrom2 	    <= csvrom;
		end
	//----------------------------------
	//===========================================================
	wire [12:0] cache_a;   //address from CACHE
	wire [15:0] cache_d;   //data from CACHE
	wire cache_v;          //data valid
	wire [1:0] cache_tmp;  //empty 16bit: 2 cache_tmp + csvrom + 13cpu_hi_addr1
	
	cache_data cache_data (
		 .clock (clk),     // -- CLK
		 .rdaddress ({csvrom1, ch_addr1}), // ADDR for RD 
		 .wraddress (loader ? za[8:0] : cpu_strobe ? {csvrom2, ch_addr2} : {csvrom1, ch_addr1}),//WR
		  //-----------------CACHE DATA -------------------------
		 .wren (loader ? 1'b1  : cpu_strobe), //c2 -strobe
		 .data (loader ? 16'b0 : cpu_rddata), //<=====
		 .q (cache_d)        // ==> data from CACHE
	);

	cache_addr cache_addr (
		 .clock (clk),    //---- CLK
		 .rdaddress ({csvrom1, ch_addr1}), //                      
		 .wraddress (loader ? za[8:0] : cpu_strobe ? {csvrom2, ch_addr2} : {csvrom1, ch_addr1}), //WR
		 //--------------arbiter.cpu_strobe <= curr_cpu && cpu_rnw_r;
		 .q ({cache_tmp, cache_v, cache_a}), // valid, addr from CACHE 
		 .data (loader ? 16'b0 : cpu_strobe ? {cache_tmp, 1'b1, cpu_hi_addr2} : {2'b0, 1'b0, 8'b0}), //wrdata 
		 .wren (loader ? 1'b1 : (cpu_strobe || cache_inv))  //c2 -strobe
	);	
	//-----------		
	wire cache_hit = (cpu_hi_addr1 == cache_a) && cache_v;
	//---ONLY RAM
	//wire cache_hit = !csvrom1 && (cpu_hi_addr1 == cache_a) && cache_v;	// asynchronous signal meaning that address requested by CPU is cached and valid
	//---ONLY ROM 
	//wire cache_hit = csvrom1 && (cpu_hi_addr1 == cache_a) && cache_v;
	
	//wire cache_hit_en = (cache_hit && cache_en) ;
	wire cache_hit_en = (cache_hit && (cache_en[win] || csvrom)) ;
	wire cache_inv = ramwr_s && cache_hit;	   // cache invalidation should be only performed if write happens to cached address
	
	

endmodule
