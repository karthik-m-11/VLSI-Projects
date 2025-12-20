# scripts/filelist.f
# Compile order: interface -> DUT -> package (includes env/sequences/tests) -> tb_top

# Interface & DUT
../src/apb_if.sv
../src/dut.sv

# Central package (includes env, sequences, tests)
../pkg/uvm_pkg.sv

# Top-level testbench
../src/tb_top.sv