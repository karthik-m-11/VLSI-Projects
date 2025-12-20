// tests/test_burst.sv
class test_burst extends test_base;
  `uvm_component_utils(test_burst)

  function new(string name = "test_burst", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);
    phase.raise_objection(this);

    burst_seq seq = burst_seq::type_id::create("seq");
    seq.start(m_env.m_agent.m_sequencer);

    phase.drop_objection(this);
  endtask
endclass