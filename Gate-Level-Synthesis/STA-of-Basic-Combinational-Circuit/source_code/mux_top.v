module mux_top (
  input  wire a,
  input  wire b,
  input  wire sel,
  output wire y
);
  wire nsel, a_path, b_path;

  INVX1 u_inv0 (.A(sel), .Y(nsel));
  AND2X1 u_and0 (.A(a), .B(nsel), .Y(a_path));
  AND2X1 u_and1 (.A(b), .B(sel), .Y(b_path));
  OR2X1  u_or0  (.A(a_path), .B(b_path), .Y(y));
endmodule