// sequences/directed/burst_seq.sv
class burst_seq extends uvm_sequence #(seq_item);
  `uvm_object_utils(burst_seq)

  function new(string name = "burst_seq");
    super.new(name);
  endfunction

  task body();
    for (int i = 0; i < 8; i++) begin
      seq_item tr = seq_item::type_id::create($sformatf("tr_%0d", i));
      tr.write = (i % 2);           // alternate write/read
      tr.addr  = 32'h0000_0040 + i*4;
      tr.data  = 32'h1111_0000 + i;
      start_item(tr);
      finish_item(tr);
    end
  endtask
endclass