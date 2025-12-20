// sequences/seq_lib.sv
class random_seq extends uvm_sequence #(seq_item);
  `uvm_object_utils(random_seq)

  function new(string name = "random_seq");
    super.new(name);
  endfunction

  task body();
    seq_item tr;
    repeat (10) begin
      tr = seq_item::type_id::create("tr");
      assert(tr.randomize() with {
        inject_err == 0;
        foreach (payload[i]) payload[i] inside {[8'h00:8'hFF]};
      });
      start_item(tr);
      finish_item(tr);
    end
  endtask
endclass

class read_after_write_seq extends uvm_sequence #(seq_item);
  `uvm_object_utils(read_after_write_seq)

  function new(string name = "read_after_write_seq");
    super.new(name);
  endfunction

  task body();
    // For Ethernet, "read-after-write" maps to "send a frame and expect loopback"
    seq_item tr = seq_item::type_id::create("raw_tr");
    assert(tr.randomize() with { len == 64; inject_err == 0; });
    start_item(tr); finish_item(tr);
  endtask
endclass