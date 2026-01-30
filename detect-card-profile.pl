#!/usr/bin/perl
# Finds a card with an available output profile and activates it.
# Prints "card_name\tprofile_name" to STDOUT for the caller to use.
use strict;
use warnings;

open(my $fh, "-|", "pactl list cards") or die "Could not run pactl: $!";

my $card_name = "";
my $best_card = "";
my $best_profile = "";
my $best_priority = -1;
my $in_profiles = 0;

while (my $line = <$fh>) {
    chomp $line;

    if ($line =~ /^\s*Name:\s*(.+)/) {
        $card_name = $1;
        $in_profiles = 0;
    }

    if ($line =~ /^\s*Profiles:/) {
        $in_profiles = 1;
        next;
    }

    # End of profiles section
    if ($in_profiles && $line =~ /^\s*Active Profile:/) {
        $in_profiles = 0;
        next;
    }

    if ($in_profiles && $line =~ /^\s*(output:\S+):.*priority:\s*(\d+).*available:\s*yes/) {
        my $profile = $1;
        my $priority = $2;
        if ($priority > $best_priority) {
            $best_priority = $priority;
            $best_profile = $profile;
            $best_card = $card_name;
        }
    }
}
close($fh);

if ($best_card eq "") {
    die "No card with an available output profile found.\n";
}

system("pactl", "set-card-profile", $best_card, $best_profile);
print "$best_card\t$best_profile\n";
