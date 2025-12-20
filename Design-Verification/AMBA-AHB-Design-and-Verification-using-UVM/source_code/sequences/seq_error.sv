// sequences/directed/error_seq.sv
class error_seq extends uvm_sequence #(seq_item);
  `uvm_object_utils(error_seq)

  function new(string name = "error_seq");
    super.new(name);
  endfunction

  task body();
    // Invalid address: outside MEM_DEPTH range
    seq_item tr = seq_item::type_id::create("tr");
    tr.write = 1;
    tr.addr  = 32'hFFFF_FFFC;
    tr.data  = 32'hBAD0_BAD0;
    start_item(tr);
    finish_item(tr);
  endtask
endclass