// tests/test_read.sv
class test_read extends test_base;
  `uvm_component_utils(test_read)

  function new(string name = "test_read", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);
    phase.raise_objection(this);

    read_seq seq = read_seq::type_id::create("seq");
    seq.start(m_env.m_agent.m_sequencer);

    phase.drop_objection(this);
  endtask
endclass