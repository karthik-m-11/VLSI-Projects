// sequences/directed/write_seq.sv
class write_seq extends uvm_sequence #(seq_item);
  `uvm_object_utils(write_seq)

  function new(string name = "write_seq");
    super.new(name);
  endfunction

  task body();
    seq_item tr = seq_item::type_id::create("tr");
    tr.write = 1;
    tr.addr  = 32'h0000_0020;
    tr.data  = 32'hDEAD_BEEF;
    start_item(tr);
    finish_item(tr);
  endtask
endclass