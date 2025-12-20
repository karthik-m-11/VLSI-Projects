// uvm_env/driver.sv
class driver extends uvm_driver #(seq_item);
  `uvm_component_utils(driver)

  virtual eth_if vif;

  function new(string name = "driver", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual eth_if)::get(this, "", "vif", vif))
      `uvm_fatal("NOVIF", "Virtual interface not set for driver")
  endfunction

  task run_phase(uvm_phase phase);
    seq_item req;
    forever begin
      seq_item_port.get_next_item(req);

      // Backpressure: wait until DUT is ready
      int nbytes = req.len;
      for (int i = 0; i < nbytes; i++) begin
        // Wait for ready
        @(posedge vif.ETH_CLK);
        while (!vif.tx_ready) @(posedge vif.ETH_CLK);

        vif.tx_data  <= req.payload[i];
        vif.tx_last  <= (i == nbytes-1);
        vif.tx_valid <= 1'b1;

        @(posedge vif.ETH_CLK);
        // Deassert valid next cycle
        vif.tx_valid <= 1'b0;
        vif.tx_last  <= 1'b0;
      end

      // Optionally accept RX backpressure
      vif.rx_ready <= 1'b1;

      seq_item_port.item_done();
    end
  endtask
endclass