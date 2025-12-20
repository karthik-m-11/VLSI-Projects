// sequences/seq_item.sv
typedef enum {READ, WRITE} apb_kind_e;

class seq_item extends uvm_sequence_item;
  `uvm_object_utils(seq_item)

  rand bit [15:0] addr;
  rand bit [31:0] data;
  rand apb_kind_e kind;

  constraint addr_c { addr < 256; } // limit to DUT memory depth

  function new(string name = "seq_item");
    super.new(name);
  endfunction

  function string convert2string();
    return $sformatf("APB %s @ addr=0x%0h data=0x%0h",
                     (kind==WRITE)?"WRITE":"READ", addr, data);
  endfunction
endclass