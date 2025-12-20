// pkg/pkg.sv
package pkg;

  // Import UVM
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  // Include defines and macros
  `include "defines.svh"
  `include "macros.svh"

  // Transaction & sequences
  `include "../sequences/seq_item.sv"
  `include "../sequences/seq_lib.sv"
  `include "../sequences/seq_read.sv"
  `include "../sequences/seq_write.sv"
  `include "../sequences/seq_burst.sv"
  `include "../sequences/seq_error.sv"

  // Environment components
  `include "../uvm_env/env.sv"
  `include "../uvm_env/agent.sv"
  `include "../uvm_env/driver.sv"
  `include "../uvm_env/sequencer.sv"
  `include "../uvm_env/monitor.sv"
  `include "../uvm_env/scoreboard.sv"
  `include "../uvm_env/coverage.sv"

  // Tests
  `include "../tests/test_base.sv"
  `include "../tests/test_reset.sv"
  `include "../tests/test_sanity.sv"
  `include "../tests/test_read.sv"
  `include "../tests/test_write.sv"
  `include "../tests/test_read_after_write.sv"
  `include "../tests/test_burst.sv"
  `include "../tests/test_error.sv"
  `include "../tests/test_random.sv"

endpackage