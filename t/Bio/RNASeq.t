#!/usr/bin/env perl
use strict;
use warnings;
use File::Spec;
use File::Temp qw/ tempdir /;
use Data::Dumper;


BEGIN { unshift(@INC, './lib') }
BEGIN {
         use Test::Most;
	 use_ok('Bio::RNASeq');
       }

my @tmrm = qw(default a);

for my $total_mapped_reads_method ( @tmrm ) {

  my $sequence_filename ="t/data/647029.pe.markdup.bam";
  my $annotation_filename = 't/data/CD630_updated_171212.embl.34.gff';

  my %protocols = ( standard => 'StandardProtocol', strand_specific => 'StrandSpecificProtocol' );
  my %filters = ( mapping_quality => 1 );


  my $tmp_dir = File::Temp->newdir( DIR => File::Spec->curdir() );
  my $output_base_filename = $tmp_dir . '/_test';

  my @output_filename_extensions = qw( .corrected.bam .corrected.bam.bai .expression.csv );

  for my $protocol( keys %protocols ) {

    my $expression_results = Bio::RNASeq->new(
							  sequence_filename    => $sequence_filename,
							  annotation_filename  => $annotation_filename,
							  filters              => \%filters,
							  protocol             => $protocols{$protocol},
							  output_base_filename => $output_base_filename,
							  total_mapped_reads_method   => $total_mapped_reads_method
							 );

    $expression_results->output_spreadsheet();


    my @headers;
    for my $extension ( @output_filename_extensions ) {

      my $output_filename = $output_base_filename . $extension;
      #print "$output_filename\n";
      ok ( -e $output_filename , "$output_filename exists");

      if ( $extension eq '.expression.csv' ) {

	open(my $exp_fh, "<", "$output_filename");
	ok ( $exp_fh, 'Valid expression csv file');

	my @lines_to_test = (1,4,10,16,28,39,43,44);

	my $counter = 0;
	while (my $line = <$exp_fh>) {
	  $line =~ s/\n$//;
	  my @row = split(',',$line);

	  @headers = @row if $counter == 0;
	  for my $header(@headers) {
	    $header =~ s/"//g;
	  }

	  if ( $counter ~~ @lines_to_test && $protocol eq 'standard' ) {

	    #print "PROTOCOL: $protocol\t METHOD: $total_mapped_reads_method\t LINE: $counter\n ROW: @row\n";
	    test_standard_file( \@row, \@headers, $protocol, $total_mapped_reads_method, $counter );

	  }

	  if ( $counter ~~ @lines_to_test && $protocol eq 'strand_specific' ) {

	    #print "PROTOCOL: $protocol\t METHOD: $total_mapped_reads_method\t LINE: $counter\n ROW: @row\n";
	    test_strand_specific_file( \@row, \@headers, $protocol, $total_mapped_reads_method, $counter );

	  }

	  $counter++;

	}
	close($exp_fh);
      }
    }
  }
}

done_testing();

sub test_standard_file {

  my ( $row, $headers, $protocol, $total_mapped_reads_method, $counter ) = @_;

  if ( $counter == 1 ) {

    if ( $total_mapped_reads_method eq 'default') {

      ok( $row->[4] == 2, "Protocol: $protocol - Method: $total_mapped_reads_method - $headers->[4] - line $counter" );
      ok( $row->[5] == 153.025056705348, "Protocol: $protocol - Method: $total_mapped_reads_method - $headers->[5] - line $counter" );
      ok( $row->[6] == 2, "Protocol: $protocol - Method: $total_mapped_reads_method - $headers->[6] - line $counter" );
      ok( $row->[7] == 153.025056705348, "Protocol: $protocol - Method: $total_mapped_reads_method - $headers->[7] - line $counter" );
      ok( $row->[8] == 4, "Protocol: $protocol - Method: $total_mapped_reads_method - $headers->[8] - line $counter" );
      ok( $row->[9] == 306.050113410695, "Protocol: $protocol - Method: $total_mapped_reads_method - $headers->[9] - line $counter" );

    } elsif ( $total_mapped_reads_method eq 'a') {

      ok( $row->[4] == 2, "Protocol: $protocol - Method: $total_mapped_reads_method - $headers->[4] - line $counter" );
      ok( $row->[5] == 65167.807103291, "Protocol: $protocol - Method: $total_mapped_reads_method - $headers->[5] - line $counter" );
      ok( $row->[6] == 2, "Protocol: $protocol - Method: $total_mapped_reads_method - $headers->[6] - line $counter" );
      ok( $row->[7] == 65167.807103291, "Protocol: $protocol - Method: $total_mapped_reads_method - $headers->[7] - line $counter" );
      ok( $row->[8] == 22, "Protocol: $protocol - Method: $total_mapped_reads_method - $headers->[8] - line $counter" );
      ok( $row->[9] == 130335.614206582, "Protocol: $protocol - Method: $total_mapped_reads_method - $headers->[9] - line $counter" );

    }
  }

  if ( $counter == 4 ) {

    if ( $total_mapped_reads_method eq 'default' ) {

      ok( $row->[4] == 0, "Protocol: $protocol - Method: $total_mapped_reads_method - $headers->[4] - line $counter" );
      ok( $row->[5] == 0, "Protocol: $protocol - Method: $total_mapped_reads_method - $headers->[5] - line $counter" );
      ok( $row->[6] == 0, "Protocol: $protocol - Method: $total_mapped_reads_method - $headers->[6] - line $counter" );
      ok( $row->[7] == 0, "Protocol: $protocol - Method: $total_mapped_reads_method - $headers->[7] - line $counter" );
      ok( $row->[8] == 0, "Protocol: $protocol - Method: $total_mapped_reads_method - $headers->[8] - line $counter" );
      ok( $row->[9] == 0, "Protocol: $protocol - Method: $total_mapped_reads_method - $headers->[9] - line $counter" );

    } elsif ( $total_mapped_reads_method eq 'a' ) {

      ok( $row->[4] == 0, "Protocol: $protocol - Method: $total_mapped_reads_method - $headers->[4] - line $counter" );
      ok( $row->[5] == 0, "Protocol: $protocol - Method: $total_mapped_reads_method - $headers->[5] - line $counter" );
      ok( $row->[6] == 0, "Protocol: $protocol - Method: $total_mapped_reads_method - $headers->[6] - line $counter" );
      ok( $row->[7] == 0, "Protocol: $protocol - Method: $total_mapped_reads_method - $headers->[7] - line $counter" );
      ok( $row->[8] == 22, "Protocol: $protocol - Method: $total_mapped_reads_method - $headers->[8] - line $counter" );
      ok( $row->[9] == 0, "Protocol: $protocol - Method: $total_mapped_reads_method - $headers->[9] - line $counter" );

    }
  }

  if ( $counter == 10 ) {

    if ( $total_mapped_reads_method eq 'default' ) {

      ok( $row->[4] == 1, "Protocol: $protocol - Method: $total_mapped_reads_method - $headers->[4] - line $counter" );
      ok( $row->[5] == 130.802667955858, "Protocol: $protocol - Method: $total_mapped_reads_method - $headers->[5] - line $counter" );
      ok( $row->[6] == 2, "Protocol: $protocol - Method: $total_mapped_reads_method - $headers->[6] - line $counter" );
      ok( $row->[7] == 261.605335911716, "Protocol: $protocol - Method: $total_mapped_reads_method - $headers->[7] - line $counter" );
      ok( $row->[8] == 3, "Protocol: $protocol - Method: $total_mapped_reads_method - $headers->[8] - line $counter" );
      ok( $row->[9] == 392.408003867573, "Protocol: $protocol - Method: $total_mapped_reads_method - $headers->[9] - line $counter" );

    } elsif ( $total_mapped_reads_method eq 'a' ) {

      ok( $row->[4] == 1, "Protocol: $protocol - Method: $total_mapped_reads_method - $headers->[4] - line $counter" );
      ok( $row->[5] == 55704.0998217469, "Protocol: $protocol - Method: $total_mapped_reads_method - $headers->[5] - line $counter" );
      ok( $row->[6] == 2, "Protocol: $protocol - Method: $total_mapped_reads_method - $headers->[6] - line $counter" );
      ok( $row->[7] == 111408.199643494, "Protocol: $protocol - Method: $total_mapped_reads_method - $headers->[7] - line $counter" );
      ok( $row->[8] == 22, "Protocol: $protocol - Method: $total_mapped_reads_method - $headers->[8] - line $counter" );
      ok( $row->[9] == 167112.299465241, "Protocol: $protocol - Method: $total_mapped_reads_method - $headers->[9] - line $counter" );

    }
  }

  if ( $counter == 16 ) {

    if ( $total_mapped_reads_method eq 'default' ) {

      ok( $row->[4] == 2, "Protocol: $protocol - Method: $total_mapped_reads_method - $headers->[4] - line $counter" );
      ok( $row->[5] == 635.327244357023, "Protocol: $protocol - Method: $total_mapped_reads_method - $headers->[5] - line $counter" );
      ok( $row->[6] == 4, "Protocol: $protocol - Method: $total_mapped_reads_method - $headers->[6] - line $counter" );
      ok( $row->[7] == 1270.65448871405, "Protocol: $protocol - Method: $total_mapped_reads_method - $headers->[7] - line $counter" );
      ok( $row->[8] == 6, "Protocol: $protocol - Method: $total_mapped_reads_method - $headers->[8] - line $counter" );
      ok( $row->[9] == 1905.98173307107, "Protocol: $protocol - Method: $total_mapped_reads_method - $headers->[9] - line $counter" );

    } elsif ( $total_mapped_reads_method eq 'a' ) {

      ok( $row->[4] == 2, "Protocol: $protocol - Method: $total_mapped_reads_method - $headers->[4] - line $counter" );
      ok( $row->[5] == 270562.770562771, "Protocol: $protocol - Method: $total_mapped_reads_method - $headers->[5] - line $counter" );
      ok( $row->[6] == 4, "Protocol: $protocol - Method: $total_mapped_reads_method - $headers->[6] - line $counter" );
      ok( $row->[7] == 541125.541125541, "Protocol: $protocol - Method: $total_mapped_reads_method - $headers->[7] - line $counter" );
      ok( $row->[8] == 22, "Protocol: $protocol - Method: $total_mapped_reads_method - $headers->[8] - line $counter" );
      ok( $row->[9] == 811688.311688312, "Protocol: $protocol - Method: $total_mapped_reads_method - $headers->[9] - line $counter" );

    }
  }

  if ( $counter == 28 ) {

    if ( $total_mapped_reads_method eq 'default' ) {

      ok( $row->[4] == 2, "Protocol: $protocol - Method: $total_mapped_reads_method - $headers->[4] - line $counter" );
      ok( $row->[5] == 1016.52359097124, "Protocol: $protocol - Method: $total_mapped_reads_method - $headers->[5] - line $counter" );
      ok( $row->[6] == 0, "Protocol: $protocol - Method: $total_mapped_reads_method - $headers->[6] - line $counter" );
      ok( $row->[7] == 0, "Protocol: $protocol - Method: $total_mapped_reads_method - $headers->[7] - line $counter" );
      ok( $row->[8] == 2, "Protocol: $protocol - Method: $total_mapped_reads_method - $headers->[8] - line $counter" );
      ok( $row->[9] == 1016.52359097124, "Protocol: $protocol - Method: $total_mapped_reads_method - $headers->[9] - line $counter" );

    } elsif ( $total_mapped_reads_method eq 'a' ) {

      ok( $row->[4] == 2, "Protocol: $protocol - Method: $total_mapped_reads_method - $headers->[4] - line $counter" );
      ok( $row->[5] == 432900.432900433, "Protocol: $protocol - Method: $total_mapped_reads_method - $headers->[5] - line $counter" );
      ok( $row->[6] == 0, "Protocol: $protocol - Method: $total_mapped_reads_method - $headers->[6] - line $counter" );
      ok( $row->[7] == 0, "Protocol: $protocol - Method: $total_mapped_reads_method - $headers->[7] - line $counter" );
      ok( $row->[8] == 22, "Protocol: $protocol - Method: $total_mapped_reads_method - $headers->[8] - line $counter" );
      ok( $row->[9] == 432900.432900433, "Protocol: $protocol - Method: $total_mapped_reads_method - $headers->[9] - line $counter" );

    }
  }

  if ( $counter == 39 ) {

    if ( $total_mapped_reads_method eq 'default' ) {

      ok( $row->[4] == 1, "Protocol: $protocol - Method: $total_mapped_reads_method - $headers->[4] - line $counter" );
      ok( $row->[5] == 90.3003189949069, "Protocol: $protocol - Method: $total_mapped_reads_method - $headers->[5] - line $counter" );
      ok( $row->[6] == 0, "Protocol: $protocol - Method: $total_mapped_reads_method - $headers->[6] - line $counter" );
      ok( $row->[7] == 0, "Protocol: $protocol - Method: $total_mapped_reads_method - $headers->[7] - line $counter" );
      ok( $row->[8] == 1, "Protocol: $protocol - Method: $total_mapped_reads_method - $headers->[8] - line $counter" );
      ok( $row->[9] == 90.3003189949069, "Protocol: $protocol - Method: $total_mapped_reads_method - $headers->[9] - line $counter" );

    } elsif ( $total_mapped_reads_method eq 'a' ) {

      ok( $row->[4] == 1, "Protocol: $protocol - Method: $total_mapped_reads_method - $headers->[4] - line $counter" );
      ok( $row->[5] == 38455.6222119674, "Protocol: $protocol - Method: $total_mapped_reads_method - $headers->[5] - line $counter" );
      ok( $row->[6] == 0, "Protocol: $protocol - Method: $total_mapped_reads_method - $headers->[6] - line $counter" );
      ok( $row->[7] == 0, "Protocol: $protocol - Method: $total_mapped_reads_method - $headers->[7] - line $counter" );
      ok( $row->[8] == 22, "Protocol: $protocol - Method: $total_mapped_reads_method - $headers->[8] - line $counter" );
      ok( $row->[9] == 38455.6222119674, "Protocol: $protocol - Method: $total_mapped_reads_method - $headers->[9] - line $counter" );

    }
  }

  if ( $counter == 43 ) {

    if ( $total_mapped_reads_method eq 'default' ) {

      ok( $row->[4] == 1, "Protocol: $protocol - Method: $total_mapped_reads_method - $headers->[4] - line $counter" );
      ok( $row->[5] == 408.946272229808, "Protocol: $protocol - Method: $total_mapped_reads_method - $headers->[5] - line $counter" );
      ok( $row->[6] == 0, "Protocol: $protocol - Method: $total_mapped_reads_method - $headers->[6] - line $counter" );
      ok( $row->[7] == 0, "Protocol: $protocol - Method: $total_mapped_reads_method - $headers->[7] - line $counter" );
      ok( $row->[8] == 1, "Protocol: $protocol - Method: $total_mapped_reads_method - $headers->[8] - line $counter" );
      ok( $row->[9] == 408.946272229808, "Protocol: $protocol - Method: $total_mapped_reads_method - $headers->[9] - line $counter" );

    } elsif ( $total_mapped_reads_method eq 'a' ) {

      ok( $row->[4] == 1, "Protocol: $protocol - Method: $total_mapped_reads_method - $headers->[4] - line $counter" );
      ok( $row->[5] == 174155.34656914, "Protocol: $protocol - Method: $total_mapped_reads_method - $headers->[5] - line $counter" );
      ok( $row->[6] == 0, "Protocol: $protocol - Method: $total_mapped_reads_method - $headers->[6] - line $counter" );
      ok( $row->[7] == 0, "Protocol: $protocol - Method: $total_mapped_reads_method - $headers->[7] - line $counter" );
      ok( $row->[8] == 22, "Protocol: $protocol - Method: $total_mapped_reads_method - $headers->[8] - line $counter" );
      ok( $row->[9] == 174155.34656914, "Protocol: $protocol - Method: $total_mapped_reads_method - $headers->[9] - line $counter" );

    }
  }

  if ( $counter == 44 ) {

    if ( $total_mapped_reads_method eq 'default' ) {

      ok( $row->[4] == 2, "Protocol: $protocol - Method: $total_mapped_reads_method - $headers->[4] - line $counter" );
      ok( $row->[5] == 494.143412277685, "Protocol: $protocol - Method: $total_mapped_reads_method - $headers->[5] - line $counter" );
      ok( $row->[6] == 2, "Protocol: $protocol - Method: $total_mapped_reads_method - $headers->[6] - line $counter" );
      ok( $row->[7] == 494.143412277685, "Protocol: $protocol - Method: $total_mapped_reads_method - $headers->[7] - line $counter" );
      ok( $row->[8] == 4, "Protocol: $protocol - Method: $total_mapped_reads_method - $headers->[8] - line $counter" );
      ok( $row->[9] == 988.28682455537, "Protocol: $protocol - Method: $total_mapped_reads_method - $headers->[9] - line $counter" );

    } elsif ( $total_mapped_reads_method eq 'a' ) {

      ok( $row->[4] == 2, "Protocol: $protocol - Method: $total_mapped_reads_method - $headers->[4] - line $counter" );
      ok( $row->[5] == 210437.71043771, "Protocol: $protocol - Method: $total_mapped_reads_method - $headers->[5] - line $counter" );
      ok( $row->[6] == 2, "Protocol: $protocol - Method: $total_mapped_reads_method - $headers->[6] - line $counter" );
      ok( $row->[7] == 210437.71043771, "Protocol: $protocol - Method: $total_mapped_reads_method - $headers->[7] - line $counter" );
      ok( $row->[8] == 22, "Protocol: $protocol - Method: $total_mapped_reads_method - $headers->[8] - line $counter" );
      ok( $row->[9] == 420875.420875421, "Protocol: $protocol - Method: $total_mapped_reads_method - $headers->[9] - line $counter" );

    }
  }


}

sub test_strand_specific_file {

  my ( $row, $headers, $protocol, $total_mapped_reads_method, $counter ) = @_;

  if ( $counter == 1 ) {

    if ( $total_mapped_reads_method eq 'default' ) {

      ok( $row->[4] == 0, "Protocol: $protocol - Method: $total_mapped_reads_method - $headers->[4] - line $counter" );
      ok( $row->[5] == 0, "Protocol: $protocol - Method: $total_mapped_reads_method - $headers->[5] - line $counter" );
      ok( $row->[6] == 4, "Protocol: $protocol - Method: $total_mapped_reads_method - $headers->[6] - line $counter" );
      ok( $row->[7] == 306.050113410695, "Protocol: $protocol - Method: $total_mapped_reads_method - $headers->[7] - line $counter" );
      ok( $row->[8] == 4, "Protocol: $protocol - Method: $total_mapped_reads_method - $headers->[8] - line $counter" );
      ok( $row->[9] == 306.050113410695, "Protocol: $protocol - Method: $total_mapped_reads_method - $headers->[9] - line $counter" );

    } elsif ( $total_mapped_reads_method eq 'a' ) {

      ok( $row->[4] == 0, "Protocol: $protocol - Method: $total_mapped_reads_method - $headers->[4] - line $counter" );
      ok( $row->[5] == 0, "Protocol: $protocol - Method: $total_mapped_reads_method - $headers->[5] - line $counter" );
      ok( $row->[6] == 4, "Protocol: $protocol - Method: $total_mapped_reads_method - $headers->[6] - line $counter" );
      ok( $row->[7] == 130335.614206582, "Protocol: $protocol - Method: $total_mapped_reads_method - $headers->[7] - line $counter" );
      ok( $row->[8] == 22, "Protocol: $protocol - Method: $total_mapped_reads_method - $headers->[8] - line $counter" );
      ok( $row->[9] == 130335.614206582, "Protocol: $protocol - Method: $total_mapped_reads_method - $headers->[9] - line $counter" );

    }
  }

  if ( $counter == 4 ) {

    if ( $total_mapped_reads_method eq 'default' ) {

      ok( $row->[4] == 0, "Protocol: $protocol - Method: $total_mapped_reads_method - $headers->[4] - line $counter" );
      ok( $row->[5] == 0, "Protocol: $protocol - Method: $total_mapped_reads_method - $headers->[5] - line $counter" );
      ok( $row->[6] == 0, "Protocol: $protocol - Method: $total_mapped_reads_method - $headers->[6] - line $counter" );
      ok( $row->[7] == 0, "Protocol: $protocol - Method: $total_mapped_reads_method - $headers->[7] - line $counter" );
      ok( $row->[8] == 0, "Protocol: $protocol - Method: $total_mapped_reads_method - $headers->[8] - line $counter" );
      ok( $row->[9] == 0, "Protocol: $protocol - Method: $total_mapped_reads_method - $headers->[9] - line $counter" );

    } elsif ( $total_mapped_reads_method eq 'a' ) {

      ok( $row->[4] == 0, "Protocol: $protocol - Method: $total_mapped_reads_method - $headers->[4] - line $counter" );
      ok( $row->[5] == 0, "Protocol: $protocol - Method: $total_mapped_reads_method - $headers->[5] - line $counter" );
      ok( $row->[6] == 0, "Protocol: $protocol - Method: $total_mapped_reads_method - $headers->[6] - line $counter" );
      ok( $row->[7] == 0, "Protocol: $protocol - Method: $total_mapped_reads_method - $headers->[7] - line $counter" );
      ok( $row->[8] == 22, "Protocol: $protocol - Method: $total_mapped_reads_method - $headers->[8] - line $counter" );
      ok( $row->[9] == 0, "Protocol: $protocol - Method: $total_mapped_reads_method - $headers->[9] - line $counter" );

    }
  }

  if ( $counter == 10 ) {

    if ( $total_mapped_reads_method eq 'default' ) {

      ok( $row->[4] == 0, "Protocol: $protocol - Method: $total_mapped_reads_method - $headers->[4] - line $counter" );
      ok( $row->[5] == 0, "Protocol: $protocol - Method: $total_mapped_reads_method - $headers->[5] - line $counter" );
      ok( $row->[6] == 3, "Protocol: $protocol - Method: $total_mapped_reads_method - $headers->[6] - line $counter" );
      ok( $row->[7] == 392.408003867573, "Protocol: $protocol - Method: $total_mapped_reads_method - $headers->[7] - line $counter" );
      ok( $row->[8] == 3, "Protocol: $protocol - Method: $total_mapped_reads_method - $headers->[8] - line $counter" );
      ok( $row->[9] == 392.408003867573, "Protocol: $protocol - Method: $total_mapped_reads_method - $headers->[9] - line $counter" );

    } elsif ( $total_mapped_reads_method eq 'a' ) {

      ok( $row->[4] == 0, "Protocol: $protocol - Method: $total_mapped_reads_method - $headers->[4] - line $counter" );
      ok( $row->[5] == 0, "Protocol: $protocol - Method: $total_mapped_reads_method - $headers->[5] - line $counter" );
      ok( $row->[6] == 3, "Protocol: $protocol - Method: $total_mapped_reads_method - $headers->[6] - line $counter" );
      ok( $row->[7] == 167112.299465241, "Protocol: $protocol - Method: $total_mapped_reads_method - $headers->[7] - line $counter" );
      ok( $row->[8] == 22, "Protocol: $protocol - Method: $total_mapped_reads_method - $headers->[8] - line $counter" );
      ok( $row->[9] == 167112.299465241, "Protocol: $protocol - Method: $total_mapped_reads_method - $headers->[9] - line $counter" );

    }
  }

  if ( $counter == 16 ) {

    if ( $total_mapped_reads_method eq 'default' ) {

      ok( $row->[4] == 0, "Protocol: $protocol - Method: $total_mapped_reads_method - $headers->[4] - line $counter" );
      ok( $row->[5] == 0, "Protocol: $protocol - Method: $total_mapped_reads_method - $headers->[5] - line $counter" );
      ok( $row->[6] == 6, "Protocol: $protocol - Method: $total_mapped_reads_method - $headers->[6] - line $counter" );
      ok( $row->[7] == 1905.98173307107, "Protocol: $protocol - Method: $total_mapped_reads_method - $headers->[7] - line $counter" );
      ok( $row->[8] == 6, "Protocol: $protocol - Method: $total_mapped_reads_method - $headers->[8] - line $counter" );
      ok( $row->[9] == 1905.98173307107, "Protocol: $protocol - Method: $total_mapped_reads_method - $headers->[9] - line $counter" );

    } elsif ( $total_mapped_reads_method eq 'a' ) {

      ok( $row->[4] == 0, "Protocol: $protocol - Method: $total_mapped_reads_method - $headers->[4] - line $counter" );
      ok( $row->[5] == 0, "Protocol: $protocol - Method: $total_mapped_reads_method - $headers->[5] - line $counter" );
      ok( $row->[6] == 6, "Protocol: $protocol - Method: $total_mapped_reads_method - $headers->[6] - line $counter" );
      ok( $row->[7] == 811688.311688312, "Protocol: $protocol - Method: $total_mapped_reads_method - $headers->[7] - line $counter" );
      ok( $row->[8] == 22, "Protocol: $protocol - Method: $total_mapped_reads_method - $headers->[8] - line $counter" );
      ok( $row->[9] == 811688.311688312, "Protocol: $protocol - Method: $total_mapped_reads_method - $headers->[9] - line $counter" );

    }
  }

  if ( $counter == 28 ) {

    if ( $total_mapped_reads_method eq 'default' ) {

      ok( $row->[4] == 0, "Protocol: $protocol - Method: $total_mapped_reads_method - $headers->[4] - line $counter" );
      ok( $row->[5] == 0, "Protocol: $protocol - Method: $total_mapped_reads_method - $headers->[5] - line $counter" );
      ok( $row->[6] == 2, "Protocol: $protocol - Method: $total_mapped_reads_method - $headers->[6] - line $counter" );
      ok( $row->[7] == 1016.52359097124, "Protocol: $protocol - Method: $total_mapped_reads_method - $headers->[7] - line $counter" );
      ok( $row->[8] == 2, "Protocol: $protocol - Method: $total_mapped_reads_method - $headers->[8] - line $counter" );
      ok( $row->[9] == 1016.52359097124, "Protocol: $protocol - Method: $total_mapped_reads_method - $headers->[9] - line $counter" );

    } elsif ( $total_mapped_reads_method eq 'a' ) {

      ok( $row->[4] == 0, "Protocol: $protocol - Method: $total_mapped_reads_method - $headers->[4] - line $counter" );
      ok( $row->[5] == 0, "Protocol: $protocol - Method: $total_mapped_reads_method - $headers->[5] - line $counter" );
      ok( $row->[6] == 2, "Protocol: $protocol - Method: $total_mapped_reads_method - $headers->[6] - line $counter" );
      ok( $row->[7] == 432900.432900433, "Protocol: $protocol - Method: $total_mapped_reads_method - $headers->[7] - line $counter" );
      ok( $row->[8] == 22, "Protocol: $protocol - Method: $total_mapped_reads_method - $headers->[8] - line $counter" );
      ok( $row->[9] == 432900.432900433, "Protocol: $protocol - Method: $total_mapped_reads_method - $headers->[9] - line $counter" );

    }
  }

  if ( $counter == 39 ) {

    if ( $total_mapped_reads_method eq 'default' ) {

      ok( $row->[4] == 1, "Protocol: $protocol - Method: $total_mapped_reads_method - $headers->[4] - line $counter" );
      ok( $row->[5] == 90.3003189949069, "Protocol: $protocol - Method: $total_mapped_reads_method - $headers->[5] - line $counter" );
      ok( $row->[6] == 0, "Protocol: $protocol - Method: $total_mapped_reads_method - $headers->[6] - line $counter" );
      ok( $row->[7] == 0, "Protocol: $protocol - Method: $total_mapped_reads_method - $headers->[7] - line $counter" );
      ok( $row->[8] == 1, "Protocol: $protocol - Method: $total_mapped_reads_method - $headers->[8] - line $counter" );
      ok( $row->[9] == 90.3003189949069, "Protocol: $protocol - Method: $total_mapped_reads_method - $headers->[9] - line $counter" );

    } elsif ( $total_mapped_reads_method eq 'a' ) {

      ok( $row->[4] == 1, "Protocol: $protocol - Method: $total_mapped_reads_method - $headers->[4] - line $counter" );
      ok( $row->[5] == 38455.6222119674, "Protocol: $protocol - Method: $total_mapped_reads_method - $headers->[5] - line $counter" );
      ok( $row->[6] == 0, "Protocol: $protocol - Method: $total_mapped_reads_method - $headers->[6] - line $counter" );
      ok( $row->[7] == 0, "Protocol: $protocol - Method: $total_mapped_reads_method - $headers->[7] - line $counter" );
      ok( $row->[8] == 22, "Protocol: $protocol - Method: $total_mapped_reads_method - $headers->[8] - line $counter" );
      ok( $row->[9] == 38455.6222119674, "Protocol: $protocol - Method: $total_mapped_reads_method - $headers->[9] - line $counter" );

    }
  }

  if ( $counter == 43 ) {

    if ( $total_mapped_reads_method eq 'default' ) {

      ok( $row->[4] == 0, "Protocol: $protocol - Method: $total_mapped_reads_method - $headers->[4] - line $counter" );
      ok( $row->[5] == 0, "Protocol: $protocol - Method: $total_mapped_reads_method - $headers->[5] - line $counter" );
      ok( $row->[6] == 1, "Protocol: $protocol - Method: $total_mapped_reads_method - $headers->[6] - line $counter" );
      ok( $row->[7] == 408.946272229808, "Protocol: $protocol - Method: $total_mapped_reads_method - $headers->[7] - line $counter" );
      ok( $row->[8] == 1, "Protocol: $protocol - Method: $total_mapped_reads_method - $headers->[8] - line $counter" );
      ok( $row->[9] == 408.946272229808, "Protocol: $protocol - Method: $total_mapped_reads_method - $headers->[9] - line $counter" );

    } elsif ( $total_mapped_reads_method eq 'a' ) {

      ok( $row->[4] == 0, "Protocol: $protocol - Method: $total_mapped_reads_method - $headers->[4] - line $counter" );
      ok( $row->[5] == 0, "Protocol: $protocol - Method: $total_mapped_reads_method - $headers->[5] - line $counter" );
      ok( $row->[6] == 1, "Protocol: $protocol - Method: $total_mapped_reads_method - $headers->[6] - line $counter" );
      ok( $row->[7] == 174155.34656914, "Protocol: $protocol - Method: $total_mapped_reads_method - $headers->[7] - line $counter" );
      ok( $row->[8] == 22, "Protocol: $protocol - Method: $total_mapped_reads_method - $headers->[8] - line $counter" );
      ok( $row->[9] == 174155.34656914, "Protocol: $protocol - Method: $total_mapped_reads_method - $headers->[9] - line $counter" );

    }
  }

  if ( $counter == 44 ) {

    if ( $total_mapped_reads_method eq 'default' ) {

      ok( $row->[4] == 0, "Protocol: $protocol - Method: $total_mapped_reads_method - $headers->[4] - line $counter" );
      ok( $row->[5] == 0, "Protocol: $protocol - Method: $total_mapped_reads_method - $headers->[5] - line $counter" );
      ok( $row->[6] == 4, "Protocol: $protocol - Method: $total_mapped_reads_method - $headers->[6] - line $counter" );
      ok( $row->[7] == 988.28682455537, "Protocol: $protocol - Method: $total_mapped_reads_method - $headers->[7] - line $counter" );
      ok( $row->[8] == 4, "Protocol: $protocol - Method: $total_mapped_reads_method - $headers->[8] - line $counter" );
      ok( $row->[9] == 988.28682455537, "Protocol: $protocol - Method: $total_mapped_reads_method - $headers->[9] - line $counter" );

    } elsif ( $total_mapped_reads_method eq 'a' ) {

      ok( $row->[4] == 0, "Protocol: $protocol - Method: $total_mapped_reads_method - $headers->[4] - line $counter" );
      ok( $row->[5] == 0, "Protocol: $protocol - Method: $total_mapped_reads_method - $headers->[5] - line $counter" );
      ok( $row->[6] == 4, "Protocol: $protocol - Method: $total_mapped_reads_method - $headers->[6] - line $counter" );
      ok( $row->[7] == 420875.420875421, "Protocol: $protocol - Method: $total_mapped_reads_method - $headers->[7] - line $counter" );
      ok( $row->[8] == 22, "Protocol: $protocol - Method: $total_mapped_reads_method - $headers->[8] - line $counter" );
      ok( $row->[9] == 420875.420875421, "Protocol: $protocol - Method: $total_mapped_reads_method - $headers->[9] - line $counter" );

    }
  }

}



