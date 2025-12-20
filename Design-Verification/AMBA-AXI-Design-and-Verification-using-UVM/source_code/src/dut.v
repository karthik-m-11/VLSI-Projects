// src/dut.sv
// Simple AXI4-Lite slave: 256 x 32-bit register file.
// Single-cycle ready on AW/W/AR and single-cycle responses. Word-aligned accesses.
module axi_lite_slave #(
  parameter MEM_DEPTH = 256
)(
  input  logic        ACLK,
  input  logic        ARESETn,

  // Write address
  input  logic [31:0] AWADDR,
  input  logic        AWVALID,
  output logic        AWREADY,

  // Write data
  input  logic [31:0] WDATA,
  input  logic [3:0]  WSTRB,
  input  logic        WVALID,
  output logic        WREADY,

  // Write response
  output logic [1:0]  BRESP,
  output logic        BVALID,
  input  logic        BREADY,

  // Read address
  input  logic [31:0] ARADDR,
  input  logic        ARVALID,
  output logic        ARREADY,

  // Read data
  output logic [31:0] RDATA,
  output logic [1:0]  RRESP,
  output logic        RVALID,
  input  logic        RREADY
);

  // Internal memory
  logic [31:0] mem [0:MEM_DEPTH-1];

  // Address decode (word index)
  wire [7:0] aw_idx = AWADDR[9:2];
  wire [7:0] ar_idx = ARADDR[9:2];
  wire       aw_valid_addr = (aw_idx < MEM_DEPTH) && (AWADDR[1:0] == 2'b00);
  wire       ar_valid_addr = (ar_idx < MEM_DEPTH) && (ARADDR[1:0] == 2'b00);

  // Simple ready/BVALID/RVALID generation:
  // Accept address/data when valid; give immediate response.
  always_ff @(posedge ACLK or negedge ARESETn) begin
    if (!ARESETn) begin
      AWREADY <= 1'b0;
      WREADY  <= 1'b0;
      BVALID  <= 1'b0;
      BRESP   <= 2'b00;
      ARREADY <= 1'b0;
      RVALID  <= 1'b0;
      RRESP   <= 2'b00;
      RDATA   <= '0;
    end else begin
      // Defaults
      AWREADY <= 1'b0;
      WREADY  <= 1'b0;
      ARREADY <= 1'b0;

      // Write address handshake
      if (AWVALID && !AWREADY) begin
        AWREADY <= 1'b1;
      end

      // Write data handshake and response generation
      if (WVALID && !WREADY) begin
        WREADY <= 1'b1;
        // Perform write only if address was valid and strobes are present
        if (aw_valid_addr) begin
          // Apply WSTRB byte enables
          for (int b = 0; b < 4; b++) begin
            if (WSTRB[b]) mem[aw_idx][8*b +: 8] <= WDATA[8*b +: 8];
          end
          BRESP  <= 2'b00; // OKAY
        end else begin
          BRESP  <= 2'b10; // SLVERR
        end
        BVALID <= 1'b1;
      end

      // Complete write response
      if (BVALID && BREADY) begin
        BVALID <= 1'b0;
      end

      // Read address handshake and data/response
      if (ARVALID && !ARREADY) begin
        ARREADY <= 1'b1;
        if (ar_valid_addr) begin
          RDATA <= mem[ar_idx];
          RRESP <= 2'b00;   // OKAY
        end else begin
          RDATA <= '0;
          RRESP <= 2'b10;   // SLVERR
        end
        RVALID <= 1'b1;
      end

      // Complete read data channel
      if (RVALID && RREADY) begin
        RVALID <= 1'b0;
      end
    end
  end

  // Optional: clear memory on reset assert
  integer i;
  always_ff @(negedge ARESETn) begin
    for (i = 0; i < MEM_DEPTH; i++) mem[i] <= '0;
  end

endmodule