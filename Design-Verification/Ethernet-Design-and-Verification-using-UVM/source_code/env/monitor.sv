// uvm_env/monitor.sv
class monitor extends uvm_monitor;
  `uvm_component_utils(monitor)

  virtual eth_if vif;
  uvm_analysis_port #(seq_item) ap;

  function new(string name = "monitor", uvm_component parent = null);
    super.new(name, parent);
    ap = new("ap", this);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual eth_if)::get(this, "", "vif", vif))
      `uvm_fatal("NOVIF", "Virtual interface not set for monitor")
  endfunction

  task run_phase(uvm_phase phase);
    seq_item tr;
    tr = seq_item::type_id::create("rx_frame");
    tr.payload.delete();
    tr.len = 0;

    // Always ready to receive
    vif.rx_ready <= 1'b1;

    forever begin
      @(posedge vif.ETH_CLK);
      if (vif.rx_valid) begin
        tr.payload.push_back(vif.rx_data);
        tr.len++;
        if (vif.rx_last) begin
          ap.write(tr);
          // Prepare for next frame
          tr = seq_item::type_id::create("rx_frame");
          tr.payload.delete();
          tr.len = 0;
        end
      end
    end
  endtask
endclass