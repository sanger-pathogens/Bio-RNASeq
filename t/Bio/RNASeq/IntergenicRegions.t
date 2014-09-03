#!/usr/bin/env perl
use strict;
use warnings;
use Data::Dumper;

BEGIN { unshift(@INC, './lib') }
BEGIN {
    use Test::Most;
    use_ok('Bio::RNASeq::IntergenicRegions');
}
use Bio::RNASeq::GFF;
use Bio::RNASeq::FeaturesTabFile;
my $rna_seq_gff = Bio::RNASeq::GFF->new(filename => 't/data/Citrobacter_rodentium_ICC168_v1_test.gff');


# valid intergenic region generation where some features are close by
ok my $intergenic_regions = Bio::RNASeq::IntergenicRegions->new(
  features => $rna_seq_gff->features(),
  window_margin => 0,
  sequence_lengths => $rna_seq_gff->sequence_lengths
  ), 'initialise intergenic regions';

ok my $features = $intergenic_regions->intergenic_features, 'create features';
my @expected_keys =  ('FN543502_intergenic_1_165', 'FN543502_intergenic_232_312','FN543502_intergenic_4998_5146','FN543502_intergenic_5921_5989','FN543502_intergenic_7421_7690','FN543502_intergenic_8645_8757','FN543502_intergenic_9346_30000');


my @actual_keys = sort keys(%{$features});

is_deeply \@actual_keys, \@expected_keys, 'expected keys';
is $features->{"FN543502_intergenic_7421_7690"}->gene_id, 'FN543502_intergenic_7421_7690', 'gene id';
is $features->{"FN543502_intergenic_7421_7690"}->gene_start ,7421, 'gene start';
is $features->{"FN543502_intergenic_7421_7690"}->gene_end ,7690, 'gene end';
is $features->{"FN543502_intergenic_7421_7690"}->gene_strand ,1, 'gene strand';
is $features->{"FN543502_intergenic_7421_7690"}->seq_id ,'FN543502', 'sequence id';
my @expected_exons  = ([7421,7690]);
is_deeply $features->{"FN543502_intergenic_7421_7690"}->exons, \@expected_exons, 'expected exons';




# intergenic regions where there is a tiny window margin
ok $intergenic_regions = Bio::RNASeq::IntergenicRegions->new(
  features => $rna_seq_gff->features(),
  window_margin => 0,
  minimum_size => 0,
  sequence_lengths => $rna_seq_gff->sequence_lengths
    ), 'initialise intergenic regions';

ok $features = $intergenic_regions->intergenic_features, 'create features';
@expected_keys = ('FN543502_intergenic_1_165','FN543502_intergenic_232_312','FN543502_intergenic_2776_2777','FN543502_intergenic_3708_3710','FN543502_intergenic_4998_5146','FN543502_intergenic_5921_5989','FN543502_intergenic_7421_7690','FN543502_intergenic_8645_8757','FN543502_intergenic_9346_30000');

@actual_keys = sort keys(%{$features});
is_deeply \@actual_keys, \@expected_keys, 'expected keys';

done_testing();
