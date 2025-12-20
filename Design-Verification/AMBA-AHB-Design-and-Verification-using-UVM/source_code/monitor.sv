// uvm_env/monitor.sv
class monitor extends uvm_monitor;
  `uvm_component_utils(monitor)

  virtual ahb_if vif;
  uvm_analysis_port #(seq_item) ap;

  function new(string name = "monitor", uvm_component parent = null);
    super.new(name, parent);
    ap = new("ap", this);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual ahb_if)::get(this, "", "vif", vif))
      `uvm_fatal("NOVIF", "Virtual interface not set for monitor")
  endfunction

  task run_phase(uvm_phase phase);
    seq_item tr;
    forever begin
      @(posedge vif.HCLK);
      // Active transfer completes when HTRANS[1]=1 and HREADY=1
      if (vif.HTRANS[1] && vif.HREADY) begin
        tr = seq_item::type_id::create("tr");
        tr.addr  = vif.HADDR;
        tr.write = vif.HWRITE;
        tr.data  = (vif.HWRITE) ? vif.HWDATA : vif.HRDATA;
        ap.write(tr);
      end
    end
  endtask
endclass