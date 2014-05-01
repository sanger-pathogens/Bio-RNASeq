#!/usr/bin/env perl
use strict;
use warnings;
use File::Spec;
use File::Temp qw/ tempdir /;
use Data::Dumper;

BEGIN { unshift( @INC, './lib' ) }

BEGIN {
    use Test::Most;
    use_ok('Bio::RNASeq');
}

my $sequence_filename   = "t/data/647029.pe.markdup.bam";
my $annotation_filename = 't/data/CD630_updated_171212.embl.34.gff';

my %protocols = (
    standard        => 'StandardProtocol',
    strand_specific => 'StrandSpecificProtocol'
);
my %filters = ( mapping_quality => 1 );

for my $protocol ( keys %protocols ) {

    my $tmp_dir =
      File::Temp->newdir( DIR => File::Spec->curdir(), CLEANUP => 1 );
    my $output_base_filename = $tmp_dir . '/_test';

    my @output_filename_extensions =
      qw( .corrected.bam .corrected.bam.bai .expression.csv );

    my $expression_results = Bio::RNASeq->new(
        sequence_filename    => $sequence_filename,
        annotation_filename  => $annotation_filename,
        filters              => \%filters,
        protocol             => $protocols{$protocol},
        output_base_filename => $output_base_filename,
    );
    $expression_results->output_spreadsheet();

    my @headers;
    for my $extension (@output_filename_extensions) {

        my $output_filename = $output_base_filename . $extension;

        #print "$output_filename\n";
        ok( -e $output_filename, "$output_filename exists" );

        if ( $extension eq '.expression.csv' ) {

            open( my $exp_fh, "<", "$output_filename" );
            ok( $exp_fh, 'Valid expression csv file' );

            my @lines_to_test = ( 1, 4, 10, 16, 28, 39, 43, 44 );

            my $counter = 0;
            while ( my $line = <$exp_fh> ) {
                $line =~ s/\n$//;
                my @row = split( ',', $line );

                @headers = @row if $counter == 0;
                for my $header (@headers) {
                    $header =~ s/"//g;
                }

                if ( $counter ~~ @lines_to_test && $protocol eq 'standard' ) {

                    #print "PROTOCOL: $protocol\t LINE: $counter\n ROW: @row\n";

                    test_standard_file( \@row, \@headers, $protocol, $counter );

                }

                if (   $counter ~~ @lines_to_test
                    && $protocol eq 'strand_specific' )
                {

                    #print "PROTOCOL: $protocol\t LINE: $counter\n ROW: @row\n";

                    test_strand_specific_file( \@row, \@headers, $protocol,
                        $counter );

                }

                $counter++;

            }
            close($exp_fh);
        }
    }
}

done_testing();

sub test_standard_file {

    my ( $row, $headers, $protocol, $counter ) = @_;

    if ( $counter == 1 ) {

        ok( $row->[4] == 2,
            "Protocol: $protocol - $headers->[4] - line $counter" );
        ok( $row->[5] == 153.025056705348,
            "Protocol: $protocol - $headers->[5] - line $counter" );
        ok( $row->[6] == 2,
            "Protocol: $protocol - $headers->[6] - line $counter" );
        ok( $row->[7] == 153.025056705348,
            "Protocol: $protocol - $headers->[7] - line $counter" );
        ok( $row->[8] == 4,
            "Protocol: $protocol - $headers->[8] - line $counter" );
        ok( $row->[9] == 306.050113410695,
            "Protocol: $protocol - $headers->[9] - line $counter" );
        ok( $row->[10] == 2,
            "Protocol: $protocol - $headers->[10] - line $counter" );
        ok( $row->[11] == 65167.807103291,
            "Protocol: $protocol - $headers->[11] - line $counter" );
        ok( $row->[12] == 2,
            "Protocol: $protocol - $headers->[12] - line $counter" );
        ok( $row->[13] == 65167.807103291,
            "Protocol: $protocol - $headers->[13] - line $counter" );
        ok( $row->[14] == 22,
            "Protocol: $protocol - $headers->[14] - line $counter" );
        ok( $row->[15] == 130335.614206582,
            "Protocol: $protocol - $headers->[15] - line $counter" );

    }

    if ( $counter == 4 ) {

        ok( $row->[4] == 0,
            "Protocol: $protocol - $headers->[4] - line $counter" );
        ok( $row->[5] == 0,
            "Protocol: $protocol - $headers->[5] - line $counter" );
        ok( $row->[6] == 0,
            "Protocol: $protocol - $headers->[6] - line $counter" );
        ok( $row->[7] == 0,
            "Protocol: $protocol - $headers->[7] - line $counter" );
        ok( $row->[8] == 0,
            "Protocol: $protocol - $headers->[8] - line $counter" );
        ok( $row->[9] == 0,
            "Protocol: $protocol - $headers->[9] - line $counter" );
        ok( $row->[10] == 0,
            "Protocol: $protocol - $headers->[10] - line $counter" );
        ok( $row->[11] == 0,
            "Protocol: $protocol - $headers->[11] - line $counter" );
        ok( $row->[12] == 0,
            "Protocol: $protocol - $headers->[12] - line $counter" );
        ok( $row->[13] == 0,
            "Protocol: $protocol - $headers->[13] - line $counter" );
        ok( $row->[14] == 22,
            "Protocol: $protocol - $headers->[14] - line $counter" );
        ok( $row->[15] == 0,
            "Protocol: $protocol - $headers->[15] - line $counter" );

    }

    if ( $counter == 10 ) {

        ok( $row->[4] == 1,
            "Protocol: $protocol - $headers->[4] - line $counter" );
        ok( $row->[5] == 130.802667955858,
            "Protocol: $protocol - $headers->[5] - line $counter" );
        ok( $row->[6] == 2,
            "Protocol: $protocol - $headers->[6] - line $counter" );
        ok( $row->[7] == 261.605335911716,
            "Protocol: $protocol - $headers->[7] - line $counter" );
        ok( $row->[8] == 3,
            "Protocol: $protocol - $headers->[8] - line $counter" );
        ok( $row->[9] == 392.408003867573,
            "Protocol: $protocol - $headers->[9] - line $counter" );
        ok( $row->[10] == 1,
            "Protocol: $protocol - $headers->[10] - line $counter" );
        ok( $row->[11] == 55704.0998217469,
            "Protocol: $protocol - $headers->[11] - line $counter" );
        ok( $row->[12] == 2,
            "Protocol: $protocol - $headers->[12] - line $counter" );
        ok( $row->[13] == 111408.199643494,
            "Protocol: $protocol - $headers->[13] - line $counter" );
        ok( $row->[14] == 22,
            "Protocol: $protocol - $headers->[14] - line $counter" );
        ok( $row->[15] == 167112.299465241,
            "Protocol: $protocol - $headers->[15] - line $counter" );

    }

    if ( $counter == 16 ) {

        ok( $row->[4] == 2,
            "Protocol: $protocol - $headers->[4] - line $counter" );
        ok( $row->[5] == 635.327244357023,
            "Protocol: $protocol - $headers->[5] - line $counter" );
        ok( $row->[6] == 4,
            "Protocol: $protocol - $headers->[6] - line $counter" );
        ok( $row->[7] == 1270.65448871405,
            "Protocol: $protocol - $headers->[7] - line $counter" );
        ok( $row->[8] == 6,
            "Protocol: $protocol - $headers->[8] - line $counter" );
        ok( $row->[9] == 1905.98173307107,
            "Protocol: $protocol - $headers->[9] - line $counter" );
        ok( $row->[10] == 2,
            "Protocol: $protocol - $headers->[10] - line $counter" );
        ok( $row->[11] == 270562.770562771,
            "Protocol: $protocol - $headers->[11] - line $counter" );
        ok( $row->[12] == 4,
            "Protocol: $protocol - $headers->[12] - line $counter" );
        ok( $row->[13] == 541125.541125541,
            "Protocol: $protocol - $headers->[13] - line $counter" );
        ok( $row->[14] == 22,
            "Protocol: $protocol - $headers->[14] - line $counter" );
        ok( $row->[15] == 811688.311688312,
            "Protocol: $protocol - $headers->[15] - line $counter" );

    }

    if ( $counter == 28 ) {

        ok( $row->[4] == 2,
            "Protocol: $protocol - $headers->[4] - line $counter" );
        ok( $row->[5] == 1016.52359097124,
            "Protocol: $protocol - $headers->[5] - line $counter" );
        ok( $row->[6] == 0,
            "Protocol: $protocol - $headers->[6] - line $counter" );
        ok( $row->[7] == 0,
            "Protocol: $protocol - $headers->[7] - line $counter" );
        ok( $row->[8] == 2,
            "Protocol: $protocol - $headers->[8] - line $counter" );
        ok( $row->[9] == 1016.52359097124,
            "Protocol: $protocol - $headers->[9] - line $counter" );
        ok( $row->[10] == 2,
            "Protocol: $protocol - $headers->[10] - line $counter" );
        ok( $row->[11] == 432900.432900433,
            "Protocol: $protocol - $headers->[11] - line $counter" );
        ok( $row->[12] == 0,
            "Protocol: $protocol - $headers->[12] - line $counter" );
        ok( $row->[13] == 0,
            "Protocol: $protocol - $headers->[13] - line $counter" );
        ok( $row->[14] == 22,
            "Protocol: $protocol - $headers->[14] - line $counter" );
        ok( $row->[15] == 432900.432900433,
            "Protocol: $protocol - $headers->[15] - line $counter" );

    }

    if ( $counter == 39 ) {

        ok( $row->[4] == 1,
            "Protocol: $protocol - $headers->[4] - line $counter" );
        ok( $row->[5] == 90.3003189949069,
            "Protocol: $protocol - $headers->[5] - line $counter" );
        ok( $row->[6] == 0,
            "Protocol: $protocol - $headers->[6] - line $counter" );
        ok( $row->[7] == 0,
            "Protocol: $protocol - $headers->[7] - line $counter" );
        ok( $row->[8] == 1,
            "Protocol: $protocol - $headers->[8] - line $counter" );
        ok( $row->[9] == 90.3003189949069,
            "Protocol: $protocol - $headers->[9] - line $counter" );
        ok( $row->[10] == 1,
            "Protocol: $protocol - $headers->[10] - line $counter" );
        ok( $row->[11] == 38455.6222119674,
            "Protocol: $protocol - $headers->[11] - line $counter" );
        ok( $row->[12] == 0,
            "Protocol: $protocol - $headers->[12] - line $counter" );
        ok( $row->[13] == 0,
            "Protocol: $protocol - $headers->[13] - line $counter" );
        ok( $row->[14] == 22,
            "Protocol: $protocol - $headers->[14] - line $counter" );
        ok( $row->[15] == 38455.6222119674,
            "Protocol: $protocol - $headers->[15] - line $counter" );

    }

    if ( $counter == 43 ) {

        ok( $row->[4] == 1,
            "Protocol: $protocol - $headers->[4] - line $counter" );
        ok( $row->[5] == 408.946272229808,
            "Protocol: $protocol - $headers->[5] - line $counter" );
        ok( $row->[6] == 0,
            "Protocol: $protocol - $headers->[6] - line $counter" );
        ok( $row->[7] == 0,
            "Protocol: $protocol - $headers->[7] - line $counter" );
        ok( $row->[8] == 1,
            "Protocol: $protocol - $headers->[8] - line $counter" );
        ok( $row->[9] == 408.946272229808,
            "Protocol: $protocol - $headers->[9] - line $counter" );
        ok( $row->[10] == 1,
            "Protocol: $protocol - $headers->[10] - line $counter" );
        ok( $row->[11] == 174155.34656914,
            "Protocol: $protocol - $headers->[11] - line $counter" );
        ok( $row->[12] == 0,
            "Protocol: $protocol - $headers->[12] - line $counter" );
        ok( $row->[13] == 0,
            "Protocol: $protocol - $headers->[13] - line $counter" );
        ok( $row->[14] == 22,
            "Protocol: $protocol - $headers->[14] - line $counter" );
        ok( $row->[15] == 174155.34656914,
            "Protocol: $protocol - $headers->[15] - line $counter" );

    }

    if ( $counter == 44 ) {

        ok( $row->[4] == 2,
            "Protocol: $protocol - $headers->[4] - line $counter" );
        ok( $row->[5] == 494.143412277685,
            "Protocol: $protocol - $headers->[5] - line $counter" );
        ok( $row->[6] == 2,
            "Protocol: $protocol - $headers->[6] - line $counter" );
        ok( $row->[7] == 494.143412277685,
            "Protocol: $protocol - $headers->[7] - line $counter" );
        ok( $row->[8] == 4,
            "Protocol: $protocol - $headers->[8] - line $counter" );
        ok( $row->[9] == 988.28682455537,
            "Protocol: $protocol - $headers->[9] - line $counter" );
        ok( $row->[10] == 2,
            "Protocol: $protocol - $headers->[10] - line $counter" );
        ok( $row->[11] == 210437.71043771,
            "Protocol: $protocol - $headers->[11] - line $counter" );
        ok( $row->[12] == 2,
            "Protocol: $protocol - $headers->[12] - line $counter" );
        ok( $row->[13] == 210437.71043771,
            "Protocol: $protocol - $headers->[13] - line $counter" );
        ok( $row->[14] == 22,
            "Protocol: $protocol - $headers->[14] - line $counter" );
        ok( $row->[15] == 420875.420875421,
            "Protocol: $protocol - $headers->[15] - line $counter" );

    }

}

sub test_strand_specific_file {

    my ( $row, $headers, $protocol, $counter ) = @_;

    if ( $counter == 1 ) {

        ok( $row->[4] == 0,
            "Protocol: $protocol - $headers->[4] - line $counter" );
        ok( $row->[5] == 0,
            "Protocol: $protocol - $headers->[5] - line $counter" );
        ok( $row->[6] == 4,
            "Protocol: $protocol - $headers->[6] - line $counter" );
        ok( $row->[7] == 306.050113410695,
            "Protocol: $protocol - $headers->[7] - line $counter" );
        ok( $row->[8] == 4,
            "Protocol: $protocol - $headers->[8] - line $counter" );
        ok( $row->[9] == 306.050113410695,
            "Protocol: $protocol - $headers->[9] - line $counter" );
        ok( $row->[10] == 0,
            "Protocol: $protocol - $headers->[10] - line $counter" );
        ok( $row->[11] == 0,
            "Protocol: $protocol - $headers->[11] - line $counter" );
        ok( $row->[12] == 4,
            "Protocol: $protocol - $headers->[12] - line $counter" );
        ok( $row->[13] == 130335.614206582,
            "Protocol: $protocol - $headers->[13] - line $counter" );
        ok( $row->[14] == 22,
            "Protocol: $protocol - $headers->[14] - line $counter" );
        ok( $row->[15] == 130335.614206582,
            "Protocol: $protocol - $headers->[15] - line $counter" );

    }

    if ( $counter == 4 ) {

        ok( $row->[4] == 0,
            "Protocol: $protocol - $headers->[4] - line $counter" );
        ok( $row->[5] == 0,
            "Protocol: $protocol - $headers->[5] - line $counter" );
        ok( $row->[6] == 0,
            "Protocol: $protocol - $headers->[6] - line $counter" );
        ok( $row->[7] == 0,
            "Protocol: $protocol - $headers->[7] - line $counter" );
        ok( $row->[8] == 0,
            "Protocol: $protocol - $headers->[8] - line $counter" );
        ok( $row->[9] == 0,
            "Protocol: $protocol - $headers->[9] - line $counter" );
        ok( $row->[10] == 0,
            "Protocol: $protocol - $headers->[10] - line $counter" );
        ok( $row->[11] == 0,
            "Protocol: $protocol - $headers->[11] - line $counter" );
        ok( $row->[12] == 0,
            "Protocol: $protocol - $headers->[12] - line $counter" );
        ok( $row->[13] == 0,
            "Protocol: $protocol - $headers->[13] - line $counter" );
        ok( $row->[14] == 22,
            "Protocol: $protocol - $headers->[14] - line $counter" );
        ok( $row->[15] == 0,
            "Protocol: $protocol - $headers->[15] - line $counter" );

    }

    if ( $counter == 10 ) {

        ok( $row->[4] == 0,
            "Protocol: $protocol - $headers->[4] - line $counter" );
        ok( $row->[5] == 0,
            "Protocol: $protocol - $headers->[5] - line $counter" );
        ok( $row->[6] == 3,
            "Protocol: $protocol - $headers->[6] - line $counter" );
        ok( $row->[7] == 392.408003867573,
            "Protocol: $protocol - $headers->[7] - line $counter" );
        ok( $row->[8] == 3,
            "Protocol: $protocol - $headers->[8] - line $counter" );
        ok( $row->[9] == 392.408003867573,
            "Protocol: $protocol - $headers->[9] - line $counter" );
        ok( $row->[10] == 0,
            "Protocol: $protocol - $headers->[10] - line $counter" );
        ok( $row->[11] == 0,
            "Protocol: $protocol - $headers->[11] - line $counter" );
        ok( $row->[12] == 3,
            "Protocol: $protocol - $headers->[12] - line $counter" );
        ok( $row->[13] == 167112.299465241,
            "Protocol: $protocol - $headers->[13] - line $counter" );
        ok( $row->[14] == 22,
            "Protocol: $protocol - $headers->[14] - line $counter" );
        ok( $row->[15] == 167112.299465241,
            "Protocol: $protocol - $headers->[15] - line $counter" );

    }

    if ( $counter == 16 ) {

        ok( $row->[4] == 0,
            "Protocol: $protocol - $headers->[4] - line $counter" );
        ok( $row->[5] == 0,
            "Protocol: $protocol - $headers->[5] - line $counter" );
        ok( $row->[6] == 6,
            "Protocol: $protocol - $headers->[6] - line $counter" );
        ok( $row->[7] == 1905.98173307107,
            "Protocol: $protocol - $headers->[7] - line $counter" );
        ok( $row->[8] == 6,
            "Protocol: $protocol - $headers->[8] - line $counter" );
        ok( $row->[9] == 1905.98173307107,
            "Protocol: $protocol - $headers->[9] - line $counter" );
        ok( $row->[10] == 0,
            "Protocol: $protocol - $headers->[10] - line $counter" );
        ok( $row->[11] == 0,
            "Protocol: $protocol - $headers->[11] - line $counter" );
        ok( $row->[12] == 6,
            "Protocol: $protocol - $headers->[12] - line $counter" );
        ok( $row->[13] == 811688.311688312,
            "Protocol: $protocol - $headers->[13] - line $counter" );
        ok( $row->[14] == 22,
            "Protocol: $protocol - $headers->[14] - line $counter" );
        ok( $row->[15] == 811688.311688312,
            "Protocol: $protocol - $headers->[15] - line $counter" );

    }

    if ( $counter == 28 ) {

        ok( $row->[4] == 0,
            "Protocol: $protocol - $headers->[4] - line $counter" );
        ok( $row->[5] == 0,
            "Protocol: $protocol - $headers->[5] - line $counter" );
        ok( $row->[6] == 2,
            "Protocol: $protocol - $headers->[6] - line $counter" );
        ok( $row->[7] == 1016.52359097124,
            "Protocol: $protocol - $headers->[7] - line $counter" );
        ok( $row->[8] == 2,
            "Protocol: $protocol - $headers->[8] - line $counter" );
        ok( $row->[9] == 1016.52359097124,
            "Protocol: $protocol - $headers->[9] - line $counter" );
        ok( $row->[10] == 0,
            "Protocol: $protocol - $headers->[10] - line $counter" );
        ok( $row->[11] == 0,
            "Protocol: $protocol - $headers->[11] - line $counter" );
        ok( $row->[12] == 2,
            "Protocol: $protocol - $headers->[12] - line $counter" );
        ok( $row->[13] == 432900.432900433,
            "Protocol: $protocol - $headers->[13] - line $counter" );
        ok( $row->[14] == 22,
            "Protocol: $protocol - $headers->[14] - line $counter" );
        ok( $row->[15] == 432900.432900433,
            "Protocol: $protocol - $headers->[15] - line $counter" );

    }

    if ( $counter == 39 ) {

        ok( $row->[4] == 1,
            "Protocol: $protocol - $headers->[4] - line $counter" );
        ok( $row->[5] == 90.3003189949069,
            "Protocol: $protocol - $headers->[5] - line $counter" );
        ok( $row->[6] == 0,
            "Protocol: $protocol - $headers->[6] - line $counter" );
        ok( $row->[7] == 0,
            "Protocol: $protocol - $headers->[7] - line $counter" );
        ok( $row->[8] == 1,
            "Protocol: $protocol - $headers->[8] - line $counter" );
        ok( $row->[9] == 90.3003189949069,
            "Protocol: $protocol - $headers->[9] - line $counter" );
        ok( $row->[10] == 1,
            "Protocol: $protocol - $headers->[10] - line $counter" );
        ok( $row->[11] == 38455.6222119674,
            "Protocol: $protocol - $headers->[11] - line $counter" );
        ok( $row->[12] == 0,
            "Protocol: $protocol - $headers->[12] - line $counter" );
        ok( $row->[13] == 0,
            "Protocol: $protocol - $headers->[13] - line $counter" );
        ok( $row->[14] == 22,
            "Protocol: $protocol - $headers->[14] - line $counter" );
        ok( $row->[15] == 38455.6222119674,
            "Protocol: $protocol - $headers->[15] - line $counter" );

    }

    if ( $counter == 43 ) {

        ok( $row->[4] == 0,
            "Protocol: $protocol - $headers->[4] - line $counter" );
        ok( $row->[5] == 0,
            "Protocol: $protocol - $headers->[5] - line $counter" );
        ok( $row->[6] == 1,
            "Protocol: $protocol - $headers->[6] - line $counter" );
        ok( $row->[7] == 408.946272229808,
            "Protocol: $protocol - $headers->[7] - line $counter" );
        ok( $row->[8] == 1,
            "Protocol: $protocol - $headers->[8] - line $counter" );
        ok( $row->[9] == 408.946272229808,
            "Protocol: $protocol - $headers->[9] - line $counter" );
        ok( $row->[10] == 0,
            "Protocol: $protocol - $headers->[10] - line $counter" );
        ok( $row->[11] == 0,
            "Protocol: $protocol - $headers->[11] - line $counter" );
        ok( $row->[12] == 1,
            "Protocol: $protocol - $headers->[12] - line $counter" );
        ok( $row->[13] == 174155.34656914,
            "Protocol: $protocol - $headers->[13] - line $counter" );
        ok( $row->[14] == 22,
            "Protocol: $protocol - $headers->[14] - line $counter" );
        ok( $row->[15] == 174155.34656914,
            "Protocol: $protocol - $headers->[15] - line $counter" );

    }

    if ( $counter == 44 ) {

        ok( $row->[4] == 0,
            "Protocol: $protocol - $headers->[4] - line $counter" );
        ok( $row->[5] == 0,
            "Protocol: $protocol - $headers->[5] - line $counter" );
        ok( $row->[6] == 4,
            "Protocol: $protocol - $headers->[6] - line $counter" );
        ok( $row->[7] == 988.28682455537,
            "Protocol: $protocol - $headers->[7] - line $counter" );
        ok( $row->[8] == 4,
            "Protocol: $protocol - $headers->[8] - line $counter" );
        ok( $row->[9] == 988.28682455537,
            "Protocol: $protocol - $headers->[9] - line $counter" );
        ok( $row->[10] == 0,
            "Protocol: $protocol - $headers->[10] - line $counter" );
        ok( $row->[11] == 0,
            "Protocol: $protocol - $headers->[11] - line $counter" );
        ok( $row->[12] == 4,
            "Protocol: $protocol - $headers->[12] - line $counter" );
        ok( $row->[13] == 420875.420875421,
            "Protocol: $protocol - $headers->[13] - line $counter" );
        ok( $row->[14] == 22,
            "Protocol: $protocol - $headers->[14] - line $counter" );
        ok( $row->[15] == 420875.420875421,
            "Protocol: $protocol - $headers->[15] - line $counter" );

    }

}

