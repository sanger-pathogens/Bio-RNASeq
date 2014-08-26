#!/usr/bin/env perl
use Moose;
use Data::Dumper;
use Test::Most;

BEGIN { unshift( @INC, './lib' ) }
BEGIN { unshift( @INC, './t/lib' ) }
with 'gffTestHelper';


my (@expected_results_library, @feature_names);

@feature_names = qw(GreatCurl.1 GreatCurl.1:exon:1 GreatCurl.2:exon:2 GreatCurl.3:exon:3 GreatCurl.1:pep StrangeCurl.1 StrangeCurl.1:exon:1 StrangeCurl.2:exon:2 StrangeCurl.3:exon:3);

run_rna_seq_check_non_existance_of_a_feature('t/data/gffs_sams/split_read_mapping_to_2_cds_chado.sam','t/data/gffs_sams/split_reads_chado.gff', \@feature_names);
run_rna_seq_check_non_existance_of_a_feature_strand_specific('t/data/gffs_sams/split_read_mapping_to_2_cds_chado.sam','t/data/gffs_sams/split_reads_chado.gff', \@feature_names);

#Split Reads

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



@feature_names = qw(ENSMUST00000180291 five_prime_UTR:ENSMUST00000180291:1 start_codon:ENSMUST00000180291:1 exon:ENSMUST00000180291:1 exon:ENSMUST00000180291:2 exon:ENSMUST00000180291:3 CDS:ENSMUST00000180291:1 CDS:ENSMUST00000180291:2 CDS:ENSMUST00000180291:3 stop_codon:ENSMUST00000180291:1 three_prime_UTR:ENSMUST00000180291:1 ENSMUST00000180292 five_prime_UTR:ENSMUST00000180292:1 start_codon:ENSMUST00000180292:1 exon:ENSMUST00000180292:1 exon:ENSMUST00000180292:2 exon:ENSMUST00000180292:3 CDS:ENSMUST00000180292:1 CDS:ENSMUST00000180292:2 CDS:ENSMUST00000180292:3 stop_codon:ENSMUST00000180292:1 three_prime_UTR:ENSMUST00000180292:1 ENSMUST00000180293 five_prime_UTR:ENSMUST00000180293:1 start_codon:ENSMUST00000180293:1 exon:ENSMUST00000180293:1 exon:ENSMUST00000180293:2 exon:ENSMUST00000180293:3 CDS:ENSMUST00000180293:1 CDS:ENSMUST00000180293:2 CDS:ENSMUST00000180293:3 stop_codon:ENSMUST00000180293:1 three_prime_UTR:ENSMUST00000180293:1);

run_rna_seq_check_non_existance_of_a_feature('t/data/gffs_sams/split_reads_mammal.sam','t/data/gffs_sams/multipurpose_3_genes_mammal_gtf2gff3.gff', \@feature_names);
run_rna_seq_check_non_existance_of_a_feature_strand_specific('t/data/gffs_sams/split_reads_mammal.sam','t/data/gffs_sams/multipurpose_3_genes_mammal_gtf2gff3.gff', \@feature_names);

@expected_results_library = (
			['Gene1', 'Total Reads Mapping', 1,'Mammal GFF split reads mapping'],
			['Gene1', 'Sense Reads Mapping', 1,'Mammal GFF split reads mapping'],
			['Gene1', 'Antisense Reads Mapping', 0,'Mammal GFF split reads mapping'],
			['Gene2', 'Total Reads Mapping', 2,'Mammal GFF split reads mapping'],
			['Gene2', 'Sense Reads Mapping', 2,'Mammal GFF split reads mapping'],
			['Gene2', 'Antisense Reads Mapping', 0,'Mammal GFF split reads mapping'],
			['Gene3', 'Total Reads Mapping', 1,'Mammal GFF split reads mapping'],
			['Gene3', 'Sense Reads Mapping', 1,'Mammal GFF split reads mapping'],
			['Gene3', 'Antisense Reads Mapping', 0,'Mammal GFF split reads mapping'],
		       );

run_rna_seq('t/data/gffs_sams/split_reads_mammal.sam','t/data/gffs_sams/multipurpose_3_genes_mammal_gtf2gff3.gff', \@expected_results_library,'DUMMY_MAMMAL_CHR');




##END Split Reads