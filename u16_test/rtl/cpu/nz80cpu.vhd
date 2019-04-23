-------------------------------------------------------------------[09.04.2014]
-- NZ80CPU v1.2.1
-------------------------------------------------------------------------------
-- Engineer: 	MVV
-- Description: 
--		Implementation of Z80 compatible CPU based on sources file
--		NextZ80 (Verilog) Version 1.0 By Nicolae Dumitrache 
--
-- 15.04.2012	Initial release.
-- 01.05.2013
-- 08.07.2013	��������� � ������ "Register select"
-- 09.04.2014

-------------------------------------------------------------------------------

library	ieee;
use	ieee.std_logic_1164.all;
use	ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity nz80cpu is
	port (
		CLK			: in	std_logic;
		CLKEN		: in	std_logic;
		RESET		: in	std_logic;
		NMI			: in	std_logic;
		INT			: in	std_logic;
		DI			: in	std_logic_vector( 7 downto  0);
		DO			: out	std_logic_vector( 7 downto  0);
		ADDR		: out	std_logic_vector(15 downto  0);
		WR			: out	std_logic;
		MREQ		: out	std_logic;
		IORQ		: out	std_logic;
		HALT		: out	std_logic;
		M1			: out	std_logic
	);
end entity nz80cpu;

architecture rtl of nz80cpu is
	
	-- connections and registers
--	signal	code		: std_logic_vector(16 downto 0);
	
	signal	cpu_status	: std_logic_vector( 9 downto 0) := "0000000000";	-- 0=AF-AF', 1=HL-HL', 2=DE-HL, 3=DE'-HL', 4=HL-X, 5=IX-IY, 6=IFF1, 7=IFF2, 9:8=IMODE
	signal	mux			: std_logic_vector(15 downto 0);
	signal	fetch		: std_logic_vector( 9 downto 0) := "0000000000";
	signal	stage		: std_logic_vector( 2 downto 0) := "000";
	signal	opd			: std_logic_vector( 5 downto 0);
	signal	op16		: std_logic_vector( 2 downto 0);
	signal	op0mem		: std_logic;
	signal	op1mem		: std_logic;
	signal	fetch98		: std_logic_vector( 1 downto 0);
	signal	do_sel		: std_logic_vector( 1 downto 0);	-- alu80 - th - flags - alu8_do[7:0]
	signal	dinw_sel	: std_logic;				-- alu8out - DI
	signal	we			: std_logic_vector( 5 downto 0);		--	5=flags, 4=PC, 3=SP, 2=tmpHI, 1=hi, 0=lo
	signal	next_stage	: std_logic;
	signal	reg_wsel	: std_logic_vector( 3 downto 0);
	signal	reg_rsel	: std_logic_vector( 3 downto 0);
	signal	status		: std_logic_vector(11 downto 0);		--	0=AF-AF', 1=HL-HL', 2=DE-HL, 3=DE'-HL', 4=HL-X, 5=IX-IY, 7:6=IFFVAL, 9:8=imode, 10=setIMODE, 11=set IFFVAL
	signal	mux_flag	: std_logic_vector( 7 downto 0);
	signal	flgmux		: std_logic_vector( 7 downto 0);		--	LD A, I/R IFF2 flag on parity
	signal	flags		: std_logic_vector( 7 downto 0);
	signal	tzf			: std_logic;
	signal	nmi_flag	: std_logic := '0';
	signal	snmi		: std_logic := '0';
	signal	sreset		: std_logic := '0';
	signal	sint		: std_logic := '0';
	signal	intop		: std_logic_vector( 2 downto 0);
	signal	xmask		: std_logic;
	signal	pc			: std_logic_vector(15 downto 0) := "0000000000000000";		--	program	counter
	signal	sp			: std_logic_vector(15 downto 0);		--	stack	pointer
	signal	r			: std_logic_vector( 7 downto 0);		--	refresh
	signal	flg			: std_logic_vector(15 downto 0) := "0000000000000000";
	signal	rdor		: std_logic_vector(15 downto 0);		--	R	out	from	RAM
	signal	rdow		: std_logic_vector(15 downto 0);		--	W	out	from	RAM
	signal	din			: std_logic_vector(15 downto 0);		--	RAM	W	in	data
	signal	mux_rdor	: std_logic_vector(15 downto 0);		--	(3)A reversed mixed with TL, (4)I mixed with R (5)SP
	signal	const		: std_logic_vector( 7 downto 0);
	signal	rstatus		: std_logic_vector( 7 downto 0);
	signal	dout_sig	: std_logic_vector( 7 downto 0);
	signal	addr_sig	: std_logic_vector(15 downto 0);
	signal	mreq_sig	: std_logic;
	signal	halt_sig	: std_logic;
	signal	m1_sig		: std_logic;
	signal	wr_sig		: std_logic;
	signal	iorq_sig	: std_logic;	
	signal	addr1		: std_logic_vector(15 downto 0);		--	address post increment
	-- ALU8
	signal	daaadjust	: std_logic_vector( 7 downto 0);
	signal	cdaa		: std_logic;
	signal	hdaa		: std_logic;
	signal	exop		: std_logic_vector( 5 downto 0);		--	exop[5:4] = 2'b11 for CPI/D/R
	signal	parity		: std_logic;
	signal	zero		: std_logic;
	signal	csin		: std_logic;
	signal	cin			: std_logic;
	signal	d0mux		: std_logic_vector( 7 downto 0);
	signal	d1mux_wir2	: std_logic_vector( 7 downto 0);
	signal	d1mux		: std_logic_vector( 7 downto 0);
	signal	sum			: std_logic_vector( 8 downto 0);
	signal	hf			: std_logic;
	signal	overflow	: std_logic;
	signal	dbit		: std_logic_vector( 7 downto 0);
	signal	alu8_do		: std_logic_vector(15 downto 0);
	signal	alu8_op		: std_logic_vector( 4 downto 0);
	signal	alu8_flags	: std_logic_vector( 7 downto 0);
	signal	alu80		: std_logic_vector( 7 downto 0);
	signal	alu81		: std_logic_vector( 7 downto 0);
	signal	alu160		: std_logic_vector(15 downto 0);
	signal	alu161		: std_logic_vector( 7 downto 0);
	signal	alu160_sel	: std_logic;							--	regs - pc
	signal	alu16_op	: std_logic_vector( 2 downto 0);
	--	DAA
	signal	h08			: std_logic;
	signal	h09			: std_logic;
	signal	l09			: std_logic;
	signal	l05			: std_logic;
	signal	adj			: std_logic_vector( 1 downto 0);
	
	signal	reg_0l		: std_logic_vector( 7 downto 0);
	signal	reg_1l		: std_logic_vector( 7 downto 0);
	signal	reg_2l		: std_logic_vector( 7 downto 0);
	signal	reg_3l		: std_logic_vector( 7 downto 0);
	signal	reg_4l		: std_logic_vector( 7 downto 0);
	signal	reg_5l		: std_logic_vector( 7 downto 0);
	signal	reg_6l		: std_logic_vector( 7 downto 0);
	signal	reg_7l		: std_logic_vector( 7 downto 0);
	signal	reg_8l		: std_logic_vector( 7 downto 0);
	signal	reg_9l		: std_logic_vector( 7 downto 0);
	signal	reg_al		: std_logic_vector( 7 downto 0);
	signal	reg_bl		: std_logic_vector( 7 downto 0);
	signal	reg_cl		: std_logic_vector( 7 downto 0);
	signal	reg_dl		: std_logic_vector( 7 downto 0);
	signal	reg_el		: std_logic_vector( 7 downto 0);
	signal	reg_fl		: std_logic_vector( 7 downto 0);

	signal	reg_0h		: std_logic_vector(7	downto	0);
	signal	reg_1h		: std_logic_vector(7	downto	0);
	signal	reg_2h		: std_logic_vector(7	downto	0);
	signal	reg_3h		: std_logic_vector(7	downto	0);
	signal	reg_4h		: std_logic_vector(7	downto	0);
	signal	reg_5h		: std_logic_vector(7	downto	0);
	signal	reg_6h		: std_logic_vector(7	downto	0);
	signal	reg_7h		: std_logic_vector(7	downto	0);
	signal	reg_8h		: std_logic_vector(7	downto	0);
	signal	reg_9h		: std_logic_vector(7	downto	0);
	signal	reg_ah		: std_logic_vector(7	downto	0);
	signal	reg_bh		: std_logic_vector(7	downto	0);
	signal	reg_ch		: std_logic_vector(7	downto	0);
	signal	reg_dh		: std_logic_vector(7	downto	0);
	signal	reg_eh		: std_logic_vector(7	downto	0);
	signal	reg_fh		: std_logic_vector(7	downto	0);
	
	signal	wire01	:	std_logic_vector(4	downto	0);
	signal	wire02	:	std_logic_vector(2	downto	0);
	signal	wire03	:	std_logic_vector(3	downto	0);
	signal	wire04	:	std_logic_vector(3	downto	0);
	signal	wire05	:	std_logic;
	signal	wire06	:	std_logic_vector(2	downto	0);
	signal	wire07	:	std_logic_vector(3	downto	0);
	signal	wire08	:	std_logic_vector(2	downto	0);
	signal	wire09	:	std_logic_vector(1	downto	0);
	signal	wire10	:	std_logic_vector(2	downto	0);
	signal	wire11	:	std_logic_vector(2	downto	0);
	signal	wire12	:	std_logic;
	signal	wire13	:	std_logic_vector(3	downto	0);
	signal	wire14	:	std_logic;
	signal	wire15	:	std_logic;
	signal	wire16	:	std_logic_vector(3	downto	0);
	signal	wire17	:	std_logic_vector(3	downto	0);
	signal	wire18	:	std_logic_vector(5	downto	0);
	signal	wire19	:	std_logic_vector(2	downto	0);
	signal	wire20	:	std_logic_vector(2	downto	0);
	signal	wire21	:	std_logic_vector(3	downto	0);
	signal	wire22	:	std_logic_vector(5	downto	0);
	signal	wire23	:	std_logic_vector(4	downto	0);
	signal	wire24	:	std_logic_vector(4	downto	0);
	signal	wire25	:	std_logic_vector(5	downto	0);
	signal	wire26	:	std_logic_vector(5	downto	0);
	signal	wire27	:	std_logic_vector(5	downto	0);
	signal	wire28	:	std_logic_vector(1	downto	0);
	signal	wire29	:	std_logic_vector(3	downto	0);
	signal	wire30	:	std_logic_vector(1	downto	0);
	signal	wire31	:	std_logic_vector(4	downto	0);
	signal	wire32	:	std_logic;
	signal	wire33	:	std_logic;
	signal	wire34	:	std_logic;
	signal	wire35	:	std_logic;
	signal	wire36	:	std_logic_vector(3	downto	0);
	signal	wire37	:	std_logic_vector(1	downto	0);
	signal	wire38	:	std_logic_vector(5	downto	0);
	signal	wire39	:	std_logic_vector(3	downto	0);
	signal	wire40	:	std_logic;
	signal	wire41	:	std_logic;
	signal	wire42	:	std_logic;
	signal	wire43	:	std_logic_vector(2	downto	0);
	signal	wire44	:	std_logic_vector(4	downto	0);
	signal	wire45	:	std_logic_vector(5	downto	0);
	signal	wire46	:	std_logic;
	signal	wire47	:	std_logic_vector(2	downto	0);
	signal	wire48	:	std_logic_vector(2	downto	0);
	signal	wire49	:	std_logic_vector(1	downto	0);
	signal	wire50	:	std_logic_vector(1	downto	0);
	signal	wire51	:	std_logic_vector(2	downto	0);
	signal	wire52	:	std_logic_vector(3	downto	0);
	signal	wire53	:	std_logic_vector(2	downto	0);
	signal	wire54	:	std_logic;
	signal	wire55	:	std_logic;
	signal	wire56	:	std_logic;
	signal	wire57	:	std_logic_vector(7	downto	0);
	signal	wire58	:	std_logic_vector(15	downto	0);
	signal	wire59	:	std_logic;
	signal	wire60	:	std_logic;
	signal	wire61	:	std_logic;
	signal	wire62	:	std_logic;
	signal	wire63	:	std_logic_vector(2	downto	0);
	signal	wire64	:	std_logic;
	signal	wire65	:	std_logic;
	signal	wire66	:	std_logic;
	signal	wire67	:	std_logic;
	signal	wire68	:	std_logic;
	signal	wire69	:	std_logic_vector(4 downto 0);
	signal	wire70	:	std_logic;

begin
	-- Drive referenced outputs
	DO	<= dout_sig;
	ADDR	<= addr_sig;
	MREQ	<= mreq_sig;
	IORQ	<= iorq_sig;
	HALT	<= halt_sig;
	M1	<= m1_sig;
	WR	<= wr_sig;
	
	op0mem	<= '1' when fetch(2 downto 0) = "110" else '0';
	op1mem	<= '1' when fetch(5 downto 3) = "110" else '0';
	mux_flag <= flags(7) & not(flags(7)) & flags(2) & not(flags(2)) & flags(0) & not(flags(0)) & flags(6) & not(flags(6));
	intop	<= "100" when fetch(1) = '1' else "101" when fetch(0) = '1' else "110";
	-- inc16 HL
	wire05	<= not(reg_wsel(0));
	wire06	<= mreq_sig & cpu_status(9 downto 8);

	process	(CLK)
	begin
		if CLK'event and CLK = '1' then
			if CLKEN = '1' then
				sreset	<= RESET;
				snmi	<= NMI;
				sint	<= INT;
				
				if snmi = '0' then
					nmi_flag <= '0';
				end if;
				
				if sreset = '1' then
					fetch <= "1110000000";
				elsif fetch(9 downto 6) = "1110" then
					fetch(9 downto 7) <= "000";							--	exit RESET state
				else
					if m1_sig = '1' then
						case wire06 is
							when "000" | "001" | "100" | "101" | "110" | "111" => fetch <= fetch98 & DI;
							when "010" => fetch <= fetch98 & "11111111";	--	IM1 - RST38
							when others =>	null;						--	IM2 - get addrLO
						end case;
--					end	if;	-- V1.2.1
					elsif next_stage = '0' and fetch98(1 downto 0) = "00" and status(4) = '0' then	--	INT or NMI sample
						if snmi = '1' and nmi_flag = '0' then			--	NMI posedge
							fetch(9 downto 6) <= "1101";
							fetch(1 downto 0) <= halt_sig & m1_sig;		--	NMI acknowledged
							nmi_flag <= '1';					--	INT request
						elsif sint = '1' and cpu_status(6) = '1' and status(11) = '0' then
							fetch(9 downto 6) <= "1100";
							fetch(1 downto 0) <= halt_sig & m1_sig;
						end if;
					end if;
				end if;
				
				if	(next_stage = '1')	then
					stage	<=	stage + "001";
				else
					stage	<=	"000";
				end	if;
				
				if	(status(4) = '1')	then
					cpu_status(5	downto	4)	<=	status(5	downto	4);
				elsif	((next_stage = '0'	and	fetch98(1) = '0')	or	fetch98(0) = '1')	then		--	clear X
					cpu_status(4)	<=	'0';
				end	if;
				cpu_status(3	downto	0)	<=	cpu_status(3	downto	0)	xor	status(3	downto	0);
				if	(status(11) = '1')	then		  					
					cpu_status(7	downto	6)	<=	status(7	downto	6);	--	IFF2:1
				end	if;
				if	(status(10) = '1')	then
					cpu_status(9	downto	8)	<=	status(9	downto	8);	--	IMM
				end	if;
				tzf	<=	alu8_flags(6);
			end	if;
		end	if;
	end	process;
	
	opd(0)				<=	fetch(0)	xor	(fetch(2) and fetch(1));
	opd(2	downto	1)	<=	fetch(2	downto	1);
	opd(3)				<=	fetch(3)	xor	(fetch(5) and fetch(4));
	opd(5	downto	4)	<=	fetch(5	downto	4);
	op16(2	downto	0)	<=	"101"	when	(fetch(5	downto	4) = "11")	else	('0' & fetch(5	downto	4)); 
	
	wire09	<=	stage(0) & mux_flag(to_integer(unsigned(fetch(4 downto 3))));
	wire28	<=	stage(0) & cpu_status(4);
	wire11	<=	stage(1	downto	0) & op16(2);
	wire19	<=	stage(1	downto	0) & cpu_status(4);
	wire36	<=	stage(1	downto	0) & cpu_status(4) & op0mem;
	wire21	<=	stage(1	downto	0) & cpu_status(4) & op1mem;
	wire24	<=	stage(1	downto	0) & cpu_status(4) & op1mem & op0mem;
	wire30	<=	('1' & not(stage(0)))			when	(op16(2) = '1')	else	"00";	--	alu80/sp
	wire23	<=	("01" & not(fetch(3)) & "01")	when	(fetch(5) = '1')	else	("110" & fetch(4	downto	3));
	wire32	<=	not(flags(2))					when	(fetch(4) = '1')	else	'1';
	wire33	<=	(not(flags(2))	or	flags(6))	when	(fetch(4) = '1')	else	'1';
	wire08	<=	"000"		when	(tzf = '1')			else	"011";		--	NOP/ADD
	wire10	<=	"011"		when	(stage(0) = '1')	else	"001";		--	ADD/INC, post inc
	wire12	<=	'1'			when	(stage(0) = '1')	else	'X';		--	PC, lo/HI
	wire40	<=	'X'			when	(stage(0) = '1')	else	'1';		--	hi/lo
	wire26	<=	"101X1X"	when	(stage(0) = '1')	else	"001XX1";	--	flags, SP, lo/hi
	wire27	<=	"001X10"	when	(stage(0) = '1')	else	"001XX1";	--	SP, lo/hi
	wire14	<=	'1'			when	(fetch(4) = '1')	else	'X';		--	lo/hi
	wire15	<=	'X'			when	(fetch(4) = '1')	else	'1';
	wire13	<=	"011X"		when	(fetch(3) = '1')	else	"0110";		--	A
	wire16	<=	"011X"		when	(fetch(4) = '1')	else	"010X";		--	A or L
	wire17	<=	"0110"		when	(fetch(4) = '1')	else	"0101";		--	A or L
	wire34	<=	flags(6)	when	(fetch(4) = '1')	else	'1';
	wire35	<=	alu80(1)	when	(fetch(4) = '1')	else	'1';
	wire31	<=	"01100"		when	(fetch(3) = '1')	else	"01011";	--	RRD/RLD
	wire37	<=	"00"		when	(fetch(7	downto	6) = "01")	else	(not(opd(0)) & opd(0));			--	flags, hi/lo
	wire39	<=	"111X"		when	(fetch(7	downto	6) = "01")	else	('0' & opd(2	downto	0));	--	dest, tmp16 for BIT
	wire18	<=	"110X01"	when	(opd(3) = '1')	else	"110X10";		--	flags, PC, hi/lo
	wire22	<=	"010001"	when	(opd(3) = '1')	else	"010010";		--	PC, hi/lo
	wire25	<=	"010X01"	when	(opd(3) = '1')	else	"010X10";		--	PC	and	LO	or	HI
	wire29	<=	"110X"		when	(opd(5	downto	3) = "111")	else	('0' & opd(5	downto	3));		--	zero/reg
	wire38	<=	"000001"	when	(opd(0) = '1')	else	"000010";		--	lo/hi
	wire20	<=	"011"		when	(cpu_status(4) = '1')	else	"000";
	
	process	(fetch, op1mem, op0mem, stage, tzf, mux_flag, op16, opd, cpu_status, flags, m1_sig, alu80, intop, wire07, wire08, wire09, wire10, wire11, wire12, wire13, wire14,
			wire15, wire16, wire17, wire18, wire19, wire20, wire21, wire22, wire23, wire24, wire25, wire26, wire27, wire28, wire29, wire30, wire31, wire32, wire33,
			wire34, wire35, wire36, wire37, wire38, wire39, wire40)
	begin
		do_sel		<= "XX";	--	alu80	-	th	-	flags	-	alu8_do[7:0]
		alu160_sel	<= 'X';		--	regs	-	pc
		dinw_sel	<= 'X';		--	alu8out	-	di
		we		<= "XXXXXX";	--	5 = flags, 4 = PC, 3 = SP, 2 = tmpHI, 1 = hi, 0 = lo
		alu8_op		<= "XXXXX";
		alu16_op	<= "000";	--	NOP, post inc
		next_stage	<= '0';
		reg_wsel	<= "XXXX";
		reg_rsel	<= "XXXX";
		m1_sig		<= '1';
		mreq_sig	<= '1';
		wr_sig		<= '0';		--	1 = Write, 0 = Read
		halt_sig	<= '0';
		iorq_sig	<= '0';
		status		<= "00XXXXX00000";
		fetch98		<= "00";
		
		wire07	<= fetch(7 downto 6) & op1mem & op0mem;
		case wire07 is
			when "0000" | "0001" | "0010" | "0011" | "0100" | "1000" | "1100" => xmask <= '1';
			when others => xmask <=	'0';
		end	case;
		--------------------------------------------------------------------
		--	block	00
		--------------------------------------------------------------------
		case	fetch(9	downto	6)	is
			when	"0000"	=>
				case	fetch(3	downto	0)	is
					--------------------------------------------------------------------
					--	NOP, EX AF, AF', DJNZ, JR, JR c
					--------------------------------------------------------------------
					when	"0000" | "1000"	=>
						case	fetch(5	downto	4)	is
							when	"00"	=>							--	NOP, EX AF, AF'
								do_sel		<=	"XX";
								alu160_sel	<=	'1';					--	PC
								we			<=	"010X00";				--	PC
								status(0)	<=	fetch(3);
							when	"01"	=>
								if	(stage(0)	= '0')	then			--	DJNZ, JR - stage1
									alu160_sel	<=	'1';				--	pc
									we			<=	"010100";			--	PC, tmpHI
									if	(fetch(3)	= '0')	then
										alu8_op		<=	"01010";		--	DEC, for tzf only
										reg_wsel	<=	"0000";			--	B
									end	if;
									next_stage	<=	'1';
									m1_sig		<=	'0';
								elsif	(fetch(3) = '1') then			--	JR - stage2
									alu160_sel	<=	'1';				--	pc
									we			<=	"010X00";			--	PC
									alu16_op	<=	"011";				--	ADD
								else									--	DJNZ - stage2
									alu160_sel	<=	'1';				--	pc
									dinw_sel	<=	'0';				--	alu80_out
									we			<=	"010X10";			--	PC, hi
									alu8_op		<=	"01010";			--	DEC
									alu16_op	<=	wire08;				--	NOP/ADD
									reg_wsel	<=	"0000";				--	B
								end	if;
							when	"10" | "11"	=>						--	JR cc, stage1, stage2
								case	wire09	is
									when	"00" | "11"	=>
										alu160_sel	<=	'1';			--	pc
										we			<=	"010X00";		--	PC
										alu16_op	<=	wire10;			--	ADD/ INC, post inc
									when	"01"	=>
										alu160_sel	<=	'1';			--	pc
										we			<=	"010100";		--	PC, tmpHI
										next_stage	<=	'1';
										m1_sig		<=	'0';
									when	others	=>	null;
								end	case;
							when	others	=>	null;
						end	case;
						--------------------------------------------------------------------
						--	LD rr,nn
						--------------------------------------------------------------------
					when	"0001"	=>									--	LD rr,nn, stage1
						case	wire11	is
							when	"000" | "001" | "010" | "011"	=>	--	LD rr,nn, stage1,2
								alu160_sel	<=	'1';					--	pc
								dinw_sel	<=	'1';					--	DI
								we			<=	("010X" & wire12 & not(stage(0)));	--	PC, lo/HI
								next_stage	<=	'1';
								reg_wsel	<=	(op16 & 'X');
								m1_sig		<=	'0';
							when	"100" | "111"	=>					--	BC, DE, HL, stage3, SP stage4
								alu160_sel	<=	'1';					--	pc
								we			<=	"010X00";				--	PC
							when	"101"	=>							--	SP stage3
								alu160_sel	<=	'0';					--	regs
								we			<=	"001X00";				--	SP
								alu16_op	<=	"100";					--	NOP
								next_stage	<=	'1';
								reg_rsel	<=	"101X";					--	tmpSP
								m1_sig		<=	'0';
								mreq_sig	<=	'0';
							when	others	=>	null;
						end	case;
						--------------------------------------------------------------------
						--	LD (BC) A -  LD (DE) A - LD (nn) HL, LD (nn),A
						--	LD A (BC) -  LD A (DE) - LD HL (nn), LD A (nn)
						--------------------------------------------------------------------
					when	"0010" | "1010"	=>
						case	stage(2	downto	0)	is
							when	"000"	=>
								if	(fetch(5) = '0') then				--	LD (BC) A, LD (DE) A - stage1
									if	(fetch(3) = '1') then
										dinw_sel<=	'1';				--	DI
									else
										do_sel	<=	"00";				--	alu80
									end	if;
									alu160_sel	<=	'0';				--	regs
									we			<=	("000X" & fetch(3) & 'X');	--	hi
									next_stage	<=	'1';
									reg_wsel	<=	wire13;				--	A
									reg_rsel	<=	(op16 & 'X');
									m1_sig		<=	'0';
									wr_sig			<=	not(fetch(3));
								else									--	LD (nn) A - LD (nn) HL - stage 1
									alu160_sel	<=	'1';				--	PC
									dinw_sel	<=	'1';				--	DI
									we			<=	"010XX1";			--	PC, lo
									next_stage	<=	'1';
									reg_wsel	<=	"111X";
									m1_sig		<=	'0';
								end	if;
							when	"001"	=>
								if	(fetch(5) = '0') then				--	LD (BC), A, LD (DE), A - stage2
									alu160_sel	<=	'1';				--	pc
									we			<=	"010X00";			--	PC
								else									--	LD (nn),A  - LH (nn),HL - stage 2
									alu160_sel	<=	'1';				--	pc
									dinw_sel	<=	'1';				--	DI
									we			<=	"010X10";			--	PC, hi
									next_stage	<=	'1';
									reg_wsel	<=	"111X";
									m1_sig		<=	'0';
								end	if;
							when	"010"	=>
								alu160_sel	<=	'0';					--	regs
								reg_rsel	<=	"111X";
								m1_sig		<=	'0';
								wr_sig			<=	not(fetch(3));
								next_stage	<=	'1';
								if	(fetch(3) = '1') then				--	LD A (nn)  - LD HL (nn) - stage 3
									dinw_sel	<=	'1';				--	DI
									we			<=	("000X" & wire14 & wire15);	--	lo/hi
									reg_wsel	<=	wire16;				--	A or L
								else									--	LD (nn),A  - LD (nn),HL - stage 3
									do_sel		<=	"00";				--	alu80
									we			<=	"000X00";			--	nothing
									reg_wsel	<=	wire17;				--	A or L
								end	if;
							when	"011"	=>
								if	(fetch(4) = '1') then				--	LD (nn),A - stage 4
									alu160_sel	<=	'1';				--	pc
									we			<=	"010X00";			--	PC
								else
									reg_rsel	<=	"111X";
									m1_sig		<=	'0';
									wr_sig			<=	not(fetch(3));
									alu160_sel	<=	'0';				--	regs
									alu16_op	<=	"001";				--	INC
									next_stage	<=	'1';
									if	(fetch(3) = '1') then			--	LD HL (nn) - stage 4
										dinw_sel	<=	'1';			--	DI
										we			<=	"000X10";		--	hi
										reg_wsel	<=	"010X";			--	H
									else								--	LD (nn),HL - stage 4
										do_sel		<=	"00";			--	alu80
										we			<=	"000X00";		--	nothing
										reg_wsel	<=	"0100";			--	H
									end	if;
								end	if;
							when	"100"	=>							--	LD (nn),HL - stage 5
								alu160_sel	<=	'1';					--	pc
								we			<=	"010X00";				--	PC
							when	others	=>	null;
						end	case;
						--------------------------------------------------------------------
						--	inc/dec rr
						--------------------------------------------------------------------
					when	"0011" | "1011"	=>
						if	(not(stage(0)) = '1')	then
							if	(op16(2) = '1')	then					--	SP - stage1
								alu160_sel	<=	'0';					--	regs
								we			<=	"001X00";				--	SP
								alu16_op	<=	(fetch(3) & '0' & fetch(3));	--	post inc, dec
								next_stage	<=	'1';
								reg_rsel	<=	"101X";					--	sp
								m1_sig		<=	'0';
								mreq_sig	<=	'0';
							else										--	BC, DE, HL - stage 1
								alu160_sel	<=	'1';					--	pc
								dinw_sel	<=	'0';					--	a;u8_out
								we			<=	"010X11";				--	PC, hi, lo
								alu8_op		<=	("0111" & fetch(3));	--	INC16 / DEC16
								reg_wsel	<=	(op16 & '0');			--	hi
								reg_rsel	<=	(op16 & '1');			--	lo
							end	if;
						else											--	SP, stage2
							alu160_sel		<=	'1';					--	pc
							we				<=	"010X00";				--	PC
						end	if;
						--------------------------------------------------------------------
						--	inc/dec 8
						--------------------------------------------------------------------
					when	"0100" | "0101" | "1100" | "1101"	=>
						if	(op1mem = '0')	then						--	regs
							dinw_sel	<=	'0';						--	alu8out
							alu160_sel	<=	'1';						--	pc
							we			<=	wire18;						--	flags, PC, hi/lo
							alu8_op		<=	("010" & fetch(0) & '0');	--	inc / dec
							reg_wsel	<=	('0' & opd(5	downto	3));
						else
							case	wire19	is
								when	"000" | "011"	=>				--	(HL) - stage1, (X) - stage2
									alu160_sel	<=	'0';				--	regs
									dinw_sel	<=	'1';				--	DI
									we			<=	"000001";			--	lo
									alu16_op	<=	wire20;
									next_stage	<=	'1';
									reg_wsel	<=	"011X";				--	tmpLO
									reg_rsel	<=	"010X";				--	HL
									m1_sig		<=	'0';
								when	"001"	=>						--	(X) - stage1
									alu160_sel	<=	'1';				--	pc
									we			<=	"010100";			--	PC, tmpHI
									next_stage	<=	'1';
									m1_sig		<=	'0';
								when	"010" | "101"	=>				--	(HL) stage2, (X) - stage3
									do_sel		<=	"11";				--	alu80_out
									alu160_sel	<=	'0';				--	regs
									we			<=	"100X0X";			--	flags
									alu8_op		<=	("010" & fetch(0) & '0');	--	inc / dec
									alu16_op	<=	wire20;
									next_stage	<=	'1';
									reg_wsel	<=	"0111";				--	tmpLO
									reg_rsel	<=	"010X";				--	HL
									m1_sig		<=	'0';
									wr_sig			<=	'1';
								when	"100" | "111"	=>				--	(HL) - stage3, (X) - stage 4
									alu160_sel	<=	'1';				--	pc
									we			<=	"010X00";			--	PC
								when	others	=>	null;
							end	case;
						end	if;
						--------------------------------------------------------------------
						--	ld r/(HL-X), n
						--------------------------------------------------------------------
					when	"0110" | "1110"	=>
						case	wire21	is
							when	"0000" | "0001" | "0010" | "0111"	=>	--	r, (HL) - stage1, (X) - stage2 (read n)
								alu160_sel	<=	'1';					--	pc
								dinw_sel	<=	'1';					--	DI
								we			<=	wire22;					--	PC, hi/lo
								next_stage	<=	'1';
								reg_wsel	<=	('0' & opd(5	downto	4) & 'X');
								m1_sig		<=	'0';
							when	"0100" | "0110" | "1001" | "1111"	=>	--	r - stage2, (HL) - stage3, (X) - stage4
								alu160_sel	<=	'1';					--	pc
								we			<=	"010X00";				--	PC
							when	"0101" | "1011"	=>					--	(HL) - stage2, (X) - stage3
								do_sel		<=	"00";					--	alu80
								alu160_sel	<=	'0';					--	regs
								we			<=	"000X0X";				--	nothing
								alu16_op	<=	wire20;
								next_stage	<=	'1';
								reg_wsel	<=	"0111";					--	tmpLO
								reg_rsel	<=	"010X";					--	HL
								m1_sig		<=	'0';
								wr_sig			<=	'1';
							when	"0011"	=>							--	(X) - stage1
								alu160_sel	<=	'1';					--	pc
								we			<=	"010100";				--	PC, tmpHI
								next_stage	<=	'1';
								m1_sig		<=	'0';
							when	others	=>	null;
						end	case;
						--------------------------------------------------------------------
						--	rlca, rrca, rla, rra, daa, cpl, scf, ccf
						--------------------------------------------------------------------
					when	"0111" | "1111"	=>
						case	fetch(5	downto	3)	is
							when	"000" | "001" | "010" | "011" | "100" | "101"	=>	--	rlca, rrca, rla, rra, daa, cpl
								alu160_sel	<=	'1';					--	pc
								dinw_sel	<=	'0';					--	alu8out
								we			<=	"110X1X";				--	flags, PC, hi
								alu8_op		<=	wire23;
								reg_wsel	<=	"0110";					--	A
							when	"110" | "111"	=>					--	scf, ccf
								alu160_sel	<=	'1';					--	pc
								dinw_sel	<=	'0';					--	alu8out
								we			<=	"110X0X";				--	flags, PC
								alu8_op		<=	("1010" & not(fetch(3)));
							when	others	=>	null;
						end	case;
						--------------------------------------------------------------------
						--	add 16
						--------------------------------------------------------------------
					when	"1001"	=>
						if	(stage(0) = '0')	then
							dinw_sel	<=	'0';						--	alu8out
							we			<=	"100X01";					--	flags, lo
							alu8_op		<=	"10000";					--	add16lo
							next_stage	<=	'1';
							reg_wsel	<=	"0101";						--	L
							reg_rsel	<=	(op16 & '1');
							m1_sig		<=	'0';
							mreq_sig	<=	'0';
						else
							alu160_sel	<=	'1';						--	pc
							dinw_sel	<=	'0';						--	alu8out
							we			<=	"110X10";					--	flags, PC, hi
							alu8_op		<=	"10001";					--	add16hi
							reg_wsel	<=	"0100";						--	H
							reg_rsel	<=	(op16 & '0');
						end	if;
					when	others	=>	null;
				end	case;
				
				
				
				--------------------------------------------------------------------
				--	block 01 LD8
				--------------------------------------------------------------------
			when	"0001"	=>
				case	wire24	is
					when	"00000" | "00100" | 						--	LD r, r 1st stage
						"01001" | 										--	LD r, (HL) 2nd stage
						"10101"	=>										--	LD r, (X) 3rd stage
						alu160_sel	<=	'1';							--	PC
						dinw_sel	<=	'0';							--	alu8
						we			<=	wire25;							--	PC and LO or HI
						alu8_op		<=	"11101";						--	PASS D1
						reg_wsel	<=	('0' & opd(5	downto	4) & 'X');
						reg_rsel	<=	('0' & opd(2	downto	0));
					when	"00001" | 									--	LD r, (HL) 1st stage
						"01101"	=>										--	LD r, (X) 2nd stage
						alu160_sel	<=	'0';							--	regs
						dinw_sel	<=	'1';							--	DI
						we			<=	"000X01";						--	LO
						alu16_op	<=	wire20;							--	ADD - NOP
						next_stage	<=	'1';
						reg_wsel	<=	"011X";							--	A - tmpLO
						reg_rsel	<=	"010X";							--	HL
						m1_sig		<=	'0';
					when	"00101" | 									--	LD r, (X) 1st stage
						"00110"	=>										--	LD (X), r 1st stage
						alu160_sel	<=	'1';							--	pc
						we			<=	"010100";						--	PC, tmpHI
						next_stage	<=	'1';
						m1_sig		<=	'0';
					when	"00010" | 									--	LD (HL), r 1st stage
						"01110"	=>										--	LD (X), r 2nd stage
						do_sel		<=	"00";							--	alu80
						alu160_sel	<=	'0';							--	regs
						we			<=	"000X00";						--	no write
						alu16_op	<=	wire20;							--	ADD - NOP
						next_stage	<=	'1';
						reg_wsel	<=	('0' & opd(2	downto	0));
						reg_rsel	<=	"010X";							--	HL
						m1_sig		<=	'0';
						wr_sig			<=	'1';
					when	"01010" | 									--	LD (HL), r 2nd stage
						"10110"	=>										--	LD (X), r 3rd stage
						alu160_sel	<=	'1';							--	pc
						we			<=	"010X00";						--	PC
					when	"00011" | "00111"	=>						--	HALT
						we			<=	"000X00";						--	no write
						m1_sig		<=	'0';
						mreq_sig	<=	'0';
						halt_sig	<=	'1';
					when	others	=>	null;
				end	case;
				--------------------------------------------------------------------
				--	block 10 arith8
				--------------------------------------------------------------------
			when	"0010"	=>
				case	wire36	is
					when	"0000" | "0010" | 							--	OP r,r 1st stage
						"0101" | 										--	OP r, (HL) 2nd stage
						"1011"	=>										--	OP r, (X) 3rd stage
						alu160_sel	<=	'1';							--	pc
						dinw_sel	<=	'0';							--	alu8out
						we			<=	("110X" & not(fetch(5) and fetch(4) and fetch(3)) & 'X');	--	flags, PC, hi
						alu8_op		<=	("00" & fetch(5	downto	3));
						reg_wsel	<=	"0110";							--	A
						reg_rsel	<=	('0' & opd(2	downto	0));
					when	"0001" | 									--	OP r, (HL) 1st stage
						"0111"	=>										--	OP r, (X) 2nd stage
						alu160_sel	<=	'0';							--	HL
						dinw_sel	<=	'1';							--	DI
						we			<=	"000X01";						--	lo
						alu16_op	<=	wire20;							--	ADD - NOP
						next_stage	<=	'1';
						reg_wsel	<=	"011X";							--	A-tmpLO
						reg_rsel	<=	"010X";							--	HL
						m1_sig		<=	'0';
					when	"0011"	=>									--	OP r, (X) 1st stage
						alu160_sel	<=	'1';							--	pc
						we			<=	"010100";						--	PC, tmpHI
						next_stage	<=	'1';
						m1_sig		<=	'0';
					when	others	=>	null;
				end	case;
				--------------------------------------------------------------------
				--	block 11
				--------------------------------------------------------------------
			when	"0011"	=>
				case	fetch(3	downto	0)	is
					--------------------------------------------------------------------
					--	RET cc
					--------------------------------------------------------------------
					when	"0000" | "1000"	=>
						case	stage(1	downto	0)	is
							when	"00" | "01"	=>						--	stage1, stage2
								if	(mux_flag(to_integer(unsigned(fetch(5 downto 3)))) = '1') then	--	POP addr
									alu160_sel	<=	'0';				--	regs
									dinw_sel	<=	'1';				--	DI
									we			<=	("001X" & wire12 & not(stage(0)));	--	SP, lo/hi
									next_stage	<=	'1';
									reg_wsel	<=	"111X";				--	tmp16
									reg_rsel	<=	"101X";				--	SP
									m1_sig		<=	'0';
								else
									alu160_sel	<=	'1';				--	pc
									we			<=	"010X00";			--	PC
								end	if;
							when	"10"	=>							--	stage3
								alu160_sel	<=	'0';					--	regs
								we			<=	"010X00";				--	PC
								reg_rsel	<=	"111X";					--	tmp16
							when	others	=>	null;
						end	case;
						--------------------------------------------------------------------
						--	POP
						--------------------------------------------------------------------
					when	"0001"	=>
						case	stage(1	downto	0)	is
							when	"00" | "01"	=>
								if	(op16(2) = '1')	then				--	AF
									we			<=	wire26;				--	flags, SP, lo/hi
									reg_wsel	<=	("011" & wire12);
									if	(stage(0) = '1')	then
										alu8_op	<=	"11110";			--	FLAGS <- D0
									end	if;
								else									--	r16
									we			<=	wire27;				--	SP, lo/hi
									reg_wsel	<=	('0' & fetch(5 downto 4) & 'X');
								end	if;
								alu160_sel	<=	'0';					--	regs
								dinw_sel	<=	'1';					--	DI
								next_stage	<=	'1';
								reg_rsel	<=	"101X";					--	SP
								m1_sig		<=	'0';
							when	"10"	=>							--	stage3
								alu160_sel	<=	'1';					--	PC
								we			<=	"010X00";				--	PC
							when	others	=>	null;
						end	case;
						--------------------------------------------------------------------
						--	JP cc
						--------------------------------------------------------------------
					when	"0010" | "1010"	=>
						case	stage(1	downto	0)	is
							when	"00" | "01"	=>						--	stage1,2
								if	(mux_flag(to_integer(unsigned(fetch(5 downto 3)))) = '1') then
									alu160_sel	<=	'1';				--	pc
									dinw_sel	<=	'1';				--	DI
									we			<=	("010X" & wire12 & not(stage(0)));	--	PC, hi/lo
									next_stage	<=	'1';
									reg_wsel	<=	"111X";				--	tmp7
									m1_sig		<=	'0';
								else
									alu160_sel	<=	'1';				--	pc
									we			<=	"010X00";			--	PC
									alu16_op	<=	"010";				--	add2
								end	if;
							when	"10"	=>							--	stage3
								alu160_sel	<=	'0';					--	regs
								we			<=	"010X00";				--	PC
								reg_rsel	<=	"111X";					--	tmp7
							when	others	=>	null;
						end	case;
						--------------------------------------------------------------------
						--	JP, OUT (n) A, EX (SP) HL, DI
						--------------------------------------------------------------------
					when	"0011"	=>
						case	fetch(5	downto	4)	is
							when	"00"	=>							--	JP
								case	stage(1	downto	0)	is
									when	"00" | "01"	=>				--	stage1,2 - read addr
										alu160_sel	<=	'1';			--	pc
										dinw_sel	<=	'1';			--	DI
										we			<=	("010X" & wire12 & not(stage(0)));	--	PC, hi/lo
										next_stage	<=	'1';
										reg_wsel	<=	"111X";			--	tmp7
										m1_sig		<=	'0';
									when	"10"	=>					--	stage3
										alu160_sel	<=	'0';			--	regs
										we			<=	"010X00";		--	PC
										reg_rsel	<=	"111X";			--	tmp7
									when	others	=>	null;
								end	case;
							when	"01"	=>							--	OUT (n), a - stage1 - read n
								case	stage(1	downto	0)	is
									when	"00"	=>
										alu160_sel	<=	'1';			--	pc
										dinw_sel	<=	'1';			--	DI
										we			<=	"010X01";		--	PC, lo
										next_stage	<=	'1';
										reg_wsel	<=	"011X";			--	tmpLO
										m1_sig		<=	'0';
									when	"01"	=>					--	stage2 - OUT
										do_sel		<=	"00";			--	alu80
										alu160_sel	<=	'0';			--	regs
										we			<=	"000X00";		--	nothing
										next_stage	<=	'1';
										reg_wsel	<=	"0110";			--	A
										reg_rsel	<=	"011X";			--	A-tmpLO
										m1_sig		<=	'0';
										mreq_sig	<=	'0';
										wr_sig			<=	'1';
										iorq_sig		<=	'1';
									when	"10"	=>					--	stage3 - fetch
										alu160_sel	<=	'1';			--	PC
										we			<=	"010X00";		--	PC
									when	others	=>	null;
								end	case;
							when	"10"	=>							--	EX (SP), HL
								case	stage(2	downto	0)	is
									when	"000" | "001"	=>			--	stage1,2 - pop tmp16
										alu160_sel	<=	'0';			--	regs
										dinw_sel	<=	'1';			--	DI
										we			<=	("001X" & wire12 & not(stage(0)));	--	SP, lo/hi
										next_stage	<=	'1';
										reg_wsel	<=	"111X";			--	tmp16
										reg_rsel	<=	"101X";			--	SP
										m1_sig		<=	'0';
									when	"010" | "011" =>			--	stage3,4 - push hl
										do_sel		<=	"00";			--	alu80
										alu160_sel	<=	'0';			--	regs
										we			<=	"001X00";		--	SP
										alu16_op	<=	"101";			--	dec
										next_stage	<=	'1';
										reg_wsel	<=	("010" & stage(0));	--	H/L
										reg_rsel	<=	"101X";			--	SP
										m1_sig		<=	'0';
										wr_sig			<=	'1';
									when	"100" | "101"	=>			--	stage5,6
										alu160_sel	<=	'1';			--	pc
										dinw_sel	<=	'0';			--	alu8out
										we			<=	('0' & stage(0) & "0X" & wire12 & not(stage(0)));	--	PC, lo/hi
										alu8_op		<=	"11101";		--	pass D1
										next_stage	<=	not(stage(0));
										reg_wsel	<=	"010X";			--	HL
										reg_rsel	<=	("111" & not(stage(0)));	--	tmp16
										m1_sig		<=	stage(0);
										mreq_sig	<=	stage(0);
									when	others	=>	null;
								end	case;
							when	"11"	=>							--	DI
								alu160_sel				<=	'1';		--	PC
								we						<=	"010X00";	--	PC
								status(11)				<=	'1';		--	set IFF flags
								status(7	downto	6)	<=	"00";
							when	others	=>	null;
						end	case;
						--------------------------------------------------------------------
						--	CALL cc
						--------------------------------------------------------------------
					when	"0100" | "1100"	=>
						case	stage(2	downto	0)	is
							when	"000" | "001"	=>				--	stage 1,2 - load addr
								if	(mux_flag(to_integer(unsigned(fetch(5 downto 3)))) = '1') then
									alu160_sel	<=	'1';				--	pc
									dinw_sel	<=	'1';				--	DI
									we			<=	("010X" & wire12 & not(stage(0)));	--	PC, hi/lo
									next_stage	<=	'1';
									reg_wsel	<=	"111X";				--	tmp7
									m1_sig		<=	'0';
								else
									alu160_sel	<=	'1';				--	pc
									we			<=	"010X00";			--	PC
									alu16_op	<=	"010";				--	add2
								end	if;
							when	"010" | "011"	=>				--	stage 3,4 - push pc
								do_sel		<=	('0' & stage(0));	--	pc hi/lo
								alu160_sel	<=	'0';					--	regs
								we			<=	"001X00";				--	SP
								alu16_op	<=	"101";					--	DEC
								next_stage	<=	'1';
								reg_wsel	<=	"1XXX";					--	pc
								reg_rsel	<=	"101X";					--	sp
								m1_sig		<=	'0';
								wr_sig			<=	'1';
							when	"100"	=>							--	stage5
								alu160_sel	<=	'0';					--	regs
								we			<=	"010X00";				--	PC
								reg_rsel	<=	"111X";					--	tmp7
							when	others	=>	null;
						end	case;
						--------------------------------------------------------------------
						--	PUSH
						--------------------------------------------------------------------
					when	"0101"	=>
						case	stage(1	downto	0)	is
							when	"00" | "01"	=>						--	stage1,2
								do_sel		<=	(stage(0) and op16(2)) & '0';	--	FLAGS/alu80
								alu160_sel	<=	'0';					--	regs
								we			<=	"001X00";				--	SP
								alu16_op	<=	"101";					--	dec
								next_stage	<=	'1';
								reg_wsel	<=	('0' & fetch(5 downto 4) & stage(0));
								reg_rsel	<=	"101X";					--	SP
								m1_sig		<=	'0';
								wr_sig			<=	'1';
							when	"10"	=>							--	stage3
								alu160_sel	<=	'1';					--	PC
								we			<=	"010X00";				--	PC
							when	others	=>	null;
						end	case;
						--------------------------------------------------------------------
						--	op A, n
						--------------------------------------------------------------------
					when	"0110" | "1110"	=>
						if	(stage(0) = '0')	then					--	stage1, read n
							alu160_sel	<=	'1';						--	pc
							dinw_sel	<=	'1';						--	DI
							we			<=	"010X01";					--	PC, lo
							next_stage	<=	'1';
							reg_wsel	<=	"011X";						--	tmpLO
							m1_sig		<=	'0';
						else											--	stage2
							dinw_sel	<=	'0';						--	alu8out[7:0]
							alu160_sel	<=	'1';						--	pc
							we			<=	("110X" & not(fetch(5) and fetch(4) and fetch(3)) & 'X');	--	flags, PC, hi
							alu8_op		<=	("00" & fetch(5	downto	3));
							reg_wsel	<=	"0110";						--	A
							reg_rsel	<=	"0111";						--	tmpLO
						end	if;
						--------------------------------------------------------------------
						--	RST
						--------------------------------------------------------------------
					when	"0111" | "1111"	=>
						case	stage(1	downto	0)	is
							when	"00" | "01"	=>						--	stage 1,2 - push pc
								do_sel		<=	('0' & stage(0));	--	pc hi/lo
								alu160_sel	<=	'0';					--	regs
								we			<=	"001X00";				--	SP
								alu16_op	<=	"101";					--	DEC
								next_stage	<=	'1';
								reg_wsel	<=	"1XXX";					--	pc
								reg_rsel	<=	"101X";					--	sp
								m1_sig		<=	'0';
								wr_sig			<=	'1';
							when	"10"	=>							--	stage3
								alu160_sel	<=	'0';					--	regs
								we			<=	"010X00";				--	PC
								reg_rsel	<=	"110X";					--	const
							when	others	=>	null;
						end	case;
						--------------------------------------------------------------------
						--	RET, EXX, JP (HL), LD SP HL
						--------------------------------------------------------------------
					when	"1001"	=>
						case	fetch(5	downto	4)	is
							when	"00"	=>							--	RET
								case	stage(1	downto	0)	is
									when	"00" | "01"	=>				--	stage1, stage2 - pop addr
										alu160_sel	<=	'0';			--	regs
										dinw_sel	<=	'1';			--	DI
										we			<=	("001X" & wire12 & not(stage(0)));	--	SP, lo/hi
										next_stage	<=	'1';
										reg_wsel	<=	"111X";			--	tmp16
										reg_rsel	<=	"101X";			--	SP
										m1_sig		<=	'0';
									when	"10"	=>					--	stage3 - jump
										alu160_sel	<=	'0';			--	regs
										we			<=	"010X00";		--	PC
										reg_rsel	<=	"111X";			--	tmp16
									when	others	=>	null;
								end	case;
							when	"01"	=>							--	EXX
								alu160_sel	<=	'1';					--	PC
								we			<=	"010X00";				--	PC
								status(1)	<=	'1';
							when	"10"	=>							--	JP (HL)
								alu160_sel	<=	'0';					--	regs
								we			<=	"010X00";				--	PC
								reg_rsel	<=	"010X";					--	HL
							when	"11"	=>							--	LD SP,HL
								if	(stage(0) = '0') then				--	stage1
									alu160_sel	<=	'0';				--	regs
									we			<=	"001X00";			--	SP
									alu16_op	<=	"100";				--	NOP, no post inc
									next_stage	<=	'1';
									reg_rsel	<=	"010X";				--	HL
									m1_sig		<=	'0';
									mreq_sig	<=	'0';
								else									--	stage2
									alu160_sel	<=	'1';				--	pc
									we			<=	"010X00";			--	PC
								end	if;
							when	others	=>	null;
						end	case;
						--------------------------------------------------------------------
						--	CB, IN A (n), EX DE HL, EI
						--------------------------------------------------------------------
					when	"1011"	=>
						case	fetch(5	downto	4)	is
							when	"00"	=>							--	CB prefix
								case	wire28	is
									when	"00" | "11"	=>
										alu160_sel	<=	'1';			--	PC
										we			<=	"010000";		--	PC
										fetch98		<=	"10";
									when	"01"	=>
										alu160_sel	<=	'1';			--	PC
										we			<=	"010100";		--	PC, tmpHI
										next_stage	<=	'1';
										m1_sig		<=	'0';
									when	others	=>	null;
								end	case;
							when	"01"	=>							--	IN A, (n)
								case	stage(1	downto	0)	is
									when	"00"	=>					--	stage1 - read n
										alu160_sel	<=	'1';			--	pc
										dinw_sel	<=	'1';			--	DI
										we			<=	"010X01";		--	PC, lo
										next_stage	<=	'1';
										reg_wsel	<=	"011X";			--	tmpLO
										m1_sig		<=	'0';
									when	"01"	=>					--	stage2 - IN
										alu160_sel	<=	'0';			--	regs
										dinw_sel	<=	'1';			--	DI
										we			<=	"000X1X";		--	hi
										next_stage	<=	'1';
										reg_wsel	<=	"011X";			--	A
										reg_rsel	<=	"011X";			--	A - tmpLO
										m1_sig		<=	'0';
										mreq_sig	<=	'0';
										iorq_sig		<=	'1';
									when	"10"	=>					--	stage3 - fetch
										alu160_sel	<=	'1';			--	PC
										we			<=	"010X00";		--	PC
									when	others	=>	null;
								end	case;
							when	"10"	=>							--	EX DE, HL
								alu160_sel	<=	'1';					--	PC
								we			<=	"010X00";				--	PC
								if	(cpu_status(1) = '1')	then
									status(3)	<=	'1';
								else
									status(2)	<=	'1';
								end	if;
							when	"11"	=>							--	EI
								alu160_sel	<=	'1';					--	PC
								we			<=	"010X00";				--	PC
								status(11)	<=	'1';
								status(7	downto	6)	<=	"11";
							when	others	=>	null;
						end	case;
						--------------------------------------------------------------------
						--	CALL , IX, ED, IY
						--------------------------------------------------------------------
					when	"1101"	=>
						case	fetch(5	downto	4)	is
							when	"00"	=>							--	CALL
								case	stage(2	downto	0)	is
									when	"000" | "001"	=>			--	stage 1,2 - load addr
										alu160_sel	<=	'1';			--	pc
										dinw_sel	<=	'1';			--	DI
										we			<=	("010X" & wire12 & not(stage(0)));	--	PC, hi/lo
										next_stage	<=	'1';
										reg_wsel	<=	"111X";			--	tmp7
										m1_sig		<=	'0';
									when	"010" | "011"	=>			--	stage 3,4 - push pc
										do_sel		<=	('0' & stage(0));	--	pc hi/lo
										alu160_sel	<=	'0';			--	regs
										we			<=	"001X00";		--	SP
										alu16_op	<=	"101";			--	DEC
										next_stage	<=	'1';
										reg_wsel	<=	"1XXX";			--	pc
										reg_rsel	<=	"101X";			--	sp
										m1_sig		<=	'0';
										wr_sig			<=	'1';
									when	"100"	=>					--	stage5 - jump
										alu160_sel	<=	'0';			--	regs
										we			<=	"010X00";		--	PC
										reg_rsel	<=	"111X";			--	tmp7
									when	others	=>	null;
								end	case;
							when	"01"	=>							--	DD - IX
								alu160_sel	<=	'1';					--	PC
								we			<=	"010X00";				--	PC
								status(5	downto	4)	<=	"01";
							when	"10"	=>							--	ED prefix
								alu160_sel	<=	'1';					--	PC
								we			<=	"010X00";				--	PC
								fetch98		<=	"01";
							when	"11"	=>							--	FD - IY
								alu160_sel	<=	'1';					--	PC
								we			<=	"010X00";				--	PC
								status(5	downto	4)	<=	"11";
							when	others	=>	null;
						end	case;
					when	others	=>	null;
				end	case;
				--------------------------------------------------------------------
				--	ED + opcode
				--------------------------------------------------------------------
			when	"0100" | "0111"	=>									--	ED + 2'b00, ED + 2'b11 	= NOP
				alu160_sel	<=	'1';									--	PC
				we			<=	"010X00";								--	PC
			when	"0101"	=>
				case	fetch(2	downto	0)	is
					--------------------------------------------------------------------
					--	in r (C)
					--------------------------------------------------------------------
					when	"000"	=>
						if	(stage(0) = '0')	then
							alu160_sel	<=	'0';						--	regs
							dinw_sel	<=	'1';						--	DI
							we			<=	("000X" & not(opd(3)) & opd(3));	--	hi/lo
							next_stage	<=	'1';
							reg_wsel	<=	('0' & opd(5	downto	4) & 'X');
							reg_rsel	<=	"000X";						--	BC
							m1_sig		<=	'0';
							mreq_sig	<=	'0';
							iorq_sig		<=	'1';
						else
							alu160_sel	<=	'1';						--	pc
							we			<=	"110X00";					--	flag, PC
							alu8_op		<=	"11101";					--	IN
							reg_rsel	<=	('0' & opd(5 downto 3));	--	reg
						end	if;
						--------------------------------------------------------------------
						--	out (C) r
						--------------------------------------------------------------------
					when	"001"	=>
						if	(stage(0) = '0')	then
							do_sel		<=	"00";						--	alu80
							alu160_sel	<=	'0';						--	regs
							we			<=	"000X00";					--	nothing
							next_stage	<=	'1';
							reg_wsel	<=	wire29;						--	zero/reg
							reg_rsel	<=	"000X";						--	BC
							m1_sig		<=	'0';
							mreq_sig	<=	'0';
							wr_sig			<=	'1';
							iorq_sig		<=	'1';
						else
							alu160_sel	<=	'1';						--	pc
							we			<=	"010X00";					--	PC
						end	if;
						--------------------------------------------------------------------
						--	SBC16, ADC16
						--------------------------------------------------------------------
					when	"010"	=>
						if	(stage(0) = '0')	then					--	stage1
							dinw_sel	<=	'0';						--	alu8out
							we			<=	"100X01";					--	flags, lo
							alu8_op		<=	("000" & not(fetch(3)) & '1');	--	SBC/ADC
							next_stage	<=	'1';
							reg_wsel	<=	"0101";						--	L
							reg_rsel	<=	(op16 & '1');
							m1_sig		<=	'0';
							mreq_sig	<=	'0';
						else
							alu160_sel	<=	'1';						--	pc
							dinw_sel	<=	'0';						--	alu8out
							we			<=	"110X10";					--	flags, PC, hi
							alu8_op		<=	("000" & not(fetch(3)) & '1');
							reg_wsel	<=	"0100";						--	H
							reg_rsel	<=	(op16 & '0');
						end	if;
						--------------------------------------------------------------------
						--	LD (nn) r16, ld r16 (nn)
						--------------------------------------------------------------------
					when	"011"	=>
						case	stage(2	downto	1)	is
							when	"00"	=>							--	stage 1,2 - read address
								alu160_sel	<=	'1';					--	pc
								dinw_sel	<=	'1';					--	DI
								we			<=	("010X" & wire12 & not(stage(0)));	--	PC, hi/lo
								next_stage	<=	'1';
								reg_wsel	<=	"111X";					--	tmp16
								m1_sig		<=	'0';
							when	"01"	=>
								alu160_sel	<=	'0';					--	regs
								next_stage	<=	'1';
								alu16_op	<=	("00" & stage(0));
								reg_rsel	<=	"111X";					--	tmp16
								reg_wsel	<=	(op16 & not(stage(0)));
								m1_sig		<=	'0';
								if	(fetch(3) = '1')	then			--	LD rr, (nn) - stage3,4
									dinw_sel	<=	'1';				--	DI
									we			<=	("000X" & wire12 & not(stage(0)));	--	lo
								else									--	LD (nn), rr - stage3,4
									do_sel	<=	wire30;					--	alu80/sp
									we		<=	"000X00";				--	nothing
									wr_sig		<=	'1';
								end	if;
							when	"10"	=>							--	stage5
								if	((fetch(3) and op16(2) and not(stage(0))) = '1') then	--	LD sp, (nn) - stage5
									alu160_sel	<=	'0';				--	regs
									we			<=	"001X00";			--	SP
									alu16_op	<=	"100";				--	NOP
									next_stage	<=	'1';
									reg_rsel	<=	"101X";				--	tmp SP
									m1_sig		<=	'0';
									mreq_sig	<=	'0';
								else
									alu160_sel	<=	'1';				--	pc
									we			<=	"010X00";			--	PC
								end	if;
							when	others	=>	null;
						end	case;
						--------------------------------------------------------------------
						--	NEG
						--------------------------------------------------------------------
					when	"100"	=>
						alu160_sel	<=	'1';							--	pc
						dinw_sel	<=	'0';							--	alu8out
						we			<=	"110X10";						--	flags, PC, hi
						alu8_op		<=	"11111";						--	NEG
						reg_wsel	<=	"011X";							--	A
						reg_rsel	<=	"0110";							--	A
						--------------------------------------------------------------------
						--	RETN, RETI
						--------------------------------------------------------------------
					when	"101"	=>
						case	stage(1	downto	0)	is
							when	"00" | "01"	=>						--	stage1, stage2 - pop addr
								alu160_sel	<=	'0';					--	regs
								dinw_sel	<=	'1';					--	DI
								we			<=	("001X" & wire12 & not(stage(0)));	--	SP, lo/hi
								next_stage	<=	'1';
								reg_wsel	<=	"111X";					--	tmp16
								reg_rsel	<=	"101X";					--	SP
								m1_sig		<=	'0';
							when	"10"	=>							--	stage3 - jump
								alu160_sel	<=	'0';					--	regs
								we			<=	"010X00";				--	PC
								reg_rsel	<=	"111X";					--	tmp16
								status(11)	<=	'1';
								status(7	downto	6)	<=	(cpu_status(7) & cpu_status(7));
							when	others	=>	null;
						end	case;
						--------------------------------------------------------------------
						--	IM
						--------------------------------------------------------------------
					when	"110"	=>
						alu160_sel	<=	'1';							--	PC
						we			<=	"010X00";						--	PC
						status(10	downto	8)	<=	('1' & fetch(4	downto	3));
						--------------------------------------------------------------------
						--	LD I A, LD R A, LD A I, LD A R, RRD, RLD
						--------------------------------------------------------------------
					when	"111"	=>
						case	fetch(5	downto	4)	is
							when	"00"	=>							--	LD I/R A
								alu160_sel	<=	'1';					--	pc
								dinw_sel	<=	'0';					--	alu8out
								we			<=	("010X" & not(fetch(3)) & fetch(3));	--	PC, hi/lo
								alu8_op		<=	"11101";				--	pass D1
								reg_wsel	<=	"100X";					--	IR
								reg_rsel	<=	"0110";					--	A
							when	"01"	=>							--	LD A I/R
								alu160_sel	<=	'1';					--	pc
								dinw_sel	<=	'0';					--	alu8out
								we			<=	"110X1X";				--	flags, PC, hi
								alu8_op		<=	"11101";				--	PASS D1
								reg_wsel	<=	"011X";					--	A
								reg_rsel	<=	("100" & fetch(3));		--	I/R
							when	"10"	=>							--	RRD, RLD
								case	stage(1	downto	0)	is
									when	"00"	=>					--	stage1, read data
										alu160_sel	<=	'0';			--	regs
										dinw_sel	<=	'1';			--	DI
										we			<=	"000X01";		--	lo
										next_stage	<=	'1';
										reg_wsel	<=	"011X";			--	tmpLO
										reg_rsel	<=	"010X";			--	HL
										m1_sig		<=	'0';
									when	"01"	=>					--	stage2, shift data
										dinw_sel	<=	'0';			--	alu8out
										we			<=	"100X11";		--	flags, hi, lo
										alu8_op		<=	wire31;			--	RRD/RLD
										next_stage	<=	'1';
										reg_wsel	<=	"0110";			--	A
										reg_rsel	<=	"0111";			--	tmpLO
										m1_sig		<=	'0';
										mreq_sig	<=	'0';
									when	"10"	=>					--	stage3 - write
										do_sel		<=	"00";			--	alu80
										alu160_sel	<=	'0';			--	regs
										we			<=	"000X0X";		--	nothing
										next_stage	<=	'1';
										reg_wsel	<=	"0111";			--	rmpLO
										reg_rsel	<=	"010X";			--	HL
										m1_sig		<=	'0';
										wr_sig			<=	'1';
									when	"11"	=>
										alu160_sel	<=	'1';			--	PC
										we			<=	"010X00";		--	PC
									when	others	=>	null;
								end	case;
							when	"11"	=>							--	NOP
								alu160_sel	<=	'1';					--	PC
								we			<=	"010X00";				--	PC
							when	others	=>	null;
						end	case;
					when	others	=>	null;
				end	case;
				--------------------------------------------------------------------
				--	block instructions
				--------------------------------------------------------------------
			when	"0110"	=>
				if	(fetch(5) = '1'	and fetch(2) = '0')	then
					case	fetch(1	downto	0)	is
						when	"00"	=>								--	LDI, LDD, LDIR, LDDR
							case	stage(1	downto	0)	is
								when	"00"	=>						--	stage1, read data, inc/dec HL
									alu160_sel	<=	'0';				--	regs
									dinw_sel	<=	'0';				--	alu8out
									we			<=	"100111";			--	flags, tmpHI, hi, lo
									alu8_op		<=	("0111" & fetch(3));	--	INC/DEC16
									next_stage	<=	'1';
									reg_wsel	<=	"0100";				--	H
									reg_rsel	<=	"0101";				--	L
									m1_sig		<=	'0';
								when	"01"	=>						--	stage2, dec BC
									dinw_sel	<=	'0';				--	alu8out
									we			<=	"100011";			--	flags, hi, lo (affects PF only)
									alu8_op		<=	"01111";			--	DEC
									next_stage	<=	'1';
									reg_wsel	<=	"0000";				--	B
									reg_rsel	<=	"0001";				--	C
									m1_sig		<=	'0';
									mreq_sig	<=	'0';
								when	"10"	=>						--	stage2, write data, inc/dec DE
									do_sel		<=	"01";				--	th
									alu160_sel	<=	'0';				--	regs
									dinw_sel	<=	'0';				--	alu8out
									we			<=	"000X11";			--	hi, lo
									alu8_op		<=	("0111" & fetch(3));	--	INC / DEC
									next_stage	<=	wire32;
									reg_wsel	<=	"0010";				--	D
									reg_rsel	<=	"0011";				--	E
									m1_sig		<=	'0';
									wr_sig			<=	'1';
								when	"11"	=>
									alu160_sel	<=	'1';				--	PC
									we			<=	"010X00";			--	PC
								when	others	=>	null;
							end	case;
						when	"01"	=>								--	CPI, CPD, CPIR, CPDR
							case	stage(1	downto	0)	is
								when	"00"	=>						--	stage1, load data
									alu160_sel	<=	'0';				--	regs
									dinw_sel	<=	'1';				--	DI
									we			<=	"000X01";			--	lo
									next_stage	<=	'1';
									reg_wsel	<=	"011X";				--	tmpLO
									reg_rsel	<=	"010X";				--	HL
									m1_sig		<=	'0';
								when	"01"	=>						--	stage2, CP
									we			<=	"100X0X";			--	flags
									alu8_op		<=	"00111";			--	CP
									next_stage	<=	'1';
									reg_wsel	<=	"0110";				--	A
									reg_rsel	<=	"0111";				--	tmpLO
									m1_sig		<=	'0';
									mreq_sig	<=	'0';
								when	"10"	=>						--	stage3, dec BC
									dinw_sel	<=	'0';				--	alu8out
									we			<=	"100X11";			--	flags, hi, lo
									alu8_op		<=	"01111";			--	DEC16
									next_stage	<=	'1';
									reg_wsel	<=	"0000";				--	B
									reg_rsel	<=	"0001";				--	C
									m1_sig		<=	'0';
									mreq_sig	<=	'0';
								when	"11"	=>						--	stage4, inc/dec HL
									alu160_sel	<=	'1';				--	pc
									dinw_sel	<=	'0';				--	alu8out
									m1_sig		<=	wire33;
									we			<=	('0' & m1_sig & "0X11");	--	PC, hi, lo
									alu8_op		<=	("0111" & fetch(3));	--	INC/DEC
									reg_wsel	<=	"0100";				--	H
									reg_rsel	<=	"0101";				--	L
									mreq_sig	<=	m1_sig;
								when	others	=>	null;
							end	case;
						when	"10"	=>								--	INI, IND, INIR, INDR
							case	stage(1	downto	0)	is
								when	"00"	=>						--	stage1, in data, dec B
									alu160_sel	<=	'0';				--	regs
									dinw_sel	<=	'0';				--	alu8out
									we			<=	"100110";			--	flags, tmpHI, hi
									alu8_op		<=	"01010";			--	DEC
									next_stage	<=	'1';
									reg_wsel	<=	"0000";				--	B
									reg_rsel	<=	"000X";				--	BC
									m1_sig		<=	'0';
									mreq_sig	<=	'0';
									iorq_sig		<=	'1';
								when	"01"	=>						--	stage2, write data, inc/dec HL
									do_sel		<=	"01";				--	th
									alu160_sel	<=	'0';				--	regs
									dinw_sel	<=	'0';				--	alu8out
									we			<=	"000X11";			--	hi, lo
									alu8_op		<=	("0111" & fetch(3));	--	INC / DEC
									next_stage	<=	wire34;
									reg_wsel	<=	"0100";				--	H
									reg_rsel	<=	"0101";				--	L
									m1_sig		<=	'0';
									wr_sig			<=	'1';
								when	"10"	=>						--	stage3
									alu160_sel	<=	'1';				--	pc
									we			<=	"010X00";			--	PC
								when	others	=>	null;
							end	case;
							--------------------------------------------------------------------
							--	OUTI/OUTD/OTIR/OTDR
							--------------------------------------------------------------------
						when	"11"	=>
							case	stage(1	downto	0)	is
								when	"00"	=>						--	stage1, load data, inc/dec HL
									alu160_sel	<=	'0';				--	regs
									dinw_sel	<=	'0';				--	alu8out
									we			<=	"000111";			--	tmpHI, hi, lo
									alu8_op		<=	("0111" & fetch(3));	--	INC / DEC
									next_stage	<=	'1';
									reg_wsel	<=	"0100";				--	H
									reg_rsel	<=	"0101";				--	L
									m1_sig		<=	'0';
								when	"01"	=>						--	stage2, out data, dec B
									do_sel		<=	"01";				--	th
									alu160_sel	<=	'0';				--	regs
									dinw_sel	<=	'0';				--	alu8out
									we			<=	"100X10";			--	lags, hi
									alu8_op		<=	"01010";			--	DEC
									next_stage	<=	wire35;
									reg_wsel	<=	"0000";				--	B
									reg_rsel	<=	"000X";				--	BC
									m1_sig		<=	'0';
									mreq_sig	<=	'0';
									iorq_sig		<=	'1';
									wr_sig			<=	'1';
								when	"10"	=>						--	stage3
									alu160_sel	<=	'1';				--	pc
									we			<=	"010X00";			--	PC
								when	others	=>	null;
							end	case;
						when	others	=>	null;
					end	case;
				else													--	NOP
					alu160_sel	<=	'1';								--	PC
					we			<=	"010X00";							--	PC
				end	if;
				--------------------------------------------------------------------
				--	CB + opcode
				--------------------------------------------------------------------
			when	"1000" | "1001" | "1010" | "1011"	=>				--	CB class (rot/shift, bit/res/set)
				case	wire36	is
					when	"0000"	=>									--	execute reg-reg
						dinw_sel	<=	'0';							--	alu8out
						alu160_sel	<=	'1';							--	pc
						we			<=	(not(fetch(7)) & "10X" & wire37);	--	flags, hi/lo
						alu8_op		<=	"11100";						--	BIT
						reg_wsel	<=	('0' & opd(2	downto	0));
					when	"0001" | "0010" | "0011"	=>				--	stage1, (HL-X) - read data
						alu160_sel	<=	'0';							--	regs
						dinw_sel	<=	'1';							--	DI
						we			<=	wire38;							--	lo/hi
						alu16_op	<=	wire20;							--	ADD - NOP
						next_stage	<=	'1';
						reg_wsel	<=	wire39;							--	dest, tmp16 for BIT
						reg_rsel	<=	"010X";							--	HL
						m1_sig		<=	'0';
					when	"0101" | "0110" | "0111"	=>				--	stage2 (HL-X) - execute, write
						case	fetch(7	downto	6)	is
							when	"00" | "10" | "11"	=>				--	exec + write
								dinw_sel	<=	'0';					--	alu8out
								do_sel		<=	"11";					--	alu8out[7:0]
								alu160_sel	<=	'0';					--	regs
								we			<=	(not(fetch(7)) & "00X" & not(opd(0)) & opd(0));	--	flags, hi/lo
								alu8_op		<=	"11100";
								alu16_op	<=	wire20;
								next_stage	<=	'1';
								reg_wsel	<=	('0' & opd(2	downto	0));
								reg_rsel	<=	"010X";					--	HL
								m1_sig		<=	'0';
								wr_sig			<=	'1';
							when	"01"	=>							--	BIT, no write
								alu160_sel	<=	'1';					--	pc
								we			<=	"110XXX";				--	flags, PC
								alu8_op		<=	"11100";				--	BIT
								reg_wsel	<=	("111" & opd(0));		--	tmp
							when	others	=>	null;
						end	case;
					when	"1001" | "1010" | "1011"	=>				--	(HL-X) - load next op
						alu160_sel	<=	'1';							--	pc
						we			<=	"010X00";						--	PC
					when	others	=>	null;
				end	case;
				--------------------------------------------------------------------
				--	RST, NMI, INT
				--------------------------------------------------------------------
			when	"1110"	=>											--	RESET: IR <- 0, IM <- 0, IFF1,IFF2 <- 0, pC <- 0
				alu160_sel	<=	'0';									--	regs
				dinw_sel	<=	'0';									--	alu8out
				we			<=	"X1XX11";								--	PC, hi, lo
				alu8_op		<=	"11101";								--	pass D1
				alu16_op	<=	"100";									--	NOP
				reg_wsel	<=	"010X";									--	IR
				reg_rsel	<=	"110X";									--	const
				m1_sig		<=	'0';
				mreq_sig	<=	'0';
				status(11	downto	6)	<=	"110000";					--	IM0, DI
			when	"1101"	=>											--	NMI
				case	stage(1	downto	0)	is
					when	"00"	=>
						alu160_sel	<=	'1';							--	pc
						we			<=	"010X00";						--	PC
						alu16_op	<=	intop;							--	DEC/DEC2 (if block instruction interrupted)
						next_stage	<=	'1';
						m1_sig		<=	'0';
						mreq_sig	<=	'0';
					when	"01" | "10"	=>
						do_sel		<=	('0' & not(stage(0)));			--	pc hi/lo
						alu160_sel	<=	'0';							--	regs
						we			<=	"001X00";						--	SP
						alu16_op	<=	"101";							--	DEC
						next_stage	<=	'1';
						reg_wsel	<=	"1XXX";							--	pc
						reg_rsel	<=	"101X";							--	sp
						m1_sig		<=	'0';
						wr_sig			<=	'1';
						status(11)	<=	'1';
						status(7 downto 6)	<=	(cpu_status(7) & '0');	--	reset IFF1
					when	"11"	=>
						alu160_sel	<=	'0';							--	regs
						we			<=	"010X00";						--	PC
						reg_rsel	<=	"110X";							--	const
					when	others	=>	null;
				end	case;
			when	"1100"	=>											--	INT
				case	cpu_status(9	downto	8)	is
					when	"00" | "01" | "10"	=>						--	IM0, IM1
						alu160_sel	<=	'1';							--	pc
						we			<=	"010X00";						--	PC
						alu16_op	<=	intop;							--	DEC/DEC2 (if block instruction interrupted)
						mreq_sig	<=	'0';
						iorq_sig		<=	'1';
						status(11)	<=	'1';
						status(7	downto	6)	<=	"00";				--	reset IFF1, IFF2
					when	"11"	=>									--	IM2
						case	stage(2	downto	0)	is
							when	"000"	=>
								alu160_sel	<=	'1';					--	pc
								dinw_sel	<=	'1';					--	DI
								we			<=	"010X01";				--	PC, lo
								alu16_op	<=	intop;					--	DEC/DEC2 (if block instruction interrupted)
								next_stage	<=	'1';
								reg_wsel	<=	"100X";					--	Itmp
								mreq_sig	<=	'0';
								iorq_sig		<=	'1';
								status(11)	<=	'1';
								status(7	downto	6)	<=	"00";		--	reset IFF1, IFF2
							when	"001" | "010"	=>					--	push bc
								do_sel		<=	('0' & not(stage(0)));	--	pc hi/lo
								alu160_sel	<=	'0';					--	regs
								we			<=	"001X00";				--	SP
								alu16_op	<=	"101";					--	DEC
								next_stage	<=	'1';
								reg_wsel	<=	"1XXX";					--	pc
								reg_rsel	<=	"101X";					--	sp
								m1_sig		<=	'0';
								wr_sig			<=	'1';
							when	"011" | "100"	=>					--	read address
								alu160_sel	<=	'0';					--	regs
								dinw_sel	<=	'1';					--	DI
								we			<=	("0X0X" & wire40 & stage(0));	--	hi/lo
								alu16_op	<=	("00" & not(stage(0)));	--	NOP/INC
								next_stage	<=	'1';
								reg_wsel	<=	"111X";					--	tmp16
								reg_rsel	<=	"1000";					--	I-Itmp
								m1_sig		<=	'0';
							when	"101"	=>							--	jump
								alu160_sel	<=	'0';					--	regs
								we			<=	"010X00";				--	PC
								reg_rsel	<=	"111X";					--	tmp16
							when	others	=>	null;
						end	case;
					when	others	=>	null;
				end	case;
			when	others	=>	null;
		end	case;
	end	process;
	
	--------------------------------------------------------------------
	--	ALU
	--------------------------------------------------------------------
	--	FLAGS: S Z X1 N X2 PV N C
	--	OP[4:0]
	--	00000	-	ADD	D0,D1
	--	00001	-	ADC	D0,D1
	--	00010	-	SUB	D0,D1
	--	00011	-	SBC	D0,D1
	--	00100	-	AND	D0,D1
	--	00101	-	XOR	D0,D1
	--	00110	-	OR	D0,D1
	--	00111	-	CP	D0,D1
	--	01000	-	INC	D0
	--	01001	-	CPL	D0
	--	01010	-	DEC	D0
	--	01011	-	RRD
	--	01100	-	RLD
	--	01101	-	DAA
	--	01110	-	INC16
	--	01111	-	DEC16
	--	10000	-	ADD16LO
	--	10001	-	ADD16HI
	--	10010	-	
	--	10011	-	
	--	10100	-	CCF, pass D0
	--	10101	-	SCF, pass D0
	--	10110	-	
	--	10111	-	
	--	11000	-	RLCA	D0
	--	11001	-	RRCA	D0
	--	1010	-	RLA		D0
	--	11011	- 	RRA		D0
	--	11100	-	{ROT, BIT, SET, RES} D0,EXOP 
	--				RLC		D0		C 		<-- D0 <-- D0[7]
	--	            RRC		D0		D0[0] 	--> D0 --> C
	--	            RL		D0		C 		<-- D0 <-- C
	--	            RR		D0		C 		--> D0 --> C
	--	            SLA		D0		C 		<-- D0 <-- 0
	--	            SRA		D0		D0[7] 	--> D0 --> C
	--				SLL		D0		C 		<-- D0 <-- 1
	--				SRL		D0		0 		--> D0 --> C
	--	11101	-	IN, pass D1
	--	11110	-	FLAGS <- D0
	--	11111	-	NEG	D1	
	
	exop		<=	fetch(8	downto	3);
	overflow	<=	(d0mux(7)	and	d1mux(7)	and	not(sum(7)))	or	(not(d0mux(7))	and	not(d1mux(7))	and	sum(7));
	sum(3	downto	0)	<=	wire69(3 downto 0);
	sum(8	downto	4)	<=	('0' & d0mux(7	downto	4) + d1mux(7	downto	4) + ("000" & hf));
	d0mux	<=	"00000000"	when	(alu8_op(4	downto	1) = "1111")	else	alu80;
	d1mux	<=	not(d1mux_wir2)	when	(alu8_op(1) = '1')	else	d1mux_wir2;
	wire69	<=	('0' & d0mux(3	downto	0) + d1mux(3	downto	0) + ("000" & cin));
	hf		<=	wire69(4);
	parity	<=	not(alu8_do(15) xor alu8_do(14) xor alu8_do(13) xor alu8_do(12) xor alu8_do(11) xor alu8_do(10) xor alu8_do(9) xor alu8_do(8));
	zero	<=	'1' when (alu8_do(15	downto	8) = "00000000") else '0';
	wire51	<=	alu8_op(4	downto	2);
	wire52	<=	alu8_op(2	downto	0) & flags(0);
	wire53	<=	exop(2	downto	0)	when	(alu8_op(3) = '1')	else	alu8_op(2	downto	0);
	wire54	<=	flags(0)	when	(alu8_op(3) = '1')	else	(sum(8)	xor	alu8_op(1));		--	inc/dec
	wire55	<=	(zero	and	flags(6))	when	((exop(5)	and	wire05) = '1')	else	zero;	--	adc16/sbc16
	wire56	<=	flags(0)	when	(exop(5) = '1')	else	not(sum(8));						--	CPI/D/R
	wire57	<=	(alu80	xor	alu81)	when	(alu8_op(0) = '1')	else	(alu80	or	alu81);
	wire58	<=	"1111111111111111"	when	(alu8_op(0) = '1')	else	"0000000000000001";
	wire59	<=	'0'	when	(reg_wsel(2) = '1')	else	flags(1);
	wire60	<=	'0'	when	(reg_wsel(2) = '1')	else	flags(4);
	wire61	<=	'1'	when	(alu8_op(0) = '1')	else	not(flags(0));
	wire62	<=	'0'	when	(alu8_op(0) = '1')	else	flags(0);
	wire63	<=	alu8_op(2) & exop(4	downto	3);
	wire64	<=	exop(0)		when	(alu8_op(2) = '1')	else	alu8_op(0);							--	right
	wire65	<=	zero	when	(exop(3) = '1')	else	parity;
	wire66	<=	(wire65)	when	(alu8_op(2) = '1')	else	flags(2);
	wire67	<=	zero	when	(alu8_op(2) = '1')	else	flags(6);
	wire68	<=	alu8_do(15)	when	(alu8_op(2) = '1')	else	flags(7);
	wire70	<=	'1' when (alu8_do	/=	"0000000000000000") else '0';
	
	process	(wire51, wire52, wire53, wire54, wire55, wire56, wire57, wire58, wire59, wire60, wire61, wire62, wire63, wire64, wire66, wire67, wire68, wire70, alu8_op, alu81, daaadjust,
			flags, exop, alu80, sum, overflow, alu8_do, hf, wire05, zero, parity, cdaa, hdaa, reg_wsel(2), csin, dbit)
	begin
		alu8_do		<=	"XXXXXXXXXXXXXXXX";
		alu8_flags	<=	"XXXXXXXX";
		case	wire51	is
			when	"000" | "001" | "100" | "111"	=>	d1mux_wir2	<=	alu81;
			when	"010"							=>	d1mux_wir2	<=	"00000001";
			when	"011"							=>	d1mux_wir2	<=	daaadjust;				--	DAA
			when	"110" | "101"					=>	d1mux_wir2	<=	"XXXXXXXX";
			when	others	=>	null;
		end	case;
		
		case	wire52	is
			when	"0000" | "0001" | "0010" | "0111" | "1000" | "1001" | "1010" | "1011" | "1100" | "1101"	=>	cin	<=	'0';
			when	"0011" | "0100" | "0101" | "0110" | "1110" | "1111"										=>	cin	<=	'1';
			when	others	=>	null;
		end	case;
		
		case	exop(3	downto	0)	is
			when	"0000"	=>	dbit	<=	"11111110";
			when	"0001"	=>	dbit	<=	"11111101";
			when	"0010"	=>	dbit	<=	"11111011";
			when	"0011"	=>	dbit	<=	"11110111";
			when	"0100"	=>	dbit	<=	"11101111";
			when	"0101"	=>	dbit	<=	"11011111";
			when	"0110"	=>	dbit	<=	"10111111";
			when	"0111"	=>	dbit	<=	"01111111";
			when	"1000"	=>	dbit	<=	"00000001";
			when	"1001"	=>	dbit	<=	"00000010";
			when	"1010"	=>	dbit	<=	"00000100";
			when	"1011"	=>	dbit	<=	"00001000";
			when	"1100"	=>	dbit	<=	"00010000";
			when	"1101"	=>	dbit	<=	"00100000";
			when	"1110"	=>	dbit	<=	"01000000";
			when	"1111"	=>	dbit	<=	"10000000";
			when	others	=>	null;
		end	case;
		
		case	wire53	is
			when	"000" | "101"	=>	csin	<=	alu80(7);
			when	"001"			=>	csin	<=	alu80(0);
			when	"010" | "011"	=>	csin	<=	flags(0);
			when	"100" | "111"	=>	csin	<=	'0';
			when	"110"			=>	csin	<=	'1';
			when	others	=>	null;
		end	case;
		
		case	alu8_op(4	downto	0)	is
			--	ADD, ADC, SUB, SBC, INC, DEC
			when	"00000" | "00001" | "00010" | "00011" | "01000" | "01010"	=>
				alu8_do(15	downto	8)	<=	sum(7	downto	0);
				alu8_do(7	downto	0)	<=	sum(7	downto	0);
				alu8_flags(0)	<=	wire54;				--	inc/dec
				alu8_flags(1)	<=	alu8_op(1);
				alu8_flags(2)	<=	overflow;
				alu8_flags(3)	<=	alu8_do(11);
				alu8_flags(4)	<=	hf	xor	alu8_op(1);
				alu8_flags(5)	<=	alu8_do(13);
				alu8_flags(6)	<=	wire55;				--	adc16/sbc16
				alu8_flags(7)	<=	alu8_do(15);
				--	ADD16LO, ADD16HI
			when	"10000" | "10001"	=>
				alu8_do(15	downto	8)	<=	sum(7	downto	0);
				alu8_do(7	downto	0)	<=	sum(7	downto	0);
				alu8_flags(0)	<=	sum(8);
				alu8_flags(1)	<=	alu8_op(1);
				alu8_flags(2)	<=	flags(2);
				alu8_flags(3)	<=	alu8_do(11);
				alu8_flags(4)	<=	hf	xor	alu8_op(1);
				alu8_flags(5)	<=	alu8_do(13);
				alu8_flags(6)	<=	flags(6);
				alu8_flags(7)	<=	flags(7);
				--	CP
			when	"00111"	=>
				alu8_do(15	downto	8)	<=	sum(7	downto	0);
				alu8_flags(0)	<=	wire56;				--	CPI/D/R
				alu8_flags(1)	<=	alu8_op(1);
				alu8_flags(2)	<=	overflow;
				alu8_flags(3)	<=	alu81(3);
				alu8_flags(4)	<=	not(hf);
				alu8_flags(5)	<=	alu81(5);
				alu8_flags(6)	<=	zero;
				alu8_flags(7)	<=	alu8_do(15);
				--	NEG
			when	"11111"	=>
				alu8_do(15	downto	8)	<=	sum(7	downto	0);
				alu8_flags(0)	<=	not(sum(8));
				alu8_flags(1)	<=	alu8_op(1);
				alu8_flags(2)	<=	overflow;
				alu8_flags(3)	<=	alu8_do(11);
				alu8_flags(4)	<=	not(hf);
				alu8_flags(5)	<=	alu8_do(13);
				alu8_flags(6)	<=	zero;
				alu8_flags(7)	<=	alu8_do(15);
				--	AND
			when	"00100"	=>
				alu8_do(15	downto	8)	<=	alu80	and	alu81;
				alu8_flags(0)	<=	'0';
				alu8_flags(1)	<=	'0';
				alu8_flags(2)	<=	parity;
				alu8_flags(3)	<=	alu8_do(11);
				alu8_flags(4)	<=	'1';
				alu8_flags(5)	<=	alu8_do(13);
				alu8_flags(6)	<=	zero;
				alu8_flags(7)	<=	alu8_do(15);
				--	XOR, OR
			when	"00101" | "00110"	=>
				alu8_do(15	downto	8)	<=	wire57;
				alu8_flags(0)	<=	'0';
				alu8_flags(1)	<=	'0';
				alu8_flags(2)	<=	parity;
				alu8_flags(3)	<=	alu8_do(11);
				alu8_flags(4)	<=	'0';
				alu8_flags(5)	<=	alu8_do(13);
				alu8_flags(6)	<=	zero;
				alu8_flags(7)	<=	alu8_do(15);
				--	CPL
			when	"01001"	=>
				alu8_do(15	downto	8)	<=	not(alu80);
				alu8_flags(0)	<=	flags(0);
				alu8_flags(1)	<=	'1';
				alu8_flags(2)	<=	flags(2);
				alu8_flags(3)	<=	alu8_do(11);
				alu8_flags(4)	<=	'1';
				alu8_flags(5)	<=	alu8_do(13);
				alu8_flags(7	downto	6)	<=	flags(7	downto	6);
				--	RLD, RRD
			when	"01011" | "01100"	=>
				if	(alu8_op(0) = '1')	then
					alu8_do	<=	(alu80(7	downto	4) & alu81(3	downto	0) & alu80(3	downto	0) & alu81(7	downto	4));
				else
					alu8_do	<=	(alu80(7	downto	4) & alu81(7	downto	0) & alu80(3	downto	0));
				end	if;
				alu8_flags(0)	<=	flags(0);
				alu8_flags(1)	<=	'0';
				alu8_flags(2)	<=	parity;
				alu8_flags(3)	<=	alu8_do(11);
				alu8_flags(4)	<=	'0';
				alu8_flags(5)	<=	alu8_do(13);
				alu8_flags(6)	<=	zero;
				alu8_flags(7)	<=	alu8_do(15);
				--	DAA
			when	"01101"	=>
				alu8_do(15	downto	8)	<=	sum(7	downto	0);
				alu8_flags(0)	<=	cdaa;
				alu8_flags(1)	<=	flags(1);
				alu8_flags(2)	<=	parity;
				alu8_flags(3)	<=	alu8_do(11);
				alu8_flags(4)	<=	hdaa;
				alu8_flags(5)	<=	alu8_do(13);
				alu8_flags(6)	<=	zero;
				alu8_flags(7)	<=	alu8_do(15);
				--	inc/dec 16
			when	"01110" | "01111"	=>
				alu8_do	<=	(alu80 & alu81) + (wire58);
				alu8_flags(0)	<=	flags(0);
				alu8_flags(1)	<=	wire59;
				alu8_flags(2)	<=	wire70;
				alu8_flags(3)	<=	flags(3);
				alu8_flags(4)	<=	wire60;
				alu8_flags(5)	<=	flags(5);
				alu8_flags(6)	<=	flags(6);
				alu8_flags(7)	<=	flags(7);
				--	CCF, SCF
			when	"10100" | "10101"	=>
				alu8_do(15	downto	8)	<=	alu80;
				alu8_flags(0)	<=	wire61;
				alu8_flags(1)	<=	'0';
				alu8_flags(2)	<=	flags(2);
				alu8_flags(3)	<=	alu8_do(11);
				alu8_flags(4)	<=	wire62;
				alu8_flags(5)	<=	alu8_do(13);
				alu8_flags(6)	<=	flags(6);
				alu8_flags(7)	<=	flags(7);
				--	ROT, BIT, RES, SET
			when	"11000" | "11001" | "11010" | "11011" | "11100"	=>
				case	wire63	is
					--	rot - shift
					when	"000" | "001" | "010" | "011" | "100"	=>
						if	(wire64 = '1')	then		--	right
							alu8_do(15	downto	8)	<=	csin & alu80(7 downto 1);
							alu8_flags(0)			<=	alu80(0);
						else							--	left
							alu8_flags(0)			<=	alu80(7);
							alu8_do(15	downto	8)	<=	alu80(6 downto 0) & csin;
						end	if;
						--	BIT, RES 
					when	"101" | "110"	=>
						alu8_flags(0)			<=	flags(0);
						alu8_do(15	downto	8)	<=	alu80	and	dbit;
						--	SET
					when	"111"	=>
						alu8_flags(0)			<=	flags(0);
						alu8_do(15	downto	8)	<=	alu80	or	dbit;
					when	others	=>	null;
				end	case;
				alu8_do(7	downto	0)	<=	alu8_do(15	downto	8);
				alu8_flags(1)	<=	'0';
				alu8_flags(2)	<=	wire66;
				alu8_flags(3)	<=	alu8_do(11);
				alu8_flags(4)	<=	alu8_op(2)	and	exop(3);
				alu8_flags(5)	<=	alu8_do(13);
				alu8_flags(6)	<=	wire67;
				alu8_flags(7)	<=	wire68;
				--	IN, pass D1
			when	"11101"	=>
				alu8_do	<=	(alu81 & alu81);
				alu8_flags(0)	<=	flags(0);
				alu8_flags(1)	<=	'0';
				alu8_flags(2)	<=	parity;
				alu8_flags(3)	<=	alu8_do(11);
				alu8_flags(4)	<=	'0';
				alu8_flags(5)	<=	alu8_do(13);
				alu8_flags(6)	<=	zero;
				alu8_flags(7)	<=	alu8_do(15);
				--	flags	<-	D0
			when	"11110"	=>
				alu8_flags	<=	alu80;
			when	others	=>	null;
		end	case;
	end	process;
	
	--------------------------------------------------------------------
	--	ALU16
	--------------------------------------------------------------------
	process	(alu16_op, alu161)
	begin
		--	0-NOP, 1-INC, 2-INC2, 3-ADD, 4-NOP, 5-DEC, 6-DEC2
		case	alu16_op	is
			when	"000"	=>	mux	<=	"0000000000000000";	--	post inc
			when	"001"	=>	mux	<=	"0000000000000001";	--	post inc
			when	"010"	=>	mux	<=	"0000000000000010";	--	post inc
			when	"011"	=>	mux	<=	(alu161(7) & alu161(7) & alu161(7) & alu161(7) & alu161(7) & alu161(7) & alu161(7) & alu161(7) & alu161(7 downto 0));	--	post inc			
			when	"100"	=>	mux	<=	"0000000000000000";	--	no post inc
			when	"101"	=>	mux	<=	"1111111111111111";	--	no post inc
			when	"110"	=>	mux	<=	"1111111111111110";	--	no post inc
			when	others	=>	mux	<=	"XXXXXXXXXXXXXXXX";
		end	case;
	end	process;
	
	addr_sig	<=	alu160 + mux;
	
	--------------------------------------------------------------------
	--	DAA
	--------------------------------------------------------------------
	h08		<=	'1' when (alu80(7	downto	4)	<	"1001") else '0';
	h09		<=	'1' when (alu80(7	downto	4)	<	"1010") else '0';
	l09		<=	'1' when (alu80(3	downto	0)	<	"1010") else '0';
	l05		<=	'1' when (alu80(3	downto	0)	<	"0110") else '0';
	
	wire01	<=	flags(0) & h08 & h09 & flags(4) & l09;
	wire02	<=	flags(1) & adj(1	downto	0);
	wire03	<=	flags(0) & h08 & h09 & l09;
	wire04	<=	flags(1) & flags(4) & l05 & l09;
	
	process	(flags, h08, h09, l09, adj, l05, wire01, wire02, wire03, wire04)
	begin
		case	wire01	is
			when	"00101" | "01101"																=>	adj	<=	"00";
			when	"00111" | "01111"																=>	adj	<=	"01";
			when	"01000" | "01010" | "01100" | "01110"											=>	adj	<=	"01";
			when	"00001" | "01001"																=>	adj	<=	"10";
			when	"10001" | "10101" | "11001" | "11101"											=>	adj	<=	"10";
			when	"10011" | "10111" | "11011" | "11111"											=>	adj	<=	"11";
			when	"10000" | "10010" | "10100" | "10110" | "11000" | "11010" | "11100" | "11110"	=>	adj	<=	"11";
			when	"00000" | "00010" | "00100" | "00110"											=>	adj	<=	"11";
			when	"00011" | "01011"																=>	adj	<=	"11";
			when	others	=>	null;
		end	case;
		
		case	wire02	is
			when	"000"	=>	daaadjust	<=	"00000000";
			when	"001"	=>	daaadjust	<=	"00000110";
			when	"010"	=>	daaadjust	<=	"01100000";
			when	"011"	=>	daaadjust	<=	"01100110";
			when	"100"	=>	daaadjust	<=	"00000000";
			when	"101"	=>	daaadjust	<=	"11111010";
			when	"110"	=>	daaadjust	<=	"10100000";
			when	"111"	=>	daaadjust	<=	"10011010";
			when	others	=>	null;
		end	case;
		
		case	wire03	is
			when	"0011" | "0111"	=>	cdaa	<=	'0';
			when	"0100" | "0110"	=>	cdaa	<=	'0';
			when	"0000" | "0010"	=>	cdaa	<=	'1';
			when	"0001" | "0101"	=>	cdaa	<=	'1';
			when	"1000" | "1001" | "1010" | "1011" | "1100" | "1101" | "1110" | "1111"	=>	cdaa	<=	'1';
			when	others	=>	null;
		end	case;
		
		case	wire04	is
			when	"0001" | "0011" | "0101" | "0111"	=>	hdaa	<=	'0';
			when	"0000" | "0010" | "0100" | "0110"	=>	hdaa	<=	'1';
			when	"1000" | "1001" | "1010" | "1011"	=>	hdaa	<=	'0';
			when	"1100" | "1101"	=>	hdaa	<=	'0';
			when	"1110" | "1111"	=>	hdaa	<=	'1';
			when	others	=>	null;
		end	case;
	end	process;
	
	--------------------------------------------------------------------
	--	Register select
	--------------------------------------------------------------------
	rstatus		<=	cpu_status(7	downto	0);	--	0=af-af', 1=exx, 2=hl-de, 3=hl'-de', 4=hl-ixy, 5=ix-iy, 6=IFF1, 7=IFF2
	alu80		<=	rdow(7	downto	0)		when	(reg_wsel(0) = '1')	else	rdow(15	downto	8);
	alu81		<=	mux_rdor(7	downto	0)	when	(reg_rsel(0) = '1')	else	mux_rdor(15	downto	8);
	alu160		<=	pc	when	(alu160_sel = '1')	else	mux_rdor;
	flags		<=	flg(15	downto	8)	when	(rstatus(0) = '1')	else	flg(7	downto	0);
	const		<=	("00" & fetch(5	downto	3) & "000")	when	(fetch(7) = '1')	else	"01100110";					--	RST/NMI	address
	addr1		<=	addr_sig + ("000000000000000" & not(alu16_op(2)));
	flgmux		<=	alu8_flags(7	downto	3) & rstatus(7) &	alu8_flags(1 downto 0)	when	(reg_rsel(3	downto	1) = "100")	else	alu8_flags(7	downto	3) & alu8_flags(2) &	alu8_flags(1 downto 0);
	
	process	(CLK, CLKEN, we, alu161, DI, sp, addr1, pc, r, alu8_do, m1_sig, rstatus, flg, flgmux)
	begin
		if	(CLK'event	and	CLK = '1')	then
			if	(CLKEN = '1')	then
				if	(we(2) = '1')	then	alu161	<=	DI;	end	if;
				if	(we(3) = '1')	then	sp	<=	addr1;	end	if;
				if	(we(4) = '1')	then	pc	<=	addr1;	end	if;
				if	(reg_wsel(3	downto	1) = "100"	and we(0) =	'1')	then
					r	<=	alu8_do(7	downto	0);
				elsif	(m1_sig = '1')	then
					r(6	downto	0)	<=	r(6	downto	0) + "0000001";
				end	if;
				if	(we(5) = '1')	then
					if	(rstatus(0) = '1')	then
						flg(15	downto	8)	<=	flgmux;
					else
						flg(7	downto	0)	<=	flgmux;
					end	if;
				end	if;
			end	if;
		end	if;
	end	process;
	
	wire43	<=	reg_wsel(3) & do_sel;
	wire44	<=	wire46 & reg_rsel(3	downto	0);
	wire46	<= '1' when alu16_op = "100" else '0';
	wire45	<=	(rstatus(5) & (rstatus(4)	and	XMASK) & rstatus(3	downto	0));
	wire47	<=	wire45(5 downto 4) & wire45(to_integer(unsigned(wire49)));
	wire49	<=	'1' & wire45(1);
	
	process	(wire43, dout_sig, alu80, alu161, flags, alu8_do, pc, sp, r, wire44, mux_rdor, rdor, const)
	begin
		case	wire43	is
			when	"000"	=>	dout_sig	<=	alu80;
			when	"001"	=>	dout_sig	<=	alu161;
			when	"010"	=>	dout_sig	<=	flags;
			when	"011"	=>	dout_sig	<=	alu8_do(7	downto	0);
			when	"100"	=>	dout_sig	<=	pc(15	downto	8);
			when	"101"	=>	dout_sig	<=	pc(7	downto	0);
			when	"110"	=>	dout_sig	<=	sp(15	downto	8);
			when	"111"	=>	dout_sig	<=	sp(7	downto	0);
			when	others	=>	null;
		end	case;
		case	wire44	is
			when	"01001" | "11001"						=>	mux_rdor	<=	(rdor(15	downto	8) & r);
			when	"01010" | "01011"						=>	mux_rdor	<=	sp;
			when	"01100" | "01101" | "11100" | "11101"	=>	mux_rdor	<=	("00000000" & const);
			when	others									=>	mux_rdor	<=	rdor;
		end	case;
	end	process;
	
--------------------------------------------------------------[V1.2 08-07-2013] begin
	wire48	<=	rstatus(5	downto	4) & rstatus(to_integer(unsigned(wire50)));
	wire50	<=	'1' & rstatus(1);
	process	(reg_rsel, rstatus, wire48, wire50, reg_0l, reg_1l, reg_2l, reg_3l, reg_4l, reg_5l, reg_6l, reg_7l, reg_8l, reg_9l, reg_al, reg_bl, reg_cl, reg_dl,
			reg_0h, reg_1h, reg_2h, reg_3h, reg_4h, reg_5h, reg_6h, reg_7h, reg_8h, reg_9h, reg_ah, reg_bh, reg_ch, reg_dh)
	begin
		case	reg_rsel(3	downto	1)	is
			when	"000"	=>
				if rstatus(1) = '0' then
					rdor	<=	reg_0h & reg_0l;	-- BC
				else
					rdor	<=	reg_8h & reg_8l;	-- BC'
				end if;
			when	"001"	=>	
				if	(rstatus(to_integer(unsigned(wire50))) = '1')	then
					if rstatus(1) = '0' then
						rdor	<=	reg_2h & reg_2l;	-- HL
					else
						rdor	<=	reg_ah & reg_al;	-- HL'
					end if;
				else
					if rstatus(1) = '0' then
						rdor	<=	reg_1h & reg_1l;	-- DE
					else
						rdor	<=	reg_9h & reg_9l;	-- DE'
					end if;
				end	if;
			when	"010"	=>
				case	wire48	is
					when	"000" | "100"	=>
						if rstatus(1) = '0' then
							rdor	<=	reg_2h & reg_2l;	-- HL
						else
							rdor	<=	reg_ah & reg_al;	-- HL'
						end if;
					when	"001" | "101"	=>
						if rstatus(1) = '0' then
							rdor	<=	reg_1h & reg_1l;	-- DE
						else
							rdor	<=	reg_9h & reg_9l;	-- DE'
						end if;
					when	"010" | "011"	=>	rdor	<=	reg_5h & reg_5l;	-- IX
					when	"110" | "111"	=>	rdor	<=	reg_6h & reg_6l;	-- IY
					when	others	=>	null;
				end	case;
			when	"011"	=>
				if rstatus(0) = '0' then
					rdor	<=	reg_3h & reg_3l;	-- A-x
				else
					rdor	<=	reg_bh & reg_bl;	-- A'-x
				end if;
			when	"100"	=>	rdor	<=	reg_4h & reg_4l;	-- I-x
			when	"101"	=>	rdor	<=	reg_ch & reg_cl;	--	tmp	SP
			when	"110"	=>	rdor	<=	reg_dh & reg_dl;	--	zero
			when	"111"	=>	rdor	<=	reg_7h & reg_7l;	--	temp reg for BIT/SET/RES
			when	others	=>	null;
		end	case;
	end	process;	

	process	(reg_wsel, wire45, wire49, wire47, reg_0l, reg_1l, reg_2l, reg_3l, reg_4l, reg_5l, reg_6l, reg_7l, reg_8l, reg_9l, reg_al, reg_bl, reg_cl, reg_dl,
				reg_0h, reg_1h, reg_2h, reg_3h, reg_4h, reg_5h, reg_6h, reg_7h, reg_8h, reg_9h, reg_ah, reg_bh, reg_ch, reg_dh)
	begin
		case	reg_wsel(3	downto	1)		is
			when	"000"	=>
				if wire45(1) = '0' then
					rdow	<=	reg_0h & reg_0l;	-- BC
				else
					rdow	<=	reg_8h & reg_8l;	-- BC'
				end if;
			when	"001"	=>
				if	(wire45(to_integer(unsigned(wire49)))	= '1')	then
					if wire45(1) = '0' then
						rdow	<=	reg_2h & reg_2l;	-- HL
					else
						rdow	<=	reg_ah & reg_al;	-- HL'
					end if;
				else
					if wire45(1) = '0' then
						rdow	<=	reg_1h & reg_1l;	-- DE
					else
						rdow	<=	reg_9h & reg_9l;	-- DE'
					end if;
				end	if;
			when	"010"	=>
				case	wire47	is
					when	"000" | "100"	=>
						if wire45(1) = '0' then
							rdow	<=	reg_2h & reg_2l;	-- HL
						else
							rdow	<=	reg_ah & reg_al;	-- HL'
						end if;
					when	"001" | "101"	=>
						if wire45(1) = '0' then
							rdow	<=	reg_1h & reg_1l;	-- DE
						else
							rdow	<=	reg_9h & reg_9l;	-- DE'
						end if;
					when	"010" | "011"	=>	rdow	<=	reg_5h & reg_5l;	--	IX
					when	"110" | "111"	=>	rdow	<=	reg_6h & reg_6l;	--	IY
					when	others	=>	null;
				end	case;
			when	"011"	=>
				if wire45(0) = '0' then
					rdow	<=	reg_3h & reg_3l;	-- A-x
				else
					rdow	<=	reg_bh & reg_bl;	-- A'-x
				end if;
			when	"100"	=>	rdow	<=	reg_4h & reg_4l;	--	I-R
			when	"101"	=>	rdow	<=	reg_ch & reg_cl;	--	tmp SP
			when	"110"	=>	rdow	<=	reg_dh & reg_dl;	--	zero
			when	"111"	=>	rdow	<=	reg_7h & reg_7l;	--	temp reg for BIT/SET/RES
			when	others	=>	null;
		end	case;
	end	process;

	--------------------------------------------------------------------
	--	Block registers
	--------------------------------------------------------------------
	--	0:BC, 1:DE, 2:HL, 3:A-x, 4:I-x, 5:IX, 6:IY, 7:x-x, 8:BC', 9:DE', 10:HL', 11:A'-x, 12:tmpSP, 13:zero
	din			<=	(DI & DI)	when	(dinw_sel = '1')	else	alu8_do;
	process	(CLK, CLKEN, din, reg_wsel, wire45, wire49, wire47, we, reg_0l, reg_1l, reg_2l, reg_3l, reg_4l, reg_5l, reg_6l, reg_7l, reg_8l, reg_9l, reg_al, reg_bl, reg_cl, reg_dl)
	begin
		if (CLK'event and CLK = '1') then
			if CLKEN = '1' then
				case	reg_wsel(3	downto	1)		is
					when	"000"	=>
						if we(0) = '1' then
							if wire45(1) = '0' then
								reg_0l	<=	din(7	downto	0);	-- BC
							else
								reg_8l	<=	din(7	downto	0);	-- BC'
							end if;
						end if;
						if we(1) = '1' then
							if wire45(1) = '0' then
								reg_0h	<=	din(15	downto	8);
							else
								reg_8h	<=	din(15	downto	8);
							end if;
						end if;

						when	"001"	=>
						if we(0) = '1' then
							if wire45(to_integer(unsigned(wire49)))	= '1' then
								if wire45(1) = '0' then
									reg_2l	<=	din(7	downto	0);	-- HL
								else
									reg_al	<=	din(7	downto	0);	-- HL'
								end if;
							else
								if wire45(1) = '0' then
									reg_1l	<=	din(7	downto	0);	-- DE
								else
									reg_9l	<=	din(7	downto	0);	-- DE'
								end if;
							end if;
						end if;
						if we(1) = '1' then
							if wire45(to_integer(unsigned(wire49)))	= '1' then
								if wire45(1) = '0' then
									reg_2h	<=	din(15	downto	8);
								else
									reg_ah	<=	din(15	downto	8);
								end if;
							else
								if wire45(1) = '0' then
									reg_1h	<=	din(15	downto	8);
								else
									reg_9h	<=	din(15	downto	8);
								end if;
							end if;
						end if;
						
					when	"010"	=>
						case	wire47	is
							when	"000" | "100"	=>
								if we(0) = '1' then
									if wire45(1) = '0' then
										reg_2l	<=	din(7	downto	0);
									else
										reg_al	<=	din(7	downto	0);
									end if;
								end if;
								if we(1) = '1' then
									if wire45(1) = '0' then
										reg_2h	<=	din(15	downto	8);
									else
										reg_ah	<=	din(15	downto	8);
									end if;
								end if;

							when	"001" | "101"	=>
								if we(0) = '1' then
									if wire45(1) = '0' then
										reg_1l	<=	din(7	downto	0);
									else
										reg_9l	<=	din(7	downto	0);
									end if;
								end if;
								if we(1) = '1' then
									if wire45(1) = '0' then
										reg_1h	<=	din(15	downto	8);
									else
										reg_9h	<=	din(15	downto	8);
									end if;
								end if;

								when	"010" | "011"	=>
									if we(0) = '1' then
										reg_5l	<=	din(7	downto	0);
									end if;
									if we(1) = '1' then
										reg_5h	<=	din(15	downto	8);
									end if;

								when	"110" | "111"	=>
									if we(0) = '1' then
										reg_6l	<=	din(7	downto	0);
									end if;
									if we(1) = '1' then
										reg_6h	<=	din(15	downto	8);
									end if;
									
							when	others	=>	null;
						end	case;
					when	"011"	=>
						if we(0) = '1' then
							if wire45(0) = '0' then
								reg_3l	<=	din(7	downto	0);
							else
								reg_bl	<=	din(7	downto	0);
							end if;
						end if;
						if we(1) = '1' then
							if wire45(0) = '0' then
								reg_3h	<=	din(15	downto	8);
							else
								reg_bh	<=	din(15	downto	8);
							end if;
						end if;

					when	"100"	=>
						if we(0) = '1' then
							reg_4l	<=	din(7	downto	0);
						end if;
						if we(1) = '1' then
							reg_4h	<=	din(15	downto	8);
						end if;

					when	"101"	=>
						if we(0) = '1' then
							reg_cl	<=	din(7	downto	0);
						end if;
						if we(1) = '1' then
							reg_ch	<=	din(15	downto	8);
						end if;
					when	"110"	=>
						if we(0) = '1' then
							reg_dl	<=	din(7	downto	0);
						end if;
						if we(1) = '1' then
							reg_dh	<=	din(15	downto	8);
						end if;

					when	"111"	=>
						if we(0) = '1' then
							reg_7l	<=	din(7	downto	0);
						end if;
						if we(1) = '1' then
							reg_7h	<=	din(15	downto	8);
						end if;
					when	others	=>	null;
				end	case;
			end if;
		end if;
	end	process;
--------------------------------------------------------------[V1.2 08-07-2013] end
	
end	architecture	rtl;
