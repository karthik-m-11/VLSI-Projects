// uvm_env/agent.sv
class agent extends uvm_agent;
  `uvm_component_utils(agent)

  driver     m_driver;
  sequencer  m_sequencer;
  monitor    m_monitor;

  virtual pcie_if vif;

  function new(string name = "agent", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    if (!uvm_config_db#(virtual pcie_if)::get(this, "", "vif", vif))
      `uvm_fatal("NOVIF", "Virtual interface not set for agent")

    m_driver    = driver::type_id::create("m_driver", this);
    m_sequencer = sequencer::type_id::create("m_sequencer", this);
    m_monitor   = monitor::type_id::create("m_monitor", this);

    uvm_config_db#(virtual pcie_if)::set(this, "m_driver",  "vif", vif);
    uvm_config_db#(virtual pcie_if)::set(this, "m_monitor", "vif", vif);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    m_driver.seq_item_port.connect(m_sequencer.seq_item_export);
  endfunction
endclass