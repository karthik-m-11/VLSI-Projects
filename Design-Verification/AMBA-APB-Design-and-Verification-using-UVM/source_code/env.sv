// uvm_env/env.sv
class env extends uvm_env;
  `uvm_component_utils(env)

  agent       m_agent;
  scoreboard  m_scoreboard;
  coverage    m_coverage;

  function new(string name = "env", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    m_agent      = agent::type_id::create("m_agent", this);
    m_scoreboard = scoreboard::type_id::create("m_scoreboard", this);
    m_coverage   = coverage::type_id::create("m_coverage", this);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    m_agent.m_monitor.ap.connect(m_scoreboard.analysis_export);
    m_agent.m_monitor.ap.connect(m_coverage.analysis_export);
  endfunction
endclass