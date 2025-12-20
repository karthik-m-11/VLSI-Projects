// sequences/directed/write_seq.sv
class write_seq extends uvm_sequence #(seq_item);
  `uvm_object_utils(write_seq)

  function new(string name = "write_seq");
    super.new(name);
  endfunction

  task body();
    seq_item tr = seq_item::type_id::create("wr");
    assert(tr.randomize() with { write==1; addr==32'h0000_0020; len_dw==2; tag==8'h01; });
    tr.data0 = 32'hDEAD_BEEF;
    tr.data1 = 32'hCAFE_F00D;
    start_item(tr); finish_item(tr);
  endtask
endclass