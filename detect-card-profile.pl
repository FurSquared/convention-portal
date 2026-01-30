#!/usr/bin/perl
# Finds a card with an available output profile and activates it.
# Polls up to 10 seconds for an hdmi profile to become available.
# Prints "card_name\tprofile_name" to STDOUT for the caller to use.
use strict;
use warnings;

sub scan_profiles {
    open(my $fh, "-|", "pactl list cards") or die "Could not run pactl: $!";

    my $card_name = "";
    my $best_card = "";
    my $best_profile = "";
    my $best_priority = -1;
    my $has_hdmi = 0;
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

        if ($in_profiles && $line =~ /^\s*Active Profile:/) {
            $in_profiles = 0;
            next;
        }

        if ($in_profiles && $line =~ /^\s*(output:\S+):.*priority:\s*(\d+).*available:\s*yes/) {
            my $profile = $1;
            my $priority = $2;
            $has_hdmi = 1 if $profile =~ /hdmi/;
            if ($priority > $best_priority) {
                $best_priority = $priority;
                $best_profile = $profile;
                $best_card = $card_name;
            }
        }
    }
    close($fh);

    return ($best_card, $best_profile, $has_hdmi);
}

# Poll up to 10 seconds for an HDMI profile to become available
my ($best_card, $best_profile, $has_hdmi);
for my $attempt (1..20) {
    ($best_card, $best_profile, $has_hdmi) = scan_profiles();
    last if $has_hdmi;
    select(undef, undef, undef, 0.5);
}

if ($best_card eq "") {
    die "No card with an available output profile found.\n";
}

system("pactl", "set-card-profile", $best_card, $best_profile);
print "$best_card\t$best_profile\n";
