// sequences/directed/error_seq.sv
// Malformed request: out-of-range address or invalid len -> expect endpoint to ignore or return zeros in completion.
class error_seq extends uvm_sequence #(seq_item);
  `uvm_object_utils(error_seq)

  function new(string name = "error_seq");
    super.new(name);
  endfunction

  task body();
    // Out-of-range MRd
    seq_item bad_rd = seq_item::type_id::create("bad_rd");
    bad_rd.write  = 0;
    bad_rd.addr   = 32'hFFFF_FFFC;
    bad_rd.len_dw = 2;
    bad_rd.tag    = 8'hEE;
    start_item(bad_rd); finish_item(bad_rd);

    // Invalid len for MWr (still packed; endpoint ignores extra)
    seq_item bad_wr = seq_item::type_id::create("bad_wr");
    bad_wr.write  = 1;
    bad_wr.addr   = 32'h0000_0100;
    bad_wr.len_dw = 2;
    bad_wr.tag    = 8'hEF;
    bad_wr.data0  = 32'hBAD0_BAD0;
    bad_wr.data1  = 32'hDEAD_DEAD;
    start_item(bad_wr); finish_item(bad_wr);
  endtask
endclass