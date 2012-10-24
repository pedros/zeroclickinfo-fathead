#!/usr/bin/env perl

use strict;
use warnings;
use Text::CSV;
use Spreadsheet::ParseExcel;

my $source = 'https://explore.data.gov/Other/FEMA-Disaster-Declarations-Summary/uihf-be6u';

my $parser = Spreadsheet::ParseExcel->new();
my $workbook = $parser->parse('fema.xls');
if (!defined $workbook) { die $parser->error(), ".\n"; }

my @disasters = ();
my %key = ();

my $worksheet = ($workbook->worksheets())[2];

my ( $row_min, $row_max ) = $worksheet->row_range();
my ( $col_min, $col_max ) = $worksheet->col_range();

for my $row ( $row_min .. $row_max ) {
    next if $row < 2;
    my %disaster = ();
    for my $col ( $col_min .. $col_max ) {
        my $cell = $worksheet->get_cell( $row, $col );
        next unless $cell;
        if ($row == 2) {
            $key{$col} = $cell->value();
        } else {
            $disaster{$key{$col}} = $cell->value();
            if ($key{$col} eq 'Incident Begin Date') {
                ($disaster{'day'}, $disaster{'month'}, $disaster{'year'})
                    = split '/', $cell->value();
            }
        }
    }
    push @disasters, \%disaster unless scalar keys %disaster == 0;
}

open my $output, '>output.txt' or die;

map {
    my %disaster = %{$_};
    print $output join "\t", (
        $disaster{'Disaster Number'},        # title
        "A",                                 # type
        "",                                  # redirect
        "",                                  # otheruses
        "Disasters in $disaster{'year'}",    # categories
        "",                                  # references
        "",                                  # see_also
        "",                                  # further_reading
        "",                                  # external_links
        "",                                  # disambiguation
        "",                                  # images
        (join '<br>', map {
            "<i>$_</i>: $disaster{$_}"
                unless /day|month|year/
        } keys %disaster),                   # abstract
        $source                              # source_url
    );
    print $output "\n";
} @disasters;

close $output;

