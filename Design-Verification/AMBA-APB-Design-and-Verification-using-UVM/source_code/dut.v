// src/dut.sv
// Simple APB slave with a register-file memory and single-cycle ready response.
// Implements APB SETUP (PSEL=1,PENABLE=0) -> ACCESS (PSEL=1,PENABLE=1).
module apb_slave #(
  parameter ADDR_WIDTH = 16,
  parameter DATA_WIDTH = 32,
  parameter MEM_DEPTH  = 256        // number of words
)(
  input  logic                  PCLK,
  input  logic                  PRESETn,
  input  logic                  PSEL,
  input  logic                  PENABLE,
  input  logic [ADDR_WIDTH-1:0] PADDR,
  input  logic                  PWRITE,
  input  logic [DATA_WIDTH-1:0] PWDATA,
  output logic [DATA_WIDTH-1:0] PRDATA,
  output logic                  PREADY,
  output logic                  PSLVERR
);

  // Internal memory
  localparam int ADDR_INDEX_WIDTH = (MEM_DEPTH <= 1) ? 1 : $clog2(MEM_DEPTH);
  logic [DATA_WIDTH-1:0] mem [0:MEM_DEPTH-1];

  // APB phase decode
  wire setup_phase  = PSEL & ~PENABLE;
  wire access_phase = PSEL &  PENABLE;

  // Address validity check
  wire [ADDR_INDEX_WIDTH-1:0] addr_idx = PADDR[ADDR_INDEX_WIDTH-1:0];
  wire valid_addr = (addr_idx < MEM_DEPTH);

  // Ready/response generation: single-cycle ready in ACCESS
  always_ff @(posedge PCLK or negedge PRESETn) begin
    if (!PRESETn) begin
      PREADY  <= 1'b0;
      PSLVERR <= 1'b0;
      PRDATA  <= '0;
    end else begin
      // Default outputs
      PREADY  <= 1'b0;
      PSLVERR <= 1'b0;

      // ACCESS phase: complete transaction
      if (access_phase) begin
        PREADY <= 1'b1;

        if (!valid_addr) begin
          PSLVERR <= 1'b1;
          PRDATA  <= '0;
        end else if (PWRITE) begin
          mem[addr_idx] <= PWDATA;
        end else begin
          PRDATA <= mem[addr_idx];
        end
      end
    end
  end

  // Optional: clear memory on reset deassertion edge
  integer i;
  always_ff @(negedge PRESETn) begin
    for (i = 0; i < MEM_DEPTH; i++) begin
      mem[i] <= '0;
    end
  end

endmodule