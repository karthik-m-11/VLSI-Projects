// sequences/directed/burst_seq.sv
// Issue a series of alternating MWr/MRd requests.
class burst_seq extends uvm_sequence #(seq_item);
  `uvm_object_utils(burst_seq)

  function new(string name = "burst_seq");
    super.new(name);
  endfunction

  task body();
    for (int i = 0; i < 8; i++) begin
      seq_item wr = seq_item::type_id::create($sformatf("wr_%0d", i));
      assert(wr.randomize() with { write==1; addr==32'h0000_0040 + i*4; len_dw==1; tag==(8'h10+i); });
      wr.data0 = 32'h1111_0000 + i;
      wr.data1 = 32'h0000_0000;
      start_item(wr); finish_item(wr);

      seq_item rd = seq_item::type_id::create($sformatf("rd_%0d", i));
      assert(rd.randomize() with { write==0; addr==wr.addr; len_dw==1; tag==(8'h20+i); });
      start_item(rd); finish_item(rd);
    end
  endtask
endclass