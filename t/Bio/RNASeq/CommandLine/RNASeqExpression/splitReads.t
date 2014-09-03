#!/usr/bin/env perl
use Moose;
use Data::Dumper;
use Test::Most;

BEGIN { unshift( @INC, './lib' ) }
BEGIN { unshift( @INC, './t/lib' ) }
with 'gffTestHelper';

my $test_name = '';
my (@expected_results_library, @feature_names);


$test_name = 'Checking presence of unwanted features - split reads - Chado';
@feature_names = qw(GreatCurl.1 GreatCurl.1:exon:1 GreatCurl.2:exon:2 GreatCurl.3:exon:3 GreatCurl.1:pep StrangeCurl.1 StrangeCurl.1:exon:1 StrangeCurl.2:exon:2 StrangeCurl.3:exon:3);

run_rna_seq_check_non_existence_of_a_feature('t/data/gffs_sams/split_read_mapping_to_2_cds_chado.sam','t/data/gffs_sams/split_reads_chado.gff', \@feature_names, $test_name );
run_rna_seq_check_non_existence_of_a_feature_strand_specific('t/data/gffs_sams/split_read_mapping_to_2_cds_chado.sam','t/data/gffs_sams/split_reads_chado.gff', \@feature_names, $test_name );

#Split Reads

#Chado total mapped reads based on gene feture type
$test_name = 'Chado GFF gene feature type split reads mapping';
@expected_results_library = (
			['GreatCurl', 'Total Reads Mapping', 2],
			['GreatCurl', 'Sense Reads Mapping', 2],
			['GreatCurl', 'Antisense Reads Mapping', 0],
			['SplitHair', 'Total Reads Mapping', 1],
			['SplitHair', 'Sense Reads Mapping', 1],
			['SplitHair', 'Antisense Reads Mapping', 0],
		       );

run_rna_seq( 't/data/gffs_sams/split_read_mapping_to_2_cds_chado.sam','t/data/gffs_sams/split_reads_chado.gff', \@expected_results_library, $test_name );

$test_name = 'Annot GFF split reads mapping';
@expected_results_library = (
			['Clostridium_difficile_630_v1.9_00001', 'Total Reads Mapping', 1],
			['Clostridium_difficile_630_v1.9_00001', 'Sense Reads Mapping', 1],
			['Clostridium_difficile_630_v1.9_00001', 'Antisense Reads Mapping', 0],
			['Clostridium_difficile_630_v1.9_00002', 'Total Reads Mapping', 2],
			['Clostridium_difficile_630_v1.9_00002', 'Sense Reads Mapping', 2],
			['Clostridium_difficile_630_v1.9_00002', 'Antisense Reads Mapping', 0],
			['Clostridium_difficile_630_v1.9_00003', 'Total Reads Mapping', 2],
			['Clostridium_difficile_630_v1.9_00003', 'Sense Reads Mapping', 2],
			['Clostridium_difficile_630_v1.9_00003', 'Antisense Reads Mapping', 0],
			['Clostridium_difficile_630_v1.9_00004', 'Total Reads Mapping', 1],
			['Clostridium_difficile_630_v1.9_00004', 'Sense Reads Mapping', 1],
			['Clostridium_difficile_630_v1.9_00004', 'Antisense Reads Mapping', 0],
		       );

run_rna_seq( 't/data/gffs_sams/split_read_mapping_to_2_cds_annot.sam','t/data/gffs_sams/split_reads_annot.gff', \@expected_results_library, $test_name );


$test_name = 'EMBL GFF split reads mapping';
@expected_results_library = (
			['DUMMY_EMBL_CHR.1', 'Total Reads Mapping', 1,],
			['DUMMY_EMBL_CHR.1', 'Sense Reads Mapping', 1,],
			['DUMMY_EMBL_CHR.1', 'Antisense Reads Mapping', 0,],
			['DUMMY_EMBL_CHR.5', 'Total Reads Mapping', 2,],
			['DUMMY_EMBL_CHR.5', 'Sense Reads Mapping', 2,],
			['DUMMY_EMBL_CHR.5', 'Antisense Reads Mapping', 0,],
			['DUMMY_EMBL_CHR.9', 'Total Reads Mapping', 2,],
			['DUMMY_EMBL_CHR.9', 'Sense Reads Mapping', 2,],
			['DUMMY_EMBL_CHR.9', 'Antisense Reads Mapping', 0,],
			['DUMMY_EMBL_CHR.10', 'Total Reads Mapping', 1,],
			['DUMMY_EMBL_CHR.10', 'Sense Reads Mapping', 1,],
			['DUMMY_EMBL_CHR.10', 'Antisense Reads Mapping', 0,],
		       );

run_rna_seq( 't/data/gffs_sams/split_read_mapping_to_2_cds_embl.sam','t/data/gffs_sams/split_reads_embl.gff', \@expected_results_library, $test_name );


$test_name = 'Checking presence of unwanted features - split reads - Mammal';
@feature_names = qw(ENSMUST00000180291 five_prime_UTR:ENSMUST00000180291:1 start_codon:ENSMUST00000180291:1 exon:ENSMUST00000180291:1 exon:ENSMUST00000180291:2 exon:ENSMUST00000180291:3 CDS:ENSMUST00000180291:1 CDS:ENSMUST00000180291:2 CDS:ENSMUST00000180291:3 stop_codon:ENSMUST00000180291:1 three_prime_UTR:ENSMUST00000180291:1 ENSMUST00000180292 five_prime_UTR:ENSMUST00000180292:1 start_codon:ENSMUST00000180292:1 exon:ENSMUST00000180292:1 exon:ENSMUST00000180292:2 exon:ENSMUST00000180292:3 CDS:ENSMUST00000180292:1 CDS:ENSMUST00000180292:2 CDS:ENSMUST00000180292:3 stop_codon:ENSMUST00000180292:1 three_prime_UTR:ENSMUST00000180292:1 ENSMUST00000180293 five_prime_UTR:ENSMUST00000180293:1 start_codon:ENSMUST00000180293:1 exon:ENSMUST00000180293:1 exon:ENSMUST00000180293:2 exon:ENSMUST00000180293:3 CDS:ENSMUST00000180293:1 CDS:ENSMUST00000180293:2 CDS:ENSMUST00000180293:3 stop_codon:ENSMUST00000180293:1 three_prime_UTR:ENSMUST00000180293:1);

run_rna_seq_check_non_existence_of_a_feature( 't/data/gffs_sams/split_reads_mammal.sam','t/data/gffs_sams/multipurpose_3_genes_mammal_gtf2gff3.gff', \@feature_names, $test_name );
run_rna_seq_check_non_existence_of_a_feature_strand_specific( 't/data/gffs_sams/split_reads_mammal.sam','t/data/gffs_sams/multipurpose_3_genes_mammal_gtf2gff3.gff', \@feature_names, $test_name );

$test_name = 'Mammal GFF split reads mapping';
@expected_results_library = (
			['Gene1', 'Total Reads Mapping', 1],
			['Gene1', 'Sense Reads Mapping', 1],
			['Gene1', 'Antisense Reads Mapping', 0],
			['Gene2', 'Total Reads Mapping', 2],
			['Gene2', 'Sense Reads Mapping', 2],
			['Gene2', 'Antisense Reads Mapping', 0],
			['Gene3', 'Total Reads Mapping', 1],
			['Gene3', 'Sense Reads Mapping', 1],
			['Gene3', 'Antisense Reads Mapping', 0],
		       );

run_rna_seq( 't/data/gffs_sams/split_reads_mammal.sam','t/data/gffs_sams/multipurpose_3_genes_mammal_gtf2gff3.gff', \@expected_results_library,'DUMMY_MAMMAL_CHR', $test_name );



##END Split Reads

done_testing();
