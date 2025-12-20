// src/tb_top.sv
`timescale 1ns/1ps

`include "uvm_macros.svh"
import uvm_pkg::*;

module tb_top;

  logic PCIE_CLK;
  logic PCIE_RSTn;

  pcie_if pcie (PCIE_CLK, PCIE_RSTn);

  // DUT
  pcie_endpoint #(.MEM_DEPTH(256)) dut (
    .PCIE_CLK (PCIE_CLK),
    .PCIE_RSTn(PCIE_RSTn),
    .req_valid(pcie.req_valid),
    .req_ready(pcie.req_ready),
    .req_tlp  (pcie.req_tlp),
    .cpl_valid(pcie.cpl_valid),
    .cpl_ready(pcie.cpl_ready),
    .cpl_tlp  (pcie.cpl_tlp)
  );

  // Clock
  initial begin
    PCIE_CLK = 1'b0;
    forever #5 PCIE_CLK = ~PCIE_CLK;
  end

  // Reset
  initial begin
    PCIE_RSTn = 1'b0;
    #100;
    PCIE_RSTn = 1'b1;
  end

  // UVM config
  initial begin
    uvm_config_db#(virtual pcie_if)::set(null, "env.m_agent.*", "vif", pcie);
    run_test(); // +UVM_TESTNAME=...
  end

  // Optional waves
  initial begin
    `ifdef DUMP_WAVES
      $dumpfile("waves/tb_top.vcd");
      $dumpvars(0, tb_top);
    `endif
  end

endmodule