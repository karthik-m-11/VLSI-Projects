// uvm_env/monitor.sv
class monitor extends uvm_monitor;
  `uvm_component_utils(monitor)

  virtual axi_if vif;
  uvm_analysis_port #(seq_item) ap;

  function new(string name = "monitor", uvm_component parent = null);
    super.new(name, parent);
    ap = new("ap", this);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual axi_if)::get(this, "", "vif", vif))
      `uvm_fatal("NOVIF", "Virtual interface not set for monitor")
  endfunction

  task run_phase(uvm_phase phase);
    seq_item tr;
    forever begin
      @(posedge vif.ACLK);
      // Observe write completion on BVALID handshake
      if (vif.BVALID && vif.BREADY) begin
        tr = seq_item::type_id::create("wr_tr");
        tr.write = 1;
        // Best effort capture last seen AWADDR/WDATA (assuming single outstanding)
        tr.addr  = vif.AWADDR;
        tr.data  = vif.WDATA;
        ap.write(tr);
      end

      // Observe read completion on RVALID handshake
      if (vif.RVALID && vif.RREADY) begin
        tr = seq_item::type_id::create("rd_tr");
        tr.write = 0;
        tr.addr  = vif.ARADDR;
        tr.data  = vif.RDATA;
        ap.write(tr);
      end
    end
  endtask
endclass