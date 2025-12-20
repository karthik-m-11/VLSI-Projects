// src/dut.sv
// Simple AHB-Lite slave: 32-bit memory-mapped register file.
// Single-cycle HREADY, OKAY response, word-aligned accesses.
module ahb_slave #(
  parameter MEM_DEPTH = 256  // number of 32-bit words
)(
  input  logic        HCLK,
  input  logic        HRESETn,
  input  logic [31:0] HADDR,
  input  logic [1:0]  HTRANS,
  input  logic        HWRITE,
  input  logic [2:0]  HSIZE,
  input  logic [31:0] HWDATA,
  output logic [31:0] HRDATA,
  output logic        HREADY,
  output logic        HRESP
);

  // Internal memory
  logic [31:0] mem [0:MEM_DEPTH-1];

  // Always ready in one cycle; always OKAY response
  assign HREADY = 1'b1;
  assign HRESP  = 1'b0;

  // Word index from address (word-aligned: [9:2] -> 256 words)
  wire [7:0] addr_idx = HADDR[9:2];
  wire       valid    = (addr_idx < MEM_DEPTH);
  wire       active   = HTRANS[1]; // NONSEQ/SEQ have bit1=1

  // Simple behavior: perform write/read when transfer active and ready
  always_ff @(posedge HCLK or negedge HRESETn) begin
    if (!HRESETn) begin
      HRDATA <= '0;
    end else if (active && HREADY) begin
      if (!valid || (HSIZE != 3'b010)) begin
        // Invalid address or non-word size: return zero, OKAY (or you may set HRESP=1)
        HRDATA <= '0;
      end else if (HWRITE) begin
        mem[addr_idx] <= HWDATA;
      end else begin
        HRDATA <= mem[addr_idx];
      end
    end
  end

  // Optional: clear memory on reset
  integer i;
  always_ff @(negedge HRESETn) begin
    for (i = 0; i < MEM_DEPTH; i++) mem[i] <= '0;
  end

endmodule