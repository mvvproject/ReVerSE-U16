-- ****
-- T80(b) core. In an effort to merge and maintain bug fixes ....
--
--
-- Ver 300 started tidyup
-- MikeJ March 2005
-- Latest version from www.fpgaarcade.com (original www.opencores.org)
--
-- ****
-- ** CUSTOM 2 CLOCK MEMORY ACCESS FOR PACMAN, MIKEJ **
--
-- Z80 compatible microprocessor core, synchronous top level with clock enable
-- Different timing than the original z80
-- Inputs needs to be synchronous and outputs may glitch
--
-- Version : 0238
--
-- Copyright (c) 2001-2002 Daniel Wallner (jesus@opencores.org)
--
-- All rights reserved
--
-- Redistribution and use in source and synthezised forms, with or without
-- modification, are permitted provided that the following conditions are met:
--
-- Redistributions of source code must retain the above copyright notice,
-- this list of conditions and the following disclaimer.
--
-- Redistributions in synthesized form must reproduce the above copyright
-- notice, this list of conditions and the following disclaimer in the
-- documentation and/or other materials provided with the distribution.
--
-- Neither the name of the author nor the names of other contributors may
-- be used to endorse or promote products derived from this software without
-- specific prior written permission.
--
-- THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
-- AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
-- THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
-- PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE
-- LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
-- CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
-- SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
-- INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
-- CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
-- ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
-- POSSIBILITY OF SUCH DAMAGE.
--
-- Please report bugs to the author, but before you do so, please
-- make sure that this is not a derivative work and that
-- you have the latest version of this file.
--
-- The latest version of this file can be found at:
--      http://www.opencores.org/cvsweb.shtml/t80/
--
-- Limitations :
--
-- File history :
--
--      0235 : First release
--
--      0236 : Added T2Write generic
--
--      0237 : Fixed T2Write with wait state
--
--      0238 : Updated for T80 interface change
--
--      0242 : Updated for T80 interface change
--

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.T80_Pack.all;

entity T80CPU is
	port(
		RESET_N_I	: in  std_logic;
		CLK_N_I		: in  std_logic;
		CLKEN_I		: in  std_logic;
		WAIT_N_I	: in  std_logic;
		INT_N_I		: in  std_logic;
		NMI_N_I		: in  std_logic;
		BUSRQ_N_I	: in  std_logic;
		DATA_I			: in  std_logic_vector(7 downto 0);
		DATA_O			: out std_logic_vector(7 downto 0);
		ADDR_O			: out std_logic_vector(15 downto 0);
		M1_N_O		: out std_logic;
		MREQ_N_O	: out std_logic;
		IORQ_N_O	: out std_logic;
		RD_N_O		: out std_logic;
		WR_N_O		: out std_logic;
		RFSH_N_O	: out std_logic;
		HALT_N_O	: out std_logic;
		BUSAK_N_O	: out std_logic
	);
end T80CPU;

architecture RTL of T80CPU is

	signal IntCycle_n	: std_logic;
	signal NoRead		: std_logic;
	signal Write		: std_logic;
	signal IORQ			: std_logic;
	signal DI_Reg		: std_logic_vector(7 downto 0);
	signal MCycle		: std_logic_vector(2 downto 0);
	signal TState		: std_logic_vector(2 downto 0);

begin

	u0 : T80
		generic map(
			Mode			=> 1,
			IOWait		=> 1)
		port map(
			CEN			=> CLKEN_I,
			M1_n			=> M1_N_O,
			IORQ			=> IORQ,
			NoRead		=> NoRead,
			Write			=> Write,
			RFSH_n		=> RFSH_N_O,
			HALT_n		=> HALT_N_O,
			WAIT_n		=> WAIT_N_I,
			INT_n			=> INT_N_I,
			NMI_n			=> NMI_N_I,
			RESET_n		=> RESET_N_I,
			BUSRQ_n		=> BUSRQ_N_I,
			BUSAK_n		=> BUSAK_N_O,
			CLK_n			=> CLK_N_I,
			A				=> ADDR_O,
			DInst			=> DATA_I,
			DI				=> DI_Reg,
			DO				=> DATA_O,
			MC				=> MCycle,
			TS				=> TState,
			IntCycle_n	=> IntCycle_n);

	process (RESET_N_I, CLK_N_I)
	begin
		if RESET_N_I = '0' then
			RD_N_O <= '1';
			WR_N_O <= '1';
			IORQ_N_O <= '1';
			MREQ_N_O <= '1';
			DI_Reg <= "00000000";
		elsif CLK_N_I'event and CLK_N_I = '1' then
			if CLKEN_I = '1' then
				RD_N_O <= '1';
				WR_N_O <= '1';
				IORQ_N_O <= '1';
				MREQ_N_O <= '1';
				if MCycle = "001" then
					if TState = "001" or (TState = "010" and WAIT_N_I = '0') then
						RD_N_O <= not IntCycle_n;
						MREQ_N_O <= not IntCycle_n;
						IORQ_N_O <= IntCycle_n;
					end if;
					if TState = "011" then
						MREQ_N_O <= '0';
					end if;
				else
					if (TState = "001" or TState = "010") and NoRead = '0' and Write = '0' then
						RD_N_O <= '0';
						IORQ_N_O <= not IORQ;
						MREQ_N_O <= IORQ;
					end if;
						if ((TState = "001") or (TState = "010")) and Write = '1' then
							WR_N_O <= '0';
							IORQ_N_O <= not IORQ;
							MREQ_N_O <= IORQ;
						end if;
				end if;
				if TState = "010" and WAIT_N_I = '1' then
					DI_Reg <= DATA_I;
				end if;
			end if;
		end if;
	end process;

end;
