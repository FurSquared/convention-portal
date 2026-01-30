#!/usr/bin/perl
# Finds a card with an available output profile and activates it.
# Prefers the highest-priority available hdmi stereo profile.
# Falls back to the highest-priority available output profile.
# Prints "card_name\tprofile_name" to STDOUT for the caller to use.
use strict;
use warnings;

open(my $fh, "-|", "pactl list cards") or die "Could not run pactl: $!";

my $card_name = "";
my $in_profiles = 0;

my $best_card = "";
my $best_profile = "";
my $best_priority = -1;

my $hdmi_card = "";
my $hdmi_profile = "";
my $hdmi_priority = -1;

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

    # Profile line format:
    #   output:hdmi-stereo: Digital Stereo (HDMI) Output (sinks: 1, sources: 0, priority: 38668, available: yes)
    # Capture the profile name (everything before the first ": " description)
    if ($in_profiles && $line =~ /^\s*(\S+):\s.*priority:\s*(\d+).*available:\s*(\w+)/) {
        my $profile = $1;
        my $priority = $2;
        my $available = $3;

        next unless $profile =~ /^output:/;
        next unless $available eq "yes";

        # Track best available hdmi-stereo profile
        if ($profile =~ /^output:hdmi-stereo$/ && $priority > $hdmi_priority) {
            $hdmi_priority = $priority;
            $hdmi_profile = $profile;
            $hdmi_card = $card_name;
        }

        # Track best available output profile overall
        if ($priority > $best_priority) {
            $best_priority = $priority;
            $best_profile = $profile;
            $best_card = $card_name;
        }
    }
}
close($fh);

# Prefer hdmi-stereo, fall back to best available
my $use_card = $hdmi_card ne "" ? $hdmi_card : $best_card;
my $use_profile = $hdmi_card ne "" ? $hdmi_profile : $best_profile;

if ($use_card eq "") {
    die "No card with an available output profile found.\n";
}

system("pactl", "set-card-profile", $use_card, $use_profile);
print "$use_card\t$use_profile\n";
