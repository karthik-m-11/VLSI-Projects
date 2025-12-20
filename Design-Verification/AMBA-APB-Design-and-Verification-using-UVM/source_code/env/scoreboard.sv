// uvm_env/scoreboard.sv
class scoreboard extends uvm_component;
  `uvm_component_utils(scoreboard)

  uvm_analysis_export #(seq_item) analysis_export;
  bit [31:0] mem [0:255]; // reference model

  function new(string name = "scoreboard", uvm_component parent = null);
    super.new(name, parent);
    analysis_export = new("analysis_export", this);
  endfunction

  function void write(seq_item tr);
    if (tr.kind == WRITE) begin
      mem[tr.addr] = tr.data;
    end else begin
      if (mem[tr.addr] !== tr.data)
        `uvm_error("MISMATCH", $sformatf("Read mismatch at addr %0h: expected %0h got %0h",
                                         tr.addr, mem[tr.addr], tr.data))
    end
  endfunction
endclass