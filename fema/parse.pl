#!/usr/bin/env perl

use strict;
use warnings;
use Text::CSV;

my $parser = Text::CSV->new();

open my $csv, '<fema.csv' or die;

my %key = ();
my $i = 0;

while (my $row = $parser->getline($csv)) {
    if ($i == 0) {
        @key{(0..scalar @{$row}-1)} = map {s/\s+$//;$_} @{$row};
        $i = 1; next;
    }
    my $column = 0;
    my @columns = @{$row};
    foreach(@columns) {
        print "$key{$column}: $_\n";
        $column++;
    }
    print "\n";
}

