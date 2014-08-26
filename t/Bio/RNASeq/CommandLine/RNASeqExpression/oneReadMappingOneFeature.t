#!/usr/bin/env perl
use Moose;
use Data::Dumper;
use Test::Most;

BEGIN { unshift( @INC, './lib' ) }
BEGIN { unshift( @INC, './t/lib' ) }
with 'gffTestHelper';


my (@expected_results_library, @feature_names);

#1 read mapping in the middle of CDS/gene
#For Chado gff's we should test for the gene feature types and not for the CDS feature types

@feature_names = qw(GreatCurl.1 GreatCurl.1:exon:1 GreatCurl.2:exon:2 GreatCurl.3:exon:3 GreatCurl.1:pep StrangeCurl.1 StrangeCurl.1:exon:1 StrangeCurl.2:exon:2 StrangeCurl.3:exon:3);

run_rna_seq_check_non_existance_of_a_feature('t/data/gffs_sams/one_read_mapping_one_gene_chado.sam','t/data/gffs_sams/multipurpose_3_cds_chado.gff', \@feature_names);
run_rna_seq_check_non_existance_of_a_feature_strand_specific('t/data/gffs_sams/one_read_mapping_one_gene_chado.sam','t/data/gffs_sams/multipurpose_3_cds_chado.gff', \@feature_names);

#Chado total mapped reads based on gene feture type
@expected_results_library = (
			['GreatCurl', 'Total Reads Mapping', 1,'Chado GFF gene feature one read mapping'],
			['GreatCurl', 'Sense Reads Mapping', 1,'Chado GFF gene feature one read mapping'],
			['GreatCurl', 'Antisense Reads Mapping', 0,'Chado GFF gene feature one read mapping'],
			['SplitHair', 'Total Reads Mapping', 0,'Chado GFF gene feature one read mapping'],
			['SplitHair', 'Sense Reads Mapping', 0,'Chado GFF gene feature one read mapping'],
			['SplitHair', 'Antisense Reads Mapping', 0,'Chado GFF gene feature one read mapping'],
		       );

run_rna_seq('t/data/gffs_sams/one_read_mapping_one_gene_chado.sam','t/data/gffs_sams/multipurpose_3_cds_chado.gff', \@expected_results_library, 'DUMMY_CHADO_CHR');

@expected_results_library = (
			['Clostridium_difficile_630_v1.9_00001', 'Total Reads Mapping', 1,'Annot GFF one read mapping'],
			['Clostridium_difficile_630_v1.9_00001', 'Sense Reads Mapping', 1,'Annot GFF one read mapping'],
			['Clostridium_difficile_630_v1.9_00001', 'Antisense Reads Mapping', 0,'Annot GFF one read mapping'],
			['Clostridium_difficile_630_v1.9_00002', 'Total Reads Mapping', 0,'Annot GFF one read mapping'],
			['Clostridium_difficile_630_v1.9_00002', 'Sense Reads Mapping', 0,'Annot GFF one read mapping'],
			['Clostridium_difficile_630_v1.9_00002', 'Antisense Reads Mapping', 0,'Annot GFF one read mapping'],
		       );

run_rna_seq('t/data/gffs_sams/one_read_mapping_one_gene_annot.sam','t/data/gffs_sams/multipurpose_3_cds_annot.gff', \@expected_results_library, 'DUMMY_ANNOT_CHR');

@expected_results_library = (
			['DUMMY_EMBL_CHR.1', 'Total Reads Mapping', 1,'EMBL GFF one read mapping'],
			['DUMMY_EMBL_CHR.1', 'Sense Reads Mapping', 1,'EMBL GFF one read mapping'],
			['DUMMY_EMBL_CHR.1', 'Antisense Reads Mapping', 0,'EMBL GFF one read mapping'],
			['DUMMY_EMBL_CHR.5', 'Total Reads Mapping', 0,'EMBL GFF one read mapping'],
			['DUMMY_EMBL_CHR.5', 'Sense Reads Mapping', 0,'EMBL GFF one read mapping'],
			['DUMMY_EMBL_CHR.5', 'Antisense Reads Mapping', 0,'EMBL GFF one read mapping'],
		       );

run_rna_seq('t/data/gffs_sams/one_read_mapping_one_gene_embl.sam','t/data/gffs_sams/multipurpose_3_cds_embl.gff', \@expected_results_library, 'DUMMY_EMBL_CHR');

@feature_names = qw(ENSMUST00000180291 five_prime_UTR:ENSMUST00000180291:1 start_codon:ENSMUST00000180291:1 exon:ENSMUST00000180291:1 exon:ENSMUST00000180291:2 exon:ENSMUST00000180291:3 CDS:ENSMUST00000180291:1 CDS:ENSMUST00000180291:2 CDS:ENSMUST00000180291:3 stop_codon:ENSMUST00000180291:1 three_prime_UTR:ENSMUST00000180291:1 ENSMUST00000180292 five_prime_UTR:ENSMUST00000180292:1 start_codon:ENSMUST00000180292:1 exon:ENSMUST00000180292:1 exon:ENSMUST00000180292:2 exon:ENSMUST00000180292:3 CDS:ENSMUST00000180292:1 CDS:ENSMUST00000180292:2 CDS:ENSMUST00000180292:3 stop_codon:ENSMUST00000180292:1 three_prime_UTR:ENSMUST00000180292:1 ENSMUST00000180293 five_prime_UTR:ENSMUST00000180293:1 start_codon:ENSMUST00000180293:1 exon:ENSMUST00000180293:1 exon:ENSMUST00000180293:2 exon:ENSMUST00000180293:3 CDS:ENSMUST00000180293:1 CDS:ENSMUST00000180293:2 CDS:ENSMUST00000180293:3 stop_codon:ENSMUST00000180293:1 three_prime_UTR:ENSMUST00000180293:1);

run_rna_seq_check_non_existance_of_a_feature('t/data/gffs_sams/one_read_mapping_one_gene_mammal.sam','t/data/gffs_sams/multipurpose_3_genes_mammal_gtf2gff3.gff', \@feature_names);
run_rna_seq_check_non_existance_of_a_feature_strand_specific('t/data/gffs_sams/one_read_mapping_one_gene_mammal.sam','t/data/gffs_sams/multipurpose_3_genes_mammal_gtf2gff3.gff', \@feature_names);

#Failing firstly because it doesn't hadle gene feature type properly. If ran with the CDS feature type IDs is as a similar result to the above tests.
@expected_results_library = (
			['ENSMUSG00000094722', 'Total Reads Mapping', 1,'Mammal GFF one read mapping'],
			['ENSMUSG00000094722', 'Sense Reads Mapping', 1,'Mammal GFF one read mapping'],
			['ENSMUSG00000094722', 'Antisense Reads Mapping', 0,'Mammal GFF one read mapping'],
			['ENSMUSG00000094723;', 'Total Reads Mapping', 0,'Mammal GFF one read mapping'],
			['ENSMUSG00000094723;', 'Sense Reads Mapping', 0,'Mammal GFF one read mapping'],
			['ENSMUSG00000094723;', 'Antisense Reads Mapping', 0,'Mammal GFF one read mapping'],
		       );

run_rna_seq('t/data/gffs_sams/one_read_mapping_one_gene_mammal.sam','t/data/gffs_sams/multipurpose_3_genes_mammal_gtf2gff3.gff', \@expected_results_library, 'DUMMY_MAMMAL_CHR');
#END 1 read mapping

done_testing();
