# scripts/run.pl
use strict;
use warnings;

# Usage: perl run.pl regression.cfg
my $cfg = shift @ARGV or die "Usage: perl run.pl <regression.cfg>\n";

open my $fh, "<", $cfg or die "Cannot open $cfg: $!\n";

while (my $line = <$fh>) {
    chomp $line;
    next if $line =~ /^\s*$/;        # skip blank
    next if $line =~ /^\s*#/;        # skip comment

    my ($test, $iters, @opts) = split /\s+/, $line;
    $iters ||= 1;

    for my $i (1..$iters) {
        my $seed = "auto";
        # Allow +SEED=val in options
        for (@opts) {
            if (/^\+SEED=(\w+)/) { $seed = $1; last; }
        }

        my $opt_str = join(" ", @opts);
        print "==> Running $test (iter $i/$iters) seed=$seed opts=[$opt_str]\n";

        # Invoke Makefile target; pass TEST and SEED
        my $cmd = "make run TEST=$test SEED=$seed";
        $cmd .= " DUMP_WAVES=0"; # default off; set 1 if needed

        # You can add verbosity or other flags by mapping @opts here if desired
        system($cmd) == 0 or warn "Failed: $cmd\n";
    }
}
close $fh;