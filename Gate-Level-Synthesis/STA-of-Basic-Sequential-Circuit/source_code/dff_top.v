module dff_top (
  input wire D,
  input wire CLK,
  output wire Q
);
  DFFX1 dff0 (.D(D), .CLK(CLK), .Q(Q));
endmodule