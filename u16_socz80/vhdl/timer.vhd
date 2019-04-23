--+-----------------------------------+-------------------------------------+--
--|                      ___   ___    | (c) 2013-2014 William R Sowerbutts  |--
--|   ___  ___   ___ ___( _ ) / _ \   | will@sowerbutts.com                 |--
--|  / __|/ _ \ / __|_  / _ \| | | |  |                                     |--
--|  \__ \ (_) | (__ / / (_) | |_| |  | A Z80 FPGA computer, just for fun   |--
--|  |___/\___/ \___/___\___/ \___/   |                                     |--
--|                                   |              http://sowerbutts.com/ |--
--+-----------------------------------+-------------------------------------+--
--| A simple timer peripheral for timing intervals and generating periodic  |--
--| interrupts.                                                             |--
--+-------------------------------------------------------------------------+--
--
-- There are two timers; a 1MHz 32-bit counter which always counts up (unless reset to 0)
-- and whose value can be transferred atomically to a 32-bit latch, and a 1MHz 24-bit down
-- counter which triggers an interrupt and is reset to a programmable value upon reaching
-- zero. Writes to the register at base+1 perform timer operations according to the value
-- written. The 1MHz is derived by prescaling the system clock.
--
-- register layout:
--
-- address   read value                           write operation
-- --------- ------------------------------------ -------------------------------------
-- base+0    status register                      set status register  
-- base+1      (unused)                           perform operation according to value written
-- base+2      (unused)                             (no operation)
-- base+3      (unused)                             (no operation)
-- base+4    muxed register value (low byte)      update muxed register value
-- base+5    muxed register value                 update muxed register value
-- base+6    muxed register value                 update muxed register value
-- base+7    muxed register value (high byte)     update muxed register value
--
--
-- operation values (for writes to base+1):
--   00 -- acknowledge interrupt
--   01 -- reset upcounter value to zero
--   02 -- update latched value from upcounter value
--   03 -- reset downcounter
--   10 -- set register mux select to upcounter current
--   11 -- set register mux select to upcounter latched
--   12 -- set register mux select to downcounter current
--   13 -- set register mux select to downcountre reset
--
--
-- control/status register layout:
--   bits 0, 1, -- register mux select (controls which register is visible in registers at base+4 through base+7):
--        0  0  upcounter current value
--        0  1  upcounter latched value
--        1  0  downcounter current value
--        1  1  downcounter reset value
--     (bits 2, 3, 4, 5 are currently unused)
--   bit 6 -- countdown timer interrupt enable (0=disable, 1=enable)
--   bit 7 -- interrupt flag (0=no interrupt, 1=one or interrupts occurred but not yet acknowledged)
--

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity timer is
    generic (
           clk_frequency    : natural := (128 * 1000000)
    );
    port ( clk              : in  std_logic;
           reset            : in  std_logic;
           cpu_address      : in  std_logic_vector(2 downto 0);
           data_in          : in  std_logic_vector(7 downto 0);
           data_out         : out std_logic_vector(7 downto 0);
           enable           : in  std_logic;
           req_read         : in  std_logic;
           req_write        : in  std_logic;
           interrupt        : out std_logic
    );
end timer;

architecture Behavioral of timer is

    signal upcounter_value      : unsigned(31 downto 0) := (others => '0');
    signal upcounter_latch      : unsigned(31 downto 0) := (others => '0');
    signal downcounter_value    : unsigned(31 downto 0) := (others => '0');
    signal downcounter_start    : unsigned(31 downto 0) := (others => '0');

    -- if using frequencies > 128MHz this counter will need to be wider than 7 bits
    signal counter_prescale     : unsigned(6 downto 0)  := (others => '0');
    constant prescale_wrap      : unsigned(6 downto 0)  := to_unsigned((clk_frequency / 1000000) - 1, 7); -- aim for a 1MHz counter

    signal interrupt_enable     : std_logic := '0';
    signal interrupt_signal     : std_logic := '0';
    signal regmux_select        : std_logic_vector(1 downto 0) := "00";

    signal regmux_output        : std_logic_vector(31 downto 0);
    signal regmux_updated       : std_logic_vector(31 downto 0);
    signal status_register_value: std_logic_vector(7 downto 0);

begin

    interrupt <= (interrupt_signal and interrupt_enable);

    with cpu_address select
        data_out <=
            status_register_value when "000",
            regmux_output(7  downto  0) when "100",
            regmux_output(15 downto  8) when "101",
            regmux_output(23 downto 16) when "110",
            regmux_output(31 downto 24) when "111",
            status_register_value when others;

    status_register_value <= interrupt_signal & interrupt_enable & "0000" & regmux_select;

    with regmux_select select
        regmux_output <= 
            std_logic_vector(upcounter_value  ) when "00",
            std_logic_vector(upcounter_latch  ) when "01",
            std_logic_vector(downcounter_value) when "10",
            std_logic_vector(downcounter_start) when "11",
            std_logic_vector(downcounter_start) when others;

    with cpu_address(1 downto 0) select
        regmux_updated <= 
             regmux_output(31 downto 8)  & data_in                               when "00",
             regmux_output(31 downto 16) & data_in & regmux_output(7  downto 0)  when "01",
             regmux_output(31 downto 24) & data_in & regmux_output(15 downto 0)  when "10",
                                           data_in & regmux_output(23 downto 0)  when "11",
                                           data_in & regmux_output(23 downto 0)  when others;

    counter_proc: process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                upcounter_value    <= (others => '0');
                upcounter_latch    <= (others => '0');
                downcounter_value  <= (others => '0');
                downcounter_start  <= (others => '0');
                counter_prescale   <= (others => '0');
                interrupt_enable   <= '0';
                interrupt_signal   <= '0';
                regmux_select      <= "00";
            else
                -- prescaled counter
                if counter_prescale = prescale_wrap then
                    counter_prescale <= (others => '0'); -- reset prescale counter
                    upcounter_value <= upcounter_value + 1;
                    if downcounter_value = 0 then
                        downcounter_value <= downcounter_start;
                        interrupt_signal <= '1';
                    else
                        downcounter_value <= downcounter_value - 1;
                    end if;
                else
                    counter_prescale <= counter_prescale + 1;
                end if;

                if enable = '1' and req_write = '1' then
                    if cpu_address = "000" then
                        interrupt_signal <= data_in(7);
                        interrupt_enable <= data_in(6);
                        regmux_select <= data_in(1 downto 0);
                    elsif cpu_address = "001" then
                        case data_in is
                            when "00000000" => interrupt_signal <= '0';
                            when "00000001" => upcounter_value <= (others => '0');
                            when "00000010" => upcounter_latch <= upcounter_value;
                            when "00000011" => downcounter_value <= downcounter_start;
                            when "00010000" => regmux_select <= "00";
                            when "00010001" => regmux_select <= "01";
                            when "00010010" => regmux_select <= "10";
                            when "00010011" => regmux_select <= "11";
                            when others =>
                        end case;
                    elsif cpu_address(2) = '1' then
                        case regmux_select is
                            when "00" => upcounter_value   <= unsigned(regmux_updated);
                            when "01" => upcounter_latch   <= unsigned(regmux_updated);
                            when "10" => downcounter_value <= unsigned(regmux_updated);
                            when "11" => downcounter_start <= unsigned(regmux_updated);
                            when others =>
                        end case;
                    end if;
                end if;
            end if;
        end if;
    end process;
end Behavioral;

