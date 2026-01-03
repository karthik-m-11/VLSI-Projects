read_liberty dff_liberty.lib
read_verilog dff_top.v
link_design dff_top
read_sdc dff_constraints.sdc

report_clock_properties

report_checks -path_delay max -digits 1
report_checks -path_delay min -digits 1