## Generated SDC file "u16.sdc"

## Copyright (C) 1991-2011 Altera Corporation
## Your use of Altera Corporation's design tools, logic functions 
## and other software and tools, and its AMPP partner logic 
## functions, and any output files from any of the foregoing 
## (including device programming or simulation files), and any 
## associated documentation or information are expressly subject 
## to the terms and conditions of the Altera Program License 
## Subscription Agreement, Altera MegaCore Function License 
## Agreement, or other applicable license agreement, including, 
## without limitation, that your use is for the sole purpose of 
## programming logic devices manufactured by Altera and sold by 
## Altera or its authorized distributors.  Please refer to the 
## applicable agreement for further details.


## VENDOR  "Altera"
## PROGRAM "Quartus II"
## VERSION "Version 11.0 Build 208 07/03/2011 Service Pack 1 SJ Full Version"

## DATE    "Sat Oct 18 20:56:19 2014"

##
## DEVICE  "EP4CE22E22C7"
##

set_time_format -unit ns -decimal_places 3

create_clock -name {CLK} -period 20.000 [get_ports {CLK}]

derive_clock_uncertainty

#derive_pll_clocks -create_base_clocks
