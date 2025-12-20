// src/dut.sv
// Simplified PCIe endpoint:
// - Accepts Memory Write/Read requests as packed TLPs on req_tlp.
// - Maintains 256 x 32-bit BAR memory.
// - Emits Completions for Reads on cpl_tlp.
// - No tags/credits/flow control beyond ready/valid; no LTSSM/CRC.
module pcie_endpoint #(
  parameter MEM_DEPTH = 256  // 32-bit words
)(
  input  logic        PCIE_CLK,
  input  logic        PCIE_RSTn,

  // Request TLP stream (Host -> EP)
  input  logic        req_valid,
  output logic        req_ready,
  input  logic [127:0] req_tlp,

  // Completion TLP stream (EP -> Host)
  output logic        cpl_valid,
  input  logic        cpl_ready,
  output logic [127:0] cpl_tlp
);

  // Memory BAR
  logic [31:0] mem [0:MEM_DEPTH-1];

  // TLP fields (simplified packing):
  // [127:120]  type (8b): 0x00=MWr, 0x01=MRd, others reserved
  // [119:88]   addr (32b)
  // [87:80]    len_dw (8b) number of dwords (max 4 in this simple model)
  // [79:72]    tag (8b)
  // [71:40]    data_dw0 (32b)
  // [39:8]     data_dw1 (32b) (optional, based on len)
  // [7:0]      reserved
  localparam [7:0] TLP_MWR = 8'h00;
  localparam [7:0] TLP_MRD = 8'h01;

  // Ready logic: always able to accept one request per cycle
  assign req_ready = 1'b1;

  // Completion defaults
  always_ff @(posedge PCIE_CLK or negedge PCIE_RSTn) begin
    if (!PCIE_RSTn) begin
      cpl_valid <= 1'b0;
      cpl_tlp   <= '0;
      // clear memory
      for (int i = 0; i < MEM_DEPTH; i++) mem[i] <= '0;
    end else begin
      cpl_valid <= 1'b0;

      if (req_valid && req_ready) begin
        // Unpack fields
        automatic logic [7:0]  type    = req_tlp[127:120];
        automatic logic [31:0] addr    = req_tlp[119:88];
        automatic logic [7:0]  len_dw  = req_tlp[87:80];
        automatic logic [7:0]  tag     = req_tlp[79:72];
        automatic logic [31:0] data0   = req_tlp[71:40];
        automatic logic [31:0] data1   = req_tlp[39:8];

        automatic logic [7:0]  idx0    = addr[9:2];  // word index
        automatic bit          valid0  = (idx0 < MEM_DEPTH);
        automatic logic [7:0]  idx1    = idx0 + 1;
        automatic bit          valid1  = (idx1 < MEM_DEPTH);

        if (type == TLP_MWR) begin
          // Write len_dw dwords starting at addr
          if (len_dw >= 1 && valid0) mem[idx0] <= data0;
          if (len_dw >= 2 && valid1) mem[idx1] <= data1;
          // No completion for MWr
        end else if (type == TLP_MRD) begin
          // Read len_dw dwords and return completion
          automatic logic [31:0] rd0 = valid0 ? mem[idx0] : 32'h0000_0000;
          automatic logic [31:0] rd1 = (len_dw >= 2 && valid1) ? mem[idx1] : 32'h0000_0000;

          // Pack completion TLP (simplified):
          // [127:120]  cpl_type (8b): 0x10 = CplD (Completion with Data)
          // [119:88]   addr echo (32b)
          // [87:80]    len_dw (8b)
          // [79:72]    tag echo (8b)
          // [71:40]    data_dw0
          // [39:8]     data_dw1
          // [7:0]      reserved
          cpl_tlp   <= {8'h10, addr, len_dw, tag, rd0, rd1, 8'h00};
          if (cpl_ready) begin
            cpl_valid <= 1'b1;
          end else begin
            // If backpressured, present valid until ready asserted next cycle
            cpl_valid <= 1'b1;
          end
        end else begin
          // Unsupported type: ignore
        end
      end else if (cpl_valid && cpl_ready) begin
        cpl_valid <= 1'b0;
      end
    end
  end

endmodule