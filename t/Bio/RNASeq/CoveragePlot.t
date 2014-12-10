#!/usr/bin/env perl
use strict;
use warnings;
use Data::Dumper;


BEGIN { unshift(@INC, './lib') }
BEGIN {

  use Test::Most;
  use List::MoreUtils qw(uniq);
  use_ok('Bio::RNASeq::CoveragePlot');
}

ok my $coverage_plots_from_bam = Bio::RNASeq::CoveragePlot->new(
   filename             => 't/data/small_multi_sequence.bam',
   output_base_filename => 't/data/coverage',
   mpileup_cmd          => "samtools mpileup"
  );
ok $coverage_plots_from_bam->create_plots();

ok are_coverage_files_created(
			      't/data/coverage.FN543502.coverageplot.gz',
			      't/data/coverage.pCROD1.coverageplot.gz',
			      't/data/coverage.pCROD2.coverageplot.gz',
			      't/data/coverage.pCROD3.coverageplot.gz',
			      't/data/coverage.all_sequences.coverageplot.gz'
			      ), 'check if all coverageplot files have been created';

# parse output files and check they are okay
ok is_input_string_found_on_given_line("0 0", 1,    't/data/coverage.FN543502.coverageplot.gz'), 'check main sequence coverage values first value';
ok is_input_string_found_on_given_line("1 1", 104,  't/data/coverage.FN543502.coverageplot.gz'), 'check main sequence coverage values for forward read only';
ok is_input_string_found_on_given_line("0 4", 548,  't/data/coverage.FN543502.coverageplot.gz'), 'check main sequence coverage values for reverse reads only';
ok is_input_string_found_on_given_line("7 24", 7795, 't/data/coverage.FN543502.coverageplot.gz'), 'check main sequence coverage values for both';
ok is_input_string_found_on_given_line("0 0", 8974, 't/data/coverage.FN543502.coverageplot.gz'), 'check main sequence coverage values last value';

ok is_input_string_found_on_given_line("0 0", 1,    't/data/coverage.pCROD1.coverageplot.gz'), 'check empty plasmid coverage values first value';
ok is_input_string_found_on_given_line("0 0", 59,   't/data/coverage.pCROD1.coverageplot.gz'), 'check empty plasmid coverage values last value';

ok is_input_string_found_on_given_line("0 0", 1,    't/data/coverage.pCROD2.coverageplot.gz'), 'check plasmid with 1 read coverage values first value';
ok is_input_string_found_on_given_line("0 0", 89,   't/data/coverage.pCROD2.coverageplot.gz'), 'check plasmid with 1 read coverage values before first base of read';
ok is_input_string_found_on_given_line("0 1", 90,   't/data/coverage.pCROD2.coverageplot.gz'), 'check plasmid with 1 read coverage values first base of read';
ok is_input_string_found_on_given_line("0 1", 143,  't/data/coverage.pCROD2.coverageplot.gz'), 'check plasmid with 1 read coverage values last base of read';
ok is_input_string_found_on_given_line("0 0", 144,  't/data/coverage.pCROD2.coverageplot.gz'), 'check plasmid with 1 read coverage values after last base of read';
ok is_input_string_found_on_given_line("0 0", 1000, 't/data/coverage.pCROD2.coverageplot.gz'), 'check plasmid with 1 read coverage values last value';

ok is_input_string_found_on_given_line("0 0", 1,   't/data/coverage.pCROD3.coverageplot.gz'), 'check another empty plasmid coverage values first value';
ok is_input_string_found_on_given_line("0 0", 100, 't/data/coverage.pCROD3.coverageplot.gz'), 'check another empty plasmid coverage values last value';


ok is_input_string_found_on_given_line("0\t0", 1,    't/data/coverage.all_sequences.coverageplot.gz'), 'check main sequence coverage values first value in all_sequences';
ok is_input_string_found_on_given_line("1\t1", 104,  't/data/coverage.all_sequences.coverageplot.gz'), 'check main sequence coverage values for forward read only in all_sequences';
ok is_input_string_found_on_given_line("0\t4", 548,  't/data/coverage.all_sequences.coverageplot.gz'), 'check main sequence coverage values for reverse reads only in all_sequences';
ok is_input_string_found_on_given_line("7\t24", 7795, 't/data/coverage.all_sequences.coverageplot.gz'), 'check main sequence coverage values for both in all_sequences';
ok is_input_string_found_on_given_line("0\t0", 8974, 't/data/coverage.all_sequences.coverageplot.gz'), 'check main sequence coverage values last value in all_sequences';

ok is_input_string_found_on_given_line("0\t0", 8975,    't/data/coverage.all_sequences.coverageplot.gz'), 'check empty plasmid coverage values first value in all_sequences';
ok is_input_string_found_on_given_line("0\t0", 9033,   't/data/coverage.all_sequences.coverageplot.gz'), 'check empty plasmid coverage values last value in all_sequences';

ok is_input_string_found_on_given_line("0\t0", 9034,    't/data/coverage.all_sequences.coverageplot.gz'), 'check plasmid with 1 read coverage values first value in all_sequences';
ok is_input_string_found_on_given_line("0\t0", 9123,   't/data/coverage.all_sequences.coverageplot.gz'), 'check plasmid with 1 read coverage values before first base of read in all_sequences';
ok is_input_string_found_on_given_line("0\t1", 9124,   't/data/coverage.all_sequences.coverageplot.gz'), 'check plasmid with 1 read coverage values first base of read in all_sequences';
ok is_input_string_found_on_given_line("0\t1", 9176,  't/data/coverage.all_sequences.coverageplot.gz'), 'check plasmid with 1 read coverage values last base of read in all_sequences';
ok is_input_string_found_on_given_line("0\t0", 9177,  't/data/coverage.all_sequences.coverageplot.gz'), 'check plasmid with 1 read coverage values after last base of read in all_sequences';
ok is_input_string_found_on_given_line("0\t0", 10033, 't/data/coverage.all_sequences.coverageplot.gz'), 'check plasmid with 1 read coverage values last value in all_sequences';

ok is_input_string_found_on_given_line("0\t0", 10034,   't/data/coverage.all_sequences.coverageplot.gz'), 'check another empty plasmid coverage values first value in all_sequences';
ok is_input_string_found_on_given_line("0\t0", 10133, 't/data/coverage.all_sequences.coverageplot.gz'), 'check another empty plasmid coverage values last value in all_sequences';



unlink("t/data/coverage.FN543502.coverageplot.gz");
unlink("t/data/coverage.pCROD1.coverageplot.gz");
unlink("t/data/coverage.pCROD2.coverageplot.gz");
unlink("t/data/coverage.pCROD3.coverageplot.gz");
#unlink("t/data/coverage.all_sequences.coverageplot.gz");

done_testing();


sub are_coverage_files_created {

  my (@array_of_filenames) = @_;
  my @array_of_presence;
  for my $filename(@array_of_filenames) {
    if(-e $filename) {
      push(@array_of_presence, 1);
    }
    else {
      push(@array_of_presence, 0);
    }
  }	

  my @unique_array_of_presence = uniq(@array_of_presence);

  if( scalar  @unique_array_of_presence == 1 &&  $unique_array_of_presence[0] == 1) {
    return 1;
  }
  else {
    return 0;
  }
}

sub is_input_string_found_on_given_line
{
  my($expected_string, $line_number, $filename) = @_;
  my $line_counter = 0;
  open(IN, '-|', "gzip -dc ".$filename);
  while(<IN>)
  {
    chomp;
    my $line = $_;
    $line_counter++;
    next unless($line_counter ==  $line_number);
    last if($line_counter >  $line_number);
    
    if($expected_string eq $line)
    {
      return 1;
    }
    else
    {
      print "Expected ".$expected_string." but got ".$line."\n";
    }
  }
  return 0;
}
