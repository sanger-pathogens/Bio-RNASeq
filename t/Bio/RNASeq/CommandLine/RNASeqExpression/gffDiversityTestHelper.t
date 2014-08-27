#!/usr/bin/env perl
use Moose;
use Data::Dumper;
use File::Slurp;
use File::Path qw( remove_tree);
use File::Spec;
use File::Temp qw/ tempdir /;
use Text::CSV;
use Cwd;

BEGIN { unshift( @INC, './lib' ) }
BEGIN { unshift( @INC, './t/lib' ) }
with 'gffTestHelper';


BEGIN {
    use Test::Most;
    use Bio::RNASeq::CommandLine::RNASeqExpression;
}

my @expected_results_library;





#Split Reads
#For Chado gff's we should test for the gene feature types and not for the CDS feature types
@expected_results_library = (
			['GreatCurl.1:exon:1', 'Total Reads Mapping', 1,'Chado GFF split reads mapping'],
			['GreatCurl.1:exon:1', 'Sense Reads Mapping', 1,'Chado GFF split reads mapping'],
			['GreatCurl.1:exon:1', 'Antisense Reads Mapping', 0,'Chado GFF split reads mapping'],
			['GreatCurl.3:exon:3', 'Total Reads Mapping', 1,'Chado GFF split reads mapping'],
			['GreatCurl.3:exon:3', 'Sense Reads Mapping', 1,'Chado GFF split reads mapping'],
			['GreatCurl.3:exon:3', 'Antisense Reads Mapping', 0,'Chado GFF split reads mapping'],
		       );

run_rna_seq('t/data/gffs_sams/split_read_mapping_to_2_cds_chado.sam','t/data/gffs_sams/split_reads_chado.gff', \@expected_results_library);

#Chado total mapped reads based on gene feture type
@expected_results_library = (
			['GreatCurl', 'Total Reads Mapping', 2,'Chado GFF gene feature type split reads mapping'],
			['GreatCurl', 'Sense Reads Mapping', 2,'Chado GFF gene feature type split reads mapping'],
			['GreatCurl', 'Antisense Reads Mapping', 0,'Chado GFF gene feature type split reads mapping'],
			['SplitHair', 'Total Reads Mapping', 1,'Chado GFF gene feature type split reads mapping'],
			['SplitHair', 'Sense Reads Mapping', 1,'Chado GFF gene feature type split reads mapping'],
			['SplitHair', 'Antisense Reads Mapping', 0,'Chado GFF gene feature type split reads mapping'],
		       );

run_rna_seq('t/data/gffs_sams/split_read_mapping_to_2_cds_chado.sam','t/data/gffs_sams/split_reads_chado.gff', \@expected_results_library);


@expected_results_library = (
			['Clostridium_difficile_630_v1.9_00001', 'Total Reads Mapping', 1,'Annot GFF split reads mapping'],
			['Clostridium_difficile_630_v1.9_00001', 'Sense Reads Mapping', 1,'Annot GFF split reads mapping'],
			['Clostridium_difficile_630_v1.9_00001', 'Antisense Reads Mapping', 0,'Annot GFF split reads mapping'],
			['Clostridium_difficile_630_v1.9_00002', 'Total Reads Mapping', 2,'Annot GFF split reads mapping'],
			['Clostridium_difficile_630_v1.9_00002', 'Sense Reads Mapping', 2,'Annot GFF split reads mapping'],
			['Clostridium_difficile_630_v1.9_00002', 'Antisense Reads Mapping', 0,'Annot GFF split reads mapping'],
			['Clostridium_difficile_630_v1.9_00003', 'Total Reads Mapping', 2,'Annot GFF split reads mapping'],
			['Clostridium_difficile_630_v1.9_00003', 'Sense Reads Mapping', 2,'Annot GFF split reads mapping'],
			['Clostridium_difficile_630_v1.9_00003', 'Antisense Reads Mapping', 0,'Annot GFF split reads mapping'],
			['Clostridium_difficile_630_v1.9_00004', 'Total Reads Mapping', 1,'Annot GFF split reads mapping'],
			['Clostridium_difficile_630_v1.9_00004', 'Sense Reads Mapping', 1,'Annot GFF split reads mapping'],
			['Clostridium_difficile_630_v1.9_00004', 'Antisense Reads Mapping', 0,'Annot GFF split reads mapping'],
		       );

run_rna_seq('t/data/gffs_sams/split_read_mapping_to_2_cds_annot.sam','t/data/gffs_sams/split_reads_annot.gff', \@expected_results_library);



@expected_results_library = (
			['DUMMY_EMBL_CHR.1', 'Total Reads Mapping', 1,'EMBL GFF split reads mapping'],
			['DUMMY_EMBL_CHR.1', 'Sense Reads Mapping', 1,'EMBL GFF split reads mapping'],
			['DUMMY_EMBL_CHR.1', 'Antisense Reads Mapping', 0,'EMBL GFF split reads mapping'],
			['DUMMY_EMBL_CHR.5', 'Total Reads Mapping', 2,'EMBL GFF split reads mapping'],
			['DUMMY_EMBL_CHR.5', 'Sense Reads Mapping', 2,'EMBL GFF split reads mapping'],
			['DUMMY_EMBL_CHR.5', 'Antisense Reads Mapping', 0,'EMBL GFF split reads mapping'],
			['DUMMY_EMBL_CHR.9', 'Total Reads Mapping', 2,'EMBL GFF split reads mapping'],
			['DUMMY_EMBL_CHR.9', 'Sense Reads Mapping', 2,'EMBL GFF split reads mapping'],
			['DUMMY_EMBL_CHR.9', 'Antisense Reads Mapping', 0,'EMBL GFF split reads mapping'],
			['DUMMY_EMBL_CHR.10', 'Total Reads Mapping', 1,'EMBL GFF split reads mapping'],
			['DUMMY_EMBL_CHR.10', 'Sense Reads Mapping', 1,'EMBL GFF split reads mapping'],
			['DUMMY_EMBL_CHR.10', 'Antisense Reads Mapping', 0,'EMBL GFF split reads mapping'],
		       );

run_rna_seq('t/data/gffs_sams/split_read_mapping_to_2_cds_embl.sam','t/data/gffs_sams/split_reads_embl.gff', \@expected_results_library);
##END Split Reads

#

#Overlapping features
#For Chado gff's we should test for the gene feature types and not for the CDS feature types. Including both for now. But the first ones should fail
@expected_results_library = (
			['GreatCurl.1:exon:1', 'Total Reads Mapping', 2,'Chado GFF overlapping features'],
			['GreatCurl.1:exon:1', 'Sense Reads Mapping', 2,'Chado GFF overlapping features'],
			['GreatCurl.1:exon:1', 'Antisense Reads Mapping', 0,'Chado GFF overlapping features'],
			['GreatCurl.2:exon:2', 'Total Reads Mapping', 1,'Chado GFF overlapping features'],
			['GreatCurl.2:exon:2', 'Sense Reads Mapping', 1,'Chado GFF overlapping features'],
			['GreatCurl.2:exon:2', 'Antisense Reads Mapping', 0,'Chado GFF overlapping features'],
			['GreatCurl.3:exon:3', 'Total Reads Mapping', 1,'Chado GFF overlapping features'],
			['GreatCurl.3:exon:3', 'Sense Reads Mapping', 1,'Chado GFF overlapping features'],
			['GreatCurl.3:exon:3', 'Antisense Reads Mapping', 0,'Chado GFF overlapping features'],
			['MightyLip.1:exon:1', 'Total Reads Mapping', 2,'Chado GFF overlapping features'],
			['MightyLip.1:exon:1', 'Sense Reads Mapping', 2,'Chado GFF overlapping features'],
			['MightyLip.1:exon:1', 'Antisense Reads Mapping', 0,'Chado GFF overlapping features'],
			['MightyLip.2:exon:2', 'Total Reads Mapping', 1,'Chado GFF overlapping features'],
			['MightyLip.2:exon:2', 'Sense Reads Mapping', 1,'Chado GFF overlapping features'],
			['MightyLip.2:exon:2', 'Antisense Reads Mapping', 0,'Chado GFF overlapping features'],
		       );

run_rna_seq('t/data/gffs_sams/overlapping_genes_chado.sam','t/data/gffs_sams/overlapping_genes_chado.gff', \@expected_results_library);

#Chado total mapped reads based on gene feture type
@expected_results_library = (
			['GreatCurl', 'Total Reads Mapping', 4,'Chado GFF overlapping genes'],
			['GreatCurl', 'Sense Reads Mapping', 4,'Chado GFF overlapping genes'],
			['GreatCurl', 'Antisense Reads Mapping', 0,'Chado GFF overlapping genes'],
			['MightyLip', 'Total Reads Mapping', 3,'Chado GFF overlapping genes'],
			['MightyLip', 'Sense Reads Mapping', 3,'Chado GFF overlapping genes'],
			['MightyLip', 'Antisense Reads Mapping', 0,'Chado GFF overlapping genes'],
		       );

run_rna_seq('t/data/gffs_sams/overlapping_genes_chado.sam','t/data/gffs_sams/overlapping_genes_chado.gff', \@expected_results_library);

#

#

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

run_rna_seq('t/data/gffs_sams/overlapping_genes_annot.sam','t/data/gffs_sams/overlapping_genes_annot.gff', \@expected_results_library);




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

run_rna_seq('t/data/gffs_sams/overlapping_genes_embl.sam','t/data/gffs_sams/overlapping_genes_embl.gff', \@expected_results_library);
##END Overlapping features

#

##Overlapping in different frames of translation
#For Chado gff's we should test for the gene feature types and not for the CDS feature types. Including both for now. But the first ones should fail
@expected_results_library = (
			['GreatCurl.1:exon:1', 'Total Reads Mapping', 4,'Chado GFF overlapping in diff frames of translation'],
			['GreatCurl.1:exon:1', 'Sense Reads Mapping', 4,'Chado GFF overlapping in diff frames of translation'],
			['GreatCurl.1:exon:1', 'Antisense Reads Mapping', 0,'Chado GFF overlapping in diff frames of translation'],
			['GreatCurl.2:exon:2', 'Total Reads Mapping', 4,'Chado GFF overlapping in diff frames of translation'],
			['GreatCurl.2:exon:2', 'Sense Reads Mapping', 4,'Chado GFF overlapping in diff frames of translation'],
			['GreatCurl.2:exon:2', 'Antisense Reads Mapping', 0,'Chado GFF overlapping in diff frames of translation'],
			['SunBurn.1:exon:1', 'Total Reads Mapping', 4,'Chado GFF overlapping in diff frames of translation'],
			['SunBurn.1:exon:1', 'Sense Reads Mapping', 4,'Chado GFF overlapping in diff frames of translation'],
			['SunBurn.1:exon:1', 'Antisense Reads Mapping', 0,'Chado GFF overlapping in diff frames of translation'],
		       );

run_rna_seq('t/data/gffs_sams/overlapping_in_diff_frames_of_trans_chado.sam','t/data/gffs_sams/overlapping_in_diff_frames_of_trans_chado.gff', \@expected_results_library);


#Chado total mapped reads based on gene feture type
@expected_results_library = (
			['GreatCurl', 'Total Reads Mapping', 6,'Chado GFF gene feature type overlapping in diff frames of translation'],
			['GreatCurl', 'Sense Reads Mapping', 6,'Chado GFF gene feature type overlapping in diff frames of translation'],
			['GreatCurl', 'Antisense Reads Mapping', 0,'Chado GFF gene feature type overlapping in diff frames of translation'],
			['SunBurn', 'Total Reads Mapping', 4,'Chado GFF gene feature type overlapping in diff frames of translation'],
			['SunBurn', 'Sense Reads Mapping', 4,'Chado GFF gene feature type overlapping in diff frames of translation'],
			['SunBurn', 'Antisense Reads Mapping', 0,'Chado GFF gene feature type overlapping in diff frames of translation'],
		       );

run_rna_seq('t/data/gffs_sams/overlapping_in_diff_frames_of_trans_chado.sam','t/data/gffs_sams/overlapping_in_diff_frames_of_trans_chado.gff', \@expected_results_library);


@expected_results_library = (
			['DUMMY_EMBL_CHR.1', 'Total Reads Mapping', 4,'EMBL GFF overlapping in diff frames of translation'],
			['DUMMY_EMBL_CHR.1', 'Sense Reads Mapping', 4,'EMBL GFF overlapping in diff frames of translation'],
			['DUMMY_EMBL_CHR.1', 'Antisense Reads Mapping', 0,'EMBL GFF overlapping in diff frames of translation'],
			['DUMMY_EMBL_CHR.5', 'Total Reads Mapping', 4,'EMBL GFF overlapping in diff frames of translation'],
			['DUMMY_EMBL_CHR.5', 'Sense Reads Mapping', 4,'EMBL GFF overlapping in diff frames of translation'],
			['DUMMY_EMBL_CHR.5', 'Antisense Reads Mapping', 0,'EMBL GFF overlapping in diff frames of translation'],
			['DUMMY_EMBL_CHR.9', 'Total Reads Mapping', 4,'EMBL GFF overlapping in diff frames of translation'],
			['DUMMY_EMBL_CHR.9', 'Sense Reads Mapping', 4,'EMBL GFF overlapping in diff frames of translation'],
			['DUMMY_EMBL_CHR.9', 'Antisense Reads Mapping', 0,'EMBL GFF overlapping in diff frames of translation'],

			    );

run_rna_seq('t/data/gffs_sams/overlapping_in_diff_frames_of_trans_embl.sam','t/data/gffs_sams/overlapping_in_diff_frames_of_trans_embl.gff', \@expected_results_library);

#

@expected_results_library = (
			['Clostridium_difficile_630_v1.9_00001', 'Total Reads Mapping', 4,'Annot GFF overlapping in diff frames of translation'],
			['Clostridium_difficile_630_v1.9_00001', 'Sense Reads Mapping', 4,'Annot GFF overlapping in diff frames of translation'],
			['Clostridium_difficile_630_v1.9_00001', 'Antisense Reads Mapping', 0,'Annot GFF overlapping in diff frames of translation'],
			['Clostridium_difficile_630_v1.9_00002', 'Total Reads Mapping', 4,'Annot GFF overlapping in diff frames of translation'],
			['Clostridium_difficile_630_v1.9_00002', 'Sense Reads Mapping', 4,'Annot GFF overlapping in diff frames of translation'],
			['Clostridium_difficile_630_v1.9_00002', 'Antisense Reads Mapping', 0,'Annot GFF overlapping in diff frames of translation'],
			['Clostridium_difficile_630_v1.9_00004', 'Total Reads Mapping', 4,'Annot GFF overlapping in diff frames of translation'],
			['Clostridium_difficile_630_v1.9_00004', 'Sense Reads Mapping', 4,'Annot GFF overlapping in diff frames of translation'],
			['Clostridium_difficile_630_v1.9_00004', 'Antisense Reads Mapping', 0,'Annot GFF overlapping in diff frames of translation'],
		       );

run_rna_seq('t/data/gffs_sams/overlapping_in_diff_frames_of_trans_annot.sam','t/data/gffs_sams/overlapping_in_diff_frames_of_trans_annot.gff', \@expected_results_library);
##END of Overlapping in diff frames of translation
#

#

#Experimental tiny regions
@expected_results_library = (
			['TeenyTiny.1:exon:1', 'Total Reads Mapping', 4,'one tiny test'],
			['TeenyTiny.1:exon:1', 'Sense Reads Mapping', 4,'one tiny test'],
			['TeenyTiny.1:exon:1', 'Antisense Reads Mapping', 0,'one tiny test'],
			['TeenyTiny.2:exon:2', 'Total Reads Mapping', 1,'one tiny test'],
			['TeenyTiny.2:exon:2', 'Sense Reads Mapping', 1,'one tiny test'],
			['TeenyTiny.2:exon:2', 'Antisense Reads Mapping', 0,'one tiny test'],
		       );

run_rna_seq('t/data/gffs_sams/tiny_chado.sam','t/data/gffs_sams/tiny_chado.gff', \@expected_results_library);




@expected_results_library = (
			['TeenyTiny.1:exon:1', 'Total Reads Mapping', 1,'one tiny test'],
			['TeenyTiny.1:exon:1', 'Sense Reads Mapping', 1,'one tiny test'],
			['TeenyTiny.1:exon:1', 'Antisense Reads Mapping', 0,'one tiny test'],
			['TeenyTiny.2:exon:2', 'Total Reads Mapping', 2,'one tiny test'],
			['TeenyTiny.2:exon:2', 'Sense Reads Mapping', 2,'one tiny test'],
			['TeenyTiny.2:exon:2', 'Antisense Reads Mapping', 0,'one tiny test'],
			['TeenyTiny.3:exon:3', 'Total Reads Mapping', 1,'one tiny test'],
			['TeenyTiny.3:exon:3', 'Sense Reads Mapping', 1,'one tiny test'],
			['TeenyTiny.3:exon:3', 'Antisense Reads Mapping', 0,'one tiny test'],
		       );

run_rna_seq('t/data/gffs_sams/overlap_simple_tiny_chado.sam','t/data/gffs_sams/overlap_simple_tiny_chado.gff', \@expected_results_library);
##END of tiny regions

#

##Reads in intronic regions and at their boundaries
#For Chado gff's we should test for the gene feature types and not for the CDS feature types. Including both for now. But the first ones should fail
@expected_results_library = (
			['GreatCurl.1:exon:1', 'Total Reads Mapping', 4,'Chado GFF intronic mappings'],
			['GreatCurl.1:exon:1', 'Sense Reads Mapping', 4,'Chado GFF intronic mappings'],
			['GreatCurl.1:exon:1', 'Antisense Reads Mapping', 0,'Chado GFF intronic mappings'],
			['GreatCurl.2:exon:2', 'Total Reads Mapping', 4,'Chado GFF intronic mappings'],
			['GreatCurl.2:exon:2', 'Sense Reads Mapping', 4,'Chado GFF intronic mappings'],
			['GreatCurl.2:exon:2', 'Antisense Reads Mapping', 0,'Chado GFF intronic mappings'],
		       );

run_rna_seq('t/data/gffs_sams/intronic_mapping_chado.sam','t/data/gffs_sams/intronic_mapping_chado.gff', \@expected_results_library);


#Chado total mapped reads based on gene feture type
@expected_results_library = (
			['GreatCurl', 'Total Reads Mapping', 9,'Chado GFF gene feature type intronic mappings'],
			['GreatCurl', 'Sense Reads Mapping', 9,'Chado GFF gene feature type intronic mappings'],
			['GreatCurl', 'Antisense Reads Mapping', 0,'Chado GFF gene feature type intronic mappings'],
		       );

run_rna_seq('t/data/gffs_sams/intronic_mapping_chado.sam','t/data/gffs_sams/intronic_mapping_chado.gff', \@expected_results_library);


@expected_results_library = (
			['DUMMY_EMBL_CHR.1', 'Total Reads Mapping', 4,'EMBL GFF intronic mappings'],
			['DUMMY_EMBL_CHR.1', 'Sense Reads Mapping', 4,'EMBL GFF intronic mappings'],
			['DUMMY_EMBL_CHR.1', 'Antisense Reads Mapping', 0,'EMBL GFF intronic mappings'],
			['DUMMY_EMBL_CHR.5', 'Total Reads Mapping', 4,'EMBL GFF intronic mappings'],
			['DUMMY_EMBL_CHR.5', 'Sense Reads Mapping', 4,'EMBL GFF intronic mappings'],
			['DUMMY_EMBL_CHR.5', 'Antisense Reads Mapping', 0,'EMBL GFF intronic mappings'],
			    );

run_rna_seq('t/data/gffs_sams/intronic_mapping_embl.sam','t/data/gffs_sams/intronic_mapping_embl.gff', \@expected_results_library);

#

@expected_results_library = (
			['Clostridium_difficile_630_v1.9_00001', 'Total Reads Mapping', 4,'Annot GFF intronic mappings'],
			['Clostridium_difficile_630_v1.9_00001', 'Sense Reads Mapping', 4,'Annot GFF intronic mappings'],
			['Clostridium_difficile_630_v1.9_00001', 'Antisense Reads Mapping', 0,'Annot GFF intronic mappings'],
			['Clostridium_difficile_630_v1.9_00002', 'Total Reads Mapping', 4,'Annot GFF intronic mappings'],
			['Clostridium_difficile_630_v1.9_00002', 'Sense Reads Mapping', 4,'Annot GFF intronic mappings'],
			['Clostridium_difficile_630_v1.9_00002', 'Antisense Reads Mapping', 0,'Annot GFF intronic mappings'],
		       );

run_rna_seq('t/data/gffs_sams/intronic_mapping_annot.sam','t/data/gffs_sams/intronic_mapping_annot.gff', \@expected_results_library);
##End of intronic mappings



##Intergenic mappings and their boundaries - Eukaryotic organisms only
#For Chado gff's we should test for the gene feature types and not for the CDS feature types. Including both for now. But the first ones should fail
@expected_results_library = (
			['GreatCurl.1:exon:1', 'Total Reads Mapping', 0,'Chado GFF intergenic mappings'],
			['GreatCurl.1:exon:1', 'Sense Reads Mapping', 0,'Chado GFF intergenic mappings'],
			['GreatCurl.1:exon:1', 'Antisense Reads Mapping', 0,'Chado GFF intergenic mappings'],
			['GreatCurl.2:exon:2', 'Total Reads Mapping', 4,'Chado GFF intergenic mappings'],
			['GreatCurl.2:exon:2', 'Sense Reads Mapping', 4,'Chado GFF intergenic mappings'],
			['GreatCurl.2:exon:2', 'Antisense Reads Mapping', 0,'Chado GFF intergenic mappings'],
			['SunBurn.1:exon:1', 'Total Reads Mapping', 5,'Chado GFF intergenic mappings'],
			['SunBurn.1:exon:1', 'Sense Reads Mapping', 5,'Chado GFF intergenic mappings'],
			['SunBurn.1:exon:1', 'Antisense Reads Mapping', 0,'Chado GFF intergenic mappings'],
			['SunBurn.2:exon:2', 'Total Reads Mapping', 0,'Chado GFF intergenic mappings'],
			['SunBurn.2:exon:2', 'Sense Reads Mapping', 0,'Chado GFF intergenic mappings'],
			['SunBurn.2:exon:2', 'Antisense Reads Mapping', 0,'Chado GFF intergenic mappings'],
		       );

run_rna_seq('t/data/gffs_sams/intergenic_mapping_chado.sam','t/data/gffs_sams/intergenic_mapping_chado.gff', \@expected_results_library);


#Chado total mapped reads based on gene feture type
@expected_results_library = (
			['GreatCurl', 'Total Reads Mapping', 4,'Chado GFF gene feature type intergenic mappings'],
			['GreatCurl', 'Sense Reads Mapping', 4,'Chado GFF gene feature type intergenic mappings'],
			['GreatCurl', 'Antisense Reads Mapping', 0,'Chado GFF gene feature type intergenic mappings'],
			['SunBurn', 'Total Reads Mapping', 5,'Chado GFF gene feature type intergenic mappings'],
			['SunBurn', 'Sense Reads Mapping', 5,'Chado GFF gene feature type intergenic mappings'],
			['SunBurn', 'Antisense Reads Mapping', 0,'Chado GFF gene feature type intergenic mappings'],
		       );

run_rna_seq('t/data/gffs_sams/intergenic_mapping_chado.sam','t/data/gffs_sams/intergenic_mapping_chado.gff', \@expected_results_library);
##End intergenic mappings

#

#Standard Protocol, Annot, reads in different strands
@expected_results_library = (
			['Clostridium_difficile_630_v1.9_00001', 'Total Reads Mapping', 3,'Annot GFF 3 reads on reverse strand feature on positive strand'],
			['Clostridium_difficile_630_v1.9_00001', 'Sense Reads Mapping', 0,'Annot GFF 3 reads on reverse strand feature on positive strand'],
			['Clostridium_difficile_630_v1.9_00001', 'Antisense Reads Mapping', 3,'Annot GFF 3 reads on reverse strand feature on positive strand'],
			['Clostridium_difficile_630_v1.9_00002', 'Total Reads Mapping', 0,'Annot GFF 3 reads on reverse strand feature on positive strand'],
			['Clostridium_difficile_630_v1.9_00002', 'Sense Reads Mapping', 0,'Annot GFF 3 reads on reverse strand feature on positive strand'],
			['Clostridium_difficile_630_v1.9_00002', 'Antisense Reads Mapping', 0,'Annot GFF 3 reads on reverse strand feature on positive strand'],
		       );

run_rna_seq('t/data/gffs_sams/mapping_to_one_feature_reverse_strand_annot.sam','t/data/gffs_sams/multipurpose_3_cds_positive_strand_annot.gff', \@expected_results_library);

@expected_results_library = (
			['Clostridium_difficile_630_v1.9_00001', 'Total Reads Mapping', 3,'Annot GFF 3 reads on reverse strand feature on negative strand'],
			['Clostridium_difficile_630_v1.9_00001', 'Sense Reads Mapping', 3,'Annot GFF 3 reads on reverse strand feature on negative strand'],
			['Clostridium_difficile_630_v1.9_00001', 'Antisense Reads Mapping', 0,'Annot GFF 3 reads on reverse strand feature on negative strand'],
			['Clostridium_difficile_630_v1.9_00002', 'Total Reads Mapping', 0,'Annot GFF 3 reads on reverse strand feature on negative strand'],
			['Clostridium_difficile_630_v1.9_00002', 'Sense Reads Mapping', 0,'Annot GFF 3 reads on reverse strand feature on negative strand'],
			['Clostridium_difficile_630_v1.9_00002', 'Antisense Reads Mapping', 0,'Annot GFF 3 reads on reverse strand feature on negative strand'],
		       );

run_rna_seq('t/data/gffs_sams/mapping_to_one_feature_reverse_strand_annot.sam','t/data/gffs_sams/multipurpose_3_cds_negative_strand_annot.gff', \@expected_results_library);

@expected_results_library = (
			['Clostridium_difficile_630_v1.9_00001', 'Total Reads Mapping', 3,'Annot GFF 3 reads on forward strand feature on positive strand'],
			['Clostridium_difficile_630_v1.9_00001', 'Sense Reads Mapping', 3,'Annot GFF 3 reads on forward strand feature on positive strand'],
			['Clostridium_difficile_630_v1.9_00001', 'Antisense Reads Mapping', 0,'Annot GFF 3 reads on forward strand feature on positive strand'],
			['Clostridium_difficile_630_v1.9_00002', 'Total Reads Mapping', 0,'Annot GFF 3 reads on forward strand feature on positive strand'],
			['Clostridium_difficile_630_v1.9_00002', 'Sense Reads Mapping', 0,'Annot GFF 3 reads on forward strand feature on positive strand'],
			['Clostridium_difficile_630_v1.9_00002', 'Antisense Reads Mapping', 0,'Annot GFF 3 reads on forward strand feature on positive strand'],
		       );

run_rna_seq('t/data/gffs_sams/mapping_to_one_feature_forward_strand_annot.sam','t/data/gffs_sams/multipurpose_3_cds_positive_strand_annot.gff', \@expected_results_library);

@expected_results_library = (
			['Clostridium_difficile_630_v1.9_00001', 'Total Reads Mapping', 3,'Annot GFF 3 reads on forward strand feature on negative strand'],
			['Clostridium_difficile_630_v1.9_00001', 'Sense Reads Mapping', 0,'Annot GFF 3 reads on forward strand feature on negative strand'],
			['Clostridium_difficile_630_v1.9_00001', 'Antisense Reads Mapping', 3,'Annot GFF 3 reads on forward strand feature on negative strand'],
			['Clostridium_difficile_630_v1.9_00002', 'Total Reads Mapping', 0,'Annot GFF 3 reads on forward strand feature on negative strand'],
			['Clostridium_difficile_630_v1.9_00002', 'Sense Reads Mapping', 0,'Annot GFF 3 reads on forward strand feature on negative strand'],
			['Clostridium_difficile_630_v1.9_00002', 'Antisense Reads Mapping', 0,'Annot GFF 3 reads on forward strand feature on negative strand'],
		       );

run_rna_seq('t/data/gffs_sams/mapping_to_one_feature_forward_strand_annot.sam','t/data/gffs_sams/multipurpose_3_cds_negative_strand_annot.gff', \@expected_results_library);
##

#Standard Protocol, EMBL, reads in different strands
@expected_results_library = (
			['DUMMY_EMBL_CHR.5', 'Total Reads Mapping', 3,'Embl GFF 3 reads on reverse strand feature on positive strand'],
			['DUMMY_EMBL_CHR.5', 'Sense Reads Mapping', 0,'Embl GFF 3 reads on reverse strand feature on positive strand'],
			['DUMMY_EMBL_CHR.5', 'Antisense Reads Mapping', 3,'Embl GFF 3 reads on reverse strand feature on positive strand'],
		       );

run_rna_seq('t/data/gffs_sams/mapping_to_one_feature_reverse_strand_embl.sam','t/data/gffs_sams/multipurpose_3_cds_positive_strand_embl.gff', \@expected_results_library);

@expected_results_library = (
			['DUMMY_EMBL_CHR.5', 'Total Reads Mapping', 3,'Embl GFF 3 reads on reverse strand feature on negative strand'],
			['DUMMY_EMBL_CHR.5', 'Sense Reads Mapping', 3,'Embl GFF 3 reads on reverse strand feature on negative strand'],
			['DUMMY_EMBL_CHR.5', 'Antisense Reads Mapping', 0,'Embl GFF 3 reads on reverse strand feature on negative strand'],
		       );

run_rna_seq('t/data/gffs_sams/mapping_to_one_feature_reverse_strand_embl.sam','t/data/gffs_sams/multipurpose_3_cds_negative_strand_embl.gff', \@expected_results_library);

@expected_results_library = (
			['DUMMY_EMBL_CHR.5', 'Total Reads Mapping', 3,'Embl GFF 3 reads on forward strand feature on positive strand'],
			['DUMMY_EMBL_CHR.5', 'Sense Reads Mapping', 3,'Embl GFF 3 reads on forward strand feature on positive strand'],
			['DUMMY_EMBL_CHR.5', 'Antisense Reads Mapping', 0,'Embl GFF 3 reads on forward strand feature on positive strand'],
		       );

run_rna_seq('t/data/gffs_sams/mapping_to_one_feature_forward_strand_embl.sam','t/data/gffs_sams/multipurpose_3_cds_positive_strand_embl.gff', \@expected_results_library);

@expected_results_library = (
			['DUMMY_EMBL_CHR.5', 'Total Reads Mapping', 3,'Embl GFF 3 reads on forward strand feature on negative strand'],
			['DUMMY_EMBL_CHR.5', 'Sense Reads Mapping', 0,'Embl GFF 3 reads on forward strand feature on negative strand'],
			['DUMMY_EMBL_CHR.5', 'Antisense Reads Mapping', 3,'Embl GFF 3 reads on forward strand feature on negative strand'],
		       );

run_rna_seq('t/data/gffs_sams/mapping_to_one_feature_forward_strand_embl.sam','t/data/gffs_sams/multipurpose_3_cds_negative_strand_embl.gff', \@expected_results_library);
##END Standard Protocol, EMBL, reads in different strands

#Standard Protocol, Chado, reads in different strands
@expected_results_library = (
			['GreatCurl.1:exon:1', 'Total Reads Mapping', 3,'Chado GFF 3 reads on reverse strand feature on positive strand'],
			['GreatCurl.1:exon:1', 'Sense Reads Mapping', 0,'Chado GFF 3 reads on reverse strand feature on positive strand'],
			['GreatCurl.1:exon:1', 'Antisense Reads Mapping', 3,'Chado GFF 3 reads on reverse strand feature on positive strand'],
		       );

run_rna_seq('t/data/gffs_sams/mapping_to_one_feature_reverse_strand_chado.sam','t/data/gffs_sams/multipurpose_3_cds_positive_strand_chado.gff', \@expected_results_library);

#Gene feature
@expected_results_library = (
			['GreatCurl', 'Total Reads Mapping', 3,'Chado GFF 3 reads on reverse strand gene on positive strand'],
			['GreatCurl', 'Sense Reads Mapping', 0,'Chado GFF 3 reads on reverse strand gene on positive strand'],
			['GreatCurl', 'Antisense Reads Mapping', 3,'Chado GFF 3 reads on reverse strand gene on positive strand'],
		       );

run_rna_seq('t/data/gffs_sams/mapping_to_one_feature_reverse_strand_chado.sam','t/data/gffs_sams/multipurpose_3_cds_positive_strand_chado.gff', \@expected_results_library);

@expected_results_library = (
			['GreatCurl.1:exon:1', 'Total Reads Mapping', 3,'Chado GFF 3 reads on reverse strand feature on negative strand'],
			['GreatCurl.1:exon:1', 'Sense Reads Mapping', 3,'Chado GFF 3 reads on reverse strand feature on negative strand'],
			['GreatCurl.1:exon:1', 'Antisense Reads Mapping', 0,'Chado GFF 3 reads on reverse strand feature on negative strand'],
		       );

run_rna_seq('t/data/gffs_sams/mapping_to_one_feature_reverse_strand_chado.sam','t/data/gffs_sams/multipurpose_3_cds_negative_strand_chado.gff', \@expected_results_library);

#Gene feature
@expected_results_library = (
			['GreatCurl', 'Total Reads Mapping', 3,'Chado GFF 3 reads on reverse strand gene on positive strand'],
			['GreatCurl', 'Sense Reads Mapping', 3,'Chado GFF 3 reads on reverse strand gene on positive strand'],
			['GreatCurl', 'Antisense Reads Mapping', 0,'Chado GFF 3 reads on reverse strand gene on positive strand'],
		       );

run_rna_seq('t/data/gffs_sams/mapping_to_one_feature_reverse_strand_chado.sam','t/data/gffs_sams/multipurpose_3_cds_negative_strand_chado.gff', \@expected_results_library);

@expected_results_library = (
			['GreatCurl.1:exon:1', 'Total Reads Mapping', 3,'Chado GFF 3 reads on forward strand feature on positive strand'],
			['GreatCurl.1:exon:1', 'Sense Reads Mapping', 3,'Chado GFF 3 reads on forward strand feature on positive strand'],
			['GreatCurl.1:exon:1', 'Antisense Reads Mapping', 0,'Chado GFF 3 reads on forward strand feature on positive strand'],
		       );

run_rna_seq('t/data/gffs_sams/mapping_to_one_feature_forward_strand_chado.sam','t/data/gffs_sams/multipurpose_3_cds_positive_strand_chado.gff', \@expected_results_library);

#Gene feature
@expected_results_library = (
			['GreatCurl', 'Total Reads Mapping', 3,'Chado GFF 3 reads on forward strand gene on positive strand'],
			['GreatCurl', 'Sense Reads Mapping', 3,'Chado GFF 3 reads on forward strand gene on positive strand'],
			['GreatCurl', 'Antisense Reads Mapping', 0,'Chado GFF 3 reads on forward strand gene on positive strand'],
		       );

run_rna_seq('t/data/gffs_sams/mapping_to_one_feature_forward_strand_chado.sam','t/data/gffs_sams/multipurpose_3_cds_positive_strand_chado.gff', \@expected_results_library);

@expected_results_library = (
			['GreatCurl.1:exon:1', 'Total Reads Mapping', 3,'Chado GFF 3 reads on forward strand feature on negative strand'],
			['GreatCurl.1:exon:1', 'Sense Reads Mapping', 0,'Chado GFF 3 reads on forward strand feature on negative strand'],
			['GreatCurl.1:exon:1', 'Antisense Reads Mapping', 3,'Chado GFF 3 reads on forward strand feature on negative strand'],
		       );

run_rna_seq('t/data/gffs_sams/mapping_to_one_feature_forward_strand_chado.sam','t/data/gffs_sams/multipurpose_3_cds_negative_strand_chado.gff', \@expected_results_library);

#Gene feature
@expected_results_library = (
			['GreatCurl', 'Total Reads Mapping', 3,'Chado GFF 3 reads on forward strand gene on negative strand'],
			['GreatCurl', 'Sense Reads Mapping', 0,'Chado GFF 3 reads on forward strand gene on negative strand'],
			['GreatCurl', 'Antisense Reads Mapping', 3,'Chado GFF 3 reads on forward strand gene on negative strand'],	
	       );

run_rna_seq('t/data/gffs_sams/mapping_to_one_feature_forward_strand_chado.sam','t/data/gffs_sams/multipurpose_3_cds_negative_strand_chado.gff', \@expected_results_library);
##END Standard Protocol, Chado, reads in different strands


#Strand Specific Protocol, Annot, reads in different strands
@expected_results_library = (
			['Clostridium_difficile_630_v1.9_00001', 'Total Reads Mapping', 3,'Annot GFF 3 reads on reverse strand feature on positive strand - StrandSpecific'],
			['Clostridium_difficile_630_v1.9_00001', 'Sense Reads Mapping', 3,'Annot GFF 3 reads on reverse strand feature on positive strand - StrandSpecific'],
			['Clostridium_difficile_630_v1.9_00001', 'Antisense Reads Mapping', 0,'Annot GFF 3 reads on reverse strand feature on positive strand - StrandSpecific'],
			['Clostridium_difficile_630_v1.9_00002', 'Total Reads Mapping', 0,'Annot GFF 3 reads on reverse strand feature on positive strand - StrandSpecific'],
			['Clostridium_difficile_630_v1.9_00002', 'Sense Reads Mapping', 0,'Annot GFF 3 reads on reverse strand feature on positive strand - StrandSpecific'],
			['Clostridium_difficile_630_v1.9_00002', 'Antisense Reads Mapping', 0,'Annot GFF 3 reads on reverse strand feature on positive strand - StrandSpecific'],
		       );

run_rna_seq_strand_specific('t/data/gffs_sams/mapping_to_one_feature_reverse_strand_annot.sam','t/data/gffs_sams/multipurpose_3_cds_positive_strand_annot.gff', \@expected_results_library);

@expected_results_library = (
			['Clostridium_difficile_630_v1.9_00001', 'Total Reads Mapping', 3,'Annot GFF 3 reads on reverse strand feature on negative strand - StrandSpecific'],
			['Clostridium_difficile_630_v1.9_00001', 'Sense Reads Mapping', 0,'Annot GFF 3 reads on reverse strand feature on negative strand - StrandSpecific'],
			['Clostridium_difficile_630_v1.9_00001', 'Antisense Reads Mapping', 3,'Annot GFF 3 reads on reverse strand feature on negative strand - StrandSpecific'],
			['Clostridium_difficile_630_v1.9_00002', 'Total Reads Mapping', 0,'Annot GFF 3 reads on reverse strand feature on negative strand - StrandSpecific'],
			['Clostridium_difficile_630_v1.9_00002', 'Sense Reads Mapping', 0,'Annot GFF 3 reads on reverse strand feature on negative strand - StrandSpecific'],
			['Clostridium_difficile_630_v1.9_00002', 'Antisense Reads Mapping', 0,'Annot GFF 3 reads on reverse strand feature on negative strand - StrandSpecific'],
		       );

run_rna_seq_strand_specific('t/data/gffs_sams/mapping_to_one_feature_reverse_strand_annot.sam','t/data/gffs_sams/multipurpose_3_cds_negative_strand_annot.gff', \@expected_results_library);

@expected_results_library = (
			['Clostridium_difficile_630_v1.9_00001', 'Total Reads Mapping', 3,'Annot GFF 3 reads on forward strand feature on positive strand - StrandSpecific'],
			['Clostridium_difficile_630_v1.9_00001', 'Sense Reads Mapping', 0,'Annot GFF 3 reads on forward strand feature on positive strand - StrandSpecific'],
			['Clostridium_difficile_630_v1.9_00001', 'Antisense Reads Mapping', 3,'Annot GFF 3 reads on forward strand feature on positive strand - StrandSpecific'],
			['Clostridium_difficile_630_v1.9_00002', 'Total Reads Mapping', 0,'Annot GFF 3 reads on forward strand feature on positive strand - StrandSpecific'],
			['Clostridium_difficile_630_v1.9_00002', 'Sense Reads Mapping', 0,'Annot GFF 3 reads on forward strand feature on positive strand - StrandSpecific'],
			['Clostridium_difficile_630_v1.9_00002', 'Antisense Reads Mapping', 0,'Annot GFF 3 reads on forward strand feature on positive strand - StrandSpecific'],
		       );

run_rna_seq_strand_specific('t/data/gffs_sams/mapping_to_one_feature_forward_strand_annot.sam','t/data/gffs_sams/multipurpose_3_cds_positive_strand_annot.gff', \@expected_results_library);

@expected_results_library = (
			['Clostridium_difficile_630_v1.9_00001', 'Total Reads Mapping', 3,'Annot GFF 3 reads on forward strand feature on negative strand - StrandSpecific'],
			['Clostridium_difficile_630_v1.9_00001', 'Sense Reads Mapping', 3,'Annot GFF 3 reads on forward strand feature on negative strand - StrandSpecific'],
			['Clostridium_difficile_630_v1.9_00001', 'Antisense Reads Mapping', 0,'Annot GFF 3 reads on forward strand feature on negative strand - StrandSpecific'],
			['Clostridium_difficile_630_v1.9_00002', 'Total Reads Mapping', 0,'Annot GFF 3 reads on forward strand feature on negative strand - StrandSpecific'],
			['Clostridium_difficile_630_v1.9_00002', 'Sense Reads Mapping', 0,'Annot GFF 3 reads on forward strand feature on negative strand - StrandSpecific'],
			['Clostridium_difficile_630_v1.9_00002', 'Antisense Reads Mapping', 0,'Annot GFF 3 reads on forward strand feature on negative strand - StrandSpecific'],
		       );

run_rna_seq_strand_specific('t/data/gffs_sams/mapping_to_one_feature_forward_strand_annot.sam','t/data/gffs_sams/multipurpose_3_cds_negative_strand_annot.gff', \@expected_results_library);
##

#Strand Specifc Protocol, EMBL, reads in different strands
@expected_results_library = (
			['DUMMY_EMBL_CHR.5', 'Total Reads Mapping', 3,'Embl GFF 3 reads on reverse strand feature on positive strand - StrandSpecific'],
			['DUMMY_EMBL_CHR.5', 'Sense Reads Mapping', 3,'Embl GFF 3 reads on reverse strand feature on positive strand - StrandSpecific'],
			['DUMMY_EMBL_CHR.5', 'Antisense Reads Mapping', 0,'Embl GFF 3 reads on reverse strand feature on positive strand - StrandSpecific'],
		       );

run_rna_seq_strand_specific('t/data/gffs_sams/mapping_to_one_feature_reverse_strand_embl.sam','t/data/gffs_sams/multipurpose_3_cds_positive_strand_embl.gff', \@expected_results_library);

@expected_results_library = (
			['DUMMY_EMBL_CHR.5', 'Total Reads Mapping', 3,'Embl GFF 3 reads on reverse strand feature on negative strand - StrandSpecific'],
			['DUMMY_EMBL_CHR.5', 'Sense Reads Mapping', 0,'Embl GFF 3 reads on reverse strand feature on negative strand - StrandSpecific'],
			['DUMMY_EMBL_CHR.5', 'Antisense Reads Mapping', 3,'Embl GFF 3 reads on reverse strand feature on negative strand - StrandSpecific'],
		       );

run_rna_seq_strand_specific('t/data/gffs_sams/mapping_to_one_feature_reverse_strand_embl.sam','t/data/gffs_sams/multipurpose_3_cds_negative_strand_embl.gff', \@expected_results_library);

@expected_results_library = (
			['DUMMY_EMBL_CHR.5', 'Total Reads Mapping', 3,'Embl GFF 3 reads on forward strand feature on positive strand - StrandSpecific'],
			['DUMMY_EMBL_CHR.5', 'Sense Reads Mapping', 0,'Embl GFF 3 reads on forward strand feature on positive strand - StrandSpecific'],
			['DUMMY_EMBL_CHR.5', 'Antisense Reads Mapping', 3,'Embl GFF 3 reads on forward strand feature on positive strand - StrandSpecific'],
		       );

run_rna_seq_strand_specific('t/data/gffs_sams/mapping_to_one_feature_forward_strand_embl.sam','t/data/gffs_sams/multipurpose_3_cds_positive_strand_embl.gff', \@expected_results_library);

@expected_results_library = (
			['DUMMY_EMBL_CHR.5', 'Total Reads Mapping', 3,'Embl GFF 3 reads on forward strand feature on negative strand - StrandSpecific'],
			['DUMMY_EMBL_CHR.5', 'Sense Reads Mapping', 3,'Embl GFF 3 reads on forward strand feature on negative strand - StrandSpecific'],
			['DUMMY_EMBL_CHR.5', 'Antisense Reads Mapping', 0,'Embl GFF 3 reads on forward strand feature on negative strand - StrandSpecific'],
		       );

run_rna_seq_strand_specific('t/data/gffs_sams/mapping_to_one_feature_forward_strand_embl.sam','t/data/gffs_sams/multipurpose_3_cds_negative_strand_embl.gff', \@expected_results_library);
##END Strand Specific Protocol, EMBL, reads in different strands


#Strand Specific Protocol, Chado, reads in different strands
@expected_results_library = (
			['GreatCurl.1:exon:1', 'Total Reads Mapping', 3,'Chado GFF 3 reads on reverse strand feature on positive strand - StrandSpecific'],
			['GreatCurl.1:exon:1', 'Sense Reads Mapping', 0,'Chado GFF 3 reads on reverse strand feature on positive strand - StrandSpecific'],
			['GreatCurl.1:exon:1', 'Antisense Reads Mapping', 3,'Chado GFF 3 reads on reverse strand feature on positive strand - StrandSpecific'],
		       );

run_rna_seq_strand_specific('t/data/gffs_sams/mapping_to_one_feature_reverse_strand_chado.sam','t/data/gffs_sams/multipurpose_3_cds_positive_strand_chado.gff', \@expected_results_library);

#Gene feature
@expected_results_library = (
			['GreatCurl', 'Total Reads Mapping', 3,'Chado GFF 3 reads on reverse strand gene on positive strand - StrandSpecific'],
			['GreatCurl', 'Sense Reads Mapping', 3,'Chado GFF 3 reads on reverse strand gene on positive strand - StrandSpecific'],
			['GreatCurl', 'Antisense Reads Mapping', 0,'Chado GFF 3 reads on reverse strand gene on positive strand - StrandSpecific'],
		       );

run_rna_seq_strand_specific('t/data/gffs_sams/mapping_to_one_feature_reverse_strand_chado.sam','t/data/gffs_sams/multipurpose_3_cds_positive_strand_chado.gff', \@expected_results_library);

@expected_results_library = (
			['GreatCurl.1:exon:1', 'Total Reads Mapping', 3,'Chado GFF 3 reads on reverse strand feature on negative strand - StrandSpecific'],
			['GreatCurl.1:exon:1', 'Sense Reads Mapping', 0,'Chado GFF 3 reads on reverse strand feature on negative strand - StrandSpecific'],
			['GreatCurl.1:exon:1', 'Antisense Reads Mapping', 3,'Chado GFF 3 reads on reverse strand feature on negative strand - StrandSpecific'],
		       );

run_rna_seq_strand_specific('t/data/gffs_sams/mapping_to_one_feature_reverse_strand_chado.sam','t/data/gffs_sams/multipurpose_3_cds_negative_strand_chado.gff', \@expected_results_library);

#Gene feature
@expected_results_library = (
			['GreatCurl', 'Total Reads Mapping', 3,'Chado GFF 3 reads on reverse strand gene on positive strand - StrandSpecific'],
			['GreatCurl', 'Sense Reads Mapping', 0,'Chado GFF 3 reads on reverse strand gene on positive strand - StrandSpecific'],
			['GreatCurl', 'Antisense Reads Mapping', 3,'Chado GFF 3 reads on reverse strand gene on positive strand - StrandSpecific'],
		       );

run_rna_seq_strand_specific('t/data/gffs_sams/mapping_to_one_feature_reverse_strand_chado.sam','t/data/gffs_sams/multipurpose_3_cds_negative_strand_chado.gff', \@expected_results_library);

@expected_results_library = (
			['GreatCurl.1:exon:1', 'Total Reads Mapping', 3,'Chado GFF 3 reads on forward strand feature on positive strand - StrandSpecific'],
			['GreatCurl.1:exon:1', 'Sense Reads Mapping', 0,'Chado GFF 3 reads on forward strand feature on positive strand - StrandSpecific'],
			['GreatCurl.1:exon:1', 'Antisense Reads Mapping', 3,'Chado GFF 3 reads on forward strand feature on positive strand - StrandSpecific'],
		       );

run_rna_seq_strand_specific('t/data/gffs_sams/mapping_to_one_feature_forward_strand_chado.sam','t/data/gffs_sams/multipurpose_3_cds_positive_strand_chado.gff', \@expected_results_library);

#Gene feature
@expected_results_library = (
			['GreatCurl', 'Total Reads Mapping', 3,'Chado GFF 3 reads on forward strand gene on positive strand - StrandSpecific'],
			['GreatCurl', 'Sense Reads Mapping', 0,'Chado GFF 3 reads on forward strand gene on positive strand - StrandSpecific'],
			['GreatCurl', 'Antisense Reads Mapping', 3,'Chado GFF 3 reads on forward strand gene on positive strand - StrandSpecific'],
		       );

run_rna_seq_strand_specific('t/data/gffs_sams/mapping_to_one_feature_forward_strand_chado.sam','t/data/gffs_sams/multipurpose_3_cds_positive_strand_chado.gff', \@expected_results_library);

@expected_results_library = (
			['GreatCurl.1:exon:1', 'Total Reads Mapping', 3,'Chado GFF 3 reads on forward strand feature on negative strand - StrandSpecific'],
			['GreatCurl.1:exon:1', 'Sense Reads Mapping', 3,'Chado GFF 3 reads on forward strand feature on negative strand - StrandSpecific'],
			['GreatCurl.1:exon:1', 'Antisense Reads Mapping', 0,'Chado GFF 3 reads on forward strand feature on negative strand - StrandSpecific'],
		       );

run_rna_seq_strand_specific('t/data/gffs_sams/mapping_to_one_feature_forward_strand_chado.sam','t/data/gffs_sams/multipurpose_3_cds_negative_strand_chado.gff', \@expected_results_library);

#Gene feature
@expected_results_library = (
			['GreatCurl', 'Total Reads Mapping', 3,'Chado GFF 3 reads on forward strand gene on negative strand - StrandSpecific'],
			['GreatCurl', 'Sense Reads Mapping', 3,'Chado GFF 3 reads on forward strand gene on negative strand - StrandSpecific'],
			['GreatCurl', 'Antisense Reads Mapping', 0,'Chado GFF 3 reads on forward strand gene on negative strand - StrandSpecific'],
		       );

run_rna_seq_strand_specific('t/data/gffs_sams/mapping_to_one_feature_forward_strand_chado.sam','t/data/gffs_sams/multipurpose_3_cds_negative_strand_chado.gff', \@expected_results_library);
##END Strand Specific Protocol, Chado, reads in different strands


@expected_results_library = (
			['DUMMY_EMBL_CHR.1', 'Total Reads Mapping', 1,'EMBL GFF paired-end reads'],
			['DUMMY_EMBL_CHR.1', 'Sense Reads Mapping', 1,'EMBL GFF paired-end reads'],
			['DUMMY_EMBL_CHR.1', 'Antisense Reads Mapping', 0,'EMBL GFF paired-end reads'],
			['DUMMY_EMBL_CHR.5', 'Total Reads Mapping', 1,'EMBL GFF paired-end reads'],
			['DUMMY_EMBL_CHR.5', 'Sense Reads Mapping', 1,'EMBL GFF paired-end reads'],
			['DUMMY_EMBL_CHR.5', 'Antisense Reads Mapping', 0,'EMBL GFF paired-end reads'],
			['DUMMY_EMBL_CHR.9', 'Total Reads Mapping', 0,'EMBL GFF paired-end reads'],
			['DUMMY_EMBL_CHR.9', 'Sense Reads Mapping', 0,'EMBL GFF paired-end reads'],
			['DUMMY_EMBL_CHR.9', 'Antisense Reads Mapping', 0,'EMBL GFF paired-end reads'],
			['DUMMY_EMBL_CHR.10', 'Total Reads Mapping', 0,'EMBL GFF paired-end reads'],
			['DUMMY_EMBL_CHR.10', 'Sense Reads Mapping', 0,'EMBL GFF paired-end reads'],
			['DUMMY_EMBL_CHR.10', 'Antisense Reads Mapping', 0,'EMBL GFF paired-end reads'],
			['DUMMY_EMBL_CHR.11', 'Total Reads Mapping', 0,'EMBL GFF paired-end reads'],
			['DUMMY_EMBL_CHR.11', 'Sense Reads Mapping', 0,'EMBL GFF paired-end reads'],
			['DUMMY_EMBL_CHR.11', 'Antisense Reads Mapping', 0,'EMBL GFF paired-end reads'],
		       );

run_rna_seq('t/data/gffs_sams/paired_reads_mapping_embl.sam','t/data/gffs_sams/overlapping_genes_embl.gff', \@expected_results_library);



done_testing();


