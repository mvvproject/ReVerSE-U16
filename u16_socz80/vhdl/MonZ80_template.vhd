--+-----------------------------------+-------------------------------------+--
--|                      ___   ___    | (c) 2013-2014 William R Sowerbutts  |--
--|   ___  ___   ___ ___( _ ) / _ \   | will@sowerbutts.com                 |--
--|  / __|/ _ \ / __|_  / _ \| | | |  |                                     |--
--|  \__ \ (_) | (__ / / (_) | |_| |  | A Z80 FPGA computer, just for fun   |--
--|  |___/\___/ \___/___\___/ \___/   |                                     |--
--|                                   |              http://sowerbutts.com/ |--
--+-----------------------------------+-------------------------------------+--
--| An inferrable 4KB ROM to contain the monitor program                    |--
--+-------------------------------------------------------------------------+--
--
-- MonZ80_template.vhd contains the template VHDL for the ROM but no actual
-- data. The "ROMHERE" string is replaced by byte data by the "make_vhdl_rom"
-- tool in software/tools which is invoked to generate "MonZ80.vhd" after
-- the monitor program has been assembled.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity MonZ80 is
   port(
      clk           : in  std_logic;
      a             : in  std_logic_vector(11 downto 0);
      d             : out std_logic_vector(7 downto 0)
   );
end MonZ80;

architecture arch of MonZ80 is
   constant byte_rom_WIDTH: integer := 8;
   type byte_rom_type is array (0 to 4095) of std_logic_vector(byte_rom_WIDTH-1 downto 0);
   signal address_latch : std_logic_vector(11 downto 0) := (others => '0');

   -- actually memory cells
   signal byte_rom : byte_rom_type := (
   -- ROM contents follows


%ROMHERE%


     );

begin

  ram_process: process(clk, byte_rom)
  begin
      if rising_edge(clk) then
          -- latch the address, in order to infer a synchronous memory
          address_latch <= a;
      end if;
  end process;

  d <= byte_rom(to_integer(unsigned(address_latch)));

end arch;
