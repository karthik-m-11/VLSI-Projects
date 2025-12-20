// uvm_env/driver.sv
class driver extends uvm_driver #(seq_item);
  `uvm_component_utils(driver)

  virtual usb_if vif;

  function new(string name = "driver", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual usb_if)::get(this, "", "vif", vif))
      `uvm_fatal("NOVIF", "Virtual interface not set for driver")
  endfunction

  // Helper to push one byte with handshake
  task automatic push_byte(byte b, bit last);
    @(posedge vif.USB_CLK);
    while (!vif.tx_ready) @(posedge vif.USB_CLK);
    vif.tx_byte  <= b;
    vif.tx_last  <= last;
    vif.tx_valid <= 1'b1;
    @(posedge vif.USB_CLK);
    vif.tx_valid <= 1'b0;
    vif.tx_last  <= 1'b0;
  endtask

  // Wait for device response packet (ACK or DATA)
  task automatic wait_device_packet(output byte pid, output byte data_bytes[$]);
    pid = 8'h00;
    data_bytes.delete();
    // Wait for rx_valid burst
    while (!vif.rx_valid) @(posedge vif.USB_CLK);
    // First byte is PID
    pid = vif.rx_byte;
    @(posedge vif.USB_CLK);
    while (vif.rx_valid) begin
      if (!vif.rx_last) data_bytes.push_back(vif.rx_byte);
      @(posedge vif.USB_CLK);
    end
  endtask

  task run_phase(uvm_phase phase);
    seq_item req;
    forever begin
      seq_item_port.get_next_item(req);

      if (req.is_setup) begin
        // SETUP token
        push_byte(8'h2D, 0); // PID_SETUP
        // (Skip addr/endpoint fields for simplicity)
        // DATA0 + 8-byte setup payload
        push_byte(8'hC3, 0); // PID_DATA0
        for (int i=0;i<8;i++) push_byte(req.payload[i], i==7);
        // Expect ACK
        byte pid; byte data_q[$];
        wait_device_packet(pid, data_q);
      end
      else if (req.write) begin
        // OUT token then DATAx payload
        push_byte(8'hE1, 0); // PID_OUT
        push_byte(req.data_pid ? 8'h4B : 8'hC3, 0); // DATA1 or DATA0
        for (int i=0;i<req.len;i++) push_byte(req.payload[i], i==req.len-1);
        // ACK expected
        byte pid; byte data_q[$];
        wait_device_packet(pid, data_q);
      end
      else begin
        // IN token: expect device DATA packet
        push_byte(8'h69, 1); // PID_IN, single-byte token for simplicity
        byte pid; byte data_q[$];
        wait_device_packet(pid, data_q);
        // Capture read back into req
        req.resp_pid   = pid;
        req.resp_bytes = data_q;
      end

      seq_item_port.item_done();
    end
  endtask
endclass