// tests/test_error.sv
class test_error extends test_base;
  `uvm_component_utils(test_error)

  function new(string name = "test_error", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);
    phase.raise_objection(this);

    error_seq seq = error_seq::type_id::create("seq");
    seq.start(m_env.m_agent.m_sequencer);

    phase.drop_objection(this);
  endtask
endclass