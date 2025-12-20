// sequences/directed/read_seq.sv
class read_seq extends uvm_sequence #(seq_item);
  `uvm_object_utils(read_seq)

  function new(string name = "read_seq");
    super.new(name);
  endfunction

  task body();
    // First, prepare device buffer via OUT, then IN to read it
    seq_item wr = seq_item::type_id::create("prime_out");
    assert(wr.randomize() with { is_setup==0; write==1; data_pid==0; len==8; });
    wr.payload = new[wr.len];
    foreach (wr.payload[i]) wr.payload[i] = i[7:0];
    start_item(wr); finish_item(wr);

    seq_item rd = seq_item::type_id::create("rd");
    rd.is_setup = 0; rd.write = 0;
    start_item(rd); finish_item(rd);
  endtask
endclass