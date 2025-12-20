// tests/test_sanity.sv
class test_sanity extends test_base;
  `uvm_component_utils(test_sanity)

  function new(string name = "test_sanity", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);
    phase.raise_objection(this);

    // Simple write then read
    write_seq wseq = write_seq::type_id::create("wseq");
    wseq.start(m_env.m_agent.m_sequencer);

    read_seq rseq = read_seq::type_id::create("rseq");
    rseq.start(m_env.m_agent.m_sequencer);

    phase.drop_objection(this);
  endtask
endclass