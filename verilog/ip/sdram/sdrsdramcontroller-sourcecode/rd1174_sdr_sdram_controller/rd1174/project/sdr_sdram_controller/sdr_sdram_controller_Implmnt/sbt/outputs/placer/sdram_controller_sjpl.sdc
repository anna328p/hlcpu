create_clock -period 1000.00 -name {sdram_controller|i_clk} -waveform [list 0.00 500.00] [get_ports i_clk]
create_clock -period 10.00 -name {i_cpu_clk} -waveform [list 0.00 5.00]
set_false_path -from [get_clocks i_cpu_clk] -to [get_clocks sdram_controller|i_clk]
set_false_path -from [get_clocks sdram_controller|i_clk] -to [get_clocks i_cpu_clk]
