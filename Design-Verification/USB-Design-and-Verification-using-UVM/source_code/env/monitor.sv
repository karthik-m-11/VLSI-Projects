// uvm_env/monitor.sv
class monitor extends uvm_monitor;
  `uvm_component_utils(monitor)

  virtual usb_if vif;
  uvm_analysis_port #(seq_item) ap;

  function new(string name = "monitor", uvm_component parent = null);
    super.new(name, parent);
    ap = new("ap", this);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual usb_if)::get(this, "", "vif", vif))
      `uvm_fatal("NOVIF", "Virtual interface not set for monitor")
  endfunction

  task run_phase(uvm_phase phase);
    seq_item tr;
    forever begin
      @(posedge vif.USB_CLK);
      // Capture device -> host packets
      if (vif.rx_valid) begin
        tr = seq_item::type_id::create("dev_pkt");
        tr.is_device_pkt = 1;
        tr.resp_pid      = vif.rx_byte;
        tr.resp_bytes.delete();
        @(posedge vif.USB_CLK);
        while (vif.rx_valid) begin
          if (!vif.rx_last) tr.resp_bytes.push_back(vif.rx_byte);
          @(posedge vif.USB_CLK);
        end
        ap.write(tr);
      end

      // Optionally capture host -> device transmissions
      if (vif.tx_valid) begin
        tr = seq_item::type_id::create("host_pkt");
        tr.is_device_pkt = 0;
        tr.pid           = vif.tx_byte;
        tr.len           = 0;
        // Lightweight sampling; deeper decoding can be added
        ap.write(tr);
      end
    end
  endtask
endclass