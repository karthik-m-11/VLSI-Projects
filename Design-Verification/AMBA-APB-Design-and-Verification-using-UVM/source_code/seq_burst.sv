// sequences/directed/burst_seq.sv
class burst_seq extends uvm_sequence #(seq_item);
  `uvm_object_utils(burst_seq)

  function new(string name = "burst_seq");
    super.new(name);
  endfunction

  task body();
    seq_item tr;
    for (int i = 0; i < 8; i++) begin
      tr = seq_item::type_id::create($sformatf("tr_%0d", i));
      tr.kind = (i % 2) ? WRITE : READ;
      tr.addr = i;
      tr.data = i * 32'h1111;
      start_item(tr);
      finish_item(tr);
    end
  endtask
endclass