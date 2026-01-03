read_liberty mux_liberty.lib
read_verilog mux_top.v
link_design mux_top
read_sdc mux_constraints.sdc

report_clock_properties

report_checks -path_delay max -from [get_ports {a b sel}] -to [get_ports y] -digits 1
report_checks -path_delay min -from [get_ports {a b sel}] -to [get_ports y] -digits 1