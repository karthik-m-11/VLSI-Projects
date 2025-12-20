// sequences/directed/write_seq.sv
// Send a single directed frame.
class write_seq extends uvm_sequence #(seq_item);
  `uvm_object_utils(write_seq)

  function new(string name = "write_seq");
    super.new(name);
  endfunction

  task body();
    seq_item tr = seq_item::type_id::create("wr");
    tr.len = 64;
    tr.payload = new[tr.len];
    foreach (tr.payload[i]) tr.payload[i] = 8'hA5;
    tr.eth_type = 16'h0800; // IPv4
    tr.inject_err = 0;
    start_item(tr); finish_item(tr);
  endtask
endclass