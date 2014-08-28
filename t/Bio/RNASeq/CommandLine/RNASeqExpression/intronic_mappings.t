#!/usr/bin/env perl
use Moose;
use Data::Dumper;
use Test::Most;

BEGIN { unshift( @INC, './lib' ) }
BEGIN { unshift( @INC, './t/lib' ) }
with 'gffTestHelper';

my $test_name = '';
my $intergenic_regions = 0;
my (@expected_results_library, @feature_names);



##Reads in intronic regions and at their boundaries
#For Chado gff's we should test for the gene feature types and not for the CDS feature types. Including both for now. But the first ones should fail
$test_name = 'Checking presence of unwanted features - intronic regions - Chado';
@feature_names = qw(GreatCurl.1 GreatCurl.1:exon:1 GreatCurl.2:exon:2 GreatCurl.1:pep);

run_rna_seq_check_non_existence_of_a_feature( 't/data/gffs_sams/intronic_mapping_chado.sam','t/data/gffs_sams/intronic_mapping_chado.gff', \@feature_names, $test_name, $intergenic_regions );
run_rna_seq_check_non_existence_of_a_feature_strand_specific( 't/data/gffs_sams/intronic_mapping_chado.sam','t/data/gffs_sams/intronic_mapping_chado.gff', \@feature_names, $test_name, $intergenic_regions );


#Chado total mapped reads based on gene feture type
$test_name = 'Chado GFF gene feature type intronic mappings';
@expected_results_library = (
			['GreatCurl', 'Total Reads Mapping', 9],
			['GreatCurl', 'Sense Reads Mapping', 9],
			['GreatCurl', 'Antisense Reads Mapping', 0],
		       );

run_rna_seq('t/data/gffs_sams/intronic_mapping_chado.sam','t/data/gffs_sams/intronic_mapping_chado.gff', \@expected_results_library, 'DUMMY_CHADO_CHR', $test_name, $intergenic_regions );


$test_name = 'EMBL GFF intronic mappings';
@expected_results_library = (
			['DUMMY_EMBL_CHR.1', 'Total Reads Mapping', 4],
			['DUMMY_EMBL_CHR.1', 'Sense Reads Mapping', 4],
			['DUMMY_EMBL_CHR.1', 'Antisense Reads Mapping', 0],
			['DUMMY_EMBL_CHR.5', 'Total Reads Mapping', 4],
			['DUMMY_EMBL_CHR.5', 'Sense Reads Mapping', 4],
			['DUMMY_EMBL_CHR.5', 'Antisense Reads Mapping', 0],
			    );

run_rna_seq('t/data/gffs_sams/intronic_mapping_embl.sam','t/data/gffs_sams/intronic_mapping_embl.gff', \@expected_results_library, 'DUMMY_EMBL_CHR', $test_name, $intergenic_regions );

#
$test_name = 'Annot GFF intronic mappings';
@expected_results_library = (
			['Clostridium_difficile_630_v1.9_00001', 'Total Reads Mapping', 4],
			['Clostridium_difficile_630_v1.9_00001', 'Sense Reads Mapping', 4],
			['Clostridium_difficile_630_v1.9_00001', 'Antisense Reads Mapping', 0],
			['Clostridium_difficile_630_v1.9_00002', 'Total Reads Mapping', 4],
			['Clostridium_difficile_630_v1.9_00002', 'Sense Reads Mapping', 4],
			['Clostridium_difficile_630_v1.9_00002', 'Antisense Reads Mapping', 0],
		       );

run_rna_seq('t/data/gffs_sams/intronic_mapping_annot.sam','t/data/gffs_sams/intronic_mapping_annot.gff', \@expected_results_library, 'DUMMY_ANNOT_CHR', $test_name, $intergenic_regions );
##End of intronic mappings

done_testing();
