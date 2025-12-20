// tests/test_reset.sv
class test_reset extends test_base;
  `uvm_component_utils(test_reset)

  function new(string name = "test_reset", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);
    phase.raise_objection(this);

    // Reset sequence (can be a simple sequence or handled by driver)
    reset_seq seq = reset_seq::type_id::create("seq");
    seq.start(m_env.m_agent.m_sequencer);

    phase.drop_objection(this);
  endtask
endclass