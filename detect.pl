#!/usr/bin/perl
use strict;
use warnings;

my $max_modes = -1;
my $best_connector = "";

open(my $fh, "-|", "modetest -c") or die "Could not run modetest: $!";

while (my $line = <$fh>) {
    # Captures name ($1) and mode count ($2)
    if ($line =~ /^\d+\s+\d+\s+(?:connected|disconnected)\s+(\S+)\s+\S+\s+(\d+)\s+\d+/) {
        my $name = $1;
        my $modes = $2;

        if ($modes > $max_modes) {
            $max_modes = $modes;
            $best_connector = $name;
        }
    }
}
close($fh);

if ($best_connector ne "") {
    print $best_connector;
}