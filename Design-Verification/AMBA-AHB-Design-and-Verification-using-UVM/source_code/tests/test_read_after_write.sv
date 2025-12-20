// tests/test_read_after_write.sv
class test_read_after_write extends test_base;
  `uvm_component_utils(test_read_after_write)

  function new(string name = "test_read_after_write", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);
    phase.raise_objection(this);

    read_after_write_seq seq = read_after_write_seq::type_id::create("seq");
    seq.start(m_env.m_agent.m_sequencer);

    phase.drop_objection(this);
  endtask
endclass