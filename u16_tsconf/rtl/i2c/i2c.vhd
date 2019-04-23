-------------------------------------------------------------------[11.09.2015]
-- I2C Controller
-------------------------------------------------------------------------------
-- Engineer: 	MVV <mvvproject@gmail.com>
--
-- 15.10.2011	Initial

-- The I2C core provides for four register addresses 
-- that the CPU can read or writen to:

-- Address 0 -> DATA (write/read) or SLAVE ADDRESS (write)  
-- Address 1 -> Command/Status Register (write/read)

-- Data Buffer (write/read):
--	bit 7-0	= Stores I2C read/write data
-- or
-- 	bit 7-1	= Holds the first seven address bits of the I2C slave device
-- 	bit 0	= I2C 1:read/0:write bit

-- Command/Status Register (write):
--	bit 7-2	= Reserved
--	bit 1-0	= 00: IDLE; 01: START; 10: nSTART; 11: STOP
-- Command/Status Register (read):
--	bit 7-2	= Reserved
--	bit 1 	= ERROR 	(I2C transaction error)
--	bit 0 	= BUSY 		(I2C bus busy)

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity i2c is
port (
	-- CPU Interface Signals
	I_RESET		: in std_logic;
	I_CLK		: in std_logic;
	I_ENA		: in std_logic;		-- 400KHz (4T = SCL clock frequency 100 kHz)
	I_ADDR		: in std_logic;
	I_DATA		: in std_logic_vector(7 downto 0);
	O_DATA		: out std_logic_vector(7 downto 0);
	I_WR		: in std_logic;
	-- I2C Interface Signals
	IO_I2C_SCL	: inout std_logic;
	IO_I2C_SDA	: inout std_logic);
end i2c;

architecture rtc_arch of i2c is
type state_t is (s_idle, s_start, s_data, s_ack, s_stop, s_done);
signal state 		: state_t;
signal data_buf		: std_logic_vector(7 downto 0);
signal go		: std_logic;
signal mode		: std_logic_vector(1 downto 0);
signal shift_reg	: std_logic_vector(7 downto 0);
signal ack		: std_logic;
signal nbit 		: std_logic_vector(2 downto 0);
signal phase 		: std_logic_vector(1 downto 0);
signal scl 		: std_logic;
signal sda 		: std_logic;
signal rw_bit 		: std_logic;
signal rw_flag		: std_logic;

begin

-- Read CPU bus into internal registers
cpu_write : process (I_CLK, I_RESET, I_WR)
begin
	if I_CLK'event and I_CLK = '1' then
		if I_WR = '1' then
			if I_ADDR = '0' then
				data_buf <= I_DATA;
			else
				mode <= I_DATA(1 downto 0);
			end if;
		end if;
	end if;
end process;

process (I_RESET, I_CLK, I_ENA, I_WR, I_ADDR, state)
begin
	if I_RESET = '1' or state = s_data then
		go <= '0';
	elsif I_CLK'event and I_CLK = '1' then
		if I_WR = '1' then
			if I_ADDR = '0' then
				go <= '1';
			end if;
		end if;
	end if;
end process;

-- Provide data for the CPU to read
cpu_read : process (I_ADDR, state, shift_reg, ack, go)
begin
	O_DATA(7 downto 2) <= "111111";
	if I_ADDR = '0' then
		O_DATA <= shift_reg;
	else
		if (state = s_idle and go = '0') then
			O_DATA(0) <= '0';
		else
			O_DATA(0) <= '1';
		end if;
		O_DATA(1) <= ack;
	end if;
end process;

--     0123  0123  01230123012301230123012301230123  0123  0123  0123
-- SCL ----  ----  __--__--__--__--__--__--__--__--  __--  ----  ----     
-- SDA ----  --__  _< 7 X 6 X 5 X 4 X 3 X 2 X 1 X 0   >x   x     ----  
--     Reset Start Data/Slave address/Word address   Ack   Stop  Done
                                                         
-- I2C transfer state machine
i2c_proc : process (I_RESET, I_CLK, I_ENA, go)
	begin
		if I_RESET = '1' then
			scl <= '1';
			sda <= '1';
			state <= s_idle;
			ack <= '0'; -- No error
			phase <= "00";
	
		elsif I_CLK'event and I_CLK = '1' then
			if I_ENA = '1' then
				phase <= phase + "01"; -- Next phase by default
	
				-- STATE: IDLE
				if state = s_idle then
					phase <= "00";
					if go = '1' then
						shift_reg <= data_buf;
						nbit <= "000";
						if mode = "01" then
							rw_flag	<= data_buf(0);	-- 1= Read; 0= Write
							rw_bit <= '0';
							state <= s_start;
						else
							rw_bit <= rw_flag;
							state <= s_data;
						end if;
					end if;
					
				-- STATE: START
				elsif state = s_start then -- Generate START condition
					case phase is
						when "00" =>
							scl <= '1';
							sda <= '1';
						when "10" =>
							sda <= '0';
						when "11" =>
							state <= s_data; -- Advance to next state
						when others => null;
					end case;
					
				-- STATE: DATA
				elsif state = s_data then -- Generate data
					case phase is
						when "00" =>
							scl <= '0'; -- Drop SCL
						when "01" =>
							if rw_bit = '0' then -- Write Data
								sda <= shift_reg(7); -- Output data and shift (MSb first)
							else
								sda <= '1';
							end if;
						when "10" =>
							scl <= '1'; -- Raise SCL
							shift_reg <= shift_reg(6 downto 0) & IO_I2C_SDA; -- Input data and shift (MSb first)
						when "11" =>
							if nbit = "111" then -- Next bit or advance to next state when done
								state <= s_ack;
							else
								nbit <= nbit + "001";
							end if;
						when others => null;
					end case;
								
				-- STATE: ACK
				elsif state = s_ack then -- Generate ACK clock and check for error condition
					case phase is
					when "00" =>
						scl <= '0'; -- Drop SCL
					when "01" =>
						if (rw_bit = '0' or mode = "11") then
							sda <= '1';
						else
							sda <= '0';
						end if;
					when "10" =>
						scl <= '1';	-- Raise SCL
						ack <= IO_I2C_SDA; -- Sample ack bit
					when "11" =>
						if mode(1) = '0' then
							state <= s_idle;
						else
							state <= s_stop;
						end if;
					when others => null;
					end case;
	
				-- STATE: STOP
				elsif state = s_stop then -- Generate STOP condition
					case phase is
					when "00" =>
						scl <= '0';
					when "01" =>
						if mode = "11" then
							sda <= '0';
						else
							sda <= '1';
						end if;
					when "10" =>
						scl <= '1';
					when "11" =>
						state <= s_done;
					when others => null;
					end case; 
				
				-- STATE: DONE	
				else	
					scl <= '1';
					sda <= '1';
					if phase = "11" then
						state <= s_idle;
					end if;
				end if;
			end if;
		end if;
	end process;

	-- Create open-drain outputs for I2C bus
	IO_I2C_SCL <= '0' when scl = '0' else 'Z';
	IO_I2C_SDA <= '0' when sda = '0' else 'Z';

end rtc_arch;