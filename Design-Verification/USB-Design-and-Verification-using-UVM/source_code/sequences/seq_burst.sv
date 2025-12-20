// sequences/directed/burst_seq.sv
class burst_seq extends uvm_sequence #(seq_item);
  `uvm_object_utils(burst_seq)

  function new(string name = "burst_seq");
    super.new(name);
  endfunction

  task body();
    // Alternate OUT and IN across several packets
    for (int n=0; n<8; n++) begin
      seq_item wr = seq_item::type_id::create($sformatf("wr_%0d", n));
      assert(wr.randomize() with { is_setup==0; write==1; data_pid==(n%2); len== (4 + n); });
      wr.payload = new[wr.len];
      foreach (wr.payload[i]) wr.payload[i] = (8'h10 + n) ^ i[7:0];
      start_item(wr); finish_item(wr);

      seq_item rd = seq_item::type_id::create($sformatf("rd_%0d", n));
      rd.is_setup = 0; rd.write = 0;
      start_item(rd); finish_item(rd);
    end
  endtask
endclass