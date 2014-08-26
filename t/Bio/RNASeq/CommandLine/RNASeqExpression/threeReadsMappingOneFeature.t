#!/usr/bin/env perl
use Moose;
use Data::Dumper;
use Test::Most;

BEGIN { unshift( @INC, './lib' ) }
BEGIN { unshift( @INC, './t/lib' ) }
with 'gffTestHelper';

my @expected_results_library;


#3 Reads mapping - 1 partly flanking to the left, 1 straight inside, 1 slightly flanking to the right
#For Chado gff's we should test for the gene feature types and not for the CDS feature types
@expected_results_library = (
			['GreatCurl.1:exon:1', 'Total Reads Mapping', 3,'Chado GFF 3 reads mapping flanking'],
			['GreatCurl.1:exon:1', 'Sense Reads Mapping', 3,'Chado GFF 3 reads mapping flanking'],
			['GreatCurl.1:exon:1', 'Antisense Reads Mapping', 0,'Chado GFF 3 reads mapping flanking'],
			['GreatCurl.3:exon:3', 'Total Reads Mapping', 0,'Chado GFF 3 reads mapping flanking'],
			['GreatCurl.3:exon:3', 'Sense Reads Mapping', 0,'Chado GFF 3 reads mapping flanking'],
			['GreatCurl.3:exon:3', 'Antisense Reads Mapping', 0,'Chado GFF 3 reads mapping flanking'],
		       );

run_rna_seq('t/data/gffs_sams/mapping_to_one_feature_chado.sam','t/data/gffs_sams/multipurpose_3_cds_chado.gff', \@expected_results_library);



@expected_results_library = (
			['Clostridium_difficile_630_v1.9_00001', 'Total Reads Mapping', 3,'Annot GFF 3 reads mapping flanking'],
			['Clostridium_difficile_630_v1.9_00001', 'Sense Reads Mapping', 3,'Annot GFF 3 reads mapping flanking'],
			['Clostridium_difficile_630_v1.9_00001', 'Antisense Reads Mapping', 0,'Annot GFF 3 reads mapping flanking'],
			['Clostridium_difficile_630_v1.9_00002', 'Total Reads Mapping', 0,'Annot GFF 3 reads mapping flanking'],
			['Clostridium_difficile_630_v1.9_00002', 'Sense Reads Mapping', 0,'Annot GFF 3 reads mapping flanking'],
			['Clostridium_difficile_630_v1.9_00002', 'Antisense Reads Mapping', 0,'Annot GFF 3 reads mapping flanking'],
		       );

run_rna_seq('t/data/gffs_sams/mapping_to_one_feature_annot.sam','t/data/gffs_sams/multipurpose_3_cds_annot.gff', \@expected_results_library);

@expected_results_library = (
			['DUMMY_EMBL_CHR.5', 'Total Reads Mapping', 3,'EMBL GFF 3 reads mapping flanking'],
			['DUMMY_EMBL_CHR.5', 'Sense Reads Mapping', 3,'EMBL GFF 3 reads mapping flanking'],
			['DUMMY_EMBL_CHR.5', 'Antisense Reads Mapping', 0,'EMBL GFF 3 reads mapping flanking'],
			['DUMMY_EMBL_CHR.1', 'Total Reads Mapping', 0,'EMBL GFF 3 reads mapping flanking'],
			['DUMMY_EMBL_CHR.1', 'Sense Reads Mapping', 0,'EMBL GFF 3 reads mapping flanking'],
			['DUMMY_EMBL_CHR.1', 'Antisense Reads Mapping', 0,'EMBL GFF 3 reads mapping flanking'],
		       );

run_rna_seq('t/data/gffs_sams/mapping_to_one_feature_embl.sam','t/data/gffs_sams/multipurpose_3_cds_embl.gff', \@expected_results_library);
#END 3 reads mapping

done_testing();
