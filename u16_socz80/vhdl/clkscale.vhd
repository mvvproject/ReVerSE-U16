--+-----------------------------------+-------------------------------------+--
--|                      ___   ___    | (c) 2013-2014 William R Sowerbutts  |--
--|   ___  ___   ___ ___( _ ) / _ \   | will@sowerbutts.com                 |--
--|  / __|/ _ \ / __|_  / _ \| | | |  |                                     |--
--|  \__ \ (_) | (__ / / (_) | |_| |  | A Z80 FPGA computer, just for fun   |--
--|  |___/\___/ \___/___\___/ \___/   |                                     |--
--|                                   |              http://sowerbutts.com/ |--
--+-----------------------------------+-------------------------------------+--
--| An attempt to modulate the CPU clock so it can be slowed down without   |--
--| also modulating the clock to the peripherals (which would break the     |--
--| UART and DRAM at least). This works but not all the peripherals are     |--
--| currently compatible (the UART, at least, doesn't handle this well).    |--
--| Strongly uggest you avoid using this before you fix the peripherals.    |--
--+-------------------------------------------------------------------------+--

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity clkscale is
    port ( clk              : in  std_logic;
           reset            : in  std_logic;
           cpu_address      : in  std_logic_vector(2 downto 0);
           data_in          : in  std_logic_vector(7 downto 0);
           data_out         : out std_logic_vector(7 downto 0);
           enable           : in  std_logic;
           read_notwrite    : in  std_logic;
           clk_enable       : out std_logic
    );
end clkscale;

-- a counter which counts up until it reaches a target value.
-- when the counter is at the target value the clock is enabled
-- for one cycle and the counter is reset. the clock is disabled
-- the rest of the time. this means the clock is enabled in the
-- proportion 1/(1+r) where r is the register value.

architecture Behavioral of clkscale is

    signal counter_target : unsigned(7 downto 0) := (others => '0');
    signal counter_value  : unsigned(7 downto 0) := (others => '0');
    signal output         : std_logic;

begin

    data_out <= std_logic_vector(counter_target);
    clk_enable <= output;

    clkscale_proc: process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then 
                counter_target <= to_unsigned(0, 8);
                counter_value  <= to_unsigned(0, 8);
                output <= '1';
            else
                -- reset on target, enable clock for one cycle
                if counter_value = counter_target then
                    counter_value <= to_unsigned(0, 8);
                    output <= '1';
                else
                    counter_value <= counter_value + 1;
                    output <= '0';
                end if;

                -- register write
                if enable = '1' and read_notwrite = '0' then
                    counter_target <= unsigned(data_in);
                end if;
            end if;
        end if;
    end process;
end Behavioral;

