#!/usr/bin/perl
use strict;
use warnings;

my $type = $ARGV[0] // "";
if ($type ne "sources" && $type ne "sinks") {
    die "Usage: detect-audio.pl <sources|sinks>\n";
}

open(my $fh, "-|", "pactl list short $type") or die "Could not run pactl: $!";

my @devices;
while (my $line = <$fh>) {
    chomp $line;
    my @fields = split(/\t/, $line);
    my $name = $fields[1] // next;

    # Skip monitor sources (they mirror sinks, not real capture devices)
    next if $type eq "sources" && $name =~ /\.monitor$/;

    push @devices, $name;
}
close($fh);

if (@devices == 0) {
    die "No $type found.\n";
}

print STDERR "Available $type:\n";
for my $i (0 .. $#devices) {
    printf STDERR "  [%d] %s\n", $i + 1, $devices[$i];
}
print STDERR "Select device [1]: ";

my $choice = <STDIN>;
chomp $choice if defined $choice;
$choice = 1 if !defined $choice || $choice eq "";

if ($choice < 1 || $choice > scalar @devices) {
    die "Invalid selection.\n";
}

print $devices[$choice - 1];
