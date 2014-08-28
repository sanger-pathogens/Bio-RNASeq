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


##Overlapping in different frames of translation
#For Chado gff's we should test for the gene feature types and not for the CDS feature types. Including both for now. But the first ones should fail
$test_name = 'Checking presence of unwanted features - overlapping in different frames of translation - Chado';
@feature_names = qw(GreatCurl.1 GreatCurl.1:exon:1 GreatCurl.2:exon:2 GreatCurl.1:pep SunBurn.1 SunBurn.1:exon:1 SunBurn.1:pep);

run_rna_seq_check_non_existence_of_a_feature( 't/data/gffs_sams/overlapping_in_diff_frames_of_trans_chado.sam','t/data/gffs_sams/overlapping_in_diff_frames_of_trans_chado.gff', \@feature_names, $test_name, $intergenic_regions );
run_rna_seq_check_non_existence_of_a_feature_strand_specific( 't/data/gffs_sams/overlapping_in_diff_frames_of_trans_chado.sam','t/data/gffs_sams/overlapping_in_diff_frames_of_trans_chado.gff', \@feature_names, $test_name, $intergenic_regions );


#Chado total mapped reads based on gene feture type
$test_name = 'Chado GFF gene feature type overlapping in diff frames of translation';
@expected_results_library = (
			['GreatCurl', 'Total Reads Mapping', 6],
			['GreatCurl', 'Sense Reads Mapping', 6],
			['GreatCurl', 'Antisense Reads Mapping', 0],
			['SunBurn', 'Total Reads Mapping', 4],
			['SunBurn', 'Sense Reads Mapping', 4],
			['SunBurn', 'Antisense Reads Mapping', 0],
		       );

run_rna_seq('t/data/gffs_sams/overlapping_in_diff_frames_of_trans_chado.sam','t/data/gffs_sams/overlapping_in_diff_frames_of_trans_chado.gff', \@expected_results_library, 'DUMMY_CHADO_CHR', $test_name, $intergenic_regions );

$test_name = 'EMBL GFF overlapping in diff frames of translation';
@expected_results_library = (
			['DUMMY_EMBL_CHR.1', 'Total Reads Mapping', 4],
			['DUMMY_EMBL_CHR.1', 'Sense Reads Mapping', 4],
			['DUMMY_EMBL_CHR.1', 'Antisense Reads Mapping', 0],
			['DUMMY_EMBL_CHR.5', 'Total Reads Mapping', 4],
			['DUMMY_EMBL_CHR.5', 'Sense Reads Mapping', 4],
			['DUMMY_EMBL_CHR.5', 'Antisense Reads Mapping', 0],
			['DUMMY_EMBL_CHR.9', 'Total Reads Mapping', 4],
			['DUMMY_EMBL_CHR.9', 'Sense Reads Mapping', 4],
			['DUMMY_EMBL_CHR.9', 'Antisense Reads Mapping', 0],

			    );

run_rna_seq('t/data/gffs_sams/overlapping_in_diff_frames_of_trans_embl.sam','t/data/gffs_sams/overlapping_in_diff_frames_of_trans_embl.gff', \@expected_results_library, 'DUMMY_EMBL_CHR', $test_name, $intergenic_regions );


$test_name = 'Annot GFF overlapping in diff frames of translation';
@expected_results_library = (
			['Clostridium_difficile_630_v1.9_00001', 'Total Reads Mapping', 4],
			['Clostridium_difficile_630_v1.9_00001', 'Sense Reads Mapping', 4],
			['Clostridium_difficile_630_v1.9_00001', 'Antisense Reads Mapping', 0],
			['Clostridium_difficile_630_v1.9_00002', 'Total Reads Mapping', 4],
			['Clostridium_difficile_630_v1.9_00002', 'Sense Reads Mapping', 4],
			['Clostridium_difficile_630_v1.9_00002', 'Antisense Reads Mapping', 0],
			['Clostridium_difficile_630_v1.9_00004', 'Total Reads Mapping', 4],
			['Clostridium_difficile_630_v1.9_00004', 'Sense Reads Mapping', 4],
			['Clostridium_difficile_630_v1.9_00004', 'Antisense Reads Mapping', 0],
		       );

run_rna_seq('t/data/gffs_sams/overlapping_in_diff_frames_of_trans_annot.sam','t/data/gffs_sams/overlapping_in_diff_frames_of_trans_annot.gff', \@expected_results_library, 'DUMMY_ANNOT_CHR', $test_name, $intergenic_regions );

done_testing();

