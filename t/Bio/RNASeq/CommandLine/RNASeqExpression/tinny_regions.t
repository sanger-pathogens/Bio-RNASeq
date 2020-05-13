#!/usr/bin/env perl
use Moose;
use Data::Dumper;
use Test::Most;

BEGIN { unshift( @INC, './t/lib' ) }
with 'gffTestHelper';

my $test_name = '';
my $intergenic_regions = 0;
my (@expected_results_library, @feature_names);



#Experimental tiny regions
$test_name = 'one tiny test';
@expected_results_library = (
			['TeenyTiny.1:exon:1', 'Total Reads Mapping', 4],
			['TeenyTiny.1:exon:1', 'Sense Reads Mapping', 4],
			['TeenyTiny.1:exon:1', 'Antisense Reads Mapping', 0],
			['TeenyTiny.2:exon:2', 'Total Reads Mapping', 1],
			['TeenyTiny.2:exon:2', 'Sense Reads Mapping', 1],
			['TeenyTiny.2:exon:2', 'Antisense Reads Mapping', 0],
		       );


run_rna_seq('t/data/gffs_sams/tiny_chado.sam','t/data/gffs_sams/tiny_chado.gff', \@expected_results_library, 'DUMMY_TINY_CHR', $test_name, $intergenic_regions );



$test_name = 'one tiny test - overlapping features';
@expected_results_library = (
			['TeenyTiny.1:exon:1', 'Total Reads Mapping', 1],
			['TeenyTiny.1:exon:1', 'Sense Reads Mapping', 1],
			['TeenyTiny.1:exon:1', 'Antisense Reads Mapping', 0],
			['TeenyTiny.2:exon:2', 'Total Reads Mapping', 2],
			['TeenyTiny.2:exon:2', 'Sense Reads Mapping', 2],
			['TeenyTiny.2:exon:2', 'Antisense Reads Mapping', 0],
			['TeenyTiny.3:exon:3', 'Total Reads Mapping', 1],
			['TeenyTiny.3:exon:3', 'Sense Reads Mapping', 1],
			['TeenyTiny.3:exon:3', 'Antisense Reads Mapping', 0],
		       );

run_rna_seq('t/data/gffs_sams/overlap_simple_tiny_chado.sam','t/data/gffs_sams/overlap_simple_tiny_chado.gff', \@expected_results_library, 'DUMMY_TINY_CHR', $test_name, $intergenic_regions );
##END of tiny regions

done_testing();
