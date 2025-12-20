// sequences/directed/error_seq.sv
class error_seq extends uvm_sequence #(seq_item);
  `uvm_object_utils(error_seq)

  function new(string name = "error_seq");
    super.new(name);
  endfunction

  task body();
    // Malformed: SETUP with zero payload, expect DUT to ACK and ignore
    seq_item bad = seq_item::type_id::create("bad_setup");
    bad.is_setup = 1; bad.write = 0; bad.len = 0;
    bad.payload = new[8]; // driver will send 8 anyway; fill unusual values
    foreach (bad.payload[i]) bad.payload[i] = 8'hFF;
    start_item(bad); finish_item(bad);

    // Oversized OUT (beyond device buffer policy), expect ACK then no IN data
    seq_item ov = seq_item::type_id::create("oversize_out");
    ov.is_setup = 0; ov.write = 1; ov.data_pid = 1; ov.len = 128; // larger than typical
    ov.payload = new[ov.len];
    foreach (ov.payload[i]) ov.payload[i] = 8'hEE;
    start_item(ov); finish_item(ov);
  endtask
endclass