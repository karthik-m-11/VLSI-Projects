// uvm_env/driver.sv
class driver extends uvm_driver #(seq_item);
  `uvm_component_utils(driver)

  virtual apb_if vif;

  function new(string name = "driver", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    if (!uvm_config_db#(virtual apb_if)::get(this, "", "vif", vif))
      `uvm_fatal("NOVIF", "Virtual interface not set for driver")
  endfunction

  task run_phase(uvm_phase phase);
    seq_item tr;
    forever begin
      seq_item_port.get_next_item(tr);

      // APB protocol: SETUP then ACCESS
      vif.cb_drv.PSEL    <= 1;
      vif.cb_drv.PADDR   <= tr.addr;
      vif.cb_drv.PWRITE  <= (tr.kind == WRITE);
      vif.cb_drv.PWDATA  <= tr.data;
      vif.cb_drv.PENABLE <= 0;
      @(vif.cb_drv);

      vif.cb_drv.PENABLE <= 1;
      do @(vif.cb_drv); while (!vif.cb_drv.PREADY);

      if (tr.kind == READ)
        tr.data = vif.cb_drv.PRDATA;

      vif.cb_drv.PSEL    <= 0;
      vif.cb_drv.PENABLE <= 0;

      seq_item_port.item_done();
    end
  endtask
endclass