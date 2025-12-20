// sequences/seq_item.sv
class seq_item extends uvm_sequence_item;
  `uvm_object_utils(seq_item)

  rand byte unsigned payload[]; // frame bytes
  rand int unsigned  len;       // number of bytes
  rand bit [15:0]    eth_type;  // optional EtherType field (not used by DUT)
  rand bit           inject_err; // request malformed frame (handled in sequences)

  constraint len_c { len inside {[46:512]}; }       // minimal payload, bounded by DUT
  constraint size_match_c { payload.size() == len; }

  function new(string name = "seq_item");
    super.new(name);
  endfunction

  function string convert2string();
    return $sformatf("ETH frame: len=%0d type=0x%04h err=%0b", len, eth_type, inject_err);
  endfunction
endclass