#!/usr/bin/env perl
use strict;
use warnings;
use File::Spec;
use File::Temp qw/ tempdir /;
use Data::Dumper;


BEGIN { unshift(@INC, './lib') }
BEGIN {
         use Test::Most;
	 use_ok('Bio::RNASeq::Expression');
       }

my @tmrm = qw(default a);

for my $total_mapped_reads_method ( @tmrm ) {

  my $sequence_filename ="t/data/647029.pe.markdup.bam";
  my $annotation_filename = 't/data/CD630_updated_171212.embl.34.gff';

  my %protocols = ( standard => 'StrandSpecificProtocol' );
  my %filters = ( mapping_quality => 1 );


  my $tmp_dir = File::Temp->newdir( DIR => File::Spec->curdir() );
  my $output_base_filename = $tmp_dir . '/_test';

  my $expression_results = Bio::RNASeq::Expression->new(
							sequence_filename    => $sequence_filename,
							annotation_filename  => $annotation_filename,
							filters              => \%filters,
							protocol             => $protocols{'standard'},
							output_base_filename => $output_base_filename,
							total_mapped_reads_method   => $total_mapped_reads_method
						       );

  $expression_results->output_spreadsheet();

  my @output_filename_extensions = qw( .corrected.bam .corrected.bam.bai .expression.csv );

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
	$line =~ s/\n//;
	my @row = split(',',$line);
	#print "$counter\t@row\n";

	if ( $counter ~~ @lines_to_test ) {

	  if ( $counter == 1 ) {

	    if ( $total_mapped_reads_method eq 'default') {

	      ok($row[4] == 0, "Method: $total_mapped_reads_method - anti sense reads that mapped - line $counter");
	      ok($row[5] == 0, "Method: $total_mapped_reads_method - anti sense rpkm - line $counter");
	      ok($row[6] == 4, "Method: $total_mapped_reads_method - sense reads that mapped - line $counter");
	      ok($row[7] == 306.050113410695, "Method: $total_mapped_reads_method - sense rpkm - line $counter");
	      ok($row[8] == 4, "Method: $total_mapped_reads_method - Total reads that mapped - line $counter");
	      ok($row[9] == 306.050113410695, "Method: $total_mapped_reads_method - Total rpkm - line $counter");

	    }
	    elsif ( $total_mapped_reads_method eq 'a') {

	      ok($row[4] == 0, "Method: $total_mapped_reads_method - anti sense reads that mapped - line $counter");
	      ok($row[5] == 0, "Method: $total_mapped_reads_method - anti sense rpkm - line $counter");
	      ok($row[6] == 4, "Method: $total_mapped_reads_method - sense reads that mapped - line $counter");
	      ok($row[7] == 130335.614206582, "Method: $total_mapped_reads_method - sense rpkm - line $counter");
	      ok($row[8] == 22, "Method: $total_mapped_reads_method - Total reads that mapped - line $counter");
	      ok($row[9] == 130335.614206582, "Method: $total_mapped_reads_method - Total rpkm - line $counter");

	    }
	  }

	  if ( $counter == 4 ) {

	    if ( $total_mapped_reads_method eq 'default') {

	      ok($row[4] == 0, "Method: $total_mapped_reads_method - anti sense reads that mapped - line $counter");
	      ok($row[5] == 0, "Method: $total_mapped_reads_method - anti sense rpkm - line $counter");
	      ok($row[6] == 0, "Method: $total_mapped_reads_method - sense reads that mapped - line $counter");
	      ok($row[7] == 0, "Method: $total_mapped_reads_method - sense rpkm - line $counter");
	      ok($row[8] == 0, "Method: $total_mapped_reads_method - Total reads that mapped - line $counter");
	      ok($row[9] == 0, "Method: $total_mapped_reads_method - Total rpkm - line $counter");

	    }
	    elsif ( $total_mapped_reads_method eq 'a') {

	      ok($row[4] == 0, "Method: $total_mapped_reads_method - anti sense reads that mapped - line $counter");
	      ok($row[5] == 0, "Method: $total_mapped_reads_method - anti sense rpkm - line $counter");
	      ok($row[6] == 0, "Method: $total_mapped_reads_method - sense reads that mapped - line $counter");
	      ok($row[7] == 0, "Method: $total_mapped_reads_method - sense rpkm - line $counter");
	      ok($row[8] == 22, "Method: $total_mapped_reads_method - Total reads that mapped - line $counter");
	      ok($row[9] == 0, "Method: $total_mapped_reads_method - Total rpkm - line $counter");

	    }
	  }

	  if ( $counter == 10 ) {

	    if ( $total_mapped_reads_method eq 'default') {

	      ok($row[4] == 0, "Method: $total_mapped_reads_method - anti sense reads that mapped - line $counter");
	      ok($row[5] == 0, "Method: $total_mapped_reads_method - anti sense rpkm - line $counter");
	      ok($row[6] == 3, "Method: $total_mapped_reads_method - sense reads that mapped - line $counter");
	      ok($row[7] == 392.408003867573, "Method: $total_mapped_reads_method - sense rpkm - line $counter");
	      ok($row[8] == 3, "Method: $total_mapped_reads_method - Total reads that mapped - line $counter");
	      ok($row[9] == 392.408003867573, "Method: $total_mapped_reads_method - Total rpkm - line $counter");

	    }
	    elsif ( $total_mapped_reads_method eq 'a') {

	      ok($row[4] == 0, "Method: $total_mapped_reads_method - anti sense reads that mapped - line $counter");
	      ok($row[5] == 0, "Method: $total_mapped_reads_method - anti sense rpkm - line $counter");
	      ok($row[6] == 3, "Method: $total_mapped_reads_method - sense reads that mapped - line $counter");
	      ok($row[7] == 167112.299465241, "Method: $total_mapped_reads_method - sense rpkm - line $counter");
	      ok($row[8] == 22, "Method: $total_mapped_reads_method - Total reads that mapped - line $counter");
	      ok($row[9] == 167112.299465241, "Method: $total_mapped_reads_method - Total rpkm - line $counter");

	    }
	  }

	  if ( $counter == 16 ) {

	    if ( $total_mapped_reads_method eq 'default') {

	      ok($row[4] == 0, "Method: $total_mapped_reads_method - anti sense reads that mapped - line $counter");
	      ok($row[5] == 0, "Method: $total_mapped_reads_method - anti sense rpkm - line $counter");
	      ok($row[6] == 6, "Method: $total_mapped_reads_method - sense reads that mapped - line $counter");
	      ok($row[7] == 1905.98173307107, "Method: $total_mapped_reads_method - sense rpkm - line $counter");
	      ok($row[8] == 6, "Method: $total_mapped_reads_method - Total reads that mapped - line $counter");
	      ok($row[9] == 1905.98173307107, "Method: $total_mapped_reads_method - Total rpkm - line $counter");

	    }
	    elsif ( $total_mapped_reads_method eq 'a') {

	      ok($row[4] == 0, "Method: $total_mapped_reads_method - anti sense reads that mapped - line $counter");
	      ok($row[5] == 0, "Method: $total_mapped_reads_method - anti sense rpkm - line $counter");
	      ok($row[6] == 6, "Method: $total_mapped_reads_method - sense reads that mapped - line $counter");
	      ok($row[7] == 811688.311688312, "Method: $total_mapped_reads_method - sense rpkm - line $counter");
	      ok($row[8] == 22, "Method: $total_mapped_reads_method - Total reads that mapped - line $counter");
	      ok($row[9] == 811688.311688312, "Method: $total_mapped_reads_method - Total rpkm - line $counter");

	    }
	  }

	  if ( $counter == 28 ) {

	    if ( $total_mapped_reads_method eq 'default') {

	      ok($row[4] == 0, "Method: $total_mapped_reads_method - anti sense reads that mapped - line $counter");
	      ok($row[5] == 0, "Method: $total_mapped_reads_method - anti sense rpkm - line $counter");
	      ok($row[6] == 2, "Method: $total_mapped_reads_method - sense reads that mapped - line $counter");
	      ok($row[7] == 1016.52359097124, "Method: $total_mapped_reads_method - sense rpkm - line $counter");
	      ok($row[8] == 2, "Method: $total_mapped_reads_method - Total reads that mapped - line $counter");
	      ok($row[9] == 1016.52359097124, "Method: $total_mapped_reads_method - Total rpkm - line $counter");

	    }
	    elsif ( $total_mapped_reads_method eq 'a') {

	      ok($row[4] == 0, "Method: $total_mapped_reads_method - anti sense reads that mapped - line $counter");
	      ok($row[5] == 0, "Method: $total_mapped_reads_method - anti sense rpkm - line $counter");
	      ok($row[6] == 2, "Method: $total_mapped_reads_method - sense reads that mapped - line $counter");
	      ok($row[7] == 432900.432900433, "Method: $total_mapped_reads_method - sense rpkm - line $counter");
	      ok($row[8] == 22, "Method: $total_mapped_reads_method - Total reads that mapped - line $counter");
	      ok($row[9] == 432900.432900433, "Method: $total_mapped_reads_method - Total rpkm - line $counter");

	    }
	  }

	  if ( $counter == 39 ) {

	    if ( $total_mapped_reads_method eq 'default') {

	      ok($row[4] == 1, "Method: $total_mapped_reads_method - anti sense reads that mapped - line $counter");
	      ok($row[5] == 90.3003189949069, "Method: $total_mapped_reads_method - anti sense rpkm - line $counter");
	      ok($row[6] == 0, "Method: $total_mapped_reads_method - sense reads that mapped - line $counter");
	      ok($row[7] == 0, "Method: $total_mapped_reads_method - sense rpkm - line $counter");
	      ok($row[8] == 1, "Method: $total_mapped_reads_method - Total reads that mapped - line $counter");
	      ok($row[9] == 90.3003189949069, "Method: $total_mapped_reads_method - Total rpkm - line $counter");

	    }
	    elsif ( $total_mapped_reads_method eq 'a') {

	      ok($row[4] == 1, "Method: $total_mapped_reads_method - anti sense reads that mapped - line $counter");
	      ok($row[5] == 38455.6222119674, "Method: $total_mapped_reads_method - anti sense rpkm - line $counter");
	      ok($row[6] == 0, "Method: $total_mapped_reads_method - sense reads that mapped - line $counter");
	      ok($row[7] == 0, "Method: $total_mapped_reads_method - sense rpkm - line $counter");
	      ok($row[8] == 22, "Method: $total_mapped_reads_method - Total reads that mapped - line $counter");
	      ok($row[9] == 38455.6222119674, "Method: $total_mapped_reads_method - Total rpkm - line $counter");

	    }
	  }

	  if ( $counter == 43 ) {

	    if ( $total_mapped_reads_method eq 'default') {

	      ok($row[4] == 0, "Method: $total_mapped_reads_method - anti sense reads that mapped - line $counter");
	      ok($row[5] == 0, "Method: $total_mapped_reads_method - anti sense rpkm - line $counter");
	      ok($row[6] == 1, "Method: $total_mapped_reads_method - sense reads that mapped - line $counter");
	      ok($row[7] == 408.946272229808, "Method: $total_mapped_reads_method - sense rpkm - line $counter");
	      ok($row[8] == 1, "Method: $total_mapped_reads_method - Total reads that mapped - line $counter");
	      ok($row[9] == 408.946272229808, "Method: $total_mapped_reads_method - Total rpkm - line $counter");

	    }
	    elsif ( $total_mapped_reads_method eq 'a') {

	      ok($row[4] == 0, "Method: $total_mapped_reads_method - anti sense reads that mapped - line $counter");
	      ok($row[5] == 0, "Method: $total_mapped_reads_method - anti sense rpkm - line $counter");
	      ok($row[6] == 1, "Method: $total_mapped_reads_method - sense reads that mapped - line $counter");
	      ok($row[7] == 174155.34656914, "Method: $total_mapped_reads_method - sense rpkm - line $counter");
	      ok($row[8] == 22, "Method: $total_mapped_reads_method - Total reads that mapped - line $counter");
	      ok($row[9] == 174155.34656914, "Method: $total_mapped_reads_method - Total rpkm - line $counter");

	    }
	  }

	  if ( $counter == 44 ) {

	    if ( $total_mapped_reads_method eq 'default') {

	      ok($row[4] == 0, "Method: $total_mapped_reads_method - anti sense reads that mapped - line $counter");
	      ok($row[5] == 0, "Method: $total_mapped_reads_method - anti sense rpkm - line $counter");
	      ok($row[6] == 4, "Method: $total_mapped_reads_method - sense reads that mapped - line $counter");
	      ok($row[7] == 988.28682455537, "Method: $total_mapped_reads_method - sense rpkm - line $counter");
	      ok($row[8] == 4, "Method: $total_mapped_reads_method - Total reads that mapped - line $counter");
	      ok($row[9] == 988.28682455537, "Method: $total_mapped_reads_method - Total rpkm - line $counter");

	    }
	    elsif ( $total_mapped_reads_method eq 'a') {

	      ok($row[4] == 0, "Method: $total_mapped_reads_method - anti sense reads that mapped - line $counter");
	      ok($row[5] == 0, "Method: $total_mapped_reads_method - anti sense rpkm - line $counter");
	      ok($row[6] == 4, "Method: $total_mapped_reads_method - sense reads that mapped - line $counter");
	      ok($row[7] == 420875.420875421, "Method: $total_mapped_reads_method - sense rpkm - line $counter");
	      ok($row[8] == 22, "Method: $total_mapped_reads_method - Total reads that mapped - line $counter");
	      ok($row[9] == 420875.420875421, "Method: $total_mapped_reads_method - Total rpkm - line $counter");

	    }
	  }
	}

	$counter++;
      }
      close($exp_fh);
    }
  }
}

done_testing();


