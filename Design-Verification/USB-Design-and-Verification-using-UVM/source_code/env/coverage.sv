// uvm_env/coverage.sv
class coverage extends uvm_subscriber #(seq_item);
  `uvm_component_utils(coverage)

  covergroup cg @(posedge pclk);
    coverpoint tr.addr;
    coverpoint tr.kind;
    coverpoint tr.data;
  endgroup

  function new(string name = "coverage", uvm_component parent = null);
    super.new(name, parent);
    cg = new();
  endfunction

  function void write(seq_item tr);
    cg.sample();
  endfunction
endclass