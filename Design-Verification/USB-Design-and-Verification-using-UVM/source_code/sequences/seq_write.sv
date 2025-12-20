// sequences/directed/write_seq.sv
class write_seq extends uvm_sequence #(seq_item);
  `uvm_object_utils(write_seq)

  function new(string name = "write_seq");
    super.new(name);
  endfunction

  task body();
    seq_item tr = seq_item::type_id::create("wr");
    assert(tr.randomize() with {
      is_setup == 0; write == 1; data_pid == 0; len == 16;
    });
    tr.payload = new[tr.len];
    foreach (tr.payload[i]) tr.payload[i] = 8'hA5;
    start_item(tr); finish_item(tr);
  endtask
endclass