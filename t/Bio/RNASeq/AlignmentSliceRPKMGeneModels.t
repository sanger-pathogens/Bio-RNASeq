#!/usr/bin/env perl
use strict;
use warnings;
use Data::Dumper;

BEGIN { unshift( @INC, './lib' ) }

BEGIN {
    use Test::Most;
    use_ok('Bio::RNASeq::AlignmentSliceRPKMGeneModel');
}
use Bio::RNASeq::GFF;

my $rna_seq_gff =
  Bio::RNASeq::GFF->new(
    filename => 't/data/Citrobacter_rodentium_ICC168_v1_test.gff' );
my $feature = $rna_seq_gff->features()->{continuous_feature_id};
$feature->gene_strand(1);
my @exons;
push @exons, [ 66630, 66940 ];
$feature->exons( \@exons );
$feature->exon_length(50);

ok my $alignment_slice = Bio::RNASeq::AlignmentSliceRPKMGeneModel->new(
    filename                       => 't/data/bam',
    window_margin                  => 10,
    total_mapped_reads             => 10000,
    total_mapped_reads_gene_models => 5000,
    feature                        => $feature,
    _input_slice_filename          => "t/data/Citrobacter_rodentium_slice"
  ),
  'initialise alignment slice';
is $alignment_slice->_window_start, 156, 'start window';
is $alignment_slice->_window_end,   241, 'end window';
ok $alignment_slice->_slice_file_handle, 'file handle initialises okay';
ok my $rpkm_values = $alignment_slice->rpkm_values, 'rpkm values';
is $rpkm_values->{rpkm_sense_gene_model},             0, 'rpkm sense gene model';
is $rpkm_values->{rpkm_antisense_gene_model},         0,     'rpkm antisense gene model';
is $rpkm_values->{mapped_reads_sense_gene_model},     26,    'mapped reads sense gene model';
is $rpkm_values->{mapped_reads_antisense_gene_model}, 0,     'mapped reads antisense gene model';

# invalid filehandle
ok $alignment_slice = Bio::RNASeq::AlignmentSliceRPKMGeneModel->new(
    filename                       => 't/data/bam',
    total_mapped_reads             => 10000,
    total_mapped_reads_gene_models => 5000,
    window_margin                  => 10,
    feature                        => $feature,
    _input_slice_filename          => "file_which_doesnt_exist"
  ),
  'initialise invalid alignment slice';
throws_ok { $alignment_slice->_slice_file_handle } qr/Cant view slice/,
  'invalid file should throw an error';

done_testing();

