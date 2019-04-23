-------------------------------------------------------------------[18.10.2014]
-- MC146818A REAL-TIME CLOCK PLUS RAM
-------------------------------------------------------------------------------
-- V0.1 	05.10.2011	Initial version
-- V0.2		06.09.2014	Added General Purpose RAM

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_unsigned.all;

entity mc146818a is
port (
	RESET		: in std_logic;
	CLK		: in std_logic;
	ENA		: in std_logic;
	CS		: in std_logic;
	KEYSCANCODE 	: in std_logic_vector(7 downto 0);
	WR		: in std_logic;
	A		: in std_logic_vector(7 downto 0);
	DI		: in std_logic_vector(7 downto 0);
	DO		: out std_logic_vector(7 downto 0));
end;

architecture rtl of mc146818a is
	signal pre_scaler		: std_logic_vector(18 downto 0);
	signal leap_reg			: std_logic_vector(1 downto 0);
	signal seconds_reg		: std_logic_vector(7 downto 0); -- 00
	signal seconds_alarm_reg	: std_logic_vector(7 downto 0); -- 01
	signal minutes_reg		: std_logic_vector(7 downto 0); -- 02
	signal minutes_alarm_reg	: std_logic_vector(7 downto 0); -- 03
	signal hours_reg		: std_logic_vector(7 downto 0); -- 04
	signal hours_alarm_reg		: std_logic_vector(7 downto 0); -- 05
	signal weeks_reg		: std_logic_vector(7 downto 0); -- 06
	signal days_reg			: std_logic_vector(7 downto 0); -- 07
	signal month_reg		: std_logic_vector(7 downto 0); -- 08
	signal year_reg			: std_logic_vector(7 downto 0); -- 09
	signal a_reg			: std_logic_vector(7 downto 0); -- 0A
	signal b_reg			: std_logic_vector(7 downto 0); -- 0B
	signal c_reg			: std_logic_vector(7 downto 0); -- 0C

	signal CMOS_Dout		: std_logic_vector(7 downto 0);
	signal Dout			: std_logic_vector(7 downto 0);
   

begin
	DO <= Dout;
	
	process(CLK, A, seconds_reg, seconds_alarm_reg, minutes_reg, minutes_alarm_reg, hours_reg, hours_alarm_reg, weeks_reg, days_reg, month_reg, year_reg, KEYSCANCODE, CMOS_Dout, a_reg, b_reg, c_reg)	
	begin
		-- 14 Bytes of Clock and Control Registers Read
		case A(7 downto 0) is
			when x"00" => Dout <= seconds_reg;
			when x"01" => Dout <= seconds_alarm_reg;
			when x"02" => Dout <= minutes_reg;
			when x"03" => Dout <= minutes_alarm_reg;
			when x"04" => Dout <= hours_reg;
			when x"05" => Dout <= hours_alarm_reg;
			when x"06" => Dout <= weeks_reg;
			when x"07" => Dout <= days_reg;
			when x"08" => Dout <= month_reg;
			when x"09" => Dout <= year_reg;
			when x"0a" => Dout <= a_reg;
			when x"0b" => Dout <= b_reg;
			when x"0c" => Dout <= c_reg;
			when x"0d" => Dout <= "10000000";
			when x"f0" => Dout <= KEYSCANCODE;
			when others => Dout <= CMOS_Dout;   
			end case;
	end process;
		
	process(CLK, ENA, RESET)
	begin
		if CLK'event and CLK = '1' then
			if RESET = '1' then
				b_reg <= (others => '0');
			-- RTC register write
			elsif WR = '1' and CS = '1' then
				case A(7 downto 0) is
					when x"00" => seconds_reg <= DI;
					when x"01" => seconds_alarm_reg <= DI;
					when x"02" => minutes_reg <= DI;
					when x"03" => minutes_alarm_reg <= DI;
					when x"04" => hours_reg <= DI;
					when x"05" => hours_alarm_reg <= DI;
					when x"06" => weeks_reg <= DI;
					when x"07" => days_reg <= DI;
					when x"08" => month_reg <= DI;
					when x"09" => year_reg <= DI;
					when x"0b" => b_reg <= DI;
					
					if b_reg(2) = '0' then -- BCD to BIN convertion
						if DI(4) = '0' then
							leap_reg <= DI(1 downto 0);
						else
							leap_reg <= (not DI(1)) & DI(0);
						end if;
					else 
						leap_reg <= DI(1 downto 0);
					end if;
									
					when others   => null;
				end case;
			end if;
			
			if RESET = '1' then
				a_reg <= "00100110";
				c_reg <= (others => '0');
			elsif b_reg(7) = '0' and ENA = '1' then
				if pre_scaler /= X"000000" then
					pre_scaler <= pre_scaler - 1;
					a_reg(7) <= '0';
				else
					pre_scaler <= "1101010110011111100"; --(0.4375MHz)
					a_reg(7) <= '1';
					c_reg(4) <= '1';
					-- alarm
					if ((seconds_reg = seconds_alarm_reg) and
						(minutes_reg = minutes_alarm_reg) and
						(hours_reg = hours_alarm_reg)) then
						c_reg(5) <= '1';
					end if;
					-- DM binary-coded-decimal (BCD) data mode
					if b_reg(2) = '0' then
						if seconds_reg(3 downto 0) /= "1001" then
							seconds_reg(3 downto 0) <= seconds_reg(3 downto 0) + 1;
						else
							seconds_reg(3 downto 0) <= (others => '0');
							if seconds_reg(6 downto 4) /= "101" then
								seconds_reg(6 downto 4) <= seconds_reg(6 downto 4) + 1;
							else
								seconds_reg(6 downto 4) <= (others => '0');
								if minutes_reg(3 downto 0) /= "1001" then
									minutes_reg(3 downto 0) <= minutes_reg(3 downto 0) + 1;
								else
									minutes_reg(3 downto 0) <= (others => '0');
									if minutes_reg(6 downto 4) /= "101" then
										minutes_reg(6 downto 4) <= minutes_reg(6 downto 4) + 1;
									else
										minutes_reg(6 downto 4) <= (others => '0');
										if hours_reg(3 downto 0) = "1001" then
											hours_reg(3 downto 0) <= (others => '0');
											hours_reg(5 downto 4) <= hours_reg(5 downto 4) + 1;
										elsif b_reg(1) & hours_reg(7) & hours_reg(4 downto 0) = "0010010" then
											hours_reg(4 downto 0) <= "00001";
											hours_reg(7) <= not hours_reg(7);
										elsif ((b_reg(1) & hours_reg(7) & hours_reg(4 downto 0) /= "0110010") and
											(b_reg(1) & hours_reg(5 downto 0) /= "1100011")) then
											hours_reg(3 downto 0) <= hours_reg(3 downto 0) + 1;
										else	
											if b_reg(1) = '0' then
												hours_reg(7 downto 0) <= "00000001";
											else
												hours_reg(5 downto 0) <= (others => '0');
											end if;
											if weeks_reg(2 downto 0) /= "111" then
												weeks_reg(2 downto 0) <= weeks_reg(2 downto 0) + 1;
											else
												weeks_reg(2 downto 0) <= "001";
											end if;
											if ((month_reg & days_reg & leap_reg = X"0228" & "01") or
												(month_reg & days_reg & leap_reg = X"0228" & "10") or
												(month_reg & days_reg & leap_reg = X"0228" & "11") or
												(month_reg & days_reg & leap_reg = X"0229" & "00") or
												(month_reg & days_reg = X"0430") or
												(month_reg & days_reg = X"0630") or
												(month_reg & days_reg = X"0930") or
												(month_reg & days_reg = X"1130") or
												(			 days_reg = X"31")) then
													days_reg(5 downto 0) <= "000001";
													if month_reg(3 downto 0) = "1001" then
														month_reg(4 downto 0) <= "10000";
													elsif month_reg(4 downto 0) /= "10010" then
														month_reg(3 downto 0) <= month_reg(3 downto 0) + 1;
													else
														month_reg(4 downto 0) <= "00001";
														leap_reg(1 downto 0) <= leap_reg(1 downto 0) + 1;
														if year_reg(3 downto 0) /= "1001" then
															year_reg(3 downto 0) <= year_reg(3 downto 0) + 1;
														else
															year_reg(3 downto 0) <= "0000";
															if year_reg(7 downto 4) /= "1001" then
																year_reg(7 downto 4) <= year_reg(7 downto 4) + 1;
															else
																year_reg(7 downto 4) <= "0000";
															end if;
														end if;
													end if;
											elsif days_reg(3 downto 0) /= "1001" then
												days_reg(3 downto 0) <= days_reg(3 downto 0) + 1;
											else
												days_reg(3 downto 0) <= (others => '0');
												days_reg(5 downto 4) <= days_reg(5 downto 4) + 1;
											end if;
										end if;
									end if;
								end if;
							end if;
						end if;
					-- DM binary data mode
					else
						if seconds_reg /= x"3B" then
							seconds_reg <= seconds_reg + 1;
						else
							seconds_reg <= (others => '0');
							if minutes_reg /= x"3B" then
								minutes_reg <= minutes_reg + 1;
							else
								minutes_reg <= (others => '0');
								if b_reg(1) & hours_reg(7) & hours_reg(3 downto 0) = "001100" then
									hours_reg(7 downto 0) <= "10000001";
								elsif ((b_reg(1) & hours_reg(7) & hours_reg(3 downto 0) /= "011100") and
									(b_reg(1) & hours_reg(4 downto 0) /= "110111")) then
									hours_reg(4 downto 0) <= hours_reg(4 downto 0) + 1;
								else
									if b_reg(1) = '0' then
										hours_reg(7 downto 0) <= "00000001";
									else
										hours_reg <= (others => '0');
									end if;
									if weeks_reg /= x"07" then
										weeks_reg <= weeks_reg + 1;
									else
										weeks_reg <= x"01"; -- Sunday = 1
									end if;
									if ((month_reg & days_reg & leap_reg = X"021C" & "01") or
										(month_reg & days_reg & leap_reg = X"021C" & "10") or
										(month_reg & days_reg & leap_reg = X"021C" & "11") or
										(month_reg & days_reg & leap_reg = X"021D" & "00") or
										(month_reg & days_reg = X"041E") or
										(month_reg & days_reg = X"061E") or
										(month_reg & days_reg = X"091E") or
										(month_reg & days_reg = X"0B1E") or
										(			 days_reg = X"1F")) then
										days_reg <= x"01";
										if month_reg /= x"0C" then
											month_reg <= month_reg + 1;
										else
											month_reg <= x"01";
											leap_reg(1 downto 0) <= leap_reg(1 downto 0) + 1;
											if year_reg /= x"63" then
												year_reg <= year_reg + 1;
											else
												year_reg <= x"00";
											end if;
										end if;
									else
										days_reg <= days_reg + 1;
									end if;
								end if;
							end if;
						end if;
					end if;
				end if;
			end if;
		end if;
	end process;

-- 50 Bytes of General Purpose RAM	
SE11: entity work.CMOS
port map (
		clock		=> CLK,	
		data		=> DI, 
		rdaddress	=> A,
		wraddress	=> A,		
		wren		=> WR and CS,
		q		=> CMOS_Dout
	);
	
end rtl;