-------------------------------------------------------------------[14.10.2011]
-- MC146818A REAL-TIME CLOCK PLUS RAM
-------------------------------------------------------------------------------
-- V0.1 	05.10.2011	первая версия
-- V0.2

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_unsigned.all;

entity MC146818A is
port (
	RESET	: in std_logic;
	CLK		: in std_logic;
	ENA		: in std_logic;
	CS		: in std_logic;
	WR		: in std_logic;
	A		: in std_logic_vector(5 downto 0);
	DI		: in std_logic_vector(7 downto 0);
	DO		: out std_logic_vector(7 downto 0));
end;

architecture RTL of MC146818A is
	signal pre_scaler			: std_logic_vector(18 downto 0);
	signal leap_reg				: std_logic_vector(1 downto 0);
	signal seconds_reg			: std_logic_vector(7 downto 0); -- 00
	signal seconds_alarm_reg	: std_logic_vector(7 downto 0); -- 01
	signal minutes_reg			: std_logic_vector(7 downto 0); -- 02
	signal minutes_alarm_reg	: std_logic_vector(7 downto 0); -- 03
	signal hours_reg			: std_logic_vector(7 downto 0); -- 04
	signal hours_alarm_reg		: std_logic_vector(7 downto 0); -- 05
	signal weeks_reg			: std_logic_vector(7 downto 0); -- 06
	signal days_reg				: std_logic_vector(7 downto 0); -- 07
	signal month_reg			: std_logic_vector(7 downto 0); -- 08
	signal year_reg				: std_logic_vector(7 downto 0); -- 09
	signal a_reg				: std_logic_vector(7 downto 0); -- 0A
	signal b_reg				: std_logic_vector(7 downto 0); -- 0B
	signal c_reg				: std_logic_vector(7 downto 0); -- 0C
--	signal d_reg				: std_logic_vector(7 downto 0); -- 0D
	signal e_reg				: std_logic_vector(7 downto 0); -- 0E
	signal f_reg				: std_logic_vector(7 downto 0); -- 0F
	signal reg10				: std_logic_vector(7 downto 0); 
	signal reg11				: std_logic_vector(7 downto 0);
	signal reg12				: std_logic_vector(7 downto 0);
	signal reg13				: std_logic_vector(7 downto 0);
	signal reg14				: std_logic_vector(7 downto 0);
	signal reg15				: std_logic_vector(7 downto 0);
	signal reg16				: std_logic_vector(7 downto 0);
	signal reg17				: std_logic_vector(7 downto 0);
	signal reg18				: std_logic_vector(7 downto 0);
	signal reg19				: std_logic_vector(7 downto 0);
	signal reg1a				: std_logic_vector(7 downto 0);
	signal reg1b				: std_logic_vector(7 downto 0);
	signal reg1c				: std_logic_vector(7 downto 0);
	signal reg1d				: std_logic_vector(7 downto 0);
	signal reg1e				: std_logic_vector(7 downto 0);
	signal reg1f				: std_logic_vector(7 downto 0);
	signal reg20				: std_logic_vector(7 downto 0);
	signal reg21				: std_logic_vector(7 downto 0);
	signal reg22				: std_logic_vector(7 downto 0);
	signal reg23				: std_logic_vector(7 downto 0);
	signal reg24				: std_logic_vector(7 downto 0);
	signal reg25				: std_logic_vector(7 downto 0);
	signal reg26				: std_logic_vector(7 downto 0);
	signal reg27				: std_logic_vector(7 downto 0);
	signal reg28				: std_logic_vector(7 downto 0);
	signal reg29				: std_logic_vector(7 downto 0);
	signal reg2a				: std_logic_vector(7 downto 0);
	signal reg2b				: std_logic_vector(7 downto 0);
	signal reg2c				: std_logic_vector(7 downto 0);
	signal reg2d				: std_logic_vector(7 downto 0);
	signal reg2e				: std_logic_vector(7 downto 0);
	signal reg2f				: std_logic_vector(7 downto 0);
	signal reg30				: std_logic_vector(7 downto 0);
	signal reg31				: std_logic_vector(7 downto 0);
	signal reg32				: std_logic_vector(7 downto 0);
	signal reg33				: std_logic_vector(7 downto 0);
	signal reg34				: std_logic_vector(7 downto 0);
	signal reg35				: std_logic_vector(7 downto 0);
	signal reg36				: std_logic_vector(7 downto 0);
	signal reg37				: std_logic_vector(7 downto 0);
	signal reg38				: std_logic_vector(7 downto 0);
	signal reg39				: std_logic_vector(7 downto 0);
	signal reg3a				: std_logic_vector(7 downto 0);
	signal reg3b				: std_logic_vector(7 downto 0);
	signal reg3c				: std_logic_vector(7 downto 0);
	signal reg3d				: std_logic_vector(7 downto 0);
	signal reg3e				: std_logic_vector(7 downto 0);
	signal reg3f				: std_logic_vector(7 downto 0);	

begin
	process(A, seconds_reg, seconds_alarm_reg, minutes_reg, minutes_alarm_reg, hours_reg, hours_alarm_reg, weeks_reg, days_reg, month_reg, year_reg,
			a_reg, b_reg, c_reg, e_reg, f_reg, reg10, reg11, reg12, reg13, reg14, reg15, reg16, reg17, reg18, reg19, reg1a, reg1b, reg1c, reg1d,
			reg1e, reg1f, reg20, reg21, reg22, reg23, reg24, reg25, reg26, reg27, reg28, reg29, reg2a, reg2b, reg2c, reg2d, reg2e, reg2f, reg30,
			reg31, reg32, reg33, reg34, reg35, reg36, reg37, reg38, reg39, reg3a, reg3b, reg3c, reg3d, reg3e, reg3f)
	begin
		-- RTC register read
		case A(5 downto 0) is
			when "000000" => DO <= seconds_reg;
			when "000001" => DO <= seconds_alarm_reg;
			when "000010" => DO <= minutes_reg;
			when "000011" => DO <= minutes_alarm_reg;
			when "000100" => DO <= hours_reg;
			when "000101" => DO <= hours_alarm_reg;
			when "000110" => DO <= weeks_reg;
			when "000111" => DO <= days_reg;
			when "001000" => DO <= month_reg;
			when "001001" => DO <= year_reg;
			when "001010" => DO <= a_reg;
			when "001011" => DO <= b_reg;
			when "001100" => DO <= c_reg;
			when "001101" => DO <= "10000000";
			when "001110" => DO <= e_reg;
			when "001111" => DO <= f_reg;
			when "010000" => DO <= reg10;
			when "010001" => DO <= reg11;
			when "010010" => DO <= reg12;
			when "010011" => DO <= reg13;
			when "010100" => DO <= reg14;
			when "010101" => DO <= reg15;
			when "010110" => DO <= reg16;
			when "010111" => DO <= reg17;
			when "011000" => DO <= reg18;
			when "011001" => DO <= reg19;
			when "011010" => DO <= reg1a;
			when "011011" => DO <= reg1b;
			when "011100" => DO <= reg1c;
			when "011101" => DO <= reg1d;
			when "011110" => DO <= reg1e;
			when "011111" => DO <= reg1f;
			when "100000" => DO <= reg20;
			when "100001" => DO <= reg21;
			when "100010" => DO <= reg22;
			when "100011" => DO <= reg23;
			when "100100" => DO <= reg24;
			when "100101" => DO <= reg25;
			when "100110" => DO <= reg26;
			when "100111" => DO <= reg27;
			when "101000" => DO <= reg28;
			when "101001" => DO <= reg29;
			when "101010" => DO <= reg2a;
			when "101011" => DO <= reg2b;
			when "101100" => DO <= reg2c;
			when "101101" => DO <= reg2d;
			when "101110" => DO <= reg2e;
			when "101111" => DO <= reg2f;
			when "110000" => DO <= reg30;
			when "110001" => DO <= reg31;
			when "110010" => DO <= reg32;
			when "110011" => DO <= reg33;
			when "110100" => DO <= reg34;
			when "110101" => DO <= reg35;
			when "110110" => DO <= reg36;
			when "110111" => DO <= reg37;
			when "111000" => DO <= reg38;
			when "111001" => DO <= reg39;
			when "111010" => DO <= reg3a;
			when "111011" => DO <= reg3b;
			when "111100" => DO <= reg3c;
			when "111101" => DO <= reg3d;
			when "111110" => DO <= reg3e;
			when "111111" => DO <= reg3f;
			when others => null;
		end case;
	end process;
		
	process(CLK, ENA, RESET)
	begin
		if RESET = '1' then
			a_reg <= "00100110";
			b_reg <= (others => '0');
			c_reg <= (others => '0');
		elsif CLK'event and CLK = '1' then
			-- RTC register write
			if WR = '1' and CS = '1' then
				case A(5 downto 0) is
					when "000000" => seconds_reg <= DI;
					when "000001" => seconds_alarm_reg <= DI;
					when "000010" => minutes_reg <= DI;
					when "000011" => minutes_alarm_reg <= DI;
					when "000100" => hours_reg <= DI;
					when "000101" => hours_alarm_reg <= DI;
					when "000110" => weeks_reg <= DI;
					when "000111" => days_reg <= DI;
					when "001000" => month_reg <= DI;
					when "001001" => year_reg <= DI;
						if b_reg(2) = '0' then -- BCD to BIN convertion
							if DI(4) = '0' then
								leap_reg <= DI(1 downto 0);
							else
								leap_reg <= (not DI(1)) & DI(0);
							end if;
						else 
							leap_reg <= DI(1 downto 0);
						end if;
					when "001010" => a_reg <= DI;
					when "001011" => b_reg <= DI;
--					when "001100" => c_reg <= DI;
--					when "001101" => d_reg <= DI;
					when "001110" => e_reg <= DI;
					when "001111" => f_reg <= DI;
					when "010000" => reg10 <= DI;
					when "010001" => reg11 <= DI;
					when "010010" => reg12 <= DI;
					when "010011" => reg13 <= DI;
					when "010100" => reg14 <= DI;
					when "010101" => reg15 <= DI;
					when "010110" => reg16 <= DI;
					when "010111" => reg17 <= DI;
					when "011000" => reg18 <= DI;
					when "011001" => reg19 <= DI;
					when "011010" => reg1a <= DI;
					when "011011" => reg1b <= DI;
					when "011100" => reg1c <= DI;
					when "011101" => reg1d <= DI;
					when "011110" => reg1e <= DI;
					when "011111" => reg1f <= DI;
					when "100000" => reg20 <= DI;
					when "100001" => reg21 <= DI;
					when "100010" => reg22 <= DI;
					when "100011" => reg23 <= DI;
					when "100100" => reg24 <= DI;
					when "100101" => reg25 <= DI;
					when "100110" => reg26 <= DI;
					when "100111" => reg27 <= DI;
					when "101000" => reg28 <= DI;
					when "101001" => reg29 <= DI;
					when "101010" => reg2a <= DI;
					when "101011" => reg2b <= DI;
					when "101100" => reg2c <= DI;
					when "101101" => reg2d <= DI;
					when "101110" => reg2e <= DI;
					when "101111" => reg2f <= DI;
					when "110000" => reg30 <= DI;
					when "110001" => reg31 <= DI;
					when "110010" => reg32 <= DI;
					when "110011" => reg33 <= DI;
					when "110100" => reg34 <= DI;
					when "110101" => reg35 <= DI;
					when "110110" => reg36 <= DI;
					when "110111" => reg37 <= DI;
					when "111000" => reg38 <= DI;
					when "111001" => reg39 <= DI;
					when "111010" => reg3a <= DI;
					when "111011" => reg3b <= DI;
					when "111100" => reg3c <= DI;
					when "111101" => reg3d <= DI;
					when "111110" => reg3e <= DI;
					when "111111" => reg3f <= DI;
					when others => null;
				end case;
			end if;
			if b_reg(7) = '0' and ENA = '1' then
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
end rtl;