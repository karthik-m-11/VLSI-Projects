// src/eth_if.sv
interface eth_if (input logic ETH_CLK, input logic ETH_RSTn);

  // Transmit channel (driver -> DUT)
  logic        tx_valid;
  logic        tx_ready;
  logic [7:0]  tx_data;
  logic        tx_last;   // indicates last byte of frame

  // Receive channel (DUT -> monitor)
  logic        rx_valid;
  logic        rx_ready;
  logic [7:0]  rx_data;
  logic        rx_last;   // indicates last byte of frame

  // Modports
  modport drv (
    output tx_valid, tx_data, tx_last, rx_ready,
    input  tx_ready, rx_valid, rx_data, rx_last
  );

  modport mon (
    input rx_valid, rx_data, rx_last, tx_valid, tx_data, tx_last
  );

  modport dut_mp (
    input  ETH_CLK, ETH_RSTn,
    input  tx_valid, tx_data, tx_last, rx_ready,
    output tx_ready, rx_valid, rx_data, rx_last
  );

endinterface