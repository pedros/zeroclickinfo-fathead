#!/usr/bin/env perl

use strict;
use warnings;
use Spreadsheet::ParseExcel;

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
            my $column_title = $cell->value;
            $column_title =~ s/^\s+|\s+$//g;
            print "|$column_title|\n";
            $key{$col} = $column_title;
        } else {
            $disaster{$key{$col}} = $cell->value();
            if ($key{$col} eq 'Incident Begin Date') {
                ($disaster{'start_day'}, $disaster{'start_month'}, $disaster{'start_year'})
                    = split '/', $cell->value();
            }
            if ($key{$col} eq 'Incident End Date') {
                ($disaster{'end_day'}, $disaster{'end_month'}, $disaster{'end_year'})
                    = split '/', $cell->value();
            }
        }
    }
    push @disasters, \%disaster unless scalar keys %disaster == 0;
}

open my $output, '>output.txt' or die;

my %states = (
    'AL' => 'Alabama',
    'AK' => 'Alaska',
    'AZ' => 'Arizona',
    'AR' => 'Arkansas',
    'CA' => 'California',
    'CO' => 'Colorado',
    'CT' => 'Connecticut',
    'DE' => 'Delaware',
    'FL' => 'Florida',
    'GA' => 'Georgia',
    'HI' => 'Hawaii',
    'ID' => 'Idaho',
    'IL' => 'Illinois',
    'IN' => 'Indiana',
    'IA' => 'Iowa',
    'KS' => 'Kansas',
    'KY' => 'Kentucky',
    'LA' => 'Louisiana',
    'ME' => 'Maine',
    'MD' => 'Maryland',
    'MA' => 'Massachusetts',
    'MI' => 'Michigan',
    'MN' => 'Minnesota',
    'MS' => 'Mississippi',
    'MO' => 'Missouri',
    'MT' => 'Montana',
    'NE' => 'Nebraska',
    'NV' => 'Nevada',
    'NH' => 'New Hampshire',
    'NJ' => 'New Jersey',
    'NM' => 'New Mexico',
    'NY' => 'New York',
    'NC' => 'North Carolina',
    'ND' => 'North Dakota',
    'OH' => 'Ohio',
    'OK' => 'Oklahoma',
    'OR' => 'Oregon',
    'PW' => 'Palau',
    'PA' => 'Pennsylvania',
    'PR' => 'Puerto Rico',
    'RI' => 'Rhode Island',
    'SC' => 'South Carolina',
    'SD' => 'South Dakota',
    'TN' => 'Tennessee',
    'TX' => 'Texas',
    'UT' => 'Utah',
    'VT' => 'Vermont',
    'VA' => 'Virginia',
    'WA' => 'Washington',
    'WV' => 'West Virginia',
    'WI' => 'Wisconsin',
    'WY' => 'Wyoming'
);

map {
    my %disaster = %{$_};
    my @duration = ($disaster{'start_year'});
    @duration = ($disaster{'start_year'}..$disaster{'end_year'})
        if $disaster{'end_year'};
    my $categories = join "\\n", map { "Disasters in $_" } @duration;
    my $abstract = "$states{$disaster{'State'}}, $disaster{'Declared County/Area'}: "
                 . "$disaster{'Title'}<br>"
                 . "<i>Duration</i>: $disaster{'Incident Begin Date'} - "
                 . ($disaster{'Incident End Date'} ? "$disaster{'Incident End Date'}"
                    : "Ongoing") . "<br>"
                 . ($disaster{'HM Program Declared'} ?
                    "A Hazard Mitigation program was declared for this disaster. " : "")
                 . ($disaster{'IH Program Declared'} ?
                    "An Individuals and Households program was declared for this disaster ." : "")
                 . ($disaster{'IA Program Declared'} ?
                    "An Individual Assistance program was declared for this disaster. " : "")
                 . ($disaster{'PA Program Declared'} ?
                    "A Public Assistance program was declared for this disaster. " : "")
                 . ($disaster{'Disaster Close Out Date'} ?
                    "All financial transactions were completed on "
                    . "$disaster{'Disaster Close Out Date'}." : "");
    my $source_url = "http://www.fema.gov/disaster/$disaster{'Disaster Number'}";
    print $output join "\t", (
        $disaster{'Disaster Number'},        # title
        "A",                                 # type
        "",                                  # redirect
        "",                                  # otheruses
        $categories,                         # categories
        "",                                  # references
        "",                                  # see_also
        "",                                  # further_reading
        "",                                  # external_links
        "",                                  # disambiguation
        "",                                  # images
        $abstract,                           # abstract
        $source_url                          # source_url
    );
    print $output "\n";
} @disasters;

close $output;

