--+-----------------------------------+-------------------------------------+--
--|                      ___   ___    | (c) 2013-2014 William R Sowerbutts  |--
--|   ___  ___   ___ ___( _ ) / _ \   | will@sowerbutts.com                 |--
--|  / __|/ _ \ / __|_  / _ \| | | |  |                                     |--
--|  \__ \ (_) | (__ / / (_) | |_| |  | A Z80 FPGA computer, just for fun   |--
--|  |___/\___/ \___/___\___/ \___/   |                                     |--
--|                                   |              http://sowerbutts.com/ |--
--+-----------------------------------+-------------------------------------+--
--| 4K paged Memory Management Unit: Translates 16-bit virtual addresses    |--
--| from the CPU into 26-bit physical addresses to allow more memory to be  |--
--| addressed. Also has a hack to allow unmapped physical memory to be      |--
--| accessed through an IO port which synthesises memory operations.        |--
--+-------------------------------------------------------------------------+--
--
-- The MMU takes a 16-bit virtual address from the CPU and divides it into a
-- 4-bit frame number and a 12-bit offset. The frame number is used as an index
-- into an array of sixteen registers which contain the hardware page numbers
-- (the translation table). The physical address is then formed from the
-- hardware page number concatenated with the 12-bit offset. My hardware page
-- numbers are 14-bits long because I wanted a 64MB physical address space but
-- you could use any length you wished.
-- 
-- So if the virtual address 0xABCD is accessed, we'd divide that into frame
-- number 0xA (decimal 10), offset 0xBCD. If the 10th MMU translation register
-- contains 0x1234 then the translated physical address would be 0x1234BCD.
-- 
-- My MMU is programmed using 8 I/O ports in the range 0xF8 through 0xFF. The
-- chip select line is asserted for any access in that range and the MMU 
-- decodes the low three bits to determine which register is being accessed.
-- 
-- The port at 0xF8 is effectively a mux which selects the function of ports
-- 0xFB through 0xFF.
-- 
-- Writing 0x00 through 0x0F to the function register at 0xF8 allows you to
-- read/write one of the 16 MMU translation registers. With these selected;
--   - 0xFC contains the high byte of the physical address
--   - 0xFD contains the low byte of the physical address
--   - 0xFB contains permission bits (read/write/execute, currently ignored)
-- 
-- So updating a mapping generally requires just three I/O writes: One to 0xF8
-- to select which frame to modify, and one each to 0xFC and 0xFD to write out
-- the new translation. The permission bits are programmable but currently
-- ignored (I had planned to add some level of memory protection to UZI one day)
-- 
-- The "17th page" is a bit of a hack bolted on. The lazy programmer in me finds
-- it much more convenient to sometimes access memory without remapping a frame;
-- in particular you don't have to select which frame to remap such as to avoid
-- remapping the memory pointed to by PC, SP or your source/target pointer.
-- 
-- Writing 0xFF to port 0xF8 selects the "17th page pointer". This is a 26-bit
-- register but again could be wider/narrower as required. With this selected
-- ports 0xFC, 0xFD, 0xFE, 0xFF are the register contents (with the high byte in
-- 0xFC, low byte in 0xFF).
-- 
-- When the CPU reads or writes the I/O port 0xFA the MMU translates the I/O
-- operation into a memory operation. The physical memory address accessed is
-- the address contained in the 17th page pointer register. After the memory
-- operation completes the 17th page pointer register is incremented so that
-- repeated accesses to 0xFA walk forward through memory.
--
--
-- MMU registers:
--
-- base = 0xF8 in standard socz80 system
--
-- base+0  mux frame select (write 00..0F to select frame, FF to select "17th page" pointer)
-- base+1  (unused)
-- base+2  17th page (read/write will address pointed memory and post-increment the pointer)
-- base+3  page permissions
-- base+4  page address (high byte) / ptr address (high byte)
-- base+5  page address (low byte)  / ptr address
-- base+6                             ptr address
-- base+7                             ptr address (low byte)
--
-- Basic operation of the MMU (older documentation, concise but still correct)
-- For memory requests:
--    The top 4 bits of CPU logical address are replaced with 14 bits taken 
--    from the MMU translation table entry indexed by those top four bits.
-- For IO requests:
--    Reads or writes to I/O port at (base+2) are converted into memory
--    requests to the address pointed to by "the 17th page", a pointer which
--    can be accessed by writing 0xFF to the frame select register (base+0)
--    and then programming a 26-bit address into I/O ports FC FD FE FF. Each
--    I/O request to port F/A results in the pointer being post-incremented
--    by 1, which means that INIR our OUTIR instructions can read/write blocks
--    of memory outside of the CPU logical address space through this port.
--
--    Note that the MMU has to insert a forced CPU wait state to give the
--    addressed memory device time to read the new address off the bus.
--

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity MMU is
    port(
        clk             : in  std_logic;
        reset           : in  std_logic;
        address_in      : in  std_logic_vector(15 downto 0);
        address_out     : out std_logic_vector(25 downto 0);
        cpu_data_in     : in  std_logic_vector(7 downto 0);
        cpu_data_out    : out std_logic_vector(7 downto 0);
        cpu_wait        : out std_logic;
        req_mem_in      : in  std_logic;
        req_mem_out     : out std_logic;
        req_io_in       : in  std_logic;
        req_io_out      : out std_logic;
        io_cs           : in  std_logic;
        req_read        : in  std_logic;
        req_write       : in  std_logic;
        access_violated : out std_logic
    );
end MMU;

architecture behaviour of MMU is
    -- each MMU entry looks like this
    type mmu_entry_type is
        record
            frame:     std_logic_vector(13 downto 0);
            can_read:  std_logic;
            can_write: std_logic;
        end record;

    -- the whole MMU state looks like this
    type mmu_entry_array is array(natural range <>) of mmu_entry_type;

    -- and here's our instance
    signal mmu_entry : mmu_entry_array(0 to 15);

    -- 17th page pointer (frame FF)
    signal mmu_frame_ff_pointer : std_logic_vector(25 downto 0);

    -- IO interface
    signal cpu_entry_select : std_logic_vector(7 downto 0);

    -- break up the incoming virtual address
    alias frame_number : std_logic_vector( 3 downto 0) is address_in(15 downto 12);
    alias page_offset : std_logic_vector(11 downto 0) is address_in(11 downto  0);

    signal map_io_to_ff_ptr : std_logic;
    signal was_map_io_to_ff_ptr : std_logic := '0';
begin

    map_io_to_mem_proc: process(address_in, req_mem_in, req_io_in)
    begin
        if req_mem_in = '0' and req_io_in = '1' and address_in(7 downto 0) = "11111010" then
            map_io_to_ff_ptr <= '1';
        else
            map_io_to_ff_ptr <= '0';
        end if;
    end process;

    with map_io_to_ff_ptr select
        address_out <= 
                      mmu_entry(to_integer(unsigned(frame_number))).frame & page_offset when '0',
                      mmu_frame_ff_pointer when '1';

    with map_io_to_ff_ptr select
        req_mem_out <= 
                      req_mem_in when '0',
                      '1' when '1';

    with map_io_to_ff_ptr select
        req_io_out <= 
                      req_io_in when '0',
                      '0' when '1';

    with map_io_to_ff_ptr select
        access_violated <= 
                          req_mem_in and ((req_read  and not mmu_entry(to_integer(unsigned(frame_number))).can_read) or
                          (req_write and not mmu_entry(to_integer(unsigned(frame_number))).can_write)) when '0',
                          '0' when '1';

    -- force CPU to wait one cycle when we map IO to memory access; this
    -- is in order to give our synchronous memories a cycle to read the
    -- address, look up the data in synchronous memory, and provide a result.
    cpu_wait <= map_io_to_ff_ptr and (not was_map_io_to_ff_ptr);

    data_out: process(address_in, cpu_entry_select, mmu_entry, mmu_frame_ff_pointer)
    begin
        if cpu_entry_select = "11111111" then
            -- pointer (FF)
            case address_in(2 downto 0) is
                when "000" => 
                    cpu_data_out <= cpu_entry_select;
                when "011" => 
                    cpu_data_out <= "00000011";
                when "100" => 
                    cpu_data_out <= "000000" & mmu_frame_ff_pointer(25 downto 24);
                when "101" => 
                    cpu_data_out <= mmu_frame_ff_pointer(23 downto 16);
                when "110" => 
                    cpu_data_out <= mmu_frame_ff_pointer(15 downto 8);
                when "111" => 
                    cpu_data_out <= mmu_frame_ff_pointer(7 downto 0);
                when others =>
                    cpu_data_out <= "00000000";
            end case;
        else
            -- 16 frames (00 .. 0F)
            case address_in(2 downto 0) is
                when "000" => 
                    cpu_data_out <= cpu_entry_select;
                when "011" => 
                    cpu_data_out <= "000000" & mmu_entry(to_integer(unsigned(cpu_entry_select(3 downto 0)))).can_write & mmu_entry(to_integer(unsigned(cpu_entry_select(3 downto 0)))).can_read;
                when "100" => 
                    cpu_data_out <= "00" & mmu_entry(to_integer(unsigned(cpu_entry_select(3 downto 0)))).frame(13 downto 8);
                when "101" => 
                    cpu_data_out <= mmu_entry(to_integer(unsigned(cpu_entry_select(3 downto 0)))).frame(7 downto 0);
                when others =>
                    cpu_data_out <= "00000000";
            end case;
        end if;
    end process;

    mmu_registers: process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                mmu_entry( 0).frame <= "10000000000000"; -- first page of SRAM (monitor ROM)
                mmu_entry( 1).frame <= "00000000000001"; -- DRAM page 1
                mmu_entry( 2).frame <= "00000000000010"; -- DRAM page 2
                mmu_entry( 3).frame <= "00000000000011"; -- DRAM page 3
                mmu_entry( 4).frame <= "00000000000100"; -- DRAM page 4
                mmu_entry( 5).frame <= "00000000000101"; -- DRAM page 5
                mmu_entry( 6).frame <= "00000000000110"; -- DRAM page 6
                mmu_entry( 7).frame <= "00000000000111"; -- DRAM page 7
                mmu_entry( 8).frame <= "00000000001000"; -- DRAM page 8
                mmu_entry( 9).frame <= "00000000001001"; -- DRAM page 9
                mmu_entry(10).frame <= "00000000001010"; -- DRAM page 10
                mmu_entry(11).frame <= "00000000001011"; -- DRAM page 11
                mmu_entry(12).frame <= "00000000001100"; -- DRAM page 12
                mmu_entry(13).frame <= "00000000001101"; -- DRAM page 13
                mmu_entry(14).frame <= "00000000001110"; -- DRAM page 14
                mmu_entry(15).frame <= "10000000000001"; -- second page of SRAM
                mmu_entry( 0).can_read  <= '1';
                mmu_entry( 1).can_read  <= '1';
                mmu_entry( 2).can_read  <= '1';
                mmu_entry( 3).can_read  <= '1';
                mmu_entry( 4).can_read  <= '1';
                mmu_entry( 5).can_read  <= '1';
                mmu_entry( 6).can_read  <= '1';
                mmu_entry( 7).can_read  <= '1';
                mmu_entry( 8).can_read  <= '1';
                mmu_entry( 9).can_read  <= '1';
                mmu_entry(10).can_read  <= '1';
                mmu_entry(11).can_read  <= '1';
                mmu_entry(12).can_read  <= '1';
                mmu_entry(13).can_read  <= '1';
                mmu_entry(14).can_read  <= '1';
                mmu_entry(15).can_read  <= '1';
                mmu_entry( 0).can_write <= '0';
                mmu_entry( 1).can_write <= '1';
                mmu_entry( 2).can_write <= '1';
                mmu_entry( 3).can_write <= '1';
                mmu_entry( 4).can_write <= '1';
                mmu_entry( 5).can_write <= '1';
                mmu_entry( 6).can_write <= '1';
                mmu_entry( 7).can_write <= '1';
                mmu_entry( 8).can_write <= '1';
                mmu_entry( 9).can_write <= '1';
                mmu_entry(10).can_write <= '1';
                mmu_entry(11).can_write <= '1';
                mmu_entry(12).can_write <= '1';
                mmu_entry(13).can_write <= '1';
                mmu_entry(14).can_write <= '1';
                mmu_entry(15).can_write <= '1';
                mmu_frame_ff_pointer <= "10000000000000000000000000"; -- map first byte of ROM to pointer on reset
                was_map_io_to_ff_ptr <= '0';
            else
                was_map_io_to_ff_ptr <= map_io_to_ff_ptr;

                if io_cs = '1' and req_write = '1' then
                    case address_in(2 downto 0) is
                        when "000" => 
                            cpu_entry_select <= cpu_data_in;
                        when "011" => 
                            if cpu_entry_select(7 downto 4) = "0000" then
                                mmu_entry(to_integer(unsigned(cpu_entry_select(3 downto 0)))).can_read  <= cpu_data_in(0);
                                mmu_entry(to_integer(unsigned(cpu_entry_select(3 downto 0)))).can_write <= cpu_data_in(1);
                            end if;
                        when "100" => 
                            if cpu_entry_select(7 downto 4) = "0000" then
                                mmu_entry(to_integer(unsigned(cpu_entry_select(3 downto 0)))).frame(13 downto 0) <= 
                                    cpu_data_in(5 downto 0) & mmu_entry(to_integer(unsigned(cpu_entry_select(3 downto 0)))).frame(7 downto 0);
                            elsif cpu_entry_select = "11111111" then
                                mmu_frame_ff_pointer <=
                                    cpu_data_in(1 downto 0) & mmu_frame_ff_pointer(23 downto 0);
                            end if;
                        when "101" => 
                            if cpu_entry_select(7 downto 4) = "0000" then
                                mmu_entry(to_integer(unsigned(cpu_entry_select(3 downto 0)))).frame(13 downto 0) <= 
                                    mmu_entry(to_integer(unsigned(cpu_entry_select(3 downto 0)))).frame(13 downto 8) & cpu_data_in(7 downto 0);
                            elsif cpu_entry_select = "11111111" then
                                mmu_frame_ff_pointer <=
                                    mmu_frame_ff_pointer(25 downto 24) & cpu_data_in(7 downto 0) & mmu_frame_ff_pointer(15 downto 0);
                            end if;
                        when "110" => 
                            if cpu_entry_select = "11111111" then
                                mmu_frame_ff_pointer <=
                                    mmu_frame_ff_pointer(25 downto 16) & cpu_data_in(7 downto 0) & mmu_frame_ff_pointer(7 downto 0);
                            end if;
                        when "111" =>
                            if cpu_entry_select = "11111111" then
                                mmu_frame_ff_pointer <=
                                    mmu_frame_ff_pointer(25 downto 8) & cpu_data_in(7 downto 0);
                            end if;
                        when others =>
                            -- nothing
                    end case;
                elsif map_io_to_ff_ptr = '0' and was_map_io_to_ff_ptr = '1' then
                    -- post-increment our pointer (this is what makes "the 17th page" efficient!)
                    mmu_frame_ff_pointer <= std_logic_vector(unsigned(mmu_frame_ff_pointer) + 1);
                end if;
            end if;
        end if;
    end process;
end;
