set_time_format -unit ns -decimal_places 3

derive_clock_uncertainty

create_clock -name {clk_50_} -period 20 [get_ports {clk_50_}]

derive_pll_clocks
