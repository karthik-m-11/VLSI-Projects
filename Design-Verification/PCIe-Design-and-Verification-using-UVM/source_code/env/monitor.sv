// uvm_env/monitor.sv
class monitor extends uvm_monitor;
  `uvm_component_utils(monitor)

  virtual pcie_if vif;
  uvm_analysis_port #(seq_item) ap;

  function new(string name = "monitor", uvm_component parent = null);
    super.new(name, parent);
    ap = new("ap", this);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual pcie_if)::get(this, "", "vif", vif))
      `uvm_fatal("NOVIF", "Virtual interface not set for monitor")
  endfunction

  task run_phase(uvm_phase phase);
    seq_item tr;
    forever begin
      @(posedge vif.PCIE_CLK);

      if (vif.req_valid && vif.req_ready) begin
        tr = seq_item::type_id::create("req");
        tr.type   = vif.req_tlp[127:120];
        tr.addr   = vif.req_tlp[119:88];
        tr.len_dw = vif.req_tlp[87:80];
        tr.tag    = vif.req_tlp[79:72];
        tr.data0  = vif.req_tlp[71:40];
        tr.data1  = vif.req_tlp[39:8];
        tr.write  = (tr.type == 8'h00);
        ap.write(tr);
      end

      if (vif.cpl_valid && vif.cpl_ready) begin
        tr = seq_item::type_id::create("cpl");
        tr.cpl_type = vif.cpl_tlp[127:120];
        tr.addr     = vif.cpl_tlp[119:88];
        tr.cpl_len  = vif.cpl_tlp[87:80];
        tr.cpl_tag  = vif.cpl_tlp[79:72];
        tr.cpl_d0   = vif.cpl_tlp[71:40];
        tr.cpl_d1   = vif.cpl_tlp[39:8];
        ap.write(tr);
      end
    end
  endtask
endclass