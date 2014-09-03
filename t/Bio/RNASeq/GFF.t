#!/usr/bin/env perl
use strict;
use warnings;
use Data::Dumper;

BEGIN { unshift(@INC, './lib') }
BEGIN {
    use Test::Most;
    use_ok('Bio::RNASeq::GFF');
}



isa_ok(	Bio::RNASeq::GFF->new( filename => 't/data/gffs_sams/multipurpose_3_cds_chado.gff' )->gene_model_handler(), 'Bio::RNASeq::GeneModelHandlers::GeneModelHandler', 'A GFF file should return a GeneModelHandler' );


ok my $ensembl_gff = Bio::RNASeq::GFF->new(filename => 't/data/gffs_sams/multipurpose_3_genes_mammal_gtf2gff3.gff'), 'Initialise valid Ensembl GFF file';
ok $ensembl_gff->features(), 'build features';

is $ensembl_gff->features->{"Gene1"}->gene_start, 528, 'find gene start of Ensembl Gene1';
is $ensembl_gff->features->{"Gene1"}->gene_end,   3623, 'find gene end of Ensembl Gene1';
is $ensembl_gff->features->{"Gene1"}->exon_length, 1443, 'length of exon features for Gene1';
is $ensembl_gff->features->{"Gene1"}->gene_strand,  1, 'strand of continuous feature';
is $ensembl_gff->features->{"Gene1"}->seq_id,  "DUMMY_MAMMAL_CHR", 'seq_id of Gene1';
is_deeply( $ensembl_gff->features->{"Gene1"}->exons,  [[528,814],[1480,2070],[3056,3623]], 'Exon regions should be the same' );


ok my $chado_gff = Bio::RNASeq::GFF->new(filename => 't/data/gffs_sams/multipurpose_3_cds_chado.gff'), 'Initialise valid Chado GFF file';
ok $chado_gff->features(), 'build features';

is $chado_gff->features->{"GreatCurl"}->gene_start, 1053, 'find gene start for GreatCurl';
is $chado_gff->features->{"GreatCurl"}->gene_end,   2474, 'find gene end for GreatCurl';
is $chado_gff->features->{"GreatCurl"}->exon_length, 1071, 'exon length for GreatCurl';
is $chado_gff->features->{"GreatCurl"}->gene_strand,  1, 'strand of GreatCurl';
is $chado_gff->features->{"GreatCurl"}->seq_id,  'DUMMY_CHADO_CHR', 'seq_id of GreatCurl';
is_deeply( $chado_gff->features->{"GreatCurl"}->exons,  [[1053, 1500], [1650, 1900], [2100, 2474]], 'Exon regions should be the same for GreatCurl gene model' );

ok my $cds_only_gff = Bio::RNASeq::GFF->new(filename => 't/data/gffs_sams/multipurpose_3_cds_annot.gff'), 'Initialise valid CDSOnly GFF file';
ok $cds_only_gff->features(), 'build features';

is $cds_only_gff->features->{"Clostridium_difficile_630_v1.9_00001"}->gene_start, 200, 'find gene start of CDS for Clostridium_difficile_630_v1.9_00001';
is $cds_only_gff->features->{"Clostridium_difficile_630_v1.9_00001"}->gene_end,   1000, 'find gene end of CDS for Clostridium_difficile_630_v1.9_00001';
is $cds_only_gff->features->{"Clostridium_difficile_630_v1.9_00001"}->exon_length, 800, 'exon length for Clostridium_difficile_630_v1.9_00001';
is $cds_only_gff->features->{"Clostridium_difficile_630_v1.9_00001"}->gene_strand,  1, 'strand of Clostridium_difficile_630_v1.9_00001';
is $cds_only_gff->features->{"Clostridium_difficile_630_v1.9_00001"}->seq_id,  'DUMMY_ANNOT_CHR', 'seq_id of Clostridium_difficile_630_v1.9_00001';


ok my $old_chado_format_gff = Bio::RNASeq::GFF->new(filename => 't/data/gffs_sams/old_style_chado.gff'), 'Initialise valid OldChadoFormat GFF file';
ok $old_chado_format_gff->features(), 'build features';

is $old_chado_format_gff->features->{"Schisto_mansoni.Chr_1.unplaced.SC_0010.248"}->gene_start, 1043973, 'find gene start of CDS for Schisto_mansoni.Chr_1.unplaced.SC_0010.248';
is $old_chado_format_gff->features->{"Schisto_mansoni.Chr_1.unplaced.SC_0010.248"}->gene_end,   1046287, 'find gene end of CDS for Schisto_mansoni.Chr_1.unplaced.SC_0010.248';
is $old_chado_format_gff->features->{"Schisto_mansoni.Chr_1.unplaced.SC_0010.248"}->exon_length, 546, 'exon length for Schisto_mansoni.Chr_1.unplaced.SC_0010.248';
is $old_chado_format_gff->features->{"Schisto_mansoni.Chr_1.unplaced.SC_0010.248"}->gene_strand,  1, 'strand of Schisto_mansoni.Chr_1.unplaced.SC_0010.248';
is $old_chado_format_gff->features->{"Schisto_mansoni.Chr_1.unplaced.SC_0010.248"}->seq_id,  'Schisto_mansoni.Chr_1.unplaced.SC_0010', 'seq_id of Schisto_mansoni.Chr_1.unplaced.SC_0010.248';
is $old_chado_format_gff->features->{"Schisto_mansoni.Chr_1.unplaced.SC_0010.248"}->locus_tag,  'Smp_019490.1', 'Schisto_mansoni.Chr_1.unplaced.SC_0010.248 locus tag';


ok my $rna_seq_gff = Bio::RNASeq::GFF->new(filename => 't/data/Citrobacter_rodentium_ICC168_v1_test.gff'), 'Initialise valid GFF file';
ok $rna_seq_gff->features(), 'build features';

# Should extract feature in a valid manner
is $rna_seq_gff->features->{"continuous_feature_id"}->gene_start, 166, 'find gene start of CDS for continuous feature';
is $rna_seq_gff->features->{"continuous_feature_id"}->gene_end,   231, 'find gene end of CDS for continuous feature';
is $rna_seq_gff->features->{"continuous_feature_id"}->exon_length, 65, 'exon length for continuous feature';
is $rna_seq_gff->features->{"continuous_feature_id"}->gene_strand,  1, 'strand of continuous feature';
is $rna_seq_gff->features->{"continuous_feature_id"}->seq_id,  "FN543502", 'seq_id of continuous feature';
is $rna_seq_gff->features->{"continuous_feature_id"}->locus_tag,  "continuous_feature_locus_tag", 'continuous feature locus tag';


is $rna_seq_gff->features->{"non_cds_feature_id"}, undef, 'Dont parse non CDS features';

# reverse strand
is $rna_seq_gff->features->{"reverse_strand_id"}->gene_strand,  -1, 'reverse strand';
is $rna_seq_gff->features->{"no_strand_identifier_id"}->gene_strand,  0, 'no strand identifier';

my @expected_gene_ids = ('FN543502.13','FN543502.18','ROD_00071','continuous_feature_id','discontinuous_feature_id','no_strand_identifier_id','reverse_strand_id');

is_deeply $rna_seq_gff->sorted_gene_ids, \@expected_gene_ids, 'sorting of gene ids';


# Discontinous features
ok( $rna_seq_gff = Bio::RNASeq::GFF->new(filename => 't/data/mm10.gff'), 'Discontinuous feature with overall CDS spanning' );
ok(my $feature = $rna_seq_gff->features()->{"10.10"}, 'get discontinous feature');
my @expected_exons = ([10206,10296],
[15002,15271],
[15608,15874],
[16453,16559]);
is_deeply($feature->exons, \@expected_exons , 'exons are as expected');
is($feature->exon_length,731 ,'overall feature length doesnt include introns');

done_testing();
