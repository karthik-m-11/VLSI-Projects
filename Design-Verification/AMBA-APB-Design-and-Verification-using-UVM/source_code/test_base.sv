// tests/test_base.sv
class test_base extends uvm_test;
  `uvm_component_utils(test_base)

  env m_env;

  function new(string name = "test_base", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    m_env = env::type_id::create("m_env", this);
    uvm_config_db#(int)::set(this, "m_env.agent", "is_active", UVM_ACTIVE);
  endfunction

  function void end_of_elaboration_phase(uvm_phase phase);
    uvm_top.print_topology();
  endfunction

  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    // Derived tests override this
    phase.drop_objection(this);
  endtask
endclass