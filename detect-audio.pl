#!/usr/bin/perl
use strict;
use warnings;

my $type = $ARGV[0] // "";
if ($type ne "sources" && $type ne "sinks") {
    die "Usage: detect-audio.pl <sources|sinks>\n";
}

sub scan_devices {
    open(my $fh, "-|", "pactl list short $type") or die "Could not run pactl: $!";
    my @devs;
    while (my $line = <$fh>) {
        chomp $line;
        my @fields = split(/\t/, $line);
        my $name = $fields[1] // next;
        next if $type eq "sources" && $name =~ /\.monitor$/;
        push @devs, $name;
    }
    close($fh);
    return @devs;
}

# Poll up to 5 seconds for echo-cancel devices to appear
my @devices;
my $has_ec = 0;
for my $attempt (1..10) {
    @devices = scan_devices();
    if (grep { /echo-cancel/ } @devices) {
        $has_ec = 1;
        last;
    }
    select(undef, undef, undef, 0.5);
}

if (@devices == 0) {
    die "No $type found.\n";
}

my $default = 1;
for my $i (0 .. $#devices) {
    if ($devices[$i] =~ /echo-cancel/) {
        $default = $i + 1;
        last;
    }
}

print STDERR "Available $type:\n";
for my $i (0 .. $#devices) {
    printf STDERR "  [%d] %s\n", $i + 1, $devices[$i];
}
print STDERR "Select device [$default]: ";

my $choice = <STDIN>;
chomp $choice if defined $choice;
$choice = $default if !defined $choice || $choice eq "";

if ($choice < 1 || $choice > scalar @devices) {
    die "Invalid selection.\n";
}

print $devices[$choice - 1];
