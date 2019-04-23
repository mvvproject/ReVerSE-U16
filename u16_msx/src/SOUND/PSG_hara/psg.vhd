-- 
-- psg.vhd
--	 Programmable Sound Generator (AY-3-8910/YM2149)
--	 Revision 1.00
-- 
-- Copyright (c) 2006 Kazuhiro Tsujikawa (ESE Artists' factory)
-- All rights reserved.
-- 
-- Redistribution and use of this source code or any derivative works, are 
-- permitted provided that the following conditions are met:
--
-- 1. Redistributions of source code must retain the above copyright notice, 
--		this list of conditions and the following disclaimer.
-- 2. Redistributions in binary form must reproduce the above copyright 
--		notice, this list of conditions and the following disclaimer in the 
--		documentation and/or other materials provided with the distribution.
-- 3. Redistributions may not be sold, nor may they be used in a commercial 
--		product or activity without specific prior written permission.
--
-- THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS 
-- "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED 
-- TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR 
-- PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR 
-- CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, 
-- EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, 
-- PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
-- OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, 
-- WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR 
-- OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF 
-- ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
-- 

-- 2006/12/29 modified by t.hara

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity psg is
	port(
		clk21m		: in	std_logic;
		reset		: in	std_logic;
		clkena		: in	std_logic;
		req			: in	std_logic;
		ack			: out	std_logic;
		wrt			: in	std_logic;
		adr			: in	std_logic_vector( 15 downto 0 );
		dbi			: out	std_logic_vector(  7 downto 0 );
		dbo			: in	std_logic_vector(  7 downto 0 );

		joya		: inout	std_logic_vector(  5 downto 0 );
		stra		: out	std_logic;
		joyb		: inout	std_logic_vector(  5 downto 0 );
		strb		: out	std_logic;

		kana		: out	std_logic;
		cmtin		: in	std_logic;
		keymode 	: in	std_logic;

		wave		: out	std_logic_vector(  9 downto 0 )
 );
end psg;

architecture rtl of psg is

	component psg_wave
		port(
			clk21m		: in	std_logic;
			reset		: in	std_logic;
			clkena		: in	std_logic;
			req			: in	std_logic;
			ack			: out	std_logic;
			wrt			: in	std_logic;
			adr			: in	std_logic_vector( 15 downto 0 );
			dbi			: out	std_logic_vector(  7 downto 0 );
			dbo			: in	std_logic_vector(  7 downto 0 );
			wave		: out	std_logic_vector(  9 downto 0 );
			reg_index	: in	std_logic_vector(  3 downto 0 )
		);
	end component;

	-- PSG signals
	signal w_wave_dbi	: std_logic_vector(  7 downto 0 );
	signal ff_reg_index	: std_logic_vector(  3 downto 0 );

	signal ff_reg_a		: std_logic_vector(  7 downto 0 );
	signal ff_reg_b		: std_logic_vector(  7 downto 0 );

	signal w_joy_sel	: std_logic_vector(  5 downto 0 );
begin

	----------------------------------------------------------------
	-- PSG register read
	----------------------------------------------------------------
	dbi <=	 ff_reg_a when ff_reg_index = "1110" and adr(1 downto 0) = "10" else
			 ff_reg_b when ff_reg_index = "1111" and adr(1 downto 0) = "10" else
			 w_wave_dbi;

	----------------------------------------------------------------
	-- PSG register write
	----------------------------------------------------------------
	process( reset, clk21m )
	begin
		if( reset = '1' )then
			ff_reg_index	<= (others => '0');
		elsif( clk21m'event and clk21m = '1' )then
			if( req = '1' and wrt = '1' and adr(1 downto 0) = "00" )then
				ff_reg_index <= dbo(3 downto 0);
			end if;
		end if;
	end process;

	process( reset, clk21m )
	begin
		if( reset = '1' )then
			ff_reg_b	<= (others => '0');
		elsif( clk21m'event and clk21m = '1' )then
			if( req = '1' and wrt = '1' and adr(1 downto 0) = "01" )then
				if( ff_reg_index = "1111" ) then
					ff_reg_b <= dbo;
				end if;
			end if;
		end if;

	end process;

	----------------------------------------------------------------
	--	ff_reg_a
	----------------------------------------------------------------
	w_joy_sel	<=	joya when( ff_reg_b(6) = '0' )else
					joyb;

	process( reset, clk21m )
	begin
		if( reset = '1' )then
			ff_reg_a	<= (others => '0');
		elsif( clk21m'event and clk21m = '1' )then
			ff_reg_a(7)			<= cmtin;		-- Cassete voice input : always '0' on MSX turboR
			ff_reg_a(6)			<= keymode;		-- KeyBoard mode : 1=JIS
			ff_reg_a(5 downto 0)<= w_joy_sel;
		end if;
	end process;

	process( reset, clk21m )
	begin
		if( reset = '1' )then
			joya		<= (others => 'Z');
		elsif( clk21m'event and clk21m = '1' )then
			-- Trigger A/B output Joystick PortA
			case ff_reg_b( 1 downto 0 ) is
				when "00"	=> joya <= "00ZZZZ";
				when "01"	=> joya <= "0ZZZZZ";
				when "10"	=> joya <= "Z0ZZZZ";
				when "11"	=> joya <= "ZZZZZZ";
				when others	=> joya <= "XXXXXX";
			end case;
		end if;
	end process;

	process( reset, clk21m )
	begin
		if( reset = '1' )then
			joyb		<= (others => 'Z');
		elsif( clk21m'event and clk21m = '1' )then
			-- Trigger A/B output Joystick PortB
			case ff_reg_b( 3 downto 2 ) is
				when "00"	=> joyb <= "00ZZZZ";
				when "01"	=> joyb <= "0ZZZZZ";
				when "10"	=> joyb <= "Z0ZZZZ";
				when "11"	=> joyb <= "ZZZZZZ";
				when others	=> joyb <= "XXXXXX";
			end case;
		end if;
	end process;

	process( reset, clk21m )
	begin
		if( reset = '1' )then
			kana	<= '0';
		elsif( clk21m'event and clk21m = '1' )then
			kana	<= ff_reg_b(7);	-- KANA-LED : 0=ON, Z=OFF
		end if;
	end process;

	process( reset, clk21m )
	begin
		if( reset = '1' )then
			strb	<= '0';
			stra	<= '0';
		elsif( clk21m'event and clk21m = '1' )then
			-- Strobe output
			strb	<= ff_reg_b(5);
			stra	<= ff_reg_b(4);
		end if;
	end process;

	----------------------------------------------------------------
	-- Connect components
	----------------------------------------------------------------
	i_psg_wave : psg_wave
	port map(
		clk21m		=> clk21m,
		reset		=> reset,
		clkena		=> clkena,
		req			=> req,
		ack			=> ack,
		wrt			=> wrt,
		adr			=> adr,
		dbi			=> w_wave_dbi,
		dbo			=> dbo,
		wave		=> wave,
		reg_index	=> ff_reg_index
	);

end rtl;
