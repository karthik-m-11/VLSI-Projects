// sequences/seq_item.sv
class seq_item extends uvm_sequence_item;
  `uvm_object_utils(seq_item)

  rand bit [31:0] addr;   // word-aligned address
  rand bit [31:0] data;   // data payload
  rand bit        write;  // 1=WRITE, 0=READ

  constraint word_align_c { addr[1:0] == 2'b00; }
  constraint addr_range_c { addr[9:2] inside {[0:255]}; } // matches MEM_DEPTH

  function new(string name = "seq_item");
    super.new(name);
  endfunction

  function string convert2string();
    return $sformatf("AXI4-Lite %s addr=0x%08h data=0x%08h",
                     write ? "WRITE" : "READ", addr, data);
  endfunction
endclass