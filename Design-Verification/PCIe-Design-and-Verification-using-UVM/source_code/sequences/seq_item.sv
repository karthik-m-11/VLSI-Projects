// sequences/seq_item.sv
class seq_item extends uvm_sequence_item;
  `uvm_object_utils(seq_item)

  // Request fields
  rand bit        write;              // 1=MWr, 0=MRd
  rand bit [31:0] addr;               // word-aligned address
  rand bit [7:0]  len_dw;             // number of dwords (1..2 in this simple model)
  rand bit [7:0]  tag;                // request tag
  rand bit [31:0] data0;              // first dword (MWr)
  rand bit [31:0] data1;              // second dword (MWr if len_dw>=2)

  // Completion capture (for MRd)
  bit [7:0]  cpl_type;
  bit [7:0]  cpl_len;
  bit [7:0]  cpl_tag;
  bit [31:0] cpl_d0;
  bit [31:0] cpl_d1;

  constraint align_c { addr[1:0] == 2'b00; }
  constraint len_c   { len_dw inside {[1:2]}; }
  constraint addr_range_c { addr[9:2] inside {[0:255]}; }

  function new(string name = "seq_item");
    super.new(name);
  endfunction

  function string convert2string();
    return $sformatf("PCIe %s addr=0x%08h len=%0d tag=0x%0h d0=0x%08h d1=0x%08h",
                     write ? "MWr" : "MRd", addr, len_dw, tag, data0, data1);
  endfunction
endclass