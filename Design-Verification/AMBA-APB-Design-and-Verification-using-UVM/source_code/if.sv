// src/apb_if.sv
interface apb_if #(parameter ADDR_WIDTH = 16, DATA_WIDTH = 32) (
  input  logic PCLK,
  input  logic PRESETn
);

  // APB3/4 (slave-side signals)
  logic                  PSEL;
  logic                  PENABLE;
  logic [ADDR_WIDTH-1:0] PADDR;
  logic                  PWRITE;
  logic [DATA_WIDTH-1:0] PWDATA;
  logic [DATA_WIDTH-1:0] PRDATA;
  logic                  PREADY;
  logic                  PSLVERR;

  // Driver clocking block: synchronized outputs, sampled inputs
  clocking cb_drv @(posedge PCLK);
    default input #1step output #1step;
    output PSEL, PENABLE, PADDR, PWRITE, PWDATA;
    input  PRDATA, PREADY, PSLVERR;
  endclocking

  // Monitor clocking block: sample everything
  clocking cb_mon @(posedge PCLK);
    default input #1step output #1step;
    input PSEL, PENABLE, PADDR, PWRITE, PWDATA, PRDATA, PREADY, PSLVERR;
  endclocking

  // Modports
  modport drv (clocking cb_drv, input PRESETn);
  modport mon (clocking cb_mon, input PRESETn);

  // Plain-signal modport for DUT connectivity
  modport dut_mp (
    input  PCLK, PRESETn,
    input  PSEL, PENABLE, PADDR, PWRITE, PWDATA,
    output PRDATA, PREADY, PSLVERR
  );

endinterface