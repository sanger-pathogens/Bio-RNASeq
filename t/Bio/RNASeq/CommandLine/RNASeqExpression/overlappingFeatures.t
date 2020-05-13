#!/usr/bin/env perl
use Moose;
use Data::Dumper;
use Test::Most;

BEGIN { unshift( @INC, './t/lib' ) }
with 'gffTestHelper';

my $test_name = '';
my (@expected_results_library, @feature_names);



#Overlapping features
#For Chado gff's we should test for the gene feature types and not for the CDS feature types. Including both for now. But the first ones should fail
$test_name = 'Checking presence of unwanted features - overlapping features - Chado';
@feature_names = qw(GreatCurl.1 GreatCurl.1:exon:1 GreatCurl.2:exon:2 GreatCurl.3:exon:3 GreatCurl.1:pep MightyLip.1 MightyLip.1:exon:1 MightyLip.2:exon:2 MightyLip.1:pep);

run_rna_seq_check_non_existence_of_a_feature( 't/data/gffs_sams/overlapping_genes_chado.sam','t/data/gffs_sams/overlapping_genes_chado.gff', \@feature_names, $test_name );
run_rna_seq_check_non_existence_of_a_feature_strand_specific( 't/data/gffs_sams/overlapping_genes_chado.sam','t/data/gffs_sams/overlapping_genes_chado.gff', \@feature_names, $test_name );

#Chado total mapped reads based on gene feture type
$test_name = 'Chado GFF overlapping genes';
@expected_results_library = (
			['GreatCurl', 'Total Reads Mapping', 4,'Chado GFF overlapping genes'],
			['GreatCurl', 'Sense Reads Mapping', 4,'Chado GFF overlapping genes'],
			['GreatCurl', 'Antisense Reads Mapping', 0,'Chado GFF overlapping genes'],
			['MightyLip', 'Total Reads Mapping', 3,'Chado GFF overlapping genes'],
			['MightyLip', 'Sense Reads Mapping', 3,'Chado GFF overlapping genes'],
			['MightyLip', 'Antisense Reads Mapping', 0,'Chado GFF overlapping genes'],
		       );

run_rna_seq( 't/data/gffs_sams/overlapping_genes_chado.sam','t/data/gffs_sams/overlapping_genes_chado.gff', \@expected_results_library, $test_name );


$test_name = 'Annot GFF overlapping features';
@expected_results_library = (
			['Clostridium_difficile_630_v1.9_00001', 'Total Reads Mapping', 2,'Annot GFF overlapping features'],
			['Clostridium_difficile_630_v1.9_00001', 'Sense Reads Mapping', 2,'Annot GFF overlapping features'],
			['Clostridium_difficile_630_v1.9_00001', 'Antisense Reads Mapping', 0,'Annot GFF overlapping features'],
			['Clostridium_difficile_630_v1.9_00002', 'Total Reads Mapping', 2,'Annot GFF overlapping features'],
			['Clostridium_difficile_630_v1.9_00002', 'Sense Reads Mapping', 2,'Annot GFF overlapping features'],
			['Clostridium_difficile_630_v1.9_00002', 'Antisense Reads Mapping', 0,'Annot GFF overlapping features'],
			['Clostridium_difficile_630_v1.9_00003', 'Total Reads Mapping', 1,'Annot GFF overlapping features'],
			['Clostridium_difficile_630_v1.9_00003', 'Sense Reads Mapping', 1,'Annot GFF overlapping features'],
			['Clostridium_difficile_630_v1.9_00003', 'Antisense Reads Mapping', 0,'Annot GFF overlapping features'],
			['Clostridium_difficile_630_v1.9_00004', 'Total Reads Mapping', 1,'Annot GFF overlapping features'],
			['Clostridium_difficile_630_v1.9_00004', 'Sense Reads Mapping', 1,'Annot GFF overlapping features'],
			['Clostridium_difficile_630_v1.9_00004', 'Antisense Reads Mapping', 0,'Annot GFF overlapping features'],
			['Clostridium_difficile_630_v1.9_00005', 'Total Reads Mapping', 1,'Annot GFF overlapping features'],
			['Clostridium_difficile_630_v1.9_00005', 'Sense Reads Mapping', 1,'Annot GFF overlapping features'],
			['Clostridium_difficile_630_v1.9_00005', 'Antisense Reads Mapping', 0,'Annot GFF overlapping features'],
		       );

run_rna_seq( 't/data/gffs_sams/overlapping_genes_annot.sam','t/data/gffs_sams/overlapping_genes_annot.gff', \@expected_results_library, $test_name );


$test_name = 'EMBL GFF overlapping features';
@expected_results_library = (
			['DUMMY_EMBL_CHR.1', 'Total Reads Mapping', 2,'EMBL GFF overlapping features'],
			['DUMMY_EMBL_CHR.1', 'Sense Reads Mapping', 2,'EMBL GFF overlapping features'],
			['DUMMY_EMBL_CHR.1', 'Antisense Reads Mapping', 0,'EMBL GFF overlapping features'],
			['DUMMY_EMBL_CHR.5', 'Total Reads Mapping', 2,'EMBL GFF overlapping features'],
			['DUMMY_EMBL_CHR.5', 'Sense Reads Mapping', 2,'EMBL GFF overlapping features'],
			['DUMMY_EMBL_CHR.5', 'Antisense Reads Mapping', 0,'EMBL GFF overlapping features'],
			['DUMMY_EMBL_CHR.9', 'Total Reads Mapping', 1,'EMBL GFF overlapping features'],
			['DUMMY_EMBL_CHR.9', 'Sense Reads Mapping', 1,'EMBL GFF overlapping features'],
			['DUMMY_EMBL_CHR.9', 'Antisense Reads Mapping', 0,'EMBL GFF overlapping features'],
			['DUMMY_EMBL_CHR.10', 'Total Reads Mapping', 1,'EMBL GFF overlapping features'],
			['DUMMY_EMBL_CHR.10', 'Sense Reads Mapping', 1,'EMBL GFF overlapping features'],
			['DUMMY_EMBL_CHR.10', 'Antisense Reads Mapping', 0,'EMBL GFF overlapping features'],
			['DUMMY_EMBL_CHR.11', 'Total Reads Mapping', 1,'EMBL GFF overlapping features'],
			['DUMMY_EMBL_CHR.11', 'Sense Reads Mapping', 1,'EMBL GFF overlapping features'],
			['DUMMY_EMBL_CHR.11', 'Antisense Reads Mapping', 0,'EMBL GFF overlapping features'],
		       );

run_rna_seq( 't/data/gffs_sams/overlapping_genes_embl.sam','t/data/gffs_sams/overlapping_genes_embl.gff', \@expected_results_library, $test_name );
##END Overlapping features

done_testing();
