-------------------------------------------------------------------[09.08.2016]
-- USB HID
-------------------------------------------------------------------------------
-- Engineer: MVV <mvvproject@gmail.com>

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use ieee.std_logic_unsigned.all;

entity hid is
port (
	I_CLK		: in std_logic;
	I_RESET		: in std_logic;
	I_RX		: in std_logic;
	I_NEWFRAME	: in std_logic;
	I_JOYPAD_CLK1	: in std_logic;
	I_JOYPAD_CLK2	: in std_logic;
	I_JOYPAD_LATCH	: in std_logic;
	O_JOYPAD_DATA1	: out std_logic;
	O_JOYPAD_DATA2	: out std_logic;
	O_JOY0		: out std_logic_vector(7 downto 0);
	O_JOY1		: out std_logic_vector(7 downto 0);
	O_KEY		: out std_logic_vector(1 downto 0));
end hid;

architecture rtl of hid is

signal data		: std_logic_vector(7 downto 0);
signal cnt1		: std_logic_vector(2 downto 0);
signal cnt2		: std_logic_vector(2 downto 0);
signal ready		: std_logic;
signal device_id	: std_logic_vector(7 downto 0);
signal count		: integer range 0 to 8;
signal joy_data		: std_logic_vector(15 downto 0);
signal joy0		: std_logic_vector(7 downto 0);
signal joy1		: std_logic_vector(7 downto 0);
signal key		: std_logic_vector(1 downto 0);

begin

	u0 : entity work.receiver
	port map (
		I_CLK		=> I_CLK,
		I_RESET		=> I_RESET,
		I_RX		=> I_RX,
		O_DATA		=> data,
		O_READY		=> ready);

	
	process (I_RESET, I_CLK, I_NEWFRAME, data, ready)
	begin
		if I_RESET = '1' then
			joy0 <= (others => '0');
			joy1 <= (others => '0');
			key <= (others => '0');
		elsif I_NEWFRAME = '0' then
			count <= 0;
		elsif (I_CLK'event and I_CLK = '1' and ready = '1') then
			-- Инициализация
			if (count = 0) then
				count <= 1;
				device_id <= data;
			else
				count <= count + 1;
				case device_id is
					when x"04" =>	-- HID0 Gamepad
						case count is
							when 4 => joy0(0) <= data(7);			-- Right
								  joy0(1) <= not data(6);		-- Left
							when 5 => joy0(2) <= data(7);			-- Down
								  joy0(3) <= not data(6);		-- Up
							when 6 => joy0(6) <= data(6) or data(7);	-- B [3][4]
								  joy0(7) <= data(4) or data(5);	-- A [1][2]
							when 7 => joy0(4) <= data(1);			-- Start [R1]
								  joy0(5) <= data(0);			-- Select [L1]
								  joy0(6) <= joy0(6) or data(2);	-- B [L2]
								  joy0(7) <= joy0(7) or data(3);	-- A [R2]
								  key(0) <= data(4);			-- Reset [9]
								  key(1) <= data(5);			-- OSD [10]
							when others => null;
						end case;
					when x"06" =>	-- HID0 Keyboard
						if count = 1 then
							joy0 <= (others => '0');
							key <= (others => '0');
							if data(0) = '1' then joy0(7) <= '1'; end if;	-- A [LCtrl]
							if data(1) = '1' then joy0(6) <= '1'; end if;	-- B [LShift]
							if data(3) = '1' then key(1) <= '1'; end if;	-- OSD [LWin]
						else
							case data is
								when X"2C" => joy0(5) <= '1';		-- Select [Space]
								when X"28" => joy0(4) <= '1';		-- Start [Enter]
								when X"52" => joy0(3) <= '1';		-- Up
								when X"51" => joy0(2) <= '1';		-- Down
								when X"50" => joy0(1) <= '1';		-- Left
								when X"4F" => joy0(0) <= '1';		-- Right
								when X"29" => key(0) <= '1';		-- Reset [Esc]
								when others => null;
							end case;
						end if;
					when x"84" =>	-- HID1 Gamepad
						case count is
							when 4 => joy1(0) <= data(7);			-- Right
								  joy1(1) <= not data(6);		-- Left
							when 5 => joy1(2) <= data(7);			-- Down
								  joy1(3) <= not data(6);		-- Up
							when 6 => joy1(7) <= data(4) or data(5);	-- A [1][2]
								  joy1(6) <= data(6) or data(7);	-- B [3][4]
							when 7 => joy1(5) <= data(0);			-- Select [L1]
								  joy1(4) <= data(1);			-- Start [R1]
								  joy1(7) <= joy1(7) or data(3);	-- A [R2]
								  joy1(6) <= joy1(6) or data(2);	-- B [L2]
							when others => null;
						end case;
					when x"86" =>	-- HID1 Keyboard
						if count = 1 then
							joy1 <= (others => '0');
							if data(0) = '1' then joy1(7) <= '1'; end if;	-- A [LCtrl]
							if data(1) = '1' then joy1(6) <= '1'; end if;	-- B [LShift]
						else
							case data is
								when X"2C" => joy1(5) <= '1';		-- Select [Space]
								when X"28" => joy1(4) <= '1';		-- Start [Enter]
								when X"52" => joy1(3) <= '1';		-- Up
								when X"51" => joy1(2) <= '1';		-- Down
								when X"50" => joy1(1) <= '1';		-- Left
								when X"4F" => joy1(0) <= '1';		-- Right
								when others => null;
							end case;
						end if;
					when others => null;
				end case;
			end if;
		end if;
	end process;
	
	process (I_JOYPAD_CLK1, I_JOYPAD_LATCH)
	begin
		if (I_JOYPAD_LATCH = '1') then
			cnt1 <= (others => '0');
		elsif (I_JOYPAD_CLK1'event and I_JOYPAD_CLK1 = '0') then
			cnt1 <= cnt1 + 1;
		end if;
	end process;

	process (I_JOYPAD_LATCH)
	begin
		if (I_JOYPAD_LATCH'event and I_JOYPAD_LATCH = '1') then
			joy_data <= joy1 & joy0;
		end if;
	end process;
	
	process (cnt1, joy_data)
	begin
		case cnt1 is
			when "111" => O_JOYPAD_DATA1 <= joy_data(0);	-- Right
			when "110" => O_JOYPAD_DATA1 <= joy_data(1);	-- Left
			when "101" => O_JOYPAD_DATA1 <= joy_data(2);	-- Down
			when "100" => O_JOYPAD_DATA1 <= joy_data(3);	-- Up
			when "011" => O_JOYPAD_DATA1 <= joy_data(4);	-- Start
			when "010" => O_JOYPAD_DATA1 <= joy_data(5);	-- Select
			when "001" => O_JOYPAD_DATA1 <= joy_data(6);	-- B
			when "000" => O_JOYPAD_DATA1 <= joy_data(7);	-- A
			when others => null;
		end case;
	end process;

	process (I_JOYPAD_CLK2, I_JOYPAD_LATCH)
	begin
		if (I_JOYPAD_LATCH = '1') then
			cnt2 <= (others => '0');
		elsif (I_JOYPAD_CLK2'event and I_JOYPAD_CLK2 = '0') then
			cnt2 <= cnt2 + 1;
		end if;
	end process;

	process (cnt2, joy_data)
	begin
		case cnt2 is
			when "111" => O_JOYPAD_DATA2 <= joy_data(8);	-- Right
			when "110" => O_JOYPAD_DATA2 <= joy_data(9);	-- Left
			when "101" => O_JOYPAD_DATA2 <= joy_data(10);	-- Down
			when "100" => O_JOYPAD_DATA2 <= joy_data(11);	-- Up
			when "011" => O_JOYPAD_DATA2 <= joy_data(12);	-- Start
			when "010" => O_JOYPAD_DATA2 <= joy_data(13);	-- Select
			when "001" => O_JOYPAD_DATA2 <= joy_data(14);	-- B
			when "000" => O_JOYPAD_DATA2 <= joy_data(15);	-- A
			when others => null;
		end case;
	end process;
	
	O_KEY <= key;
	O_JOY0 <= joy0;
	O_JOY1 <= joy1;
	
end architecture;
