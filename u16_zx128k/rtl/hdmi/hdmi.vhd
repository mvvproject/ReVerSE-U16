-------------------------------------------------------------------[22.06.2015]
-- HDMI
-------------------------------------------------------------------------------
-- Engineer: 	MVV
--
-- 03.08.2014	Initial release

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity hdmi is
port (
	CLK_DVI_I	: in std_logic;
	CLK_PIXEL_I	: in std_logic;
	R_I		: in std_logic_vector(7 downto 0);
	G_I		: in std_logic_vector(7 downto 0);
	B_I		: in std_logic_vector(7 downto 0);
	BLANK_I		: in std_logic;
	HSYNC_I		: in std_logic;
	VSYNC_I		: in std_logic;
	HCNT_I		: in std_logic_vector(9 downto 0);
	HB_I		: in std_logic_vector(95 downto 0);
	PB_I		: in std_logic_vector(767 downto 0);
	TMDS_D0_O	: out std_logic;
	TMDS_D1_O	: out std_logic;
	TMDS_D2_O	: out std_logic;
	TMDS_CLK_O	: out std_logic);
end entity;

architecture rtl of hdmi is
	signal red	: std_logic_vector(9 downto 0);
	signal green	: std_logic_vector(9 downto 0);
	signal blue	: std_logic_vector(9 downto 0);		
	signal tx_in	: std_logic_vector(29 downto 0);
	signal tmds_d	: std_logic_vector(2 downto 0);
	signal ctl	: std_logic_vector(3 downto 0);
	signal ade	: std_logic;
	signal aux0	: std_logic_vector(3 downto 0);
	signal aux1	: std_logic_vector(3 downto 0);
	signal aux2	: std_logic_vector(3 downto 0);
	signal tx	: std_logic_vector(29 downto 0);
	signal c	: std_logic_vector(1 downto 0);
	signal p	: std_logic;
	signal n	: std_logic;
	
	signal hb	: std_logic_vector(31 downto 0) := (others => '0');
	signal pb	: std_logic_vector(255 downto 0) := (others => '0');

begin

-- Channel 0
enc0: entity work.encoder
port map (
	CLK_I		=> CLK_PIXEL_I,
	DATA_I		=> B_I,
	C_I		=> c,
	VDE_I		=> not BLANK_I,
	ADE_I		=> ade,
	AUX_I		=> aux0,
	ENCODED_O	=> blue);

-- Channel 1
enc1: entity work.encoder
port map (
	CLK_I		=> CLK_PIXEL_I,
	DATA_I		=> G_I,
	C_I		=> ctl(1 downto 0),
	VDE_I		=> not BLANK_I,
	ADE_I		=> ade,
	AUX_I		=> aux1,
	ENCODED_O	=> green);

-- Channel 2
enc2: entity work.encoder
port map (
	CLK_I		=> CLK_PIXEL_I,
	DATA_I		=> R_I,
	C_I		=> ctl(3 downto 2),
	VDE_I		=> not BLANK_I,
	ADE_I		=> ade,
	AUX_I		=> aux2,
	ENCODED_O	=> red);

serializer_inst: entity work.serializer
PORT MAP (
	tx_in	 	=> tx_in,
	tx_inclock	=> CLK_DVI_I,
	tx_syncclock	=> CLK_PIXEL_I,
	tx_out	 	=> tmds_d);

	
ade  <= '1' when (HCNT_I > 654 and HCNT_I < 783) else '0';

-- CTL3 CTL2 CTL1 CTL0
-- 0    0    0    1    Video Data Period
-- 0    1    0    1    Data Island Period
-- 0    0    0    0
ctl  <= "0001" when (HCNT_I > 789 and HCNT_I < 798) else
	"0101" when (HCNT_I > 644 and HCNT_I < 653) else
	"0000";
	

process (CLK_PIXEL_I)
begin
	if (CLK_PIXEL_I'event and CLK_PIXEL_I = '1') then
		if (HCNT_I > 797) then
			tx <= "1011001100" & "0100110011" & "1011001100";
		elsif ((HCNT_I > 652 and HCNT_I < 655) or (HCNT_I > 782 and HCNT_I < 785)) then
			tx(29 downto 10) <= "0100110011" & "0100110011";
			case c is
				when "00" => tx(9 downto 0) <= "1010001110";
				when "01" => tx(9 downto 0) <= "1001110001";
				when "10" => tx(9 downto 0) <= "0101100011";
				when "11" => tx(9 downto 0) <= "1011000011";
				when others => null;
			end case;
		end if;
	end if;
end process;
			

tx_in <= tx(20) & tx(21) & tx(22) & tx(23) & tx(24) & tx(25) & tx(26) & tx(27) & tx(28) & tx(29) &
	 tx(10) & tx(11) & tx(12) & tx(13) & tx(14) & tx(15) & tx(16) & tx(17) & tx(18) & tx(19) &
	 tx(0) & tx(1) & tx(2) & tx(3) & tx(4) & tx(5) & tx(6) & tx(7) & tx(8) & tx(9) when (HCNT_I > 798) or (HCNT_I = 0) or (HCNT_I > 653 and HCNT_I < 656) or (HCNT_I > 783 and HCNT_I < 786) else
	 red(0) & red(1) & red(2) & red(3) & red(4) & red(5) & red(6) & red(7) & red(8) & red(9) &
	 green(0) & green(1) & green(2) & green(3) & green(4) & green(5) & green(6) & green(7) & green(8) & green(9) &
	 blue(0) & blue(1) & blue(2) & blue(3) & blue(4) & blue(5) & blue(6) & blue(7) & blue(8) & blue(9);

	 
--   0-639	Video data period	Video data		640 CLK		TMDS code
-- 640-644	Control period		Control data		  5 CLK		
-- 645-652	Control period		Preamble		  8 CLK		Data island preamble
-- 653-654	Data island period	Leading guard band	  2 CLK		Data island guard
-- 655-686	Data island period	Packet 0		 32 CLK		TERC4 code
-- 687-718	Data island period	Packet 1		 32 CLK		TERC4 code
-- 719-750	Data island period	Packet 2		 32 CLK		TERC4 code
-- 751-782	Data island period	Packet 3		 32 CLK		TERC4 code
-- 783-784	Data island period	Leading guard band	  2 CLK		Data island guard
-- 785-789	Control period		Control data		  5 CLK		
-- 790-797	Control period		Preamble		  8 CLK		Video preamble
-- 798-799	Video data period	Leading guard band	  2 CLK		Video guardband

-------------------------------------------------------------------------------
process (CLK_PIXEL_I, HCNT_I, HB_I, PB_I)
begin
	if (CLK_PIXEL_I'event and CLK_PIXEL_I = '1') then
		if (HCNT_I = 655) then
			hb <= HB_I(31 downto 0);
			pb <= PB_I(255 downto 0);
		elsif (HCNT_I = 687) then
			hb <= HB_I(63 downto 32);
			pb <= PB_I(511 downto 256);
		elsif (HCNT_I = 719) then
			hb <= HB_I(95 downto 64);
			pb <= PB_I(767 downto 512);
		else
			hb <= '0' & hb(31 downto 1);
			pb <= "00" & pb(255 downto 2);
		end if;
	end if;
end process;

p    <= hb(0);
aux1 <= pb(192) & pb(128) & pb(64) & pb(0);
aux2 <= pb(193) & pb(129) & pb(65) & pb(1);
-------------------------------------------------------------------------------


--process (HCNT_I, HB_I, PB_I)
--begin
--	case HCNT_I is
---- Packets 0
--		when "1010010000" =>
--			p    <= HB_I(0);	-- HB0
--			aux1 <= PB_I(192) & PB_I(128) & PB_I(64) & PB_I(0);
--			aux2 <= PB_I(193) & PB_I(129) & PB_I(65) & PB_I(1);
--		when "1010010001" =>
--			p    <= HB_I(1);
--			aux1 <= PB_I(194) & PB_I(130) & PB_I(66) & PB_I(2);
--			aux2 <= PB_I(195) & PB_I(131) & PB_I(67) & PB_I(3);
--		when "1010010010" =>
--			p    <= HB_I(2);
--			aux1 <= PB_I(196) & PB_I(132) & PB_I(68) & PB_I(4);
--			aux2 <= PB_I(197) & PB_I(133) & PB_I(69) & PB_I(5);
--		when "1010010011" =>
--			p    <= HB_I(3);
--			aux1 <= PB_I(198) & PB_I(134) & PB_I(70) & PB_I(6);
--			aux2 <= PB_I(199) & PB_I(135) & PB_I(71) & PB_I(7);
--		when "1010010100" =>
--			p    <= HB_I(4);
--			aux1 <= PB_I(200) & PB_I(136) & PB_I(72) & PB_I(8);
--			aux2 <= PB_I(201) & PB_I(137) & PB_I(73) & PB_I(9);
--		when "1010010101" =>
--			p    <= HB_I(5);
--			aux1 <= PB_I(202) & PB_I(138) & PB_I(74) & PB_I(10);
--			aux2 <= PB_I(203) & PB_I(139) & PB_I(75) & PB_I(11);
--		when "1010010110" =>
--			p    <= HB_I(6);
--			aux1 <= PB_I(204) & PB_I(140) & PB_I(76) & PB_I(12);
--			aux2 <= PB_I(205) & PB_I(141) & PB_I(77) & PB_I(13);
--		when "1010010111" =>
--			p    <= HB_I(7);
--			aux1 <= PB_I(206) & PB_I(142) & PB_I(78) & PB_I(14);
--			aux2 <= PB_I(207) & PB_I(143) & PB_I(79) & PB_I(15);
--		when "1010011000" =>
--			p    <= HB_I(8);	-- HB1
--			aux1 <= PB_I(208) & PB_I(144) & PB_I(80) & PB_I(16);
--			aux2 <= PB_I(209) & PB_I(145) & PB_I(81) & PB_I(17);
--		when "1010011001" => 
--			p    <= HB_I(9);
--			aux1 <= PB_I(210) & PB_I(146) & PB_I(82) & PB_I(18);
--			aux2 <= PB_I(211) & PB_I(147) & PB_I(83) & PB_I(19);
--		when "1010011010" =>
--			p    <= HB_I(10);
--			aux1 <= PB_I(212) & PB_I(148) & PB_I(84) & PB_I(20);
--			aux2 <= PB_I(213) & PB_I(149) & PB_I(85) & PB_I(21);
--		when "1010011011" =>
--			p    <= HB_I(11);
--			aux1 <= PB_I(214) & PB_I(150) & PB_I(86) & PB_I(22);
--			aux2 <= PB_I(215) & PB_I(151) & PB_I(87) & PB_I(23);
--		when "1010011100" =>
--			p    <= HB_I(12);
--			aux1 <= PB_I(216) & PB_I(152) & PB_I(88) & PB_I(24);
--			aux2 <= PB_I(217) & PB_I(153) & PB_I(89) & PB_I(25);
--		when "1010011101" =>
--			p    <= HB_I(13);
--			aux1 <= PB_I(218) & PB_I(154) & PB_I(90) & PB_I(26);
--			aux2 <= PB_I(219) & PB_I(155) & PB_I(91) & PB_I(27);
--		when "1010011110" =>
--			p    <= HB_I(14);
--			aux1 <= PB_I(220) & PB_I(156) & PB_I(92) & PB_I(28);
--			aux2 <= PB_I(221) & PB_I(157) & PB_I(93) & PB_I(29);
--		when "1010011111" =>
--			p    <= HB_I(15);
--			aux1 <= PB_I(222) & PB_I(158) & PB_I(94) & PB_I(30);
--			aux2 <= PB_I(223) & PB_I(159) & PB_I(95) & PB_I(31);
--		when "1010100000" =>
--			p    <= HB_I(16);	-- HB2
--			aux1 <= PB_I(224) & PB_I(160) & PB_I(96) & PB_I(32);
--			aux2 <= PB_I(225) & PB_I(161) & PB_I(97) & PB_I(33);
--		when "1010100001" =>
--			p    <= HB_I(17);
--			aux1 <= PB_I(226) & PB_I(162) & PB_I(98) & PB_I(34);
--			aux2 <= PB_I(227) & PB_I(163) & PB_I(99) & PB_I(35);
--		when "1010100010" =>
--			p    <= HB_I(18);
--			aux1 <= PB_I(228) & PB_I(164) & PB_I(100) & PB_I(36);
--			aux2 <= PB_I(229) & PB_I(165) & PB_I(101) & PB_I(37);
--		when "1010100011" =>
--			p    <= HB_I(19);
--			aux1 <= PB_I(230) & PB_I(166) & PB_I(102) & PB_I(38);
--			aux2 <= PB_I(231) & PB_I(167) & PB_I(103) & PB_I(39);
--		when "1010100100" =>
--			p    <= HB_I(20);
--			aux1 <= PB_I(232) & PB_I(168) & PB_I(104) & PB_I(40);
--			aux2 <= PB_I(233) & PB_I(169) & PB_I(105) & PB_I(41);
--		when "1010100101" =>
--			p    <= HB_I(21);
--			aux1 <= PB_I(234) & PB_I(170) & PB_I(106) & PB_I(42);
--			aux2 <= PB_I(235) & PB_I(171) & PB_I(107) & PB_I(43);
--		when "1010100110" =>
--			p    <= HB_I(22);
--			aux1 <= PB_I(236) & PB_I(172) & PB_I(108) & PB_I(44);
--			aux2 <= PB_I(237) & PB_I(173) & PB_I(109) & PB_I(45);
--		when "1010100111" =>
--			p    <= HB_I(23);
--			aux1 <= PB_I(238) & PB_I(174) & PB_I(110) & PB_I(46);
--			aux2 <= PB_I(239) & PB_I(175) & PB_I(111) & PB_I(47);
--		when "1010101000" =>
--			p    <= HB_I(24);	-- ECC
--			aux1 <= PB_I(240) & PB_I(176) & PB_I(112) & PB_I(48);
--			aux2 <= PB_I(241) & PB_I(177) & PB_I(113) & PB_I(49);
--		when "1010101001" =>
--			p    <= HB_I(25);
--			aux1 <= PB_I(242) & PB_I(178) & PB_I(114) & PB_I(50);
--			aux2 <= PB_I(243) & PB_I(179) & PB_I(115) & PB_I(51);
--		when "1010101010" =>
--			p    <= HB_I(26);
--			aux1 <= PB_I(244) & PB_I(180) & PB_I(116) & PB_I(52);
--			aux2 <= PB_I(245) & PB_I(181) & PB_I(117) & PB_I(53);
--		when "1010101011" =>
--			p    <= HB_I(27);
--			aux1 <= PB_I(246) & PB_I(182) & PB_I(118) & PB_I(54);
--			aux2 <= PB_I(247) & PB_I(183) & PB_I(119) & PB_I(55);
--		when "1010101100" =>
--			p    <= HB_I(28);
--			aux1 <= PB_I(248) & PB_I(184) & PB_I(120) & PB_I(56);
--			aux2 <= PB_I(249) & PB_I(185) & PB_I(121) & PB_I(57);
--		when "1010101101" =>
--			p    <= HB_I(29);
--			aux1 <= PB_I(250) & PB_I(186) & PB_I(122) & PB_I(58);
--			aux2 <= PB_I(251) & PB_I(187) & PB_I(123) & PB_I(59);
--		when "1010101110" =>
--			p    <= HB_I(30);
--			aux1 <= PB_I(252) & PB_I(188) & PB_I(124) & PB_I(60);
--			aux2 <= PB_I(253) & PB_I(189) & PB_I(125) & PB_I(61);
--		when "1010101111" =>
--			p    <= HB_I(31);
--			aux1 <= PB_I(254) & PB_I(190) & PB_I(126) & PB_I(62);
--			aux2 <= PB_I(255) & PB_I(191) & PB_I(127) & PB_I(63);
---- Packets 1
--		when "1010110000" =>
--			p    <= HB_I(32);	-- HB0
--			aux1 <= PB_I(448) & PB_I(384) & PB_I(320) & PB_I(256);
--			aux2 <= PB_I(449) & PB_I(385) & PB_I(321) & PB_I(257);
--		when "1010110001" =>
--			p    <= HB_I(33);
--			aux1 <= PB_I(450) & PB_I(386) & PB_I(322) & PB_I(258);
--			aux2 <= PB_I(451) & PB_I(387) & PB_I(323) & PB_I(259);
--		when "1010110010" =>
--			p    <= HB_I(34);
--			aux1 <= PB_I(452) & PB_I(388) & PB_I(324) & PB_I(260);
--			aux2 <= PB_I(453) & PB_I(389) & PB_I(325) & PB_I(261);
--		when "1010110011" =>
--			p    <= HB_I(35);
--			aux1 <= PB_I(454) & PB_I(390) & PB_I(326) & PB_I(262);
--			aux2 <= PB_I(455) & PB_I(391) & PB_I(327) & PB_I(263);
--		when "1010110100" =>
--			p    <= HB_I(36);
--			aux1 <= PB_I(456) & PB_I(392) & PB_I(328) & PB_I(264);
--			aux2 <= PB_I(457) & PB_I(393) & PB_I(329) & PB_I(265);
--		when "1010110101" =>
--			p    <= HB_I(37);
--			aux1 <= PB_I(458) & PB_I(394) & PB_I(330) & PB_I(266);
--			aux2 <= PB_I(459) & PB_I(395) & PB_I(331) & PB_I(267);
--		when "1010110110" =>
--			p    <= HB_I(38);
--			aux1 <= PB_I(460) & PB_I(396) & PB_I(332) & PB_I(268);
--			aux2 <= PB_I(461) & PB_I(397) & PB_I(333) & PB_I(269);
--		when "1010110111" =>
--			p    <= HB_I(39);
--			aux1 <= PB_I(462) & PB_I(398) & PB_I(334) & PB_I(270);
--			aux2 <= PB_I(463) & PB_I(399) & PB_I(335) & PB_I(271);
--		when "1010111000" =>
--			p    <= HB_I(40);	-- HB1
--			aux1 <= PB_I(464) & PB_I(400) & PB_I(336) & PB_I(272);
--			aux2 <= PB_I(465) & PB_I(401) & PB_I(337) & PB_I(273);
--		when "1010111001" => 
--			p    <= HB_I(41);
--			aux1 <= PB_I(466) & PB_I(402) & PB_I(338) & PB_I(274);
--			aux2 <= PB_I(467) & PB_I(403) & PB_I(339) & PB_I(275);
--		when "1010111010" =>
--			p    <= HB_I(42);
--			aux1 <= PB_I(468) & PB_I(404) & PB_I(340) & PB_I(276);
--			aux2 <= PB_I(469) & PB_I(405) & PB_I(341) & PB_I(277);
--		when "1010111011" =>
--			p    <= HB_I(43);
--			aux1 <= PB_I(470) & PB_I(406) & PB_I(342) & PB_I(278);
--			aux2 <= PB_I(471) & PB_I(407) & PB_I(343) & PB_I(279);
--		when "1010111100" =>
--			p    <= HB_I(44);
--			aux1 <= PB_I(472) & PB_I(408) & PB_I(344) & PB_I(280);
--			aux2 <= PB_I(473) & PB_I(409) & PB_I(345) & PB_I(281);
--		when "1010111101" =>
--			p    <= HB_I(45);
--			aux1 <= PB_I(474) & PB_I(410) & PB_I(346) & PB_I(282);
--			aux2 <= PB_I(475) & PB_I(411) & PB_I(347) & PB_I(283);
--		when "1010111110" =>
--			p    <= HB_I(46);
--			aux1 <= PB_I(476) & PB_I(412) & PB_I(348) & PB_I(284);
--			aux2 <= PB_I(477) & PB_I(413) & PB_I(349) & PB_I(285);
--		when "1010111111" =>
--			p    <= HB_I(47);
--			aux1 <= PB_I(478) & PB_I(414) & PB_I(350) & PB_I(286);
--			aux2 <= PB_I(479) & PB_I(415) & PB_I(351) & PB_I(287);
--		when "1011000000" =>
--			p    <= HB_I(48);	-- HB2
--			aux1 <= PB_I(480) & PB_I(416) & PB_I(352) & PB_I(288);
--			aux2 <= PB_I(481) & PB_I(417) & PB_I(353) & PB_I(289);
--		when "1011000001" =>
--			p    <= HB_I(49);
--			aux1 <= PB_I(482) & PB_I(418) & PB_I(354) & PB_I(290);
--			aux2 <= PB_I(483) & PB_I(419) & PB_I(355) & PB_I(291);
--		when "1011000010" =>
--			p    <= HB_I(50);
--			aux1 <= PB_I(484) & PB_I(420) & PB_I(356) & PB_I(292);
--			aux2 <= PB_I(485) & PB_I(421) & PB_I(357) & PB_I(293);
--		when "1011000011" =>
--			p    <= HB_I(51);
--			aux1 <= PB_I(486) & PB_I(422) & PB_I(358) & PB_I(294);
--			aux2 <= PB_I(487) & PB_I(423) & PB_I(359) & PB_I(295);
--		when "1011000100" =>
--			p    <= HB_I(52);
--			aux1 <= PB_I(488) & PB_I(424) & PB_I(360) & PB_I(296);
--			aux2 <= PB_I(489) & PB_I(425) & PB_I(361) & PB_I(297);
--		when "1011000101" =>
--			p    <= HB_I(53);
--			aux1 <= PB_I(490) & PB_I(426) & PB_I(362) & PB_I(298);
--			aux2 <= PB_I(491) & PB_I(427) & PB_I(363) & PB_I(299);
--		when "1011000110" =>
--			p    <= HB_I(54);
--			aux1 <= PB_I(492) & PB_I(428) & PB_I(364) & PB_I(300);
--			aux2 <= PB_I(493) & PB_I(429) & PB_I(365) & PB_I(301);
--		when "1011000111" =>
--			p    <= HB_I(55);
--			aux1 <= PB_I(494) & PB_I(430) & PB_I(366) & PB_I(302);
--			aux2 <= PB_I(495) & PB_I(431) & PB_I(367) & PB_I(303);
--		when "1011001000" =>
--			p    <= HB_I(56);	-- ECC
--			aux1 <= PB_I(496) & PB_I(432) & PB_I(368) & PB_I(304);
--			aux2 <= PB_I(497) & PB_I(433) & PB_I(369) & PB_I(305);
--		when "1011001001" =>
--			p    <= HB_I(57);
--			aux1 <= PB_I(498) & PB_I(434) & PB_I(370) & PB_I(306);
--			aux2 <= PB_I(499) & PB_I(435) & PB_I(371) & PB_I(307);
--		when "1011001010" =>
--			p    <= HB_I(58);
--			aux1 <= PB_I(500) & PB_I(436) & PB_I(372) & PB_I(308);
--			aux2 <= PB_I(501) & PB_I(437) & PB_I(373) & PB_I(309);
--		when "1011001011" =>
--			p    <= HB_I(59);
--			aux1 <= PB_I(502) & PB_I(438) & PB_I(374) & PB_I(310);
--			aux2 <= PB_I(503) & PB_I(439) & PB_I(375) & PB_I(311);
--		when "1011001100" =>
--			p    <= HB_I(60);
--			aux1 <= PB_I(504) & PB_I(440) & PB_I(376) & PB_I(312);
--			aux2 <= PB_I(505) & PB_I(441) & PB_I(377) & PB_I(313);
--		when "1011001101" =>
--			p    <= HB_I(61);
--			aux1 <= PB_I(506) & PB_I(442) & PB_I(378) & PB_I(314);
--			aux2 <= PB_I(507) & PB_I(443) & PB_I(379) & PB_I(315);
--		when "1011001110" =>
--			p    <= HB_I(62);
--			aux1 <= PB_I(508) & PB_I(444) & PB_I(380) & PB_I(316);
--			aux2 <= PB_I(509) & PB_I(445) & PB_I(381) & PB_I(317);
--		when "1011001111" =>
--			p    <= HB_I(63);
--			aux1 <= PB_I(510) & PB_I(446) & PB_I(382) & PB_I(318);
--			aux2 <= PB_I(511) & PB_I(447) & PB_I(383) & PB_I(319);
--		when others =>
--			p    <= '0';
--			aux1 <= "0000";
--			aux2 <= "0000";
--	end case;
--end process;

n    <= '0' when (HCNT_I = "1010010000") else '1';	
c    <= VSYNC_I & HSYNC_I;		
aux0 <= n & p & c;

TMDS_D0_O  <= tmds_d(0);
TMDS_D1_O  <= tmds_d(1);
TMDS_D2_O  <= tmds_d(2);
TMDS_CLK_O <= CLK_PIXEL_I;

end rtl;