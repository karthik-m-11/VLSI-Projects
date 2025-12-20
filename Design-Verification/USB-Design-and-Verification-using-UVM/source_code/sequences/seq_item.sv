// sequences/seq_item.sv
class seq_item extends uvm_sequence_item;
  `uvm_object_utils(seq_item)

  // Host request fields
  rand bit        is_setup;     // SETUP stage (8-byte payload)
  rand bit        write;        // OUT transfer if 1, IN if 0
  rand bit        data_pid;     // 0=DATA0, 1=DATA1 (for OUT)
  rand int unsigned len;        // data payload length (OUT)
  rand byte unsigned payload[]; // setup/data payload

  // Device observation fields
  bit  is_device_pkt;
  byte resp_pid;                // PID from device (ACK/DATAx)
  byte resp_bytes[$];           // payload returned on IN

  // Raw PID for monitor convenience
  byte pid;

  constraint c_len { len inside {[0:64]}; }
  constraint c_size { payload.size() == (is_setup ? 8 : len); }

  function new(string name = "seq_item");
    super.new(name);
  endfunction

  function string convert2string();
    return $sformatf("USB %s %s len=%0d pid=%0h resp=%0h",
      is_setup ? "SETUP" : (write ? "OUT" : "IN"),
      data_pid ? "DATA1" : "DATA0", len, pid, resp_pid);
  endfunction
endclass