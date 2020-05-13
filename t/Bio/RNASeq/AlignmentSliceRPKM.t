#!/usr/bin/env perl
use strict;
use warnings;
use Data::Dumper;


BEGIN {
    use Test::Most;
    use_ok('Bio::RNASeq::AlignmentSliceRPKM');
}
use Bio::RNASeq::GFF;

my $rna_seq_gff = Bio::RNASeq::GFF->new(filename => 't/data/gffs_sams/multipurpose_3_cds_embl.gff');
my $feature = $rna_seq_gff->features()->{'DUMMY_EMBL_CHR.5'};
$feature->gene_strand(1);

my $cmd1 = "samtools view -bS t/data/gffs_sams/mapping_to_one_feature_embl.sam 2>/dev/null > t/data/gffs_sams/mapping_to_one_feature_embl.bam";

system($cmd1);

my $cmd2 = "samtools index t/data/gffs_sams/mapping_to_one_feature_embl.bam 2>/dev/null";

system($cmd2);

ok my $alignment_slice = Bio::RNASeq::AlignmentSliceRPKM->new(
  filename => 't/data/gffs_sams/mapping_to_one_feature_embl.bam',
  window_margin => 0,
  total_mapped_reads => 10000,
  feature => $feature,
), 'initialise alignment slice';


is($alignment_slice->rpkm_values->{total_rpkm}, 271.24773960217, "Total RPKM check");
is($alignment_slice->rpkm_values->{rpkm_sense}, 271.24773960217, "Sense RPKM check");
is($alignment_slice->rpkm_values->{rpkm_antisense}, 0, "Antisense RPKM check");
is($alignment_slice->rpkm_values->{total_mapped_reads}, 3, "Total mapped reads check");
is($alignment_slice->rpkm_values->{mapped_reads_sense}, 3, "Sense mapped reads check");
is($alignment_slice->rpkm_values->{mapped_reads_antisense}, 0, "Antisense mapped reads check");

unlink('t/data/gffs_sams/mapping_to_one_feature_embl.bam');
unlink('t/data/gffs_sams/mapping_to_one_feature_embl.bam.bai');

done_testing();


