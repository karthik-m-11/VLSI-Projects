// src/tb_top.sv
`timescale 1ns/1ps

`include "uvm_macros.svh"
import uvm_pkg::*;

module tb_top;

  // Clock and reset
  logic HCLK;
  logic HRESETn;

  // Interface
  ahb_if ahb (HCLK, HRESETn);

  // DUT
  ahb_slave #(.MEM_DEPTH(256)) dut (
    .HCLK   (HCLK),
    .HRESETn(HRESETn),
    .HADDR  (ahb.HADDR),
    .HTRANS (ahb.HTRANS),
    .HWRITE (ahb.HWRITE),
    .HSIZE  (ahb.HSIZE),
    .HWDATA (ahb.HWDATA),
    .HRDATA (ahb.HRDATA),
    .HREADY (ahb.HREADY),
    .HRESP  (ahb.HRESP)
  );

  // Clock generation: 100 MHz
  initial begin
    HCLK = 1'b0;
    forever #5 HCLK = ~HCLK;
  end

  // Reset generation
  initial begin
    HRESETn = 1'b0;
    #100;
    HRESETn = 1'b1;
  end

  // UVM config: provide virtual interface to agent
  initial begin
    uvm_config_db#(virtual ahb_if)::set(null, "env.m_agent.*", "vif", ahb);
    // If your agent uses path "env.agent.*", adjust accordingly
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