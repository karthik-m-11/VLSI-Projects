// src/axi_if.sv
interface axi_if (input logic ACLK, input logic ARESETn);

  // AXI4-Lite write address channel
  logic [31:0] AWADDR;
  logic        AWVALID;
  logic        AWREADY;

  // AXI4-Lite write data channel
  logic [31:0] WDATA;
  logic [3:0]  WSTRB;
  logic        WVALID;
  logic        WREADY;

  // AXI4-Lite write response channel
  logic [1:0]  BRESP;   // 00=OKAY, 10=SLVERR
  logic        BVALID;
  logic        BREADY;

  // AXI4-Lite read address channel
  logic [31:0] ARADDR;
  logic        ARVALID;
  logic        ARREADY;

  // AXI4-Lite read data channel
  logic [31:0] RDATA;
  logic [1:0]  RRESP;   // 00=OKAY, 10=SLVERR
  logic        RVALID;
  logic        RREADY;

  // Master/slave modports
  modport master (
    output AWADDR, AWVALID, WDATA, WSTRB, WVALID, BREADY, ARADDR, ARVALID, RREADY,
    input  AWREADY, WREADY, BVALID, BRESP, ARREADY, RVALID, RRESP, RDATA
  );

  modport slave (
    input  AWADDR, AWVALID, WDATA, WSTRB, WVALID, BREADY, ARADDR, ARVALID, RREADY,
    output AWREADY, WREADY, BVALID, BRESP, ARREADY, RVALID, RRESP, RDATA
  );

endinterface