// src/dut.sv
// Simple Ethernet MAC loopback:
// - Accepts TX bytes and buffers them into a small FIFO until tx_last.
// - When a complete frame is buffered and rx_ready, streams it out on RX.
module eth_mac #(
  parameter FIFO_BYTES   = 2048,   // total buffering
  parameter MAX_FRAME    = 512     // max frame length (bytes) for this simple model
)(
  input  logic       ETH_CLK,
  input  logic       ETH_RSTn,

  // TX stream in
  input  logic       tx_valid,
  output logic       tx_ready,
  input  logic [7:0] tx_data,
  input  logic       tx_last,

  // RX stream out
  output logic       rx_valid,
  input  logic       rx_ready,
  output logic [7:0] rx_data,
  output logic       rx_last
);

  // Simple byte buffer
  logic [7:0] fifo [0:FIFO_BYTES-1];
  int         wr_ptr, rd_ptr;
  int         frame_len;
  logic       frame_ready;

  // TX path: buffer incoming bytes
  always_ff @(posedge ETH_CLK or negedge ETH_RSTn) begin
    if (!ETH_RSTn) begin
      wr_ptr      <= 0;
      frame_len   <= 0;
      frame_ready <= 1'b0;
      tx_ready    <= 1'b1;
    end else begin
      tx_ready <= !frame_ready && (wr_ptr < FIFO_BYTES);

      if (tx_valid && tx_ready) begin
        fifo[wr_ptr] <= tx_data;
        wr_ptr       <= wr_ptr + 1;
        frame_len    <= frame_len + 1;

        if (tx_last) begin
          // Basic error: frame too long -> drop and flag ready for RX as empty
          if (frame_len == 0 || frame_len > MAX_FRAME) begin
            // Drop frame
            wr_ptr      <= 0;
            frame_len   <= 0;
            frame_ready <= 1'b0;
          end else begin
            frame_ready <= 1'b1;
            rd_ptr      <= 0;
          end
        end
      end
    end
  end

  // RX path: stream out buffered frame
  always_ff @(posedge ETH_CLK or negedge ETH_RSTn) begin
    if (!ETH_RSTn) begin
      rx_valid <= 1'b0;
      rx_last  <= 1'b0;
      rx_data  <= '0;
    end else begin
      rx_valid <= 1'b0;
      rx_last  <= 1'b0;

      if (frame_ready && rx_ready) begin
        rx_valid <= 1'b1;
        rx_data  <= fifo[rd_ptr];
        rx_last  <= (rd_ptr == frame_len-1);
        rd_ptr   <= rd_ptr + 1;

        if (rd_ptr == frame_len-1) begin
          // Frame fully sent; reset buffer
          frame_ready <= 1'b0;
          wr_ptr      <= 0;
          frame_len   <= 0;
        end
      end
    end
  end

endmodule