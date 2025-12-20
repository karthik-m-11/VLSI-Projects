// uvm_env/driver.sv
class driver extends uvm_driver #(seq_item);
  `uvm_component_utils(driver)

  virtual axi_if vif;

  function new(string name = "driver", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual axi_if)::get(this, "", "vif", vif))
      `uvm_fatal("NOVIF", "Virtual interface not set for driver")
  endfunction

  task run_phase(uvm_phase phase);
    seq_item req;
    forever begin
      seq_item_port.get_next_item(req);

      if (req.write) begin
        // Write address phase
        vif.AWADDR  <= req.addr;
        vif.AWVALID <= 1'b1;
        @(posedge vif.ACLK);
        while (!vif.AWREADY) @(posedge vif.ACLK);
        vif.AWVALID <= 1'b0;

        // Write data phase
        vif.WDATA   <= req.data;
        vif.WSTRB   <= 4'hF; // full word
        vif.WVALID  <= 1'b1;
        @(posedge vif.ACLK);
        while (!vif.WREADY) @(posedge vif.ACLK);
        vif.WVALID  <= 1'b0;

        // Write response
        vif.BREADY  <= 1'b1;
        @(posedge vif.ACLK);
        while (!vif.BVALID) @(posedge vif.ACLK);
        // Optionally check BRESP
        vif.BREADY  <= 1'b0;
      end else begin
        // Read address phase
        vif.ARADDR  <= req.addr;
        vif.ARVALID <= 1'b1;
        @(posedge vif.ACLK);
        while (!vif.ARREADY) @(posedge vif.ACLK);
        vif.ARVALID <= 1'b0;

        // Read data phase
        vif.RREADY  <= 1'b1;
        @(posedge vif.ACLK);
        while (!vif.RVALID) @(posedge vif.ACLK);
        req.data = vif.RDATA; // capture read data
        vif.RREADY  <= 1'b0;
      end

      seq_item_port.item_done();
    end
  endtask
endclass