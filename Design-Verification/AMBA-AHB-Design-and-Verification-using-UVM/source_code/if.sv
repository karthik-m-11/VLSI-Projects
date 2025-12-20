// src/ahb_if.sv
interface ahb_if (input logic HCLK, input logic HRESETn);

  // AHB-Lite signals (single master, single slave)
  logic [31:0] HADDR;
  logic [1:0]  HTRANS;   // IDLE(00), BUSY(01), NONSEQ(10), SEQ(11)
  logic        HWRITE;
  logic [2:0]  HSIZE;    // transfer size: 010 = 32-bit
  logic [31:0] HWDATA;
  logic [31:0] HRDATA;
  logic        HREADY;   // indicates transfer completion
  logic        HRESP;    // 0=OKAY, 1=ERROR (AHB-Lite uses single-bit)

  // Master/slave modports
  modport master (
    output HADDR, HTRANS, HWRITE, HSIZE, HWDATA,
    input  HRDATA, HREADY, HRESP
  );

  modport slave (
    input  HADDR, HTRANS, HWRITE, HSIZE, HWDATA,
    output HRDATA, HREADY, HRESP
  );

endinterface