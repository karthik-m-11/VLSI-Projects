// pkg/macros.svh
`ifndef MACROS_SVH
`define MACROS_SVH

// Simple logging macros
`define INFO(MSG)  `uvm_info(get_type_name(), MSG, `VERBOSITY)
`define ERROR(MSG) `uvm_error(get_type_name(), MSG)
`define FATAL(MSG) `uvm_fatal(get_type_name(), MSG)

// Quick check macro
`define CHECK_EQ(EXP, ACT) \
  if ((EXP) !== (ACT)) \
    `uvm_error("CHECK_EQ", $sformatf("Expected %0h, got %0h", EXP, ACT))

`endif