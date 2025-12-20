// sequences/directed/read_seq.sv
class read_seq extends uvm_sequence #(seq_item);
  `uvm_object_utils(read_seq)

  function new(string name = "read_seq");
    super.new(name);
  endfunction

  task body();
    seq_item tr = seq_item::type_id::create("rd");
    assert(tr.randomize() with { write==0; addr==32'h0000_0020; len_dw==2; tag==8'h02; });
    start_item(tr); finish_item(tr);
  endtask
endclass