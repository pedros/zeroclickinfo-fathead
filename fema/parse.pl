#!/usr/bin/perl

use strict;
use warnings;

open my $csv, '<fema.csv' or die;
my $i = 0;
my %key = ();
while (<$csv>) {
    chomp;
    s/"//g;
    if ($i == 0) {
        my @keys = split ',', $_;
        @key{(0..scalar @keys-1)} = map {s/\s+$//;$_} @keys;
        $i++; next;
    }
    my $column = 0;
    foreach(split ',', $_) {
        print "$key{$column}: $_\n";
        $column++;
        $column = 0 if $column == scalar keys %key;
    }
    print "\n";
}
close $csv;

