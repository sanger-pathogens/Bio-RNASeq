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




#

#



#





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


