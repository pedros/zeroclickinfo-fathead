#!/usr/bin/env perl

use strict;
use warnings;
use Text::CSV;

my $source = 'https://explore.data.gov/Other/FEMA-Disaster-Declarations-Summary/uihf-be6u';

my $parser = Text::CSV->new();

open my $csv, '<fema.csv' or die;

my @disasters = ();
my %key = ();
my $i = 0;

while (my $row = $parser->getline($csv)) {
    if ($i == 0) {
        @key{(0..scalar @{$row}-1)} = map {s/\s+$//;$_} @{$row};
        $i = 1; next;
    }
    my $column = 0;
    my @columns = @{$row};
    my %disaster = ();
    foreach(@columns) {
        $disaster{$key{$column}} = $_;
        $column++;
    }
    push @disasters, \%disaster;
}

close $csv;


open my $output, '>output.txt' or die;

map {
    my %disaster = %{$_};
    print $output join "\t", (
        $disaster{'Disaster Number'},        # title
        "A",                                 # type
        "",                                  # redirect
        "",                                  # otheruses
        "FEMA Disasters",                    # categories
        "",                                  # references
        "",                                  # see_also
        "",                                  # further_reading
        "",                                  # external_links
        "",                                  # disambiguation
        "",                                  # images
        (join '<br>', map {
            "<i>$_</i>: $disaster{$_}"
        } keys %disaster),                   # abstract
        $source                              # source_url
    );
    print $output "\n";
} @disasters;

close $output;

