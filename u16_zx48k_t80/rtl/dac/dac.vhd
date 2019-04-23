-------------------------------------------------------------------------------
-- Delta-Sigma DAC
--
-- This DAC requires an external RC low-pass filter:
--
--   DAC_O 0---XXXXX---+---0 analog audio
--                3k3    |
--                      === 4n7
--                       |
--                      GND
--
-- For example, for an 8-bit DAC (msbi_g = 7) the lowest VOUT is 0V when
-- DACin is 0. The highest VOUT is 255/256 VCCO volts when DACin is 0xFF.
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity dac is

  generic (
    msbi_g : integer := 1
  );
  port (
    CLK_I   	: in  std_logic;
    RESET_I 	: in  std_logic;
    DAC_DATA_I	: in  std_logic_vector(msbi_g downto 0);
    DAC_O   	: out std_logic
  );

end dac;

library ieee;
use ieee.numeric_std.all;

architecture rtl of dac is

  signal DACout_q : std_logic;
  signal DeltaAdder_s,
         SigmaAdder_s,
         SigmaLatch_q,
         DeltaB_s : unsigned(msbi_g+2 downto 0);

begin

  DeltaB_s(msbi_g +2 downto msbi_g +1) 	<= SigmaLatch_q(msbi_g +2) & SigmaLatch_q(msbi_g +2);
  DeltaB_s(msbi_g downto 0) 		<= (others => '0');

  DeltaAdder_s <= unsigned('0' & '0' & DAC_DATA_I) + DeltaB_s;

  SigmaAdder_s <= DeltaAdder_s + SigmaLatch_q;

  seq: process (CLK_I, RESET_I)
  begin
    if RESET_I = '1' then
      SigmaLatch_q <= to_unsigned(2**(msbi_g+1), SigmaLatch_q'length);
      DACout_q     <= '0';

    elsif CLK_I'event and CLK_I = '1' then
      SigmaLatch_q <= SigmaAdder_s;
      DACout_q     <= SigmaLatch_q(msbi_g+2);
    end if;
  end process seq;

  DAC_O <= DACout_q;

end rtl;
