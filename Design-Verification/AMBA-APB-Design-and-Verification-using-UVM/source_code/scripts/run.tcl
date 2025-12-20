# scripts/run.tcl
# Args: <test> <seed> <cov_enable> <ucdb_out>
# Example: vsim -c tb_top -do "run.tcl test_read 123 1 ../reports/test_read.ucdb"

proc getarg {index default} {
    if {$index < [llength $::argv]} {
        return [lindex $::argv $index]
    } else {
        return $default
    }
}

set test    [getarg 0 "test_sanity"]
set seed    [getarg 1 "auto"]
set cov_en  [getarg 2 "1"]
set ucdb    [getarg 3 "../reports/${test}.ucdb"]

# Set UVM test and seed
if {$seed eq "auto"} {
    set randseed "auto"
} else {
    set randseed $seed
}
puts "UVM test: $test  seed: $randseed  coverage: $cov_en  ucdb: $ucdb"

# Enable coverage if requested
if {$cov_en eq "1"} {
    set CoverageOptions "-coverage"
} else {
    set CoverageOptions ""
}

# Elaborate with coverage if enabled
eval "vsim $CoverageOptions -quiet -t ps $::TOP"

# Propagate runtime plusargs
set Plusargs "+UVM_TESTNAME=$test +ntb_random_seed=$randseed"

# Run simulation to completion
run -all $Plusargs

# Save coverage database if enabled
if {$cov_en eq "1"} {
    coverage save $ucdb
}

quit -f