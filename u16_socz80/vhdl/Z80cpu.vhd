--+-----------------------------------+-------------------------------------+--
--|                      ___   ___    | (c) 2013-2014 William R Sowerbutts  |--
--|   ___  ___   ___ ___( _ ) / _ \   | will@sowerbutts.com                 |--
--|  / __|/ _ \ / __|_  / _ \| | | |  |                                     |--
--|  \__ \ (_) | (__ / / (_) | |_| |  | A Z80 FPGA computer, just for fun   |--
--|  |___/\___/ \___/___\___/ \___/   |                                     |--
--|                                   |              http://sowerbutts.com/ |--
--+-----------------------------------+-------------------------------------+--
--| Wrap the T80 CPU core and produce more easily comprehended signals      |--
--+-------------------------------------------------------------------------+--

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.T80_Pack.all;

entity Z80cpu is
    port (
        -- reset
        reset               : in  std_logic;

        -- clocking
        clk                 : in  std_logic;
        clk_enable          : in  std_logic;

        -- indicates when we're in the M1 cycle (start of an instruction)
        m1_cycle            : out std_logic;
        
        -- memory and I/O interface
        req_mem             : out std_logic;    -- memory request?
        req_io              : out std_logic;    -- i/o request?
        req_read            : out std_logic;    -- read?
        req_write           : out std_logic;    -- write?
        mem_wait            : in  std_logic;    -- memory or i/o can force the CPU to wait
        address             : out std_logic_vector(15 downto 0);
        data_in             : in  std_logic_vector(7 downto 0);
        data_out            : out std_logic_vector(7 downto 0);

        -- interrupts
        interrupt           : in  std_logic;
        nmi                 : in  std_logic
         );
end Z80cpu;

architecture behavioural of Z80cpu is
    signal RESET_n : std_logic;
    signal WAIT_n : std_logic;
    signal INT_n : std_logic;
    signal NMI_n : std_logic;
    signal M1_n : std_logic;
    signal MREQ_n : std_logic;
    signal IORQ_n : std_logic;
    signal RFSH_n : std_logic;
    signal RD_n : std_logic;
    signal WR_n : std_logic;
begin

    RESET_n  <= not reset;
    WAIT_n   <= not mem_wait;
    INT_n    <= not interrupt;
    NMI_n    <= not nmi;
    m1_cycle <= not M1_n;

    req_mem   <= (not MREQ_n) and (RFSH_n);
    req_io    <= (not IORQ_n) and (M1_n); -- IORQ is active during M1 when handling interrupts (it's well documented, but I found out the hard way...)
    req_read  <= (not RD_n) and (RFSH_n);
    req_write <= (not WR_n);

    cpu : entity work.T80se
    generic map (
        Mode => 1,    -- 0 => Z80, 1 => Fast Z80, 2 => 8080, 3 => GB
        T2Write => 1, -- 0 => WR_n active in T3, /=0 => WR_n active in T2
        IOWait => 0   -- 0 => single cycle I/O, 1 => standard I/O cycle
    )
    port map (
        RESET_n => RESET_n,
        CLK_n => clk,
        CLKEN => clk_enable,
        WAIT_n => WAIT_n,
        INT_n => INT_n,
        NMI_n => NMI_n,
        BUSRQ_n => '1',
        BUSAK_n => open,
        M1_n => M1_n,
        MREQ_n => MREQ_n,
        IORQ_n => IORQ_n,
        RD_n => RD_n,
        WR_n => WR_n,
        RFSH_n => RFSH_n,
        HALT_n => open,
        A => address,
        DI => data_in,
        DO => data_out
    );

end;
