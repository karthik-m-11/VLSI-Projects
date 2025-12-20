// tests/test_random.sv
class test_random extends test_base;
  `uvm_component_utils(test_random)

  function new(string name = "test_random", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);
    phase.raise_objection(this);

    random_seq seq = random_seq::type_id::create("seq");
    seq.start(m_env.m_agent.m_sequencer);

    phase.drop_objection(this);
  endtask
endclass