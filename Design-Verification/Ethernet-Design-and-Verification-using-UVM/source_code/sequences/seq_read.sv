// sequences/directed/read_seq.sv
// For Ethernet, "read" is observing loopback; driver still sends.
class read_seq extends uvm_sequence #(seq_item);
  `uvm_object_utils(read_seq)

  function new(string name = "read_seq");
    super.new(name);
  endfunction

  task body();
    seq_item tr = seq_item::type_id::create("rd");
    tr.len = 64;
    tr.payload = new[tr.len];
    foreach (tr.payload[i]) tr.payload[i] = i[7:0];
    tr.eth_type = 16'h86DD; // IPv6
    tr.inject_err = 0;
    start_item(tr); finish_item(tr);
  endtask
endclass