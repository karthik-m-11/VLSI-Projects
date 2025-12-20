// sequences/seq_lib.sv
class random_seq extends uvm_sequence #(seq_item);
  `uvm_object_utils(random_seq)

  function new(string name = "random_seq");
    super.new(name);
  endfunction

  task body();
    seq_item tr;
    repeat (20) begin
      tr = seq_item::type_id::create("tr");
      assert(tr.randomize());
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
    seq_item wr, rd;
    wr = seq_item::type_id::create("wr");
    rd = seq_item::type_id::create("rd");

    wr.kind = WRITE;
    wr.addr = 16'h10;
    wr.data = 32'hABCD1234;
    start_item(wr); finish_item(wr);

    rd.kind = READ;
    rd.addr = wr.addr;
    start_item(rd); finish_item(rd);
  endtask
endclass