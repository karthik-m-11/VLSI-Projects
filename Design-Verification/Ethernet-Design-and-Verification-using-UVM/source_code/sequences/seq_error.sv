// sequences/directed/error_seq.sv
// Send a malformed frame (length too large or zero) to provoke drop.
class error_seq extends uvm_sequence #(seq_item);
  `uvm_object_utils(error_seq)

  function new(string name = "error_seq");
    super.new(name);
  endfunction

  task body();
    // Oversized frame
    seq_item bad = seq_item::type_id::create("bad");
    bad.len = 1024; // exceeds MAX_FRAME
    bad.payload = new[bad.len];
    foreach (bad.payload[i]) bad.payload[i] = 8'hFF;
    bad.eth_type = 16'hFFFF;
    bad.inject_err = 1;
    start_item(bad); finish_item(bad);
  endtask
endclass