create_clock -name VCLK -period 2.0

set_input_delay 0.20 -clock VCLK [get_ports {a b sel}]
set_input_transition 0.05 [get_ports {a b sel}]

set_output_delay 0.80 -clock VCLK [get_ports y]
set_load 0.02 [get_ports y]