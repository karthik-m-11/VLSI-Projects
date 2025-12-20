// uvm_env/monitor.sv
class monitor extends uvm_monitor;
  `uvm_component_utils(monitor)

  virtual apb_if vif;
  uvm_analysis_port #(seq_item) ap;

  function new(string name = "monitor", uvm_component parent = null);
    super.new(name, parent);
    ap = new("ap", this);
  endfunction

  function void build_phase(uvm_phase phase);
    if (!uvm_config_db#(virtual apb_if)::get(this, "", "vif", vif))
      `uvm_fatal("NOVIF", "Virtual interface not set for monitor")
  endfunction

  task run_phase(uvm_phase phase);
    seq_item tr;
    forever begin
      @(posedge vif.PCLK);
      if (vif.PSEL && vif.PENABLE && vif.PREADY) begin
        tr = seq_item::type_id::create("tr");
        tr.addr = vif.PADDR;
        tr.kind = vif.PWRITE ? WRITE : READ;
        tr.data = vif.PWRITE ? vif.PWDATA : vif.PRDATA;
        ap.write(tr);
      end
    end
  endtask
endclass