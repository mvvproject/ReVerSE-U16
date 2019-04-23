-------------------------------------------------------------------[23.06.2018]
-- CONTROLLER USB HID
-------------------------------------------------------------------------------
-- Engineer: MVV <mvvproject@gmail.com>

---------------------------------------------------------------------------
-- (c) 2015 Alexey Spirkov
-- I am happy for anyone to use this for non-commercial use.
-- If my vhdl/c files are used commercially or otherwise sold,
-- please contact me for explicit permission at me _at_ alsp.net.
-- This applies for source and binary form and derived works.
---------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.all;
use ieee.numeric_std.all;

ENTITY vnc2hid IS
PORT
( 
	CLK			: IN STD_LOGIC;
	RESET			: IN STD_LOGIC;
	USB_TX			: IN STD_LOGIC;
	KEYBOARD_SCAN		: IN STD_LOGIC_VECTOR(5 downto 0);
	KEYBOARD_RESPONSE	: OUT STD_LOGIC_VECTOR(1 downto 0);
	CONSOL_START		: OUT STD_LOGIC;
	CONSOL_SELECT		: OUT STD_LOGIC;
	CONSOL_OPTION		: OUT STD_LOGIC;
	RESET_BUTTON		: OUT STD_LOGIC;
	FKEYS			: OUT STD_LOGIC_VECTOR(11 downto 0);
	JOY1_n			: OUT std_logic_vector(4 downto 0);
	JOY2_n			: OUT std_logic_vector(4 downto 0);
	CTL_KEYS		: OUT std_logic_vector(8 downto 0); -- SCRLOCK(8) & LGUI (7) & LALT (6) & ESC (5) & RET (4) & Right (3) & Left (2) & Down (1) & Up (0)
	CTL_KEYS_PREV		: OUT std_logic_vector(8 downto 0);
	NEW_FRAME		: IN STD_LOGIC);
--	DEBUG1			: OUT STD_LOGIC;
--	DEBUG2			: OUT STD_LOGIC);
	
END vnc2hid;

ARCHITECTURE vhdl OF vnc2hid IS
	signal consol_start_int : std_logic;
	signal consol_select_int : std_logic;
	signal consol_option_int : std_logic;
	signal reset_button_int : std_logic;
	signal fkeys_int : std_logic_vector(11 downto 0);
	signal atari_keyboard : std_logic_vector(63 downto 0);
	signal shift_pressed :  std_logic;
	signal break_pressed :  std_logic;
	signal control_pressed :  std_logic;
	signal keyb_data	: std_logic_vector(7 downto 0);
	signal joy1_int_n: std_logic_vector(4 downto 0);
	signal joy2_int_n: std_logic_vector(4 downto 0);
	signal joy_int_n_new: std_logic_vector(4 downto 0);
	signal ctl_keys_int: std_logic_vector(8 downto 0);
	signal ctl_keys_prev_int: std_logic_vector(8 downto 0);
	signal consol_start_joy_int : std_logic;
	signal consol_select_joy_int : std_logic;
	signal consol_option_joy_int : std_logic;
	signal reset_button_joy_int : std_logic;
	signal joy_button_f11_int : std_logic;
	signal joy_button_f12_int : std_logic;
	signal debug: std_logic;
	signal debug_2: std_logic;
	signal byte_ready: std_logic;
	signal byte_count: integer range 0 to 8;
	signal frame_signal_prev: std_logic;
	signal port_selector: std_logic;
	signal device_id: std_logic_vector(3 downto 0);
	
BEGIN

	inst_rx : entity work.receiver
	port map (
		I_CLK		=> CLK,
		I_RESET		=> RESET,
		I_RX		=> USB_TX,
		O_DATA		=> keyb_data,
		O_READY		=> byte_ready
		);
	
	process (RESET,CLK,NEW_FRAME,byte_ready)
	begin
	
		if RESET = '1' then
			atari_keyboard <= (others=>'0');
			shift_pressed <= '0';
			control_pressed <= '0';
			break_pressed <= '0';
			consol_start_int <= '0';
			consol_select_int <= '0';
			consol_option_int <= '0';
			reset_button_int <= '0';
			consol_start_joy_int <= '0';
			consol_select_joy_int <= '0';
			consol_option_joy_int <= '0';
			reset_button_joy_int <= '0';
			joy_button_f11_int <= '0';
			joy_button_f12_int <= '0';
			joy1_int_n <= (others=>'1');
			joy2_int_n <= (others=>'1');
			joy_int_n_new <= (others=>'1');
			ctl_keys_int <= (others=>'0');
			ctl_keys_prev_int <= (others=>'0');
			fkeys_int <= (others=>'0');	
			byte_count <= 0;
			port_selector <= '0';
			device_id <= (others=>'0');								
			--debug <= '0';
			--debug_2 <= '0';
		elsif NEW_FRAME = '0' then 
			byte_count <= 0;
		elsif CLK'event and CLK = '1' and byte_ready = '1' then
		   -- debug <= not debug;
			if byte_count = 0 then 	
					byte_count <= 1;
					-- debug_2 <= '1';					
					port_selector <= keyb_data(7);
					device_id <= keyb_data(3 downto 0);
					case keyb_data(3 downto 0) is
						when x"6" =>
							atari_keyboard <= (others=>'0');
							shift_pressed <= '0';
							control_pressed <= '0';
							break_pressed <= '0';
							consol_start_int <= '0';
							consol_select_int <= '0';
							consol_option_int <= '0';
							reset_button_int <= '0';
							ctl_keys_prev_int <= ctl_keys_int;
							ctl_keys_int <= (others=>'0');
							fkeys_int <= (others=>'0');			
							joy1_int_n <= (others=>'1');
							joy2_int_n <= (others=>'1');
						when x"4" => 					
							consol_start_joy_int <= '0';
							consol_select_joy_int <= '0';
							consol_option_joy_int <= '0';
							reset_button_joy_int <= '0';
							joy_button_f11_int <= '0';
							joy_button_f12_int <= '0';
							joy_int_n_new <= (others=>'1');
						when others => null;
					end case;
			else	
				byte_count <= byte_count + 1;
				--debug_2 <= '0'; 
				case device_id is
					when x"4" => 					-- joystick
						if(byte_count = 4) then	-- left/right						
								joy_int_n_new(3) <= not keyb_data(7); -- (Right)
								joy_int_n_new(2) <= keyb_data(6); -- (Left)						
						elsif (byte_count = 5) then -- up/down
								joy_int_n_new(1) <= not keyb_data(7); -- (Up)
								joy_int_n_new(0) <= keyb_data(6); -- (Down)
						elsif (byte_count = 6) then -- buttons
								joy_int_n_new(4) <= not (keyb_data(7) or keyb_data(6) or keyb_data(5) or keyb_data(4)); -- (Fire)					
						elsif (byte_count = 7) then -- control buttons 
							consol_start_joy_int <= keyb_data(5); -- Key 10
							consol_select_joy_int <= keyb_data(4); -- Key 9
							consol_option_joy_int <= keyb_data(2); -- L2
							reset_button_joy_int <= keyb_data(3); -- R2
							joy_button_f11_int <= keyb_data(0); -- L1
							joy_button_f12_int <= keyb_data(1); -- R1
						elsif (byte_count = 8) then -- write
							if(port_selector = '0') then								
									joy1_int_n <= joy_int_n_new;
							else 
									joy2_int_n <= joy_int_n_new;
							end if;
						end if;
					when x"6" => -- keyboard				
						if byte_count = 1 then 
								control_pressed  <= keyb_data(4); -- CTRL
								shift_pressed <= keyb_data(1) or keyb_data(5); -- Shifts
								atari_keyboard(39) <= keyb_data(6); -- Right Alt (Inv)				
								joy1_int_n(4) <= not keyb_data(0); -- Left Control (Fire)	
								ctl_keys_int(6) <= keyb_data(2); -- Left Alt 
								ctl_keys_int(7) <= keyb_data(3); -- Left Gui 
						else				
							case keyb_data is

								when X"0f" => atari_keyboard(0)  <= '1'; -- L
								when X"0d" => atari_keyboard(1)  <= '1'; -- J
								when X"33" => atari_keyboard(2)  <= '1'; -- ;
								when X"3a" => atari_keyboard(3)  <= '1'; -- F1
										fkeys_int(0) <= '1';
								when X"3b" => atari_keyboard(4)  <= '1'; -- F2
										fkeys_int(1) <= '1';
								when X"0e" => atari_keyboard(5)  <= '1'; -- K
								when X"34" => atari_keyboard(6)  <= '1'; -- "
								when X"31" => atari_keyboard(7)  <= '1'; -- \
								when X"12" => atari_keyboard(8)  <= '1'; -- O
								when X"13" => atari_keyboard(10) <= '1'; -- P
								when X"18" => atari_keyboard(11) <= '1'; -- U
								when X"28" => atari_keyboard(12) <= '1'; -- ENTER
										ctl_keys_int(4) <= '1';
								when X"0c" => atari_keyboard(13) <= '1'; -- I
								when X"2f" => atari_keyboard(14) <= '1'; -- -
								when X"30" => atari_keyboard(15) <= '1'; -- =
								when X"19" => atari_keyboard(16) <= '1'; -- V
								when X"3e" => atari_keyboard(17) <= '1'; -- F5 (Help)
										fkeys_int(4) <= '1';				
								when X"4a" => atari_keyboard(17) <= '1'; -- Home (Help)
								when X"06" => atari_keyboard(18) <= '1'; -- C
								when X"3c" => atari_keyboard(19) <= '1'; -- F3
										fkeys_int(2) <= '1';				
								when X"3d" => atari_keyboard(20) <= '1'; -- F4
										fkeys_int(3) <= '1';				
								when X"05" => atari_keyboard(21) <= '1'; -- B
								when X"1b" => atari_keyboard(22) <= '1'; -- X
								when X"1d" => atari_keyboard(23) <= '1'; -- Z
								when X"21" => atari_keyboard(24) <= '1'; -- 4
								when X"20" => atari_keyboard(26) <= '1'; -- 3
								when X"23" => atari_keyboard(27) <= '1'; -- 6
								when X"29" => atari_keyboard(28) <= '1'; -- Esc
										ctl_keys_int(5) <= '1';
								when X"22" => atari_keyboard(29) <= '1'; -- 5
								when X"1f" => atari_keyboard(30) <= '1'; -- 2
								when X"1e" => atari_keyboard(31) <= '1'; -- 1
								when X"36" => atari_keyboard(32) <= '1'; -- ,
								when X"2c" => atari_keyboard(33) <= '1'; -- SPACE
								when X"37" => atari_keyboard(34) <= '1'; -- .
								when X"11" => atari_keyboard(35) <= '1'; -- N
								when X"10" => atari_keyboard(37) <= '1'; -- M
								when X"38" => atari_keyboard(38) <= '1'; -- ?
								when X"15" => atari_keyboard(40) <= '1'; -- R
								when X"08" => atari_keyboard(42) <= '1'; -- E
								when X"1c" => atari_keyboard(43) <= '1'; -- Y
								when X"2b" => atari_keyboard(44) <= '1'; -- Tab
								when X"17" => atari_keyboard(45) <= '1'; -- T
								when X"1a" => atari_keyboard(46) <= '1'; -- W
								when X"14" => atari_keyboard(47) <= '1'; -- Q
								when X"26" => atari_keyboard(48) <= '1'; -- 9
								when X"27" => atari_keyboard(50) <= '1'; -- 0
								when X"24" => atari_keyboard(51) <= '1'; -- 7
								when X"2a" => atari_keyboard(52) <= '1'; -- Backspace
								when X"25" => atari_keyboard(53) <= '1'; -- 8
								when X"2d" => atari_keyboard(54) <= '1'; -- -(<)
								when X"2e" => atari_keyboard(55) <= '1'; -- =(>)
								when X"09" => atari_keyboard(56) <= '1'; -- F
								when X"0b" => atari_keyboard(57) <= '1'; -- H
								when X"07" => atari_keyboard(58) <= '1'; -- D
								when X"39" => atari_keyboard(60) <= '1'; -- Caps
								when X"0a" => atari_keyboard(61) <= '1'; -- G
								when X"16" => atari_keyboard(62) <= '1'; -- S
								when X"04" => atari_keyboard(63) <= '1'; -- A
								when X"3f" => fkeys_int(5) <= '1';  -- F6
										 consol_start_int <= '1';
								when X"40" => fkeys_int(6)  <= '1'; -- F7
										 consol_select_int <= '1';
								when X"41" => fkeys_int(7)  <= '1'; -- F8
										 consol_option_int <= '1';
								when X"42" => fkeys_int(8)  <= '1'; -- F9
								when X"43" => fkeys_int(9)  <= '1'; -- F10
								when X"44" => fkeys_int(10) <= '1'; -- F11
								when X"45" => fkeys_int(11) <= '1'; -- F12
								
								-- Cursor keys
								when X"4f" => joy1_int_n(3) <= '0'; -- Right
										ctl_keys_int(3) <= '1';
								when X"50" => joy1_int_n(2) <= '0'; -- Left
										ctl_keys_int(2) <= '1';
								when X"51" => joy1_int_n(1) <= '0'; -- Down
										ctl_keys_int(1) <= '1';
								when X"52" => joy1_int_n(0) <= '0'; -- Up
										ctl_keys_int(0) <= '1';

								when X"62" => joy2_int_n(4) <= '0'; -- [0] (Fire)
								when X"5e" => joy2_int_n(3) <= '0'; -- [6] (Right)
								when X"5c" => joy2_int_n(2) <= '0'; -- [4] (Left)
								when X"5d" => joy2_int_n(1) <= '0'; -- [5] (Down)
								when X"60" => joy2_int_n(0) <= '0'; -- [8] (Up)
						
								when X"48" => break_pressed <= '1';	-- Pause

								when X"46" => reset_button_int <= '1';	-- PrtScr

								when X"47" => ctl_keys_int(8) <= '1';	-- Scroll Lock
								-- when X"4c" => freezer_activate_int <= '1';	-- Delete
											
								when others => null;
							end case;
						end if;
					when others => null;
				end case;			
			end if;						
		end if;

	end process;
		
	-- provide results as if we were a grid to pokey...
	process(keyboard_scan, atari_keyboard, control_pressed, shift_pressed, break_pressed)
		begin	
			keyboard_response <= (others=>'1');		
			
			if (atari_keyboard(to_integer(unsigned(not(keyboard_scan)))) = '1') then
				keyboard_response(0) <= '0';
			end if;
			
			if (keyboard_scan(5 downto 4)="00" and break_pressed = '1') then
				keyboard_response(1) <= '0';
			end if;
			
			if (keyboard_scan(5 downto 4)="10" and shift_pressed = '1') then
				keyboard_response(1) <= '0';
			end if;

			if (keyboard_scan(5 downto 4)="11" and control_pressed = '1') then
				keyboard_response(1) <= '0';
			end if;
	end process;		 

	
	-- outputs
	CONSOL_START <= consol_start_int or consol_start_joy_int;
	CONSOL_SELECT <= consol_select_int or consol_select_joy_int;
	CONSOL_OPTION <= consol_option_int or consol_option_joy_int;
	RESET_BUTTON <= reset_button_int or reset_button_joy_int;
	
	FKEYS <= (fkeys_int(11) or joy_button_f12_int) & (fkeys_int(10) or joy_button_f11_int) & fkeys_int(9 downto 0);

	JOY1_n <= joy1_int_n;
	JOY2_n <= joy2_int_n;
	
	CTL_KEYS <= ctl_keys_int;

	CTL_KEYS_PREV <= ctl_keys_prev_int;
	
	--DEBUG1 <= debug;
	--DEBUG2 <= debug_2;

END vhdl;

