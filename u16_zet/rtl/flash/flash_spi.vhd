library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

entity spiflash is
   port (
      wb_clk_i      	: in  std_logic;
      wb_rst_i      	: in  std_logic;
      wb_dat_i      	: in  std_logic_vector(15 downto 0);
      wb_dat_o      	: out std_logic_vector(15 downto 0);
      wb_we_i      	: in  std_logic;
      wb_adr_i      	: in  std_logic;    -- Wishbone address line
      wb_sel_i      	: in  std_logic_vector(1 downto 0);
      wb_stb_i      	: in  std_logic;
      wb_cyc_i      	: in  std_logic;
      wb_ack_o      	: out std_logic;
   
      asmi_dataout   : in  std_logic_vector(0 downto 0);
      asmi_dataoe   	: out std_logic_vector(0 downto 0);
      asmi_dclk      : out std_logic;
      asmi_scein     : out std_logic;
      asmi_sdoin     : out std_logic_vector(0 downto 0) );
end;

architecture rtl of spiflash is
   -- Registers and nets
   signal op         	: std_logic;
   signal wr_command   	: std_logic;
   signal address      	: std_logic_vector(23 downto 0);
   signal rden         	: std_logic;
   signal read         	: std_logic;
   signal busy         	: std_logic;
   signal reset        	: std_logic;
   signal lb         	: std_logic_vector(7 downto 0);
   signal hb         	: std_logic_vector(7 downto 0);
   signal dataout      	: std_logic_vector(7 downto 0);
   signal state         : std_logic_vector(1 downto 0);
   signal data_valid    : std_logic;

begin

asmi_inst : entity work.asmi --Active Serial Memory Interface
PORT MAP (
   addr         => address,
   clkin        => not wb_clk_i,
   rden         => rden,
   read         => read,
   reset        => reset,
   busy         => busy,
   data_valid   => data_valid,
   dataout      => dataout,

   asmi_dataout  => asmi_dataout,
   asmi_dataoe   => asmi_dataoe,
   asmi_dclk     => asmi_dclk,
   asmi_scein    => asmi_scein,
   asmi_sdoin    => asmi_sdoin 
	);

   -- Combinatorial logic
   op         	<= wb_stb_i and wb_cyc_i;
   wr_command  <= op and wb_we_i;  -- Wishbone write access Signal

   wb_dat_o   	<= hb & lb;
   wb_ack_o   	<= op and not(busy);
   
   --------------------------------------------------------------------
   -- Register addresses and defaults
   --------------------------------------------------------------------
   process (wb_rst_i, wb_clk_i)
   begin
      if (wb_clk_i'event and wb_clk_i = '1') then   -- Synchrounous
         if (wb_rst_i = '1') then
            address <= (others => '0');          -- Interupt Enable default
            state <= (others => '0');
            read <= '0';
            rden <= '0';
            reset <= '1';
         else
            reset <= '0';
            case state is
               when "00" =>
                  if (wr_command = '1') then   -- If a WB write was requested (WR ADDR) 
                     case wb_adr_i is      -- Determine which register was writen to
                        when '0' =>
                           address(16 downto  0) <= wb_dat_i & '0';              -- Lower bits of address lines
                        when '1' =>
                           address(23 downto 17) <= "01" & wb_dat_i(4 downto 0); -- Upper bits of address lines
                           read <= '1';
                           rden <= '1';
                           state <= state + 1;
                        when others => null;
                     end case;
                  end if;
               
               when "01" =>
                  read <= '0';
                  if data_valid = '1' then
                     rden <= '0';
                     lb <= dataout;
                     state <= state + 1;
                  end if;
                  
               when "10" =>
                  if data_valid = '1' then
                     hb <= dataout;
                     state <= (others => '0');
                  end if;
                  
               when others => null;
            end case;
         end if;   
      end if;
   end process;
   
end rtl;