// src/pcie_if.sv
interface pcie_if (input logic PCIE_CLK, input logic PCIE_RSTn);

  // Request (Host -> Endpoint): Memory Read/Write TLPs
  logic        req_valid;
  logic        req_ready;
  logic [127:0] req_tlp;  // packed TLP header+data (simplified)

  // Completion/Response (Endpoint -> Host)
  logic        cpl_valid;
  logic        cpl_ready;
  logic [127:0] cpl_tlp;  // packed completion TLP (header+data)

  // Modports
  modport drv (
    output req_valid, req_tlp, cpl_ready,
    input  req_ready, cpl_valid, cpl_tlp
  );

  modport mon (
    input req_valid, req_ready, req_tlp, cpl_valid, cpl_tlp, cpl_ready
  );

  modport dut_mp (
    input  PCIE_CLK, PCIE_RSTn,
    input  req_valid, req_tlp, cpl_ready,
    output req_ready, cpl_valid, cpl_tlp
  );

endinterface