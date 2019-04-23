-------------------------------------------------------------------[24.06.2018]
-- Empty Project (build 20180624)
-- FPGA SoftCore for ReVerSE-U16 Rev.C
-------------------------------------------------------------------------------
-- Engineer: MVV <mvvproject@gmail.com>
-- https://github.com/mvvproject/ReVerSE-U16/tree/master/u16_empty
--
-- All rights reserved
--
-- Redistribution and use in source and synthezised forms, with or without
-- modification, are permitted provided that the following conditions are met:
--
-- * Redistributions of source code must retain the above copyright notice,
--   this list of conditions and the following disclaimer.
--
-- * Redistributions in synthesized form must reproduce the above copyright
--   notice, this list of conditions and the following disclaimer in the
--   documentation and/or other materials provided with the distribution.
--
-- * Neither the name of the author nor the names of other contributors may
--   be used to endorse or promote products derived from this software without
--   specific prior written agreement from the author.
--
-- * License is granted for non-commercial use only.  A fee may not be charged
--   for redistributions as source code or in synthesized/hardware form without 
--   specific prior written agreement from the author.
--
-- THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
-- AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
-- THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
-- PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE
-- LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
-- CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
-- SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
-- INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
-- CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
-- ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
-- POSSIBILITY OF SUCH DAMAGE.

library IEEE; 
use IEEE.std_logic_1164.all; 
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all; 

entity top is
port (
	-- Clock (50MHz)
	CLK_50MHZ	: in std_logic;
	-- SDRAM (32MB 16x16bit)
	DRAM_DQ		: inout std_logic_vector(15 downto 0);
	DRAM_A		: out std_logic_vector(12 downto 0);
	DRAM_BA		: out std_logic_vector(1 downto 0);
	DRAM_CLK	: out std_logic;
	DRAM_DQML	: out std_logic;
	DRAM_DQMH	: out std_logic;
	DRAM_NWE	: out std_logic;
	DRAM_NCAS	: out std_logic;
	DRAM_NRAS	: out std_logic;
	-- I2C (HDMI/RTC)
	I2C_SCL		: inout std_logic;
	I2C_SDA		: inout std_logic;
	-- RTC (DS1338Z-33+)
	SQW		: in std_logic;
	-- SPI FLASH (M25P16/W25Q64)
	DATA0		: in std_logic;
	NCSO		: out std_logic;
	DCLK		: out std_logic;
	ASDO		: out std_logic;
	-- HDMI
	HDMI_CEC	: inout std_logic;
	HDMI_NDET	: in std_logic;
	HDMI		: out std_logic_vector(7 downto 0);
	-- Memory Card (SD/MMC)
	SD_NDET		: in std_logic;
	SD_SO		: in std_logic;
	SD_SI		: out std_logic;
	SD_CLK		: out std_logic;
	SD_NCS		: out std_logic;
	-- Ethernet (ENC424J600)
	ETH_SO		: in std_logic;
	ETH_NINT	: in std_logic;
	ETH_NCS		: out std_logic;
	-- USB Host (VNC2-32)
	USB_NRESET	: inout std_logic;
	USB_IO1		: in std_logic;
	USB_IO3		: in std_logic;
	USB_TX		: in std_logic;
	USB_RX		: out std_logic;
	USB_CLK		: out std_logic;
	USB_SI		: out std_logic;
	USB_SO		: in std_logic;
	USB_NCS		: out std_logic;
	-- uBUS+
	AP		: inout std_logic;
	AN		: inout std_logic;
	BP		: in std_logic;
	BN		: in std_logic;
	CP		: in std_logic;
	CN		: in std_logic;
	DP		: inout std_logic;
	DN		: inout std_logic);
end top;


architecture rtl of top is



begin



end rtl;