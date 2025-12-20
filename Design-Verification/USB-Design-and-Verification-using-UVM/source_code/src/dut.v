// src/dut.sv
// Simplified USB device core:
// - Packet-level interface: tx_* is host->device; rx_* is device->host.
// - Recognizes basic PIDs: SETUP, IN, OUT, DATA0/DATA1, ACK.
// - EP0 buffer: writes on OUT, reads on IN, SETUP clears state.
// - No CRC, timing or full USB state machine; educational/stimulus-level DUT.
module usb_device #(
  parameter MEM_DEPTH = 256
)(
  input  logic       USB_CLK,
  input  logic       USB_RSTn,

  // Host->Device (TX stream into DUT)
  input  logic       tx_valid,
  output logic       tx_ready,
  input  logic [7:0] tx_byte,
  input  logic       tx_last,

  // Device->Host (RX stream from DUT)
  output logic       rx_valid,
  input  logic       rx_ready,
  output logic [7:0] rx_byte,
  output logic       rx_last
);

  // PID constants (subset)
  localparam byte PID_OUT   = 8'hE1;
  localparam byte PID_IN    = 8'h69;
  localparam byte PID_SETUP = 8'h2D;
  localparam byte PID_DATA0 = 8'hC3;
  localparam byte PID_DATA1 = 8'h4B;
  localparam byte PID_ACK   = 8'hD2;

  // Simple EP0 data buffer (device memory)
  logic [7:0] mem [0:MEM_DEPTH-1];
  int         wr_idx, rd_idx, frame_len;
  bit         ep0_armed;       // indicates device has data to send on IN
  bit         data_toggle;     // DATA0/DATA1 toggle

  // TX receive state (host -> device)
  typedef enum logic [1:0] {IDLE, TOKEN, DATA} rx_state_e;
  rx_state_e rx_state;

  // Ack generator (device responses)
  task automatic send_ack();
    if (rx_ready) begin
      rx_valid <= 1'b1;
      rx_byte  <= PID_ACK;
      rx_last  <= 1'b1;
      @(posedge USB_CLK);
      rx_valid <= 1'b0;
      rx_last  <= 1'b0;
    end
  endtask

  // Send data packet (DATA0/DATA1 + payload)
  task automatic send_data_packet();
    if (!ep0_armed) return;
    // PID
    if (rx_ready) begin
      rx_valid <= 1'b1;
      rx_byte  <= (data_toggle ? PID_DATA1 : PID_DATA0);
      rx_last  <= 1'b0;
      @(posedge USB_CLK);
      // Payload
      for (int i = 0; i < frame_len; i++) begin
        rx_byte <= mem[i];
        rx_last <= (i == frame_len-1);
        @(posedge USB_CLK);
      end
      rx_valid <= 1'b0;
      rx_last  <= 1'b0;
      data_toggle <= ~data_toggle;
      ep0_armed   <= 1'b0; // consume buffer
    end
  endtask

  // Ready/backpressure
  always_ff @(posedge USB_CLK or negedge USB_RSTn) begin
    if (!USB_RSTn) begin
      tx_ready   <= 1'b1;
      rx_valid   <= 1'b0;
      rx_byte    <= '0;
      rx_last    <= 1'b0;
      rx_state   <= IDLE;
      wr_idx     <= 0;
      rd_idx     <= 0;
      frame_len  <= 0;
      ep0_armed  <= 1'b0;
      data_toggle<= 1'b0;
      // clear mem
      for (int i=0;i<MEM_DEPTH;i++) mem[i] <= '0;
    end else begin
      // Default
      tx_ready <= 1'b1;

      if (tx_valid && tx_ready) begin
        case (rx_state)
          IDLE: begin
            // Expect a token PID first
            if (tx_byte == PID_SETUP) begin
              // Clear buffer/state on SETUP
              wr_idx    <= 0;
              frame_len <= 0;
              ep0_armed <= 0;
              data_toggle <= 0;
              rx_state  <= TOKEN;
              if (tx_last) rx_state <= IDLE;
              send_ack();
            end else if (tx_byte == PID_OUT) begin
              rx_state <= DATA; // data packet follows
              if (tx_last) rx_state <= IDLE;
            end else if (tx_byte == PID_IN) begin
              // Host requests IN data: send if armed
              send_data_packet();
              send_ack();
              rx_state <= IDLE;
            end else begin
              // Unknown PID: ignore
              rx_state <= IDLE;
            end
          end

          TOKEN: begin
            // For simplicity, skip token fields (addr/endpoint)
            if (tx_last) rx_state <= IDLE;
          end

          DATA: begin
            // Expect DATA0/DATA1 then payload bytes
            if ((tx_byte == PID_DATA0) || (tx_byte == PID_DATA1)) begin
              wr_idx    <= 0;
              frame_len <= 0;
            end else begin
              // Payload
              if (wr_idx < MEM_DEPTH) begin
                mem[wr_idx] <= tx_byte;
                wr_idx      <= wr_idx + 1;
                frame_len   <= frame_len + 1;
              end
            end

            if (tx_last) begin
              // Arm EP0 for IN to return what we received
              ep0_armed <= (frame_len > 0);
              send_ack();
              rx_state <= IDLE;
            end
          end
        endcase
      end
    end
  end

endmodule