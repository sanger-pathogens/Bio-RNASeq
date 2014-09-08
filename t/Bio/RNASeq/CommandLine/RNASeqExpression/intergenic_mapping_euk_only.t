#!/usr/bin/env perl
use Moose;
use Data::Dumper;
use Test::Most;

BEGIN { unshift( @INC, './lib' ) }
BEGIN { unshift( @INC, './t/lib' ) }
with 'gffTestHelper';

my $test_name = '';
my $intergenic_regions = '';
my (@expected_results_library, @feature_names);


##Intergenic mappings and their boundaries - Eukaryotic organisms only
$test_name = 'Checking presence of unwanted features - intergenic mappings and boundaries - Chado';
@feature_names = qw(GreatCurl.1 GreatCurl.1:exon:1 GreatCurl.2:exon:2 GreatCurl.1:pep SunBurn.1 SunBurn.1:exon:1 SunBurn.1:pep);

run_rna_seq_check_non_existence_of_a_feature( 't/data/gffs_sams/intergenic_mapping_chado.sam','t/data/gffs_sams/intergenic_mapping_chado.gff', \@feature_names, $test_name, $intergenic_regions );
run_rna_seq_check_non_existence_of_a_feature_strand_specific( 't/data/gffs_sams/intergenic_mapping_chado.sam','t/data/gffs_sams/intergenic_mapping_chado.gff', \@feature_names, $test_name, $intergenic_regions );


#Chado total mapped reads based on gene feture type
$test_name = 'Chado GFF gene feature type intergenic mappings';
@expected_results_library = (
			['GreatCurl', 'Total Reads Mapping', 3],
			['GreatCurl', 'Sense Reads Mapping', 3],
			['GreatCurl', 'Antisense Reads Mapping', 0],
			['SunBurn', 'Total Reads Mapping', 5],
			['SunBurn', 'Sense Reads Mapping', 5],
			['SunBurn', 'Antisense Reads Mapping', 0],
		       );

run_rna_seq('t/data/gffs_sams/intergenic_mapping_chado.sam','t/data/gffs_sams/intergenic_mapping_chado.gff', \@expected_results_library, 'DUMMY_CHADO_CHR', $test_name, $intergenic_regions );
##End intergenic mappings

done_testing();

