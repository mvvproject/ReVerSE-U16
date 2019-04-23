-------------------------------------------------------------------[24.06.2018]
-- DMA Sound (8 Chanels x 8bit)
-------------------------------------------------------------------------------
-- Engineer: 	MVV <mvvproject@gmail.com>
--
-- Copyright (c) 2015-2018 Vladislav Matlash
--
-- 08.03.2015	First Version
--
-- Реализовано 8-мь звуковых канала, каждый играет 8-разрядный (signed) звуковой образ (при необходимости в дальнейшей версии может быть расширен). Индивидуальная частота, громкость, стартовая позиция и длина. Возможность зацикливания (loop) с произвольного места.
-- Для управления звуком выбран диапазон портов 0x0050-0x8250 (младший байт всегда 0x50).
--
-- Управление каналами:
-- 0x8050: Стерео микшер 0-7 (7..0) т.е. биты (3..0)=1 то каналы 0-3 (правые) слышны ещё и слева, если биты (7..4)=1 то каналы 4-7 (левые) слышны ещё и справа.
-- 0x8150: Зацикливание каналов 0-7 (7..0) т.е. бит 0=1 разрешает зацикливание канала 0
-- 0x8250: Разрешает работу каналов 0-7 (7..0) т.е. бит 0=1 разрешает работу канала 0. Чтение порта возвращает текущее состояние каналов, т.е. если бит 0=1 то канал 0 работает. Если бит 0=0, то канал закончил работу.
--
-- Канал 0:
-- 0x0050: Стартовый адрес (7..0) т.е. 0x000000-0xFFFFFF
-- 0x0150: Стартовый адрес (15..8)
-- 0x0250: Стартовый адрес (23..16)
-- ..
-- 0x0450: Длина (7..0) т.е. 0x000000=1 байт .. 0xFFFFFF=0x1000000 байт
-- 0x0550: Длина (15..8)
-- 0x0650: Длина (23..16)
-- ..
-- 0x0850: Частота (7..0) т.е. 0=3,5MHz .. 65535=53,4..Hz
-- 0x0950: Частота (15..8)
-- 0x0A50: Громкость (5..0) т.е. 0=минимальная .. 63=максимальная
--
-- Канал 1:
-- 0x1050: Стартовый адрес (7..0) т.е. 0x000000-0xFFFFFF
-- 0x1150: Стартовый адрес (15..8)
-- 0x1250: Стартовый адрес (23..16)
-- ..
-- 0x1450: Длина (7..0) т.е. 0x000000=1 байт .. 0xFFFFFF=0x1000000 байт
-- 0x1550: Длина (15..8)
-- 0x1650: Длина (23..16)
-- ..
-- 0x1850: Частота (7..0) т.е. 0=3,5MHz .. 65535=53,4..Hz
-- 0x1950: Частота (15..8)
-- 0x1A50: Громкость (5..0) т.е. 0=минимальная .. 63=максимальная


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.std_logic_unsigned.all;

entity dmasound is
port ( 
	I_RST			: in  std_logic;
	I_CLK			: in  std_logic;
	I_ENA			: in  std_logic;
	I_ADR			: in  std_logic_vector(15 downto 0);
	I_DAT			: in  std_logic_vector( 7 downto 0);
	O_DAT			: out std_logic_vector( 7 downto 0);
	I_WR_N			: in  std_logic;
	I_RD_N			: in  std_logic;
	I_IORQ_N		: in  std_logic;
	I_INTA			: in  std_logic;
	O_INT			: out std_logic;
	-- Sound
	O_LEFT			: out std_logic_vector(16 downto 0);
	O_RIGHT			: out std_logic_vector(16 downto 0);
	-- Memory
	O_MEM_ADR		: out std_logic_vector(23 downto 0);
	I_MEM_DAT		: in  std_logic_vector( 7 downto 0);
	O_MEM_RD		: out std_logic;
	I_MEM_ACK		: in  std_logic);
end dmasound;
 
architecture rtl of dmasound is

	signal ch0_out 			: std_logic_vector(7 downto 0);
	signal ch1_out 			: std_logic_vector(7 downto 0);
	signal ch2_out 			: std_logic_vector(7 downto 0);
	signal ch3_out 			: std_logic_vector(7 downto 0);
	signal ch4_out 			: std_logic_vector(7 downto 0);
	signal ch5_out 			: std_logic_vector(7 downto 0);
	signal ch6_out 			: std_logic_vector(7 downto 0);
	signal ch7_out 			: std_logic_vector(7 downto 0);

	signal ch0_volume 		: std_logic_vector(5 downto 0);
	signal ch1_volume 		: std_logic_vector(5 downto 0);
	signal ch2_volume 		: std_logic_vector(5 downto 0);
	signal ch3_volume 		: std_logic_vector(5 downto 0);
	signal ch4_volume 		: std_logic_vector(5 downto 0);
	signal ch5_volume 		: std_logic_vector(5 downto 0);
	signal ch6_volume 		: std_logic_vector(5 downto 0);
	signal ch7_volume 		: std_logic_vector(5 downto 0);

	signal ch0_base_adr		: std_logic_vector(23 downto 0);
	signal ch1_base_adr		: std_logic_vector(23 downto 0);
	signal ch2_base_adr		: std_logic_vector(23 downto 0);
	signal ch3_base_adr		: std_logic_vector(23 downto 0);
	signal ch4_base_adr		: std_logic_vector(23 downto 0);
	signal ch5_base_adr		: std_logic_vector(23 downto 0);
	signal ch6_base_adr		: std_logic_vector(23 downto 0);
	signal ch7_base_adr		: std_logic_vector(23 downto 0);

	signal ch0_base_count		: std_logic_vector(23 downto 0);
	signal ch1_base_count		: std_logic_vector(23 downto 0);
	signal ch2_base_count		: std_logic_vector(23 downto 0);
	signal ch3_base_count		: std_logic_vector(23 downto 0);
	signal ch4_base_count		: std_logic_vector(23 downto 0);
	signal ch5_base_count		: std_logic_vector(23 downto 0);
	signal ch6_base_count		: std_logic_vector(23 downto 0);
	signal ch7_base_count		: std_logic_vector(23 downto 0);

	signal ch0_current_adr		: std_logic_vector(23 downto 0);
	signal ch1_current_adr		: std_logic_vector(23 downto 0);
	signal ch2_current_adr		: std_logic_vector(23 downto 0);
	signal ch3_current_adr		: std_logic_vector(23 downto 0);
	signal ch4_current_adr		: std_logic_vector(23 downto 0);
	signal ch5_current_adr		: std_logic_vector(23 downto 0);
	signal ch6_current_adr		: std_logic_vector(23 downto 0);
	signal ch7_current_adr		: std_logic_vector(23 downto 0);

	signal ch0_current_count	: std_logic_vector(23 downto 0);
	signal ch1_current_count	: std_logic_vector(23 downto 0);
	signal ch2_current_count	: std_logic_vector(23 downto 0);
	signal ch3_current_count	: std_logic_vector(23 downto 0);
	signal ch4_current_count	: std_logic_vector(23 downto 0);
	signal ch5_current_count	: std_logic_vector(23 downto 0);
	signal ch6_current_count	: std_logic_vector(23 downto 0);
	signal ch7_current_count	: std_logic_vector(23 downto 0);

	signal ch0_base_timer		: std_logic_vector(15 downto 0);
	signal ch1_base_timer		: std_logic_vector(15 downto 0);
	signal ch2_base_timer		: std_logic_vector(15 downto 0);
	signal ch3_base_timer		: std_logic_vector(15 downto 0);
	signal ch4_base_timer		: std_logic_vector(15 downto 0);
	signal ch5_base_timer		: std_logic_vector(15 downto 0);
	signal ch6_base_timer		: std_logic_vector(15 downto 0);
	signal ch7_base_timer		: std_logic_vector(15 downto 0);

	signal ch0_current_timer	: std_logic_vector(15 downto 0);
	signal ch1_current_timer	: std_logic_vector(15 downto 0);
	signal ch2_current_timer	: std_logic_vector(15 downto 0);
	signal ch3_current_timer	: std_logic_vector(15 downto 0);
	signal ch4_current_timer	: std_logic_vector(15 downto 0);
	signal ch5_current_timer	: std_logic_vector(15 downto 0);
	signal ch6_current_timer	: std_logic_vector(15 downto 0);
	signal ch7_current_timer	: std_logic_vector(15 downto 0);

	signal temp_adr			: std_logic_vector(23 downto 0);
	signal temp_read		: std_logic;
	signal temp_int			: std_logic;
	signal state			: std_logic := '0';
	signal priority			: std_logic_vector(2 downto 0) := "000";
	signal channal			: std_logic_vector(2 downto 0) := "000";
	
	signal ch0_req			: std_logic := '0';
	signal ch1_req			: std_logic := '0';
	signal ch2_req			: std_logic := '0';
	signal ch3_req			: std_logic := '0';
	signal ch4_req			: std_logic := '0';
	signal ch5_req			: std_logic := '0';
	signal ch6_req			: std_logic := '0';
	signal ch7_req			: std_logic := '0';
	
	signal ch_enable		: std_logic_vector(7 downto 0);
	signal ch_loop			: std_logic_vector(7 downto 0);
	signal ch_mixing		: std_logic_vector(7 downto 0);
	
	signal ch0_volume_out		: std_logic_vector(13 downto 0);
	signal ch1_volume_out		: std_logic_vector(13 downto 0);
	signal ch2_volume_out		: std_logic_vector(13 downto 0);
	signal ch3_volume_out		: std_logic_vector(13 downto 0);
	signal ch4_volume_out		: std_logic_vector(13 downto 0);
	signal ch5_volume_out		: std_logic_vector(13 downto 0);
	signal ch6_volume_out		: std_logic_vector(13 downto 0);
	signal ch7_volume_out		: std_logic_vector(13 downto 0);
	
	signal left_stream0		: std_logic_vector(13 downto 0);
	signal left_stream1		: std_logic_vector(13 downto 0);
	signal left_stream2		: std_logic_vector(13 downto 0);
	signal left_stream3		: std_logic_vector(13 downto 0);

	signal right_stream0		: std_logic_vector(13 downto 0);
	signal right_stream1		: std_logic_vector(13 downto 0);
	signal right_stream2		: std_logic_vector(13 downto 0);
	signal right_stream3		: std_logic_vector(13 downto 0);
	
begin

process (I_RST, I_CLK, I_IORQ_N, I_WR_N, I_ADR, I_DAT, I_RD_N, ch_enable, ch0_out, ch0_volume, ch1_out, ch1_volume, ch2_out, ch2_volume, ch3_out, ch3_volume, ch4_out, ch4_volume, ch5_out,
	ch5_volume, ch6_out, ch6_volume, ch7_out, ch7_volume, ch_mixing, ch0_volume_out, ch1_volume_out, ch2_volume_out, ch3_volume_out, ch4_volume_out, ch5_volume_out, ch6_volume_out, ch7_volume_out)
begin
	if (I_RST = '1') then
		ch0_volume	<= (others => '0');
		ch1_volume	<= (others => '0');
		ch2_volume	<= (others => '0');
		ch3_volume	<= (others => '0');
		ch4_volume	<= (others => '0');
		ch5_volume	<= (others => '0');
		ch6_volume	<= (others => '0');
		ch7_volume	<= (others => '0');

		ch0_base_adr	<= (others => '0');
		ch1_base_adr	<= (others => '0');
		ch2_base_adr	<= (others => '0');
		ch3_base_adr	<= (others => '0');
		ch4_base_adr	<= (others => '0');
		ch5_base_adr	<= (others => '0');
		ch6_base_adr	<= (others => '0');
		ch7_base_adr	<= (others => '0');
		
		ch0_base_count	<= (others => '0');
		ch1_base_count	<= (others => '0');
		ch2_base_count	<= (others => '0');
		ch3_base_count	<= (others => '0');
		ch4_base_count	<= (others => '0');
		ch5_base_count	<= (others => '0');
		ch6_base_count	<= (others => '0');
		ch7_base_count	<= (others => '0');
			
		ch0_base_timer	<= (others => '0');
		ch1_base_timer	<= (others => '0');
		ch2_base_timer	<= (others => '0');
		ch3_base_timer	<= (others => '0');
		ch4_base_timer	<= (others => '0');
		ch5_base_timer	<= (others => '0');
		ch6_base_timer	<= (others => '0');
		ch7_base_timer	<= (others => '0');

		ch_enable	<= (others => '0');
		ch_loop		<= (others => '0');
		ch_mixing	<= (others => '0');
		
		ch0_req		<= '0';
		ch1_req		<= '0';
		ch2_req		<= '0';
		ch3_req		<= '0';
		ch4_req		<= '0';
		ch5_req		<= '0';
		ch6_req		<= '0';
		ch7_req		<= '0';
		
		priority	<= (others => '0');
		temp_int	<= '0';
	
	elsif (I_CLK'event and I_CLK = '1') then
		------------------------------------------------------------------------
		-- INT
		if (I_INTA = '1') then temp_int <= '0'; end if;

		------------------------------------------------------------------------
		-- Channal 0
		if (I_IORQ_N = '0' and I_WR_N = '0' and I_ADR = X"0050") then ch0_base_adr( 7 downto  0) <= I_DAT; ch0_current_adr( 7 downto  0) <= I_DAT; end if;
		if (I_IORQ_N = '0' and I_WR_N = '0' and I_ADR = X"0150") then ch0_base_adr(15 downto  8) <= I_DAT; ch0_current_adr(15 downto  8) <= I_DAT; end if;
		if (I_IORQ_N = '0' and I_WR_N = '0' and I_ADR = X"0250") then ch0_base_adr(23 downto 16) <= I_DAT; ch0_current_adr(23 downto 16) <= I_DAT; end if;
--		if (I_IORQ_N = '0' and I_WR_N = '0' and I_ADR = X"0350") then ch0_base_adr(31 downto 24) <= I_DAT; ch0_current_adr(31 downto 24) <= I_DAT; end if;
		if (I_IORQ_N = '0' and I_WR_N = '0' and I_ADR = X"0450") then ch0_base_count( 7 downto  0) <= I_DAT; ch0_current_count( 7 downto  0) <= I_DAT; end if;
		if (I_IORQ_N = '0' and I_WR_N = '0' and I_ADR = X"0550") then ch0_base_count(15 downto  8) <= I_DAT; ch0_current_count(15 downto  8) <= I_DAT; end if;
		if (I_IORQ_N = '0' and I_WR_N = '0' and I_ADR = X"0650") then ch0_base_count(23 downto 16) <= I_DAT; ch0_current_count(23 downto 16) <= I_DAT; end if;
--		if (I_IORQ_N = '0' and I_WR_N = '0' and I_ADR = X"0750") then ch0_base_count(31 downto 24) <= I_DAT; ch0_current_count(31 downto 24) <= I_DAT; end if;
		if (I_IORQ_N = '0' and I_WR_N = '0' and I_ADR = X"0850") then ch0_base_timer( 7 downto  0) <= I_DAT; end if;
		if (I_IORQ_N = '0' and I_WR_N = '0' and I_ADR = X"0950") then ch0_base_timer(15 downto  8) <= I_DAT; end if;
		if (I_IORQ_N = '0' and I_WR_N = '0' and I_ADR = X"0A50") then ch0_volume <= I_DAT( 5 downto  0); end if;
		------------------------------------------------------------------------
		-- Channal 1
		if (I_IORQ_N = '0' and I_WR_N = '0' and I_ADR = X"1050") then ch1_base_adr( 7 downto  0) <= I_DAT; ch1_current_adr( 7 downto  0) <= I_DAT; end if;
		if (I_IORQ_N = '0' and I_WR_N = '0' and I_ADR = X"1150") then ch1_base_adr(15 downto  8) <= I_DAT; ch1_current_adr(15 downto  8) <= I_DAT; end if;
		if (I_IORQ_N = '0' and I_WR_N = '0' and I_ADR = X"1250") then ch1_base_adr(23 downto 16) <= I_DAT; ch1_current_adr(23 downto 16) <= I_DAT; end if;
--		if (I_IORQ_N = '0' and I_WR_N = '0' and I_ADR = X"1350") then ch1_base_adr(31 downto 24) <= I_DAT; ch1_current_adr(31 downto 24) <= I_DAT; end if;
		if (I_IORQ_N = '0' and I_WR_N = '0' and I_ADR = X"1450") then ch1_base_count( 7 downto  0) <= I_DAT; ch1_current_count( 7 downto  0) <= I_DAT; end if;
		if (I_IORQ_N = '0' and I_WR_N = '0' and I_ADR = X"1550") then ch1_base_count(15 downto  8) <= I_DAT; ch1_current_count(15 downto  8) <= I_DAT; end if;
		if (I_IORQ_N = '0' and I_WR_N = '0' and I_ADR = X"1650") then ch1_base_count(23 downto 16) <= I_DAT; ch1_current_count(23 downto 16) <= I_DAT; end if;
--		if (I_IORQ_N = '0' and I_WR_N = '0' and I_ADR = X"1750") then ch1_base_count(31 downto 24) <= I_DAT; ch1_current_count(31 downto 24) <= I_DAT; end if;
		if (I_IORQ_N = '0' and I_WR_N = '0' and I_ADR = X"1850") then ch1_base_timer( 7 downto  0) <= I_DAT; end if;
		if (I_IORQ_N = '0' and I_WR_N = '0' and I_ADR = X"1950") then ch1_base_timer(15 downto  8) <= I_DAT; end if;
		if (I_IORQ_N = '0' and I_WR_N = '0' and I_ADR = X"1A50") then ch1_volume <= I_DAT(5 downto 0); end if;
		------------------------------------------------------------------------
		-- Channal 2
		if (I_IORQ_N = '0' and I_WR_N = '0' and I_ADR = X"2050") then ch2_base_adr( 7 downto  0) <= I_DAT; ch2_current_adr( 7 downto  0) <= I_DAT; end if;
		if (I_IORQ_N = '0' and I_WR_N = '0' and I_ADR = X"2150") then ch2_base_adr(15 downto  8) <= I_DAT; ch2_current_adr(15 downto  8) <= I_DAT; end if;
		if (I_IORQ_N = '0' and I_WR_N = '0' and I_ADR = X"2250") then ch2_base_adr(23 downto 16) <= I_DAT; ch2_current_adr(23 downto 16) <= I_DAT; end if;
--		if (I_IORQ_N = '0' and I_WR_N = '0' and I_ADR = X"2350") then ch2_base_adr(31 downto 24) <= I_DAT; ch2_current_adr(31 downto 24) <= I_DAT; end if;
		if (I_IORQ_N = '0' and I_WR_N = '0' and I_ADR = X"2450") then ch2_base_count( 7 downto  0) <= I_DAT; ch2_current_count( 7 downto  0) <= I_DAT; end if;
		if (I_IORQ_N = '0' and I_WR_N = '0' and I_ADR = X"2550") then ch2_base_count(15 downto  8) <= I_DAT; ch2_current_count(15 downto  8) <= I_DAT; end if;
		if (I_IORQ_N = '0' and I_WR_N = '0' and I_ADR = X"2650") then ch2_base_count(23 downto 16) <= I_DAT; ch2_current_count(23 downto 16) <= I_DAT; end if;
--		if (I_IORQ_N = '0' and I_WR_N = '0' and I_ADR = X"2750") then ch2_base_count(31 downto 24) <= I_DAT; ch2_current_count(31 downto 24) <= I_DAT; end if;
		if (I_IORQ_N = '0' and I_WR_N = '0' and I_ADR = X"2850") then ch2_base_timer( 7 downto  0) <= I_DAT; end if;
		if (I_IORQ_N = '0' and I_WR_N = '0' and I_ADR = X"2950") then ch2_base_timer(15 downto  8) <= I_DAT; end if;
		if (I_IORQ_N = '0' and I_WR_N = '0' and I_ADR = X"2A50") then ch2_volume <= I_DAT(5 downto 0); end if;
		------------------------------------------------------------------------
		-- Channal 3
		if (I_IORQ_N = '0' and I_WR_N = '0' and I_ADR = X"3050") then ch3_base_adr( 7 downto  0) <= I_DAT; ch3_current_adr( 7 downto  0) <= I_DAT; end if;
		if (I_IORQ_N = '0' and I_WR_N = '0' and I_ADR = X"3150") then ch3_base_adr(15 downto  8) <= I_DAT; ch3_current_adr(15 downto  8) <= I_DAT; end if;
		if (I_IORQ_N = '0' and I_WR_N = '0' and I_ADR = X"3250") then ch3_base_adr(23 downto 16) <= I_DAT; ch3_current_adr(23 downto 16) <= I_DAT; end if;
--		if (I_IORQ_N = '0' and I_WR_N = '0' and I_ADR = X"3350") then ch3_base_adr(31 downto 24) <= I_DAT; ch3_current_adr(31 downto 24) <= I_DAT; end if;
		if (I_IORQ_N = '0' and I_WR_N = '0' and I_ADR = X"3450") then ch3_base_count( 7 downto  0) <= I_DAT; ch3_current_count( 7 downto  0) <= I_DAT; end if;
		if (I_IORQ_N = '0' and I_WR_N = '0' and I_ADR = X"3550") then ch3_base_count(15 downto  8) <= I_DAT; ch3_current_count(15 downto  8) <= I_DAT; end if;
		if (I_IORQ_N = '0' and I_WR_N = '0' and I_ADR = X"3650") then ch3_base_count(23 downto 16) <= I_DAT; ch3_current_count(23 downto 16) <= I_DAT; end if;
--		if (I_IORQ_N = '0' and I_WR_N = '0' and I_ADR = X"3750") then ch3_base_count(31 downto 24) <= I_DAT; ch3_current_count(31 downto 24) <= I_DAT; end if;
		if (I_IORQ_N = '0' and I_WR_N = '0' and I_ADR = X"3850") then ch3_base_timer( 7 downto  0) <= I_DAT; end if;
		if (I_IORQ_N = '0' and I_WR_N = '0' and I_ADR = X"3950") then ch3_base_timer(15 downto  8) <= I_DAT; end if;
		if (I_IORQ_N = '0' and I_WR_N = '0' and I_ADR = X"3A50") then ch3_volume <= I_DAT(5 downto 0); end if;
		------------------------------------------------------------------------
		-- Channal 4
		if (I_IORQ_N = '0' and I_WR_N = '0' and I_ADR = X"4050") then ch4_base_adr( 7 downto  0) <= I_DAT; ch4_current_adr( 7 downto  0) <= I_DAT; end if;
		if (I_IORQ_N = '0' and I_WR_N = '0' and I_ADR = X"4150") then ch4_base_adr(15 downto  8) <= I_DAT; ch4_current_adr(15 downto  8) <= I_DAT; end if;
		if (I_IORQ_N = '0' and I_WR_N = '0' and I_ADR = X"4250") then ch4_base_adr(23 downto 16) <= I_DAT; ch4_current_adr(23 downto 16) <= I_DAT; end if;
--		if (I_IORQ_N = '0' and I_WR_N = '0' and I_ADR = X"4350") then ch4_base_adr(31 downto 24) <= I_DAT; ch4_current_adr(31 downto 24) <= I_DAT; end if;
		if (I_IORQ_N = '0' and I_WR_N = '0' and I_ADR = X"4450") then ch4_base_count( 7 downto  0) <= I_DAT; ch4_current_count( 7 downto  0) <= I_DAT; end if;
		if (I_IORQ_N = '0' and I_WR_N = '0' and I_ADR = X"4550") then ch4_base_count(15 downto  8) <= I_DAT; ch4_current_count(15 downto  8) <= I_DAT; end if;
		if (I_IORQ_N = '0' and I_WR_N = '0' and I_ADR = X"4650") then ch4_base_count(23 downto 16) <= I_DAT; ch4_current_count(23 downto 16) <= I_DAT; end if;
--		if (I_IORQ_N = '0' and I_WR_N = '0' and I_ADR = X"4750") then ch4_base_count(31 downto 24) <= I_DAT; ch4_current_count(31 downto 24) <= I_DAT; end if;
		if (I_IORQ_N = '0' and I_WR_N = '0' and I_ADR = X"4850") then ch4_base_timer( 7 downto  0) <= I_DAT; end if;
		if (I_IORQ_N = '0' and I_WR_N = '0' and I_ADR = X"4950") then ch4_base_timer(15 downto  8) <= I_DAT; end if;
		if (I_IORQ_N = '0' and I_WR_N = '0' and I_ADR = X"4A50") then ch4_volume <= I_DAT(5 downto 0); end if;
		------------------------------------------------------------------------
		-- Channal 5
		if (I_IORQ_N = '0' and I_WR_N = '0' and I_ADR = X"5050") then ch5_base_adr( 7 downto  0) <= I_DAT; ch5_current_adr( 7 downto  0) <= I_DAT; end if;
		if (I_IORQ_N = '0' and I_WR_N = '0' and I_ADR = X"5150") then ch5_base_adr(15 downto  8) <= I_DAT; ch5_current_adr(15 downto  8) <= I_DAT; end if;
		if (I_IORQ_N = '0' and I_WR_N = '0' and I_ADR = X"5250") then ch5_base_adr(23 downto 16) <= I_DAT; ch5_current_adr(23 downto 16) <= I_DAT; end if;
--		if (I_IORQ_N = '0' and I_WR_N = '0' and I_ADR = X"5350") then ch5_base_adr(31 downto 24) <= I_DAT; ch5_current_adr(31 downto 24) <= I_DAT; end if;
		if (I_IORQ_N = '0' and I_WR_N = '0' and I_ADR = X"5450") then ch5_base_count( 7 downto  0) <= I_DAT; ch5_current_count( 7 downto  0) <= I_DAT; end if;
		if (I_IORQ_N = '0' and I_WR_N = '0' and I_ADR = X"5550") then ch5_base_count(15 downto  8) <= I_DAT; ch5_current_count(15 downto  8) <= I_DAT; end if;
		if (I_IORQ_N = '0' and I_WR_N = '0' and I_ADR = X"5650") then ch5_base_count(23 downto 16) <= I_DAT; ch5_current_count(23 downto 16) <= I_DAT; end if;
--		if (I_IORQ_N = '0' and I_WR_N = '0' and I_ADR = X"5750") then ch5_base_count(31 downto 24) <= I_DAT; ch5_current_count(31 downto 24) <= I_DAT; end if;
		if (I_IORQ_N = '0' and I_WR_N = '0' and I_ADR = X"5850") then ch5_base_timer( 7 downto  0) <= I_DAT; end if;
		if (I_IORQ_N = '0' and I_WR_N = '0' and I_ADR = X"5950") then ch5_base_timer(15 downto  8) <= I_DAT; end if;
		if (I_IORQ_N = '0' and I_WR_N = '0' and I_ADR = X"5A50") then ch5_volume <= I_DAT(5 downto 0); end if;
		------------------------------------------------------------------------
		-- Channal 6
		if (I_IORQ_N = '0' and I_WR_N = '0' and I_ADR = X"6050") then ch6_base_adr( 7 downto  0) <= I_DAT; ch6_current_adr( 7 downto  0) <= I_DAT; end if;
		if (I_IORQ_N = '0' and I_WR_N = '0' and I_ADR = X"6150") then ch6_base_adr(15 downto  8) <= I_DAT; ch6_current_adr(15 downto  8) <= I_DAT; end if;
		if (I_IORQ_N = '0' and I_WR_N = '0' and I_ADR = X"6250") then ch6_base_adr(23 downto 16) <= I_DAT; ch6_current_adr(23 downto 16) <= I_DAT; end if;
--		if (I_IORQ_N = '0' and I_WR_N = '0' and I_ADR = X"6350") then ch6_base_adr(31 downto 24) <= I_DAT; ch6_current_adr(31 downto 24) <= I_DAT; end if;
		if (I_IORQ_N = '0' and I_WR_N = '0' and I_ADR = X"6450") then ch6_base_count( 7 downto  0) <= I_DAT; ch6_current_count( 7 downto  0) <= I_DAT; end if;
		if (I_IORQ_N = '0' and I_WR_N = '0' and I_ADR = X"6550") then ch6_base_count(15 downto  8) <= I_DAT; ch6_current_count(15 downto  8) <= I_DAT; end if;
		if (I_IORQ_N = '0' and I_WR_N = '0' and I_ADR = X"6650") then ch6_base_count(23 downto 16) <= I_DAT; ch6_current_count(23 downto 16) <= I_DAT; end if;
--		if (I_IORQ_N = '0' and I_WR_N = '0' and I_ADR = X"6750") then ch6_base_count(31 downto 24) <= I_DAT; ch6_current_count(31 downto 24) <= I_DAT; end if;
		if (I_IORQ_N = '0' and I_WR_N = '0' and I_ADR = X"6850") then ch6_base_timer( 7 downto  0) <= I_DAT; end if;
		if (I_IORQ_N = '0' and I_WR_N = '0' and I_ADR = X"6950") then ch6_base_timer(15 downto  8) <= I_DAT; end if;
		if (I_IORQ_N = '0' and I_WR_N = '0' and I_ADR = X"6A50") then ch6_volume <= I_DAT(5 downto 0); end if;
		------------------------------------------------------------------------
		-- Channal 7
		if (I_IORQ_N = '0' and I_WR_N = '0' and I_ADR = X"7050") then ch7_base_adr( 7 downto  0) <= I_DAT; ch7_current_adr( 7 downto  0) <= I_DAT; end if;
		if (I_IORQ_N = '0' and I_WR_N = '0' and I_ADR = X"7150") then ch7_base_adr(15 downto  8) <= I_DAT; ch7_current_adr(15 downto  8) <= I_DAT; end if;
		if (I_IORQ_N = '0' and I_WR_N = '0' and I_ADR = X"7250") then ch7_base_adr(23 downto 16) <= I_DAT; ch7_current_adr(23 downto 16) <= I_DAT; end if;
--		if (I_IORQ_N = '0' and I_WR_N = '0' and I_ADR = X"7350") then ch7_base_adr(31 downto 24) <= I_DAT; ch7_current_adr(31 downto 24) <= I_DAT; end if;
		if (I_IORQ_N = '0' and I_WR_N = '0' and I_ADR = X"7450") then ch7_base_count( 7 downto  0) <= I_DAT; ch7_current_count( 7 downto  0) <= I_DAT; end if;
		if (I_IORQ_N = '0' and I_WR_N = '0' and I_ADR = X"7550") then ch7_base_count(15 downto  8) <= I_DAT; ch7_current_count(15 downto  8) <= I_DAT; end if;
		if (I_IORQ_N = '0' and I_WR_N = '0' and I_ADR = X"7650") then ch7_base_count(23 downto 16) <= I_DAT; ch7_current_count(23 downto 16) <= I_DAT; end if;
--		if (I_IORQ_N = '0' and I_WR_N = '0' and I_ADR = X"7750") then ch7_base_count(31 downto 24) <= I_DAT; ch7_current_count(31 downto 24) <= I_DAT; end if;
		if (I_IORQ_N = '0' and I_WR_N = '0' and I_ADR = X"7850") then ch7_base_timer( 7 downto  0) <= I_DAT; end if;
		if (I_IORQ_N = '0' and I_WR_N = '0' and I_ADR = X"7950") then ch7_base_timer(15 downto  8) <= I_DAT; end if;
		if (I_IORQ_N = '0' and I_WR_N = '0' and I_ADR = X"7A50") then ch7_volume <= I_DAT(5 downto 0); end if;
		

		if (I_IORQ_N = '0' and I_WR_N = '0' and I_ADR = X"8050") then ch_mixing <= I_DAT; end if;
		if (I_IORQ_N = '0' and I_WR_N = '0' and I_ADR = X"8150") then ch_loop   <= I_DAT; end if;
		if (I_IORQ_N = '0' and I_WR_N = '0' and I_ADR = X"8250") then ch_enable <= I_DAT; end if;

		------------------------------------------------------------------------
		-- Timer Channel 0
		if (ch_enable(0) = '1') then
			if (I_ENA = '1') then
				if (ch0_current_timer = ch0_base_timer) then
					ch0_current_timer <= (others => '0');
					ch0_req <= '1';
				else
					ch0_current_timer <= ch0_current_timer + 1;
				end if;
			end if;
		else
			ch0_current_timer <= (others => '0');
		end if;
		------------------------------------------------------------------------
		-- Timer Channel 1
		if (ch_enable(1) = '1') then
			if (I_ENA = '1') then
				if (ch1_current_timer = ch1_base_timer) then
					ch1_current_timer <= (others => '0');
					ch1_req <= '1';
				else
					ch1_current_timer <= ch1_current_timer + 1;
				end if;
			end if;
		else
			ch1_current_timer <= (others => '0');
		end if;
		------------------------------------------------------------------------
		-- Timer Channel 2
		if (ch_enable(2) = '1') then
			if (I_ENA = '1') then
				if (ch2_current_timer = ch2_base_timer) then
					ch2_current_timer <= (others => '0');
					ch2_req <= '1';
				else
					ch2_current_timer <= ch2_current_timer + 1;
				end if;
			end if;
		else
			ch2_current_timer <= (others => '0');
		end if;
		------------------------------------------------------------------------
		-- Timer Channel 3
		if (ch_enable(3) = '1') then
			if (I_ENA = '1') then
				if (ch3_current_timer = ch3_base_timer) then
					ch3_current_timer <= (others => '0');
					ch3_req <= '1';
				else
					ch3_current_timer <= ch3_current_timer + 1;
				end if;
			end if;
		else
			ch3_current_timer <= (others => '0');
		end if;
		------------------------------------------------------------------------
		-- Timer Channel 4
		if (ch_enable(4) = '1') then
			if (I_ENA = '1') then
				if (ch4_current_timer = ch4_base_timer) then
					ch4_current_timer <= (others => '0');
					ch4_req <= '1';
				else
					ch4_current_timer <= ch4_current_timer + 1;
				end if;
			end if;
		else
			ch4_current_timer <= (others => '0');
		end if;
		------------------------------------------------------------------------
		-- Timer Channel 5
		if (ch_enable(5) = '1') then
			if (I_ENA = '1') then
				if (ch5_current_timer = ch5_base_timer) then
					ch5_current_timer <= (others => '0');
					ch5_req <= '1';
				else
					ch5_current_timer <= ch5_current_timer + 1;
				end if;
			end if;
		else
			ch5_current_timer <= (others => '0');
		end if;
		------------------------------------------------------------------------
		-- Timer Channel 6
		if (ch_enable(6) = '1') then
			if (I_ENA = '1') then
				if (ch6_current_timer = ch6_base_timer) then
					ch6_current_timer <= (others => '0');
					ch6_req <= '1';
				else
					ch6_current_timer <= ch6_current_timer + 1;
				end if;
			end if;
		else
			ch6_current_timer <= (others => '0');
		end if;
		------------------------------------------------------------------------
		-- Timer Channel 7
		if (ch_enable(7) = '1') then
			if (I_ENA = '1') then
				if (ch7_current_timer = ch7_base_timer) then
					ch7_current_timer <= (others => '0');
					ch7_req <= '1';
				else
					ch7_current_timer <= ch7_current_timer + 1;
				end if;
			end if;
		else
			ch7_current_timer <= (others => '0');
		end if;

		------------------------------------------------------------------------
		-- DMA
		case state is
			-- Idle
			when '0' =>
				-- Channel 0
				if (ch0_req = '1' and (priority = "000" or (ch1_req = '0' and ch2_req = '0' and ch3_req = '0' and ch4_req = '0' and ch5_req = '0' and ch6_req = '0' and ch7_req = '0'))) then
					ch0_req <= '0';
					priority <= priority + 1;
					channal <= "000";
					temp_adr <= ch0_current_adr;
					temp_read <= '1';
					state <= '1';
					if (ch0_current_count = X"000000") then
						if (ch_loop(0) = '1') then
							ch0_current_adr <= ch0_base_adr;
							ch0_current_count <= ch0_base_count;
						else
							ch_enable(0) <= '0';
							temp_int <= '1';
						end if;
					else
						ch0_current_adr <= ch0_current_adr + 1;
						ch0_current_count <= ch0_current_count + X"FFFFFF";
					end if;
				-- Channel 1
				elsif (ch1_req = '1' and (priority = "001" or (ch0_req = '0' and ch2_req = '0' and ch3_req = '0' and ch4_req = '0' and ch5_req = '0' and ch6_req = '0' and ch7_req = '0'))) then
					ch1_req <= '0';
					priority <= priority + 1;
					channal <= "001";
					temp_adr <= ch1_current_adr;
					temp_read <= '1';
					state <= '1';
					if (ch1_current_count = X"000000") then
						if (ch_loop(1) = '1') then
							ch1_current_adr <= ch1_base_adr;
							ch1_current_count <= ch1_base_count;
						else
							ch_enable(1) <= '0';
							temp_int <= '1';
						end if;
					else
						ch1_current_adr <= ch1_current_adr + 1;
						ch1_current_count <= ch1_current_count + X"FFFFFF";
					end if;
				-- Channel 2
				elsif (ch2_req = '1' and (priority = "010" or (ch0_req = '0' and ch1_req = '0' and ch3_req = '0' and ch4_req = '0' and ch5_req = '0' and ch6_req = '0' and ch7_req = '0'))) then
					ch2_req <= '0';
					priority <= priority + 1;
					channal <= "010";
					temp_adr <= ch2_current_adr;
					temp_read <= '1';
					state <= '1';
					if (ch2_current_count = X"000000") then
						if (ch_loop(2) = '1') then
							ch2_current_adr <= ch2_base_adr;
							ch2_current_count <= ch2_base_count;
						else
							ch_enable(2) <= '0';
							temp_int <= '1';
						end if;
					else
						ch2_current_adr <= ch2_current_adr + 1;
						ch2_current_count <= ch2_current_count + X"FFFFFF";
					end if;
				-- Channel 3
				elsif (ch3_req = '1' and (priority = "011" or (ch0_req = '0' and ch1_req = '0' and ch2_req = '0' and ch4_req = '0' and ch5_req = '0' and ch6_req = '0' and ch7_req = '0'))) then
					ch3_req <= '0';
					priority <= priority + 1;
					channal <= "011";
					temp_adr <= ch3_current_adr;
					temp_read <= '1';
					state <= '1';
					if (ch3_current_count = X"000000") then
						if (ch_loop(0) = '1') then
							ch3_current_adr <= ch3_base_adr;
							ch3_current_count <= ch3_base_count;
						else
							ch_enable(3) <= '0';
							temp_int <= '1';
						end if;
					else
						ch3_current_adr <= ch3_current_adr + 1;
						ch3_current_count <= ch3_current_count + X"FFFFFF";
					end if;
				-- Channel 4
				elsif (ch4_req = '1' and (priority = "100" or (ch0_req = '0' and ch1_req = '0' and ch2_req = '0' and ch3_req = '0' and ch5_req = '0' and ch6_req = '0' and ch7_req = '0'))) then
					ch4_req <= '0';
					priority <= priority + 1;
					channal <= "100";
					temp_adr <= ch4_current_adr;
					temp_read <= '1';
					state <= '1';
					if (ch4_current_count = X"000000") then
						if (ch_loop(4) = '1') then
							ch4_current_adr <= ch4_base_adr;
							ch4_current_count <= ch4_base_count;
						else
							ch_enable(4) <= '0';
							temp_int <= '1';
						end if;
					else
						ch4_current_adr <= ch4_current_adr + 1;
						ch4_current_count <= ch4_current_count + X"FFFFFF";
					end if;
				-- Channel 5
				elsif (ch5_req = '1' and (priority = "101" or (ch0_req = '0' and ch1_req = '0' and ch2_req = '0' and ch3_req = '0' and ch4_req = '0' and ch6_req = '0' and ch7_req = '0'))) then
					ch5_req <= '0';
					priority <= priority + 1;
					channal <= "101";
					temp_adr <= ch5_current_adr;
					temp_read <= '1';
					state <= '1';
					if (ch5_current_count = X"000000") then
						if (ch_loop(5) = '1') then
							ch5_current_adr <= ch5_base_adr;
							ch5_current_count <= ch5_base_count;
						else
							ch_enable(5) <= '0';
							temp_int <= '1';
						end if;
					else
						ch5_current_adr <= ch5_current_adr + 1;
						ch5_current_count <= ch5_current_count + X"FFFFFF";
					end if;
				-- Channel 6
				elsif (ch6_req = '1' and (priority = "110" or (ch0_req = '0' and ch1_req = '0' and ch2_req = '0' and ch3_req = '0' and ch4_req = '0' and ch5_req = '0' and ch7_req = '0'))) then
					ch6_req <= '0';
					priority <= priority + 1;
					channal <= "110";
					temp_adr <= ch6_current_adr;
					temp_read <= '1';
					state <= '1';
					if (ch6_current_count = X"000000") then
						if (ch_loop(6) = '1') then
							ch6_current_adr <= ch6_base_adr;
							ch6_current_count <= ch6_base_count;
						else
							ch_enable(6) <= '0';
							temp_int <= '1';
						end if;
					else
						ch6_current_adr <= ch6_current_adr + 1;
						ch6_current_count <= ch6_current_count + X"FFFFFF";
					end if;
				-- Channel 7
				elsif (ch7_req = '1' and (priority = "111" or (ch0_req = '0' and ch1_req = '0' and ch2_req = '0' and ch3_req = '0' and ch4_req = '0' and ch5_req = '0' and ch6_req = '0'))) then
					ch7_req <= '0';
					priority <= priority + 1;
					channal <= "111";
					temp_adr <= ch7_current_adr;
					temp_read <= '1';
					state <= '1';
					if (ch7_current_count = X"000000") then
						if (ch_loop(7) = '1') then
							ch7_current_adr <= ch7_base_adr;
							ch7_current_count <= ch7_base_count;
						else
							ch_enable(7) <= '0';
							temp_int <= '1';
						end if;
					else
						ch7_current_adr <= ch7_current_adr + 1;
						ch7_current_count <= ch7_current_count + X"FFFFFF";
					end if;
				end if;
			------------------------------------------------------------------------
			when '1' =>
				if (I_MEM_ACK = '1') then
					case channal is
						when "000" => ch0_out <= I_MEM_DAT;
						when "001" => ch1_out <= I_MEM_DAT;
						when "010" => ch2_out <= I_MEM_DAT;
						when "011" => ch3_out <= I_MEM_DAT;
						when "100" => ch4_out <= I_MEM_DAT;
						when "101" => ch5_out <= I_MEM_DAT;
						when "110" => ch6_out <= I_MEM_DAT;
						when "111" => ch7_out <= I_MEM_DAT;
						when others => null;
					end case;
					state <= '0';
					temp_read <= '0';
				end if;
			when others => null;
		end case;

	end if;

	------------------------------------------------------------------------
	-- Port OUT
	if (I_ADR(15 downto 8) = X"82") then O_DAT <= ch_enable; else O_DAT <= (others => '1'); end if;	
	
	------------------------------------------------------------------------
	-- Volume Channal
	ch0_volume_out <= ch0_out * ch0_volume;
	ch1_volume_out <= ch1_out * ch1_volume;
	ch2_volume_out <= ch2_out * ch2_volume;
	ch3_volume_out <= ch3_out * ch3_volume;
	ch4_volume_out <= ch4_out * ch4_volume;
	ch5_volume_out <= ch5_out * ch5_volume;
	ch6_volume_out <= ch6_out * ch6_volume;
	ch7_volume_out <= ch7_out * ch7_volume;

	------------------------------------------------------------------------
	-- Mixing Channal
	if ch_mixing(0) = '1' then left_stream0 <= ch0_volume_out; else left_stream0 <= (others => '0'); end if;
	if ch_mixing(1) = '1' then left_stream1 <= ch1_volume_out; else left_stream1 <= (others => '0'); end if;
	if ch_mixing(2) = '1' then left_stream2 <= ch2_volume_out; else left_stream2 <= (others => '0'); end if;
	if ch_mixing(3) = '1' then left_stream3 <= ch3_volume_out; else left_stream3 <= (others => '0'); end if;
	
	if ch_mixing(4) = '1' then right_stream0 <= ch4_volume_out; else right_stream0 <= (others => '0'); end if;
	if ch_mixing(5) = '1' then right_stream1 <= ch5_volume_out; else right_stream1 <= (others => '0'); end if;
	if ch_mixing(6) = '1' then right_stream2 <= ch6_volume_out; else right_stream2 <= (others => '0'); end if;
	if ch_mixing(7) = '1' then right_stream3 <= ch7_volume_out; else right_stream3 <= (others => '0'); end if;

end process;

------------------------------------------------------------------------
O_MEM_ADR <= temp_adr;
O_MEM_RD  <= temp_read;
O_INT     <= temp_int;
O_LEFT    <= ("000" & ch7_volume_out) + ("000" & ch6_volume_out) + ("000" & ch5_volume_out) + ("000" & ch4_volume_out) + ("000" & left_stream3) + ("000" & left_stream2) + ("000" & left_stream1) + ("000" & left_stream0);
O_RIGHT   <= ("000" & ch3_volume_out) + ("000" & ch2_volume_out) + ("000" & ch1_volume_out) + ("000" & ch0_volume_out) + ("000" & right_stream3) + ("000" & right_stream2) + ("000" & right_stream1) + ("000" & right_stream0);

end rtl;

