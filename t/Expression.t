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
  my $annotation_filename = 't/data/Clostridium_difficile_630_v1.6.gff';

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

  }
}

=head


my $rna_seq_gff = Bio::RNASeq::GFF->new(filename => 't/data/Citrobacter_rodentium_ICC168_v1_test.gff');
my $feature = $rna_seq_gff->features()->{continuous_feature_id};
$feature->gene_strand(1);
my @exons;
push @exons, [66630,66940];
$feature->exons(\@exons);
$feature->exon_length(50);

ok my $alignment_slice = Bio::RNASeq::StandardProtocol::AlignmentSlice->new(
  filename => 't/data/bam',
  window_margin => 10,
  total_mapped_reads => 10000,
  feature => $feature,
  _input_slice_filename => "t/data/Citrobacter_rodentium_slice"
), 'initialise alignment slice';
is $alignment_slice->_window_start, 156, 'start window';
is $alignment_slice->_window_end, 241, 'end window';
ok $alignment_slice->_slice_file_handle, 'file handle initialises okay';
ok my $rpkm_values = $alignment_slice->rpkm_values;
is $rpkm_values->{rpkm_sense}, 52000, 'rpkm sense';
is $rpkm_values->{rpkm_antisense},0, 'rpkm antisense';
is $rpkm_values->{mapped_reads_sense},26, 'mapped reads sense';
is $rpkm_values->{mapped_reads_antisense},0, 'mapped reads antisense';



# invalid filehandle
ok $alignment_slice = Bio::RNASeq::StandardProtocol::AlignmentSlice->new(
  filename => 't/data/bam',
  total_mapped_reads => 10000,
  window_margin => 10,
  feature => $feature,
  _input_slice_filename => "file_which_doesnt_exist"
), 'initialise invalid alignment slice';
throws_ok  {$alignment_slice->_slice_file_handle} qr/Cant view slice/ , 'invalid file should throw an error';

=cut

done_testing();


