// uvm_env/driver.sv
class driver extends uvm_driver #(seq_item);
  `uvm_component_utils(driver)

  virtual pcie_if vif;

  localparam byte TLP_MWR = 8'h00;
  localparam byte TLP_MRD = 8'h01;

  function new(string name = "driver", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual pcie_if)::get(this, "", "vif", vif))
      `uvm_fatal("NOVIF", "Virtual interface not set for driver")
  endfunction

  task automatic send_req_tlp(bit [127:0] tlp);
    @(posedge vif.PCIE_CLK);
    while (!vif.req_ready) @(posedge vif.PCIE_CLK);
    vif.req_tlp  <= tlp;
    vif.req_valid<= 1'b1;
    @(posedge vif.PCIE_CLK);
    vif.req_valid<= 1'b0;
  endtask

  task automatic wait_completion(output bit [127:0] cpl);
    cpl = '0;
    @(posedge vif.PCIE_CLK);
    while (!vif.cpl_valid) @(posedge vif.PCIE_CLK);
    cpl = vif.cpl_tlp;
    // acknowledge
    vif.cpl_ready <= 1'b1;
    @(posedge vif.PCIE_CLK);
    vif.cpl_ready <= 1'b0;
  endtask

  task run_phase(uvm_phase phase);
    seq_item req;
    forever begin
      seq_item_port.get_next_item(req);

      bit [127:0] tlp;
      // Pack request TLP
      // {type, addr, len_dw, tag, data0, data1, 8'h00}
      tlp = { (req.write ? TLP_MWR : TLP_MRD),
              req.addr, req.len_dw[7:0], req.tag[7:0],
              req.data0, req.data1, 8'h00 };

      // Send request
      send_req_tlp(tlp);

      // If read, wait for completion and capture data
      if (!req.write) begin
        bit [127:0] cpl;
        wait_completion(cpl);
        req.cpl_type = cpl[127:120];      // expect 0x10
        req.cpl_len  = cpl[87:80];
        req.cpl_tag  = cpl[79:72];
        req.cpl_d0   = cpl[71:40];
        req.cpl_d1   = cpl[39:8];
      end

      seq_item_port.item_done();
    end
  endtask
endclass