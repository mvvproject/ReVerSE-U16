--+-----------------------------------+-------------------------------------+--
--|                      ___   ___    | (c) 2013-2014 William R Sowerbutts  |--
--|   ___  ___   ___ ___( _ ) / _ \   | will@sowerbutts.com                 |--
--|  / __|/ _ \ / __|_  / _ \| | | |  |                                     |--
--|  \__ \ (_) | (__ / / (_) | |_| |  | A Z80 FPGA computer, just for fun   |--
--|  |___/\___/ \___/___\___/ \___/   |                                     |--
--|                                   |              http://sowerbutts.com/ |--
--+-----------------------------------+-------------------------------------+--
--| FIFO implementation with high water mark. Could be improved; currently  |--
--| it is impossible to use the last byte in the FIFO (because it cannot    |--
--| distinguish completely-full from completely-empty)                      |--
--+-------------------------------------------------------------------------+--

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity fifo is
    generic(
        depth_log2  : integer := 10; -- 5 gives 32 bytes, implements without a BRAM.
        hwm_space   : integer := 5;  -- minimum bytes free in buffer before we assert flow control signals
        width       : integer := 8
    );
    port(
        clk         : in  std_logic;
        reset       : in  std_logic;
        write_en    : in  std_logic;
        write_ready : out std_logic; -- is there space to write?
        read_en     : in  std_logic;
        read_ready  : out std_logic; -- is there data waiting to read?
        data_in     : in  std_logic_vector(width-1 downto 0);
        data_out    : out std_logic_vector(width-1 downto 0);
        high_water_mark : out std_logic
    );
end fifo;

architecture behaviour of fifo is
    type fifo_entry is array (natural range <>) of std_logic_vector(width-1 downto 0);
    signal fifo_contents : fifo_entry(0 to (2 ** depth_log2) - 1); -- this is the FIFO buffer memory

    signal read_ptr  : unsigned(depth_log2-1 downto 0) := (others => '0');
    signal write_ptr : unsigned(depth_log2-1 downto 0) := (others => '0');
    signal full      : std_logic;
    signal empty     : std_logic;
begin

    is_empty: process(read_ptr, write_ptr)
    begin
        if read_ptr = write_ptr then
            empty <= '1';
        else
            empty <= '0';
        end if;
        if read_ptr = (write_ptr+1) then
            full <= '1';
        else
            full <= '0';
        end if;
        if (write_ptr - read_ptr) >= ((2 ** depth_log2) - 1 - hwm_space) then
            high_water_mark <= '1';
        else
            high_water_mark <= '0';
        end if;
    end process;

    fifo_update: process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                -- reset
                read_ptr  <= to_unsigned(0, depth_log2);
                write_ptr <= to_unsigned(0, depth_log2);
            else
                -- normal operation
                if write_en = '1' and full = '0' then
                    fifo_contents(to_integer(write_ptr)) <= data_in;
                    write_ptr <= write_ptr + 1;
                end if;

                if read_en = '1' and empty = '0' then
                    read_ptr <= read_ptr + 1;
                end if;

                data_out <= fifo_contents(to_integer(read_ptr));

            end if;
        end if;
    end process;

    write_ready <= not full;
    read_ready  <= not empty;

end;
