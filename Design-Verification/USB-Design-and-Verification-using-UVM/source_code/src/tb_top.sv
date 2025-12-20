// src/tb_top.sv
`timescale 1ns/1ps

`include "uvm_macros.svh"
import uvm_pkg::*;

module tb_top;

  logic USB_CLK;
  logic USB_RSTn;

  usb_if usb (USB_CLK, USB_RSTn);

  // DUT
  usb_device #(.MEM_DEPTH(256)) dut (
    .USB_CLK (USB_CLK),
    .USB_RSTn(USB_RSTn),
    .tx_valid(usb.tx_valid),
    .tx_ready(usb.tx_ready),
    .tx_byte (usb.tx_byte),
    .tx_last (usb.tx_last),
    .rx_valid(usb.rx_valid),
    .rx_ready(usb.rx_ready),
    .rx_byte (usb.rx_byte),
    .rx_last (usb.rx_last)
  );

  // Clock
  initial begin
    USB_CLK = 1'b0;
    forever #5 USB_CLK = ~USB_CLK;
  end

  // Reset
  initial begin
    USB_RSTn = 1'b0;
    #100;
    USB_RSTn = 1'b1;
  end

  // UVM config
  initial begin
    uvm_config_db#(virtual usb_if)::set(null, "env.m_agent.*", "vif", usb);
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