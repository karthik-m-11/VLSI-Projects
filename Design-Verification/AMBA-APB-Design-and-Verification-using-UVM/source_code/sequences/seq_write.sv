// sequences/directed/write_seq.sv
class write_seq extends uvm_sequence #(seq_item);
  `uvm_object_utils(write_seq)

  function new(string name = "write_seq");
    super.new(name);
  endfunction

  task body();
    seq_item tr = seq_item::type_id::create("tr");
    tr.kind = WRITE;
    tr.addr = 16'h20;
    tr.data = 32'hDEADBEEF;
    start_item(tr);
    finish_item(tr);
  endtask
endclass