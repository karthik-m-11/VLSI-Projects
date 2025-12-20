// src/tb_top.sv
`timescale 1ns/1ps

`include "uvm_macros.svh"
import uvm_pkg::*;

module tb_top;

  // Parameters
  localparam ADDR_WIDTH = 16;
  localparam DATA_WIDTH = 32;
  localparam MEM_DEPTH  = 256;

  // Clock and reset
  logic PCLK;
  logic PRESETn;

  // Interface
  apb_if #(.ADDR_WIDTH(ADDR_WIDTH), .DATA_WIDTH(DATA_WIDTH)) apb (PCLK, PRESETn);

  // DUT instantiation
  apb_slave #(
    .ADDR_WIDTH(ADDR_WIDTH),
    .DATA_WIDTH(DATA_WIDTH),
    .MEM_DEPTH (MEM_DEPTH)
  ) dut (
    .PCLK    (PCLK),
    .PRESETn (PRESETn),
    .PSEL    (apb.PSEL),
    .PENABLE (apb.PENABLE),
    .PADDR   (apb.PADDR),
    .PWRITE  (apb.PWRITE),
    .PWDATA  (apb.PWDATA),
    .PRDATA  (apb.PRDATA),
    .PREADY  (apb.PREADY),
    .PSLVERR (apb.PSLVERR)
  );

  // Clock generation: 100 MHz (10 ns period)
  initial begin
    PCLK = 1'b0;
    forever #5 PCLK = ~PCLK;
  end

  // Reset generation
  initial begin
    PRESETn = 1'b0;
    #100;
    PRESETn = 1'b1;
  end

  // UVM configuration: provide virtual interface to agent
  initial begin
    // Common: set the full interface if agent expects virtual apb_if
    uvm_config_db#(virtual apb_if)::set(null, "env.agent.*", "vif", apb);

    // If your driver/monitor use explicit modports, you can additionally set:
    // uvm_config_db#(virtual apb_if.drv)::set(null, "env.agent.driver", "vif", apb);
    // uvm_config_db#(virtual apb_if.mon)::set(null, "env.agent.monitor", "vif", apb);

    // Start UVM (test name via +UVM_TESTNAME=...)
    run_test();
  end

  // Optional: waves
  initial begin
    `ifdef DUMP_WAVES
      $dumpfile("waves/tb_top.vcd");
      $dumpvars(0, tb_top);
    `endif
  end

endmodule