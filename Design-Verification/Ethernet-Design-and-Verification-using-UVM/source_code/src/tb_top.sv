// src/tb_top.sv
`timescale 1ns/1ps

`include "uvm_macros.svh"
import uvm_pkg::*;

module tb_top;

  logic ETH_CLK;
  logic ETH_RSTn;

  eth_if eth (ETH_CLK, ETH_RSTn);

  // DUT
  eth_mac #(.FIFO_BYTES(2048), .MAX_FRAME(512)) dut (
    .ETH_CLK (ETH_CLK),
    .ETH_RSTn(ETH_RSTn),
    .tx_valid(eth.tx_valid),
    .tx_ready(eth.tx_ready),
    .tx_data (eth.tx_data),
    .tx_last (eth.tx_last),
    .rx_valid(eth.rx_valid),
    .rx_ready(eth.rx_ready),
    .rx_data (eth.rx_data),
    .rx_last (eth.rx_last)
  );

  // Clock
  initial begin
    ETH_CLK = 1'b0;
    forever #5 ETH_CLK = ~ETH_CLK;
  end

  // Reset
  initial begin
    ETH_RSTn = 1'b0;
    #100;
    ETH_RSTn = 1'b1;
  end

  // UVM config
  initial begin
    uvm_config_db#(virtual eth_if)::set(null, "env.m_agent.*", "vif", eth);
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