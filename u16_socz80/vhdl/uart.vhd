--+-----------------------------------+-------------------------------------+--
--|                      ___   ___    | (c) 2013-2014 William R Sowerbutts  |--
--|   ___  ___   ___ ___( _ ) / _ \   | will@sowerbutts.com                 |--
--|  / __|/ _ \ / __|_  / _ \| | | |  |                                     |--
--|  \__ \ (_) | (__ / / (_) | |_| |  | A Z80 FPGA computer, just for fun   |--
--|  |___/\___/ \___/___\___/ \___/   |                                     |--
--|                                   |              http://sowerbutts.com/ |--
--+-----------------------------------+-------------------------------------+--
--| UART implementation                                                     |--
--+-------------------------------------------------------------------------+--

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity uart is
    generic (
           clk_frequency    : natural := (128 * 1000000)
    );
    port ( clk              : in  std_logic;
           serial_out       : out std_logic;
           serial_in        : in  std_logic;
           data_in          : in  std_logic_vector(7 downto 0);
           data_in_load     : in  std_logic;
           data_out         : out std_logic_vector(7 downto 0);
           data_out_ready   : out std_logic;
           bad_bit          : out std_logic;
           transmitter_busy : out std_logic;
           can_transmit     : in  std_logic
    );
end uart;

architecture Behavioral of uart is

    -- tested at 1,000,000bps with 48MHz clock. Works (apparently).
    constant rx_sample_interval : unsigned(13 downto 0) := to_unsigned(clk_frequency / (115200 * 16) - 1, 14);  -- clock speed / (baud x 16) - 1 ; eg 32MHz / (9600 * 16) - 1 = 207
    constant bit_duration       : unsigned(13 downto 0) := to_unsigned(clk_frequency / (115200 *  1) - 1, 14);  -- clock speed / baud - 1 ; eg 32MHz / 9600 - 1 = 3332

    signal tx_counter   : unsigned(13 downto 0) := to_unsigned(0, 14);
    signal tx_shift_reg : std_logic_vector(8 downto 0) := "111111111";
    signal tx_bits_left : unsigned(3 downto 0) := to_unsigned(0, 4);
    signal tx_busy      : std_logic;

    signal rx_counter   : unsigned(13 downto 0) := to_unsigned(0, 14);
    signal rx_shift_reg : std_logic_vector(8 downto 0) := "000000000";
    signal rx_bits_got  : unsigned(3 downto 0) := to_unsigned(0, 4);
    signal rx_state     : unsigned(7 downto 0) := (others => '0'); -- 10 bits x 16 samples each = at least 160 states.
    signal rx_out_ready : std_logic := '0';
    signal data_out_buf : std_logic_vector(7 downto 0) := "00000000";

    signal rx_clkin1    : std_logic := '0';
    signal rx_clkin2    : std_logic := '0';
    signal rx_sample1   : std_logic := '0';
    signal rx_sample2   : std_logic := '0';
    signal rx_sample3   : std_logic := '0';
    signal rx_sample_majority : std_logic;

    signal rx_badbit    : std_logic := '0';

begin

    -- -- receiver -- --
    --
    -- Incoming data is oversampled 16 times. We check three samples in the
    -- middle of each bit and take a simple majority. There is provision for
    -- rejecting noise where a start bit should have been. We compensate for
    -- small amounts of clock drift by potentially cutting a stop bit short.
    --
    -- This is not dissimilar to how the AVR USART receiver works.
    --

    data_out_ready <= rx_out_ready;
    bad_bit <= rx_badbit;
    data_out <= data_out_buf;

    rx_sample_majority <= (rx_sample1 and rx_sample2) or (rx_sample1 and rx_sample3) or (rx_sample2 and rx_sample3); -- simple majority wins

    receiver: process(clk)
    begin
        if rising_edge(clk) then
            -- Bring serial_in into our clock domain
            rx_clkin1 <= serial_in;
            rx_clkin2 <= rx_clkin1; -- rx_clkin2 should now be safe to use.

            -- We latch the incoming serial data at full clock speed (NOT divided down)
            rx_sample1 <= rx_clkin2;
            rx_out_ready <= '0';

            -- bad bit
            rx_badbit <= rx_badbit;

            -- clock divider
            rx_counter <= rx_counter + 1;
            if rx_counter = rx_sample_interval then
                rx_counter <= (others => '0');

                if rx_state = "00000000" then 
                    -- line is in the idle state, we're waiting for a start bit!
                    -- the anticipation is killing me.
                    if rx_sample1 = '0' then
                        rx_state <= "00000001"; -- and we're off!
                        rx_counter <= (others => '0');
                    end if;
                elsif rx_state = "10011010" then 
                    -- wait for the line to be idle. we don't leave this state until the serial line 
                    -- goes high (it should be already, because we should be in mid stop bit).
                    if rx_sample1 = '1' then
                        rx_state <= "00000000";
                    end if;
                else
                    -- we're in the normal bit reception pattern
                    rx_state <= rx_state + 1;

                    -- rx_sample1 contains the incoming serial data, latched
                    rx_sample3 <= rx_sample2;
                    rx_sample2 <= rx_sample1;

                    -- when we have the three middle samples, update the shift register
                    if rx_state(3 downto 0) = "1001" then
                        rx_shift_reg <= rx_sample_majority & rx_shift_reg(rx_shift_reg'length-1 downto 1);
                        -- false start bit noise rejection: if we read the start bit as a logical 1, start over again.
                        if (rx_state(7 downto 4) = "0000") and (rx_sample_majority = '1') then
                            rx_badbit <= '1';
                            rx_state <= "00000000";
                        end if;
                        -- check stop bit framing and alert CPU if valid byte received
                        if (rx_state(7 downto 4) = "1001") then 
                            if (rx_sample_majority = '1') then
                                data_out_buf <= rx_shift_reg(8 downto 1);
                                rx_out_ready <= '1';
                                rx_badbit <= '0';
                            else
                                rx_badbit <= '1';
                            end if;
                            -- if line is high we can skip waiting for the line to go idle which buys us a little more tolerance for clock drift.
                            if rx_sample1 = '1' then
                                rx_state <= "00000000";
                            end if;
                        end if;
                    end if;
                end if;
            end if;
        end if;
    end process;
    

    -- -- transmitter -- --
    --
    -- just clock out the bits, damn it.
    --

    serial_out <= tx_shift_reg(0); -- we always output the bottom bit of the shift register.
    transmitter_busy <= tx_busy; -- or data_in_load;

    transmitter: process(clk)
    begin

        if rising_edge(clk) then
            tx_busy <= '1';

            if tx_bits_left = 0 then
                -- idle
                if data_in_load = '1' then
                    tx_shift_reg <= data_in & '0';              -- data bits, start bit
                    tx_bits_left <= to_unsigned(10, 4);         -- total ten bits to transmit including stop bit
                    tx_counter <= (others => '0');              -- reset counter
                else
                    if can_transmit = '0' then
                        tx_busy <= '1';
                    else
                        tx_busy <= '0';
                    end if;
                end if;
            else
                -- busy
                if (tx_counter = 0) and (tx_bits_left = 10) and (can_transmit = '0') then
                    -- do nothing, we're waiting for our peer to indicate that we can transmit
                    tx_counter <= (others => '0');
                else
                    tx_counter <= tx_counter + 1;
                    if tx_counter = bit_duration then
                        -- shift out the next bit
                        tx_shift_reg <= '1' & tx_shift_reg(8 downto 1); -- stop bit and line idle state are both 1 so shift that in the top
                        tx_counter <= (others => '0');              -- reset counter
                        tx_bits_left <= tx_bits_left - 1;
                    end if;
                end if;
            end if;
        end if;
    end process;

end Behavioral;

