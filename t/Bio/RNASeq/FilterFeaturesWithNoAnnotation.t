#!/usr/bin/env perl
use strict;
use warnings;
use Data::Dumper;

BEGIN { unshift(@INC, './lib') }
BEGIN {
    use Test::Most;
    use Bio::RNASeq ;
}

my %filters = ( mapping_quality => 1 );
unlink('t/data/gffs_sams/nothing_to_map_mammal.bam') if ( -e 't/data/gffs_sams/nothing_to_map_mammal.bam');
`samtools view -bSh t/data/gffs_sams/nothing_to_map_mammal.sam 2>/dev/null > t/data/gffs_sams/nothing_to_map_mammal.bam`;

my $rnaseq = Bio::RNASeq->new(
    sequence_filename    => 't/data/gffs_sams/nothing_to_map_mammal.bam',
    annotation_filename  => 't/data/gffs_sams/multipurpose_3_genes_mammal_gtf2gff3.gff',
    window_margin        => 0,
    filters              => \%filters,
    protocol             => 'StandardProtocol',
    output_base_filename => 'output',
    intergenic_regions   => 0,
);

my $bitWise = Bio::RNASeq::BitWise->new(
			    filename        => $rnaseq->sequence_filename,
			    output_filename => $rnaseq->_corrected_sequence_filename,
			    protocol        => $rnaseq->protocol,
			    samtools_exec   => $rnaseq->samtools_exec
			   );
$bitWise->update_bitwise_flags();
ok($rnaseq->_split_bam_by_chromosome, 'split up the bams and run mpileup on a file where there are no mapping features');

for my $feature (values %{$rnaseq->_annotation_file->features})
{
  is($feature->reads_mapping, 0, 'we havent flagged if reads are mapping from mpileup yet');
}

ok($rnaseq->flag_features_with_no_annotation, 'flag up features with no annotation');

is($rnaseq->_annotation_file->features->{'Gene1'}->reads_mapping, 0,'gene 1 has no mapping');
is($rnaseq->_annotation_file->features->{'Gene2'}->reads_mapping, 0,'gene 2 has no mapping');
is($rnaseq->_annotation_file->features->{'Gene3'}->reads_mapping, 1,'gene 3 has no mapping but one read is near a gene so needs a more sensitive lookup');


unlink('t/data/gffs_sams/nothing_to_map_mammal.bam') if ( -e 't/data/gffs_sams/nothing_to_map_mammal.bam');



unlink('t/data/gffs_sams/mapping_to_one_feature_mammal.bam') if ( -e 't/data/gffs_sams/mapping_to_one_feature_mammal.bam');
`samtools view -bSh t/data/gffs_sams/mapping_to_one_feature_mammal.sam 2>/dev/null >t/data/gffs_sams/mapping_to_one_feature_mammal.bam`;


$rnaseq = Bio::RNASeq->new(
    sequence_filename    => 't/data/gffs_sams/mapping_to_one_feature_mammal.bam',
    annotation_filename  => 't/data/gffs_sams/multipurpose_3_genes_mammal_gtf2gff3.gff',
    window_margin        => 0,
    filters              => \%filters,
    protocol             => 'StandardProtocol',
    output_base_filename => 'output',
    intergenic_regions   => 0,
);
$bitWise = Bio::RNASeq::BitWise->new(
			    filename        => $rnaseq->sequence_filename,
			    output_filename => $rnaseq->_corrected_sequence_filename,
			    protocol        => $rnaseq->protocol,
			    samtools_exec   => $rnaseq->samtools_exec
			   );
$bitWise->update_bitwise_flags();
ok($rnaseq->_split_bam_by_chromosome, 'split up the bams and run mpileup on a file where there are reads mapping to features');

for my $feature (values %{$rnaseq->_annotation_file->features})
{
  is($feature->reads_mapping, 0, 'we havent flagged if reads are mapping from mpileup yet');
}

ok($rnaseq->flag_features_with_no_annotation, 'flag up features with no annotation');

is($rnaseq->_annotation_file->features->{'Gene1'}->reads_mapping, 1,'gene 1 has mapping');
is($rnaseq->_annotation_file->features->{'Gene2'}->reads_mapping, 0,'gene 2 has no mapping');
is($rnaseq->_annotation_file->features->{'Gene3'}->reads_mapping, 0,'gene 3 has no mapping');

unlink('t/data/gffs_sams/mapping_to_one_feature_mammal.bam') if ( -e 't/data/gffs_sams/mapping_to_one_feature_mammal.bam');
done_testing();