// sequences/directed/burst_seq.sv
// Send a sequence of frames back-to-back.
class burst_seq extends uvm_sequence #(seq_item);
  `uvm_object_utils(burst_seq)

  function new(string name = "burst_seq");
    super.new(name);
  endfunction

  task body();
    for (int n = 0; n < 8; n++) begin
      seq_item tr = seq_item::type_id::create($sformatf("tr_%0d", n));
      tr.len = 60 + n; // vary lengths
      tr.payload = new[tr.len];
      foreach (tr.payload[i]) tr.payload[i] = (8'h10 + n) ^ i[7:0];
      tr.eth_type = 16'h0806; // ARP
      tr.inject_err = 0;
      start_item(tr); finish_item(tr);
    end
  endtask
endclass