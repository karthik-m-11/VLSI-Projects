// src/tb_top.sv
`timescale 1ns/1ps

`include "uvm_macros.svh"
import uvm_pkg::*;

module tb_top;

  // Clock and reset
  logic ACLK;
  logic ARESETn;

  // Interface
  axi_if axi (ACLK, ARESETn);

  // DUT
  axi_lite_slave #(.MEM_DEPTH(256)) dut (
    .ACLK   (ACLK),
    .ARESETn(ARESETn),
    .AWADDR (axi.AWADDR),
    .AWVALID(axi.AWVALID),
    .AWREADY(axi.AWREADY),
    .WDATA  (axi.WDATA),
    .WSTRB  (axi.WSTRB),
    .WVALID (axi.WVALID),
    .WREADY (axi.WREADY),
    .BRESP  (axi.BRESP),
    .BVALID (axi.BVALID),
    .BREADY (axi.BREADY),
    .ARADDR (axi.ARADDR),
    .ARVALID(axi.ARVALID),
    .ARREADY(axi.ARREADY),
    .RDATA  (axi.RDATA),
    .RRESP  (axi.RRESP),
    .RVALID (axi.RVALID),
    .RREADY (axi.RREADY)
  );

  // Clock generation: 100 MHz
  initial begin
    ACLK = 1'b0;
    forever #5 ACLK = ~ACLK;
  end

  // Reset generation
  initial begin
    ARESETn = 1'b0;
    #100;
    ARESETn = 1'b1;
  end

  // UVM configuration: provide virtual interface
  initial begin
    uvm_config_db#(virtual axi_if)::set(null, "env.m_agent.*", "vif", axi);
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