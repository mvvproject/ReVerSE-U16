-- 
-- psg_wave.vhd
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

entity psg_wave is
	port(
		clk21m		: in	std_logic;
		reset		: in	std_logic;
		clkena		: in	std_logic;
		req		: in	std_logic;
		ack		: out	std_logic;
		wrt		: in	std_logic;
		adr		: in	std_logic_vector( 15 downto 0 );
		dbi		: out	std_logic_vector(  7 downto 0 );
		dbo		: in	std_logic_vector(  7 downto 0 );
		wave		: out	std_logic_vector(  9 downto 0 );
		reg_index	: in	std_logic_vector(  3 downto 0 )
	);
end psg_wave;

architecture rtl of psg_wave is

	signal clk_div_cnt	: std_logic_vector(  4 downto 0 );

	signal ff_ch_a_rect	: std_logic;
	signal ff_ch_b_rect	: std_logic;
	signal ff_ch_c_rect	: std_logic;
	signal w_noise		: std_logic;
	signal ff_vol_env	: std_logic_vector(  3 downto 0 );
	signal ff_env_req	: std_logic;

	signal ff_ch_a_freq	: std_logic_vector( 11 downto 0 );
	signal ff_ch_b_freq	: std_logic_vector( 11 downto 0 );
	signal ff_ch_c_freq	: std_logic_vector( 11 downto 0 );
	signal ff_noise_freq	: std_logic_vector(  4 downto 0 );
	signal ff_ch_off	: std_logic_vector(  5 downto 0 );
	signal ff_ch_a_vol	: std_logic_vector(  4 downto 0 );
	signal ff_ch_b_vol	: std_logic_vector(  4 downto 0 );
	signal ff_ch_c_vol	: std_logic_vector(  4 downto 0 );
	signal ff_env_freq	: std_logic_vector( 15 downto 0 );
	signal ff_env_pat	: std_logic_vector(  3 downto 0 );

	signal w_112khz		: std_logic;
	signal w_56khz		: std_logic;

	signal ff_freq_cnt_ch_a	: std_logic_vector( 11 downto 0 );
	signal ff_freq_cnt_ch_b	: std_logic_vector( 11 downto 0 );
	signal ff_freq_cnt_ch_c	: std_logic_vector( 11 downto 0 );
	signal ff_freq_cnt_noise : std_logic_vector(  4 downto 0 );
	signal ff_noise_gen	: std_logic_vector( 17 downto 0 );
	signal ff_cnt_env	: std_logic_vector( 15 downto 0 );
	signal ff_env_ptr	: std_logic_vector(  4 downto 0 );
	signal w_env_pat	: std_logic_vector(  3 downto 0 );

	alias state			: std_logic_vector(  1 downto 0 ) is clk_div_cnt(  1 downto 0 );
	signal w_tone_off	: std_logic;
	signal w_cur_edge	: std_logic;
	signal w_noise_off	: std_logic;
	signal w_cur_vol	: std_logic_vector(  4 downto 0 );
	signal ff_mixer		: std_logic_vector(  9 downto 0 );
	signal ff_wave		: std_logic_vector(  9 downto 0 );

	signal w_cur_vol_level	: std_logic_vector(  3 downto 0 );
	signal w_cur_vol_log	: std_logic_vector(  7 downto 0 );

	alias hold		: std_logic is ff_env_pat( 0 );
	alias alter		: std_logic is ff_env_pat( 1 );
	alias attack	: std_logic is ff_env_pat( 2 );
	alias cont		: std_logic is ff_env_pat( 3 );

	constant all_zero	: std_logic_vector( 15 downto 0 ) := (others => '0');
begin

	----------------------------------------------------------------
	-- Miscellaneous control / clock enable (divider)
	----------------------------------------------------------------
	process( reset, clk21m )
	begin
		if( reset = '1' )then
			clk_div_cnt <= (others => '0');
		elsif( clk21m'event and clk21m = '1' )then
			if (clkena = '1') then
				clk_div_cnt <= clk_div_cnt - 1;
			end if;
		end if;
	end process;

	-- 112kHz = 3.58MHz / 16 / 2
	w_112khz <= '1'	when( clk_div_cnt(3 downto 0) = "0000"  and clkena = '1' )else
			'0';
	-- 56kHz = 3.58MHz / 32 / 2
	w_56khz	 <= '1'	when( clk_div_cnt(4 downto 0) = "00000" and clkena = '1' )else
			'0';

	ack <= req;

	----------------------------------------------------------------
	-- PSG register read
	----------------------------------------------------------------
	dbi <=		 ff_ch_a_freq( 7 downto 0)	when( reg_index = "0000" and adr( 1 downto 0 ) = "10" )else
		"0000" & ff_ch_a_freq(11 downto 8)	when( reg_index = "0001" and adr( 1 downto 0 ) = "10" )else
			 ff_ch_b_freq( 7 downto 0)	when( reg_index = "0010" and adr( 1 downto 0 ) = "10" )else
		"0000" & ff_ch_b_freq(11 downto 8)	when( reg_index = "0011" and adr( 1 downto 0 ) = "10" )else
			 ff_ch_c_freq( 7 downto 0)	when( reg_index = "0100" and adr( 1 downto 0 ) = "10" )else
		"0000" & ff_ch_c_freq(11 downto 8)	when( reg_index = "0101" and adr( 1 downto 0 ) = "10" )else
		"000"  & ff_noise_freq			when( reg_index = "0110" and adr( 1 downto 0 ) = "10" )else
		"10"   & ff_ch_off				when( reg_index = "0111" and adr( 1 downto 0 ) = "10" )else
		"000"  & ff_ch_a_vol			when( reg_index = "1000" and adr( 1 downto 0 ) = "10" )else
		"000"  & ff_ch_b_vol			when( reg_index = "1001" and adr( 1 downto 0 ) = "10" )else
		"000"  & ff_ch_c_vol			when( reg_index = "1010" and adr( 1 downto 0 ) = "10" )else
			 ff_env_freq(7 downto 0)	when( reg_index = "1011" and adr( 1 downto 0 ) = "10" )else
			 ff_env_freq(15 downto 8)	when( reg_index = "1100" and adr( 1 downto 0 ) = "10" )else
		"0000" & ff_env_pat				when( reg_index = "1101" and adr( 1 downto 0 ) = "10" )else
		(others => '1');

	----------------------------------------------------------------
	-- PSG register write
	----------------------------------------------------------------
	process( reset, clk21m )
	begin
		if (reset = '1') then
			ff_ch_a_freq	<= (others => '1');
			ff_ch_b_freq	<= (others => '1');
			ff_ch_c_freq	<= (others => '1');
			ff_noise_freq	<= (others => '1');
			ff_ch_off	<= (others => '1');
			ff_ch_a_vol	<= (others => '1');
			ff_ch_b_vol	<= (others => '1');
			ff_ch_c_vol	<= (others => '1');
			ff_env_freq	<= (others => '1');
			ff_env_pat	<= (others => '1');
		elsif (clk21m'event and clk21m = '1') then
			if (req = '1' and wrt = '1' and adr(1 downto 0) = "01") then
				-- PSG registers
				case reg_index is
					when "0000" => ff_ch_a_freq(  7 downto 0 ) <= dbo;
					when "0001" => ff_ch_a_freq( 11 downto 8 ) <= dbo( 3 downto 0 );
					when "0010" => ff_ch_b_freq(  7 downto 0 ) <= dbo;
					when "0011" => ff_ch_b_freq( 11 downto 8 ) <= dbo( 3 downto 0 );
					when "0100" => ff_ch_c_freq(  7 downto 0 ) <= dbo;
					when "0101" => ff_ch_c_freq( 11 downto 8 ) <= dbo( 3 downto 0 );
					when "0110" => ff_noise_freq		   <= dbo( 4 downto 0 );
					when "0111" => ff_ch_off		   <= dbo( 5 downto 0 );
					when "1000" => ff_ch_a_vol		   <= dbo( 4 downto 0 );
					when "1001" => ff_ch_b_vol		   <= dbo( 4 downto 0 );
					when "1010" => ff_ch_c_vol		   <= dbo( 4 downto 0 );
					when "1011" => ff_env_freq(7 downto 0)	   <= dbo;
					when "1100" => ff_env_freq(15 downto 8)	   <= dbo;
					when "1101" => ff_env_pat		   <= dbo( 3 downto 0 );
					when others => null;
				end case;
			end if;
		end if;
	end process;

	-- envelope ptr reset request
	process( reset, clk21m )
	begin
		if (reset = '1') then
			ff_env_req <= '0';
		elsif (clk21m'event and clk21m = '1') then
			if (req = '1' and wrt = '1' and adr(1 downto 0) = "01") then
				if( reg_index = "1101" )then
					ff_env_req <= '1';
				end if;
			elsif( w_56khz = '1' )then
				ff_env_req <= '0';
			end if;
		end if;
	end process;

	----------------------------------------------------------------
	-- Tone generator (CH.A)
	----------------------------------------------------------------
	process( reset, clk21m )
	begin
		if( reset = '1' )then
			ff_freq_cnt_ch_a <= (others => '0');
		elsif( clk21m'event and clk21m = '1' )then
			if( w_112khz = '1' )then
				if( ff_freq_cnt_ch_a( 11 downto 1 ) = all_zero( 11 downto 1 ) )then
					ff_freq_cnt_ch_a <= ff_ch_a_freq;
				else
					ff_freq_cnt_ch_a <= ff_freq_cnt_ch_a - 1;
				end if;
			end if;
		end if;
	end process;

	process( reset, clk21m )
	begin
		if( reset = '1' )then
			ff_ch_a_rect	<= '0';
		elsif( clk21m'event and clk21m = '1' )then
			if( w_112khz = '1' )then
				if( ff_freq_cnt_ch_a = X"001" )then
					ff_ch_a_rect <= not ff_ch_a_rect;
				end if;
			end if;
		end if;
	end process;

	----------------------------------------------------------------
	-- Tone generator (CH.B)
	----------------------------------------------------------------
	process( reset, clk21m )
	begin
		if( reset = '1' )then
			ff_freq_cnt_ch_b <= (others => '0');
		elsif( clk21m'event and clk21m = '1' )then
			if( w_112khz = '1' ) then
				if( ff_freq_cnt_ch_b( 11 downto 1 ) = all_zero( 11 downto 1 ) )then
					ff_freq_cnt_ch_b <= ff_ch_b_freq;
				else
					ff_freq_cnt_ch_b <= ff_freq_cnt_ch_b - 1;
				end if;
			end if;
		end if;
	end process;

	process( reset, clk21m )
	begin
		if( reset = '1' )then
			ff_ch_b_rect	<= '0';
		elsif( clk21m'event and clk21m = '1' )then
			if( w_112khz = '1' ) then
				if (ff_freq_cnt_ch_b = X"001") then
					ff_ch_b_rect <= not ff_ch_b_rect;
				end if;
			end if;
		end if;
	end process;

	----------------------------------------------------------------
	-- Tone generator (CH.C)
	----------------------------------------------------------------
	process( reset, clk21m )
	begin
		if( reset = '1' )then
			ff_freq_cnt_ch_c <= (others => '0');
		elsif( clk21m'event and clk21m = '1' )then
			if( w_112khz = '1' )then
				if( ff_freq_cnt_ch_c( 11 downto 1 ) = all_zero( 11 downto 1 ) )then
					ff_freq_cnt_ch_c <= ff_ch_c_freq;
				else
					ff_freq_cnt_ch_c <= ff_freq_cnt_ch_c - 1;
				end if;
			end if;
		end if;
	end process;

	process( reset, clk21m )
	begin
		if( reset = '1' )then
			ff_ch_c_rect	<= '0';
		elsif( clk21m'event and clk21m = '1' )then
			if( w_112khz = '1' )then
				if (ff_freq_cnt_ch_c = X"001") then
					ff_ch_c_rect <= not ff_ch_c_rect;
				end if;
			end if;
		end if;
	end process;

	----------------------------------------------------------------
	-- Noise generator 
	----------------------------------------------------------------
	process( reset, clk21m )
	begin
		if( reset = '1' )then
			ff_freq_cnt_noise <= (others => '0');
		elsif( clk21m'event and clk21m = '1' )then
			if( w_112khz = '1' )then
				-- Noise frequency counter
				if( ff_freq_cnt_noise( 4 downto 1 ) = "0000" )then
					ff_freq_cnt_noise <= ff_noise_freq;
				else
					ff_freq_cnt_noise <= ff_freq_cnt_noise - 1;
				end if;
			end if;
		end if;
	end process;

	process( reset, clk21m )
	begin
		if( reset = '1' )then
			ff_noise_gen <= (others => '1');
		elsif( clk21m'event and clk21m = '1' )then
			if( w_112khz = '1' )then
				-- 18bit maximum length code 
				if (ff_freq_cnt_noise = "00001") then
					ff_noise_gen( 17 downto 1 ) <= ff_noise_gen( 16 downto 0 );
					ff_noise_gen( 0 )           <= ff_noise_gen( 16 ) xor ff_noise_gen( 13 );
				end if;
			end if;
		end if;
	end process;

	w_noise <= ff_noise_gen( 17 );

	----------------------------------------------------------------
	-- Envelope generator
	----------------------------------------------------------------

	-- Envelope period counter
	process( reset, clk21m )
	begin
		if( reset = '1' )then
			ff_cnt_env <= (others => '0');
		elsif( clk21m'event and clk21m = '1' )then
			if( w_56khz = '1' )then
				if( (ff_env_req = '1') or (ff_cnt_env( 15 downto 1 ) = all_zero( 15 downto 1 )) )then
					ff_cnt_env <= ff_env_freq;
				else
					ff_cnt_env <= ff_cnt_env - 1;
				end if;
			end if;
		end if;
	end process;

	-- Envelope phase counter
	process( reset, clk21m )
	begin
		if( reset = '1' )then
			ff_env_ptr <= (others => '1');
		elsif( clk21m'event and clk21m = '1' )then
			if( w_56khz = '1' )then
				if( ff_env_req = '1' )then
					ff_env_ptr <= (others => '1');
				elsif( (ff_cnt_env = X"0001") and (ff_env_ptr(4) = '1' or (hold = '0' and cont = '1')))then
					ff_env_ptr <= ff_env_ptr - 1;
				end if;
			end if;
		end if;
	end process;

	-- Envelope amplitude control
	w_env_pat <= ff_env_ptr( 3 downto 0 ) when( attack = '0' )else
		     not ff_env_ptr( 3 downto 0 );

	process( reset, clk21m )
	begin
		if( reset = '1' )then
			ff_vol_env <= (others => '0');
		elsif( clk21m'event and clk21m = '1' )then
			if( w_56khz = '1' )then
				if( (ff_env_ptr(4) = '0') and (cont = '0') )then
					ff_vol_env <= (others => '0');
				elsif( (ff_env_ptr(4) = '1') or ((alter xor hold) = '0') )then
					ff_vol_env <= w_env_pat;
				else
					ff_vol_env <= not w_env_pat;
				end if;
			end if;
		end if;
	end process;

	----------------------------------------------------------------
	-- Mixer
	--
	--	state		X   3  X   2  X   1  X   0  X   3  X   2  X   1  X   0  X   3  X   2  X   1  X   0  X
	--	w_tone_off	X ch.A X ch.B X ch.C X   1  X ch.A X ch.B X ch.C X   1  X 
	--	w_cur_edge	X ch.A X ch.B X ch.C X   1  X ch.A X ch.B X ch.C X   1  X 
 	--	w_noise_off	X ch.A X ch.B X ch.C X   1  X ch.A X ch.B X ch.C X   1  X 
	--	w_cur_vol	X ch.A X ch.B X ch.C X   0  X ch.A X ch.B X ch.C X   0  X 
	--	ff_mixer	X    0 X    A X   AB X  ABC X    0 X    A X   AB X  ABC X
	--	ff_wave		                            X  ABC                      X  ABC
	--	wave		                            X  ABC                      X  ABC
	----------------------------------------------------------------
	with state select w_tone_off <=
		ff_ch_off(0)	when "11",
		ff_ch_off(1)	when "10",
		ff_ch_off(2)	when "01",
		'1'				when others;

	with state select w_cur_edge <=
		ff_ch_a_rect	when "11",
		ff_ch_b_rect	when "10",
		ff_ch_c_rect	when "01",
		'1'				when others;

	with state select w_noise_off <=
		ff_ch_off(3)	when "11",
		ff_ch_off(4)	when "10",
		ff_ch_off(5)	when "01",
		'1'				when others;

	with state select w_cur_vol <=
		ff_ch_a_vol		when "11",
		ff_ch_b_vol		when "10",
		ff_ch_c_vol		when "01",
		"00000"			when others;

	w_cur_vol_level	<= (others => '0') 	when( ((w_tone_off or w_cur_edge) and (w_noise_off or w_noise)) = '0' ) else
			    w_cur_vol( 3 downto 0 )	when( w_cur_vol(4) = '0' ) else
			    ff_vol_env;

	with w_cur_vol_level select w_cur_vol_log <=
		"11111111" when "1111",	--	15 -> 255
		"10110100" when "1110",	--	14 -> 180
		"01111111" when "1101",	--	13 -> 127
		"01011010" when "1100",	--	12 -> 90
		"00111111" when "1011",	--	11 -> 63
		"00101101" when "1010",	--	10 -> 45
		"00011111" when "1001",	--	9  -> 31
		"00010110" when "1000",	--	8  -> 22
		"00001111" when "0111",	--	7  -> 15
		"00001011" when "0110",	--	6  -> 11
		"00000111" when "0101",	--	5  -> 7
		"00000101" when "0100",	--	4  -> 5
		"00000011" when "0011",	--	3  -> 3
		"00000010" when "0010",	--	2  -> 2
		"00000001" when "0001",	--	1  -> 1
		"00000000" when others;	--	0  -> 0

	process( reset, clk21m )
	begin
		if( reset = '1' )then
			ff_mixer <= (others => '0');
		elsif( clk21m'event and clk21m = '1' )then
			if( clkena = '1' )then
				if( state = "00" )then
					ff_mixer <= (others => '0');
				else
					ff_mixer <= ff_mixer + ("00" & w_cur_vol_log);
				end if;
			end if;
		end if;
	end process;

	process( reset, clk21m )
	begin
		if( reset = '1' )then
			ff_wave	<= (others => '0');
		elsif( clk21m'event and clk21m = '1' )then
			if( clkena = '1' ) then
				if( state = "00" )then
					ff_wave	<= ff_mixer(9 downto 0);
				else
					-- hold
				end if;
			end if;
		end if;
	end process;
	wave <= ff_wave;

end rtl;
