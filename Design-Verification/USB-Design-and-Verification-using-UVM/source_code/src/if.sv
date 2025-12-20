// src/usb_if.sv
interface usb_if (input logic USB_CLK, input logic USB_RSTn);

  // Transmit stream to DUT (host -> device)
  logic        tx_valid;
  logic        tx_ready;
  logic [7:0]  tx_byte;   // PID, token fields, data bytes serialized
  logic        tx_last;   // last byte of a packet

  // Receive stream from DUT (device -> host)
  logic        rx_valid;
  logic        rx_ready;
  logic [7:0]  rx_byte;   // PID or data bytes
  logic        rx_last;

  // Modports
  modport drv (
    output tx_valid, tx_byte, tx_last, rx_ready,
    input  tx_ready, rx_valid, rx_byte, rx_last
  );

  modport mon (
    input tx_valid, tx_byte, tx_last, rx_valid, rx_byte, rx_last
  );

  modport dut_mp (
    input  USB_CLK, USB_RSTn,
    input  tx_valid, tx_byte, tx_last, rx_ready,
    output tx_ready, rx_valid, rx_byte, rx_last
  );

endinterface