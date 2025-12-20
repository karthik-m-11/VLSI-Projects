// uvm_env/coverage.sv
class coverage extends uvm_subscriber #(seq_item);
  `uvm_component_utils(coverage)

  // Capture fields from last seen transaction for sampling
  seq_item tr_q;
  // Use a simple clock; replace with HCLK via vifs if preferred
  // For simplicity, sample on write() call.

  covergroup cg;
    coverpoint tr_q.addr[9:2] { bins low[] = {[0:31]}; bins mid[] = {[32:127]}; bins high[] = {[128:255]}; }
    coverpoint tr_q.write     { bins read = {0}; bins write = {1}; }
    coverpoint tr_q.data      { bins zeros = {32'h0000_0000}; bins ones = {32'hFFFF_FFFF}; bins misc[] = default; }
  endgroup

  function new(string name = "coverage", uvm_component parent = null);
    super.new(name, parent);
    cg = new();
  endfunction

  function void write(seq_item t);
    tr_q = t;
    cg.sample();
  endfunction
endclass