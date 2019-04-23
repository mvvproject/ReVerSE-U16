set_time_format -unit ns -decimal_places 3

derive_clock_uncertainty

create_clock -name {CLK_50MHZ} -period 20 [get_ports {CLK_50MHZ}]

derive_pll_clocks
