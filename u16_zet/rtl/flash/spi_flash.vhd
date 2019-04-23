-------------------------------------------------------------------[01.09.2013]
-- SPI Master
-------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

entity spi_flash is
	port (
		RESET		: in std_logic;						-- 
		CLK		: in std_logic;						-- 
		SCK		: in std_logic;						-- 
		spi_addr : in std_logic_vector(23 downto 0);   -- 
		spi_data : out std_logic_vector(15 downto 0);	 -- 
		spi_rd	: in std_logic;						       -- 1 = 
		READY		: out std_logic;					          -- 1 = 		
		---//------------------------------------
		CS_n		: out std_logic;					-- 
		SCLK		: out std_logic;					-- 
		MOSI		: out std_logic;					-- 
		MISO		: in std_logic 
		);					
end;

architecture rtl of spi_flash is
	signal cnt			: std_logic_vector(2 downto 0) := "000";		-- ������� ������������/����������� ���
	signal shift_reg	: std_logic_vector(7 downto 0) := "11111111";	-- ��������� �������
	signal cs			: std_logic := '1';
	signal buffer_reg	: std_logic_vector(7 downto 0) := "11111111";
	signal state		: std_logic_vector(3 downto 0) := "0000";
	signal start		: std_logic := '0';
	signal addr_reg	: std_logic_vector(23 downto 0);
	signal sclk_en	   : std_logic := '0';
	--//===============================================================

	
begin

	-- start
	process (RESET, CLK, state)
	begin
		if (RESET = '1' or not (state = X"0")) then
			start <= '0';
		elsif (CLK'event and CLK = '1') then
			if (spi_rd = '1') then
				start <= '1';
			end if;
		end if;
	end process;

	process (RESET, SCK, start, buffer_reg)
	begin
		if (RESET = '1') then
			state <= X"0";
			cnt <= "000";
			--shift_reg <= "11111111";
		elsif (SCK'event and SCK = '0') then
			case state is
			--================================================
				when X"0" =>     ------- Waiting for new RD CMD			
					if (start = '0') then
						--CS_n <= '1';  ---  Waiting 	
					else             ---- START = 1
					   addr_reg <= spi_addr; 
						--CS_n <= '0';  --- Chip is Selected
						state <= X"1";						
					end if;
				--============================================== 	
				when X"1" => -- WR READ CMD ------------------------------
					shift_reg <= "00000011"; --RD CMD           -- 1   Bit
					sclk_en <= '1';
					cnt <= "000";
					state <= X"2";
				when X"2" =>
					shift_reg <= shift_reg(6 downto 0) & MISO;  -- 1-8 bit
					cnt <= cnt + 1;
					if (cnt	= "111") then 
						state <= X"3"; 
						shift_reg <= addr_reg(23 downto 16); -- Hi Addr Byte 
						cnt <= "000";
						state <= X"4";
					end if; 
				--===============================================
				when X"4" =>
					shift_reg <= shift_reg(6 downto 0) & MISO;
					cnt <= cnt + 1;
					if (cnt	= "111") then	
						shift_reg <= addr_reg(15 downto 8); -- Mid Addr Byte
						cnt <= "000";
						state <= X"6"; 
					end if; 
				--===============================================
				when X"6" =>
					shift_reg <= shift_reg(6 downto 0) & MISO;
					cnt <= cnt + 1;
					if (cnt	= "111") then 
						shift_reg <= addr_reg(7 downto 0); -- Lo Addr Byte
						cnt <= "000";
						state <= X"8";
					end if; 
				--===============================================
				when X"8" =>
					shift_reg <= shift_reg(6 downto 0) & MISO;
					cnt <= cnt + 1;
					if (cnt	= "111") then 
						shift_reg <= "00000000";            
						cnt <= "000";
						state <= X"A"; 
					end if; 
				--===============================================
			   -- READ DATA BYTE
				when X"A" =>  -- READ Lo DATA BYTE
					shift_reg <= shift_reg(6 downto 0) & MISO;
					if (cnt	= "111") then 
						--spi_data(7 downto 0) <= shift_reg;
					   spi_data(7 downto 0) <= shift_reg(6 downto 0) & MISO;	
						-----------------------------------------------------
						shift_reg <= "00000000"; 
						cnt <= "000";
						state <= X"B";
					else
						cnt <= cnt + 1;
					end if; 
				--================================================
				when X"B" =>  -- READ Hi DATA BYTE
					shift_reg <= shift_reg(6 downto 0) & MISO;
					if (cnt	= "111") then 
						--spi_data(15 downto 8) <= shift_reg;
					   spi_data(15 downto 8) <= shift_reg(6 downto 0) & MISO;	
						---------------------------
						cnt <= "000";
						state <= X"0";
						--CS_n <= '1';    --- Chip is deselected
						sclk_en <= '0'; --- CLK Disable
					else
						cnt <= cnt + 1;
					end if; 
				--================================================
				when others => null;
			end case;
		end if;
	end process;
	

MOSI  <= shift_reg(7);
SCLK  <= SCK when sclk_en = '1' else '0';
CS_n  <= '0' when sclk_en = '1' else '1';
READY <= '0' when sclk_en = '1' else '1';

end rtl;