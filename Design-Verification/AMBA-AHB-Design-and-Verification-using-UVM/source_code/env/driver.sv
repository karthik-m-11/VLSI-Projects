// uvm_env/driver.sv
class driver extends uvm_driver #(seq_item);
  `uvm_component_utils(driver)

  virtual ahb_if vif;

  function new(string name = "driver", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual ahb_if)::get(this, "", "vif", vif))
      `uvm_fatal("NOVIF", "Virtual interface not set for driver")
  endfunction

  task run_phase(uvm_phase phase);
    seq_item req;
    forever begin
      seq_item_port.get_next_item(req);

      // Address/control phase
      vif.HTRANS <= 2'b10; // NONSEQ
      vif.HADDR  <= req.addr;
      vif.HWRITE <= req.write;
      vif.HSIZE  <= 3'b010; // word (32-bit)

      // For writes, present data in the data phase (next cycle)
      if (req.write) begin
        @(posedge vif.HCLK);
        vif.HWDATA <= req.data;
        @(posedge vif.HCLK);
      end else begin
        // Reads: sample data in data phase
        @(posedge vif.HCLK);
        @(posedge vif.HCLK);
        req.data = vif.HRDATA;
      end

      // Return to IDLE
      vif.HTRANS <= 2'b00;

      seq_item_port.item_done();
    end
  endtask
endclass