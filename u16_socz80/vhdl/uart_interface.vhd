--+-----------------------------------+-------------------------------------+--
--|                      ___   ___    | (c) 2013-2014 William R Sowerbutts  |--
--|   ___  ___   ___ ___( _ ) / _ \   | will@sowerbutts.com                 |--
--|  / __|/ _ \ / __|_  / _ \| | | |  |                                     |--
--|  \__ \ (_) | (__ / / (_) | |_| |  | A Z80 FPGA computer, just for fun   |--
--|  |___/\___/ \___/___\___/ \___/   |                                     |--
--|                                   |              http://sowerbutts.com/ |--
--+-----------------------------------+-------------------------------------+--
--| Combine the UART with a receive FIFO and provide an interface to the    |--
--| microprocessor.                                                         |--
--+-------------------------------------------------------------------------+--

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity uart_interface is
    Generic ( watch_for_reset : integer := 0;
              clk_frequency   : natural := (128*1000000);
              flow_control    : integer := 0) ;
    Port ( clk           : in  std_logic;
           reset         : in  std_logic;
              -- rs232
           serial_in     : in  std_logic;
           serial_out    : out std_logic;
              -- flow control (optional)
           serial_cts    : in  std_logic;
           serial_rts    : out std_logic;
              -- memory interface
           cpu_address   : in  std_logic_vector (2 downto 0);
           cpu_data_in   : in  std_logic_vector (7 downto 0);
           cpu_data_out  : out std_logic_vector (7 downto 0);
           reset_out     : out std_logic;
           enable        : in  std_logic;
           interrupt     : out std_logic;
           req_read      : in  std_logic;
           req_write     : in  std_logic);
end uart_interface;

architecture Behavioral of uart_interface is
    signal uart_data_in         : std_logic_vector(7 downto 0);
    signal uart_data_out        : std_logic_vector(7 downto 0);
    signal fifo_data_out        : std_logic_vector(7 downto 0);
    signal fifo_data_ready      : std_logic;
    signal uart_rx_ready        : std_logic;
    signal uart_tx_busy         : std_logic;
    signal uart_badbit          : std_logic;
    signal uart_data_load       : std_logic;
    signal fifo_data_ack        : std_logic;
    signal uart_status_register : std_logic_vector(7 downto 0);
    signal rx_interrupt_enable  : std_logic := '0';
    signal tx_interrupt_enable  : std_logic := '0';
    signal rx_interrupt_signal  : std_logic := '0';
    signal tx_interrupt_signal  : std_logic := '0';
    signal uart_tx_was_busy     : std_logic := '0';
    signal fifo_data_was_ready  : std_logic := '0';
    signal cts_clk1             : std_logic;
    signal cts_clk2             : std_logic;
    signal fifo_nearly_full     : std_logic;
    signal can_transmit         : std_logic;

    type reset_seq_state is (
                 st_idle,
                 st_seen1,
                 st_seen2,
                 st_seen3,
                 st_seen4,
                 st_seen5
             );
    signal reset_seq : reset_seq_state := st_idle;
    signal reset_saw_byte0  : std_logic;
    signal reset_saw_byte1  : std_logic;
begin

    -- this whole module could really do with a bit of a rethink.
    with cpu_address select
        cpu_data_out <=
            uart_status_register when "000",
            fifo_data_out when others;

    uart_data_in <= cpu_data_in;

    uart_status_register <= fifo_data_ready & uart_tx_busy & '0' & uart_badbit & rx_interrupt_enable & tx_interrupt_enable & rx_interrupt_signal & tx_interrupt_signal;

    interrupt <= (rx_interrupt_signal and rx_interrupt_enable) or (tx_interrupt_signal and tx_interrupt_enable);

    -- this decodes cpu_address="001" in a rather longwinded way.
    uart_data_load <= cpu_address(0) and (not cpu_address(1)) and (not cpu_address(2)) and enable and req_write;
    fifo_data_ack  <= cpu_address(0) and (not cpu_address(1)) and (not cpu_address(2)) and enable and req_read;

    -- optional hardware flow control
    process(fifo_nearly_full, cts_clk2)
    begin
        if flow_control = 1 then
            serial_rts <= fifo_nearly_full;
            can_transmit <= (not cts_clk2);
        else
            serial_rts <= '0';
            can_transmit <= '1';
        end if;
    end process;
    
    -- optional reset on data sequence
    process(uart_data_out)
    begin
        if watch_for_reset = 1 then
            if uart_data_out = "00100001" then
                reset_saw_byte0 <= '1';
                reset_saw_byte1 <= '0';
            elsif uart_data_out = "01111110" then
                reset_saw_byte0 <= '0';
                reset_saw_byte1 <= '1';
            else
                reset_saw_byte0 <= '0';
                reset_saw_byte1 <= '0';
            end if;
        end if;
    end process;


    process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                fifo_data_was_ready <= '0';
                rx_interrupt_enable <= '0';
                rx_interrupt_signal <= '0';
                tx_interrupt_enable <= '0';
                tx_interrupt_signal <= '0';
                uart_tx_was_busy <= '0';
                reset_out <= '0';
                reset_seq <= st_idle;
                cts_clk1 <= '0';
                cts_clk2 <= '0';
            else
                tx_interrupt_signal <= tx_interrupt_signal;
                rx_interrupt_signal <= rx_interrupt_signal;

                -- bring CTS into our clock domain
                if flow_control = 1 then
                    cts_clk1 <= serial_cts;
                    cts_clk2 <= cts_clk1;
                end if;

                -- handle writes to the status register
                if enable = '1' and req_write = '1' and cpu_address = "000" then
                    rx_interrupt_enable <= cpu_data_in(3);
                    tx_interrupt_enable <= cpu_data_in(2);
                    rx_interrupt_signal <= cpu_data_in(1);
                    tx_interrupt_signal <= cpu_data_in(0);
                end if;

                uart_tx_was_busy <= uart_tx_busy;
                fifo_data_was_ready <= fifo_data_ready;

                if uart_tx_was_busy = '1' and uart_tx_busy = '0' then
                    tx_interrupt_signal <= '1';
                end if;

                if fifo_data_ready = '1' and fifo_data_was_ready = '0' then
                    rx_interrupt_signal <= '1';
                end if;

                if watch_for_reset = 1 then
                    if uart_rx_ready = '1' then
                        reset_seq <= st_idle; -- end up here unless we match the conditions below
                        reset_out <= '0';
                        case reset_seq is
                            when st_idle  => if reset_saw_byte0 = '1' then reset_seq <= st_seen1; end if;
                            when st_seen1 => if reset_saw_byte1 = '1' then reset_seq <= st_seen2; end if;
                            when st_seen2 => if reset_saw_byte0 = '1' then reset_seq <= st_seen3; end if;
                            when st_seen3 => if reset_saw_byte1 = '1' then reset_seq <= st_seen4; end if;
                            when st_seen4 => if reset_saw_byte0 = '1' then reset_seq <= st_seen5; end if;
                            when st_seen5 => if reset_saw_byte1 = '1' then reset_out <= '1'; end if;
                            when others =>
                        end case;
                    else
                        reset_seq <= reset_seq;
                        reset_out <= '0';
                    end if;
                end if;
            end if;
        end if;
    end process;

    fifo_instance: entity work.fifo
    PORT MAP(
        clk => clk,
        reset => reset,
        data_in => uart_data_out,
        data_out => fifo_data_out,
        read_ready => fifo_data_ready,
        read_en => fifo_data_ack,
        write_ready => open,
        write_en => uart_rx_ready,
        high_water_mark => fifo_nearly_full
    );

    uart_instance: entity work.uart 
    GENERIC MAP(
        clk_frequency => clk_frequency
    )
    PORT MAP(
        clk => clk,
        serial_out => serial_out,
        serial_in => serial_in,
        data_in => uart_data_in,
        data_in_load => uart_data_load,
        data_out => uart_data_out,
        data_out_ready => uart_rx_ready,
        bad_bit => uart_badbit,
        transmitter_busy => uart_tx_busy,
        can_transmit => can_transmit
    );

end Behavioral;
