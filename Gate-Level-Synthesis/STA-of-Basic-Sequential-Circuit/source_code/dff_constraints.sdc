create_clock -name CLK -period 1.0 [get_ports CLK]

set_input_delay 0.20 -clock CLK [get_ports D]
set_input_transition 0.05 [get_ports D]

set_output_delay 0.80 -clock CLK [get_ports Q]
set_load 0.02 [get_ports Q]