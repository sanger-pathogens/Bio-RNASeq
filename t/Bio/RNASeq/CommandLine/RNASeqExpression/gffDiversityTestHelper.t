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
#with 'TestMappingHelper';

BEGIN {
    use Test::Most;
    use Bio::RNASeq::CommandLine::RNASeqExpression;
}

my @expected_results_library;

#1 read mapping in the middle of CDS/gene
#For Chado gff's we should test for the gene feature types and not for the CDS feature types
@expected_results_library = (
			['GreatCurl.1:exon:1', 'Total Reads Mapping', 1],
			['GreatCurl.1:exon:1', 'Sense Reads Mapping', 1],
			['GreatCurl.1:exon:1', 'Antisense Reads Mapping', 0],
			['GreatCurl.3:exon:3', 'Total Reads Mapping', 0],
			['GreatCurl.3:exon:3', 'Sense Reads Mapping', 0],
			['GreatCurl.3:exon:3', 'Antisense Reads Mapping', 0],
		       );

run_rna_seq('t/data/gffs_sams/one_read_mapping_one_gene_chado.sam','t/data/gffs_sams/multipurpose_3_cds_chado.gff', \@expected_results_library);

@expected_results_library = (
			['Clostridium_difficile_630_v1.9_00001', 'Total Reads Mapping', 1],
			['Clostridium_difficile_630_v1.9_00001', 'Sense Reads Mapping', 1],
			['Clostridium_difficile_630_v1.9_00001', 'Antisense Reads Mapping', 0],
			['Clostridium_difficile_630_v1.9_00002', 'Total Reads Mapping', 0],
			['Clostridium_difficile_630_v1.9_00002', 'Sense Reads Mapping', 0],
			['Clostridium_difficile_630_v1.9_00002', 'Antisense Reads Mapping', 0],
		       );

run_rna_seq('t/data/gffs_sams/one_read_mapping_one_gene_annot.sam','t/data/gffs_sams/multipurpose_3_cds_annot.gff', \@expected_results_library);

@expected_results_library = (
			['DUMMY_EMBL_CHR.1', 'Total Reads Mapping', 1],
			['DUMMY_EMBL_CHR.1', 'Sense Reads Mapping', 1],
			['DUMMY_EMBL_CHR.1', 'Antisense Reads Mapping', 0],
			['DUMMY_EMBL_CHR.5', 'Total Reads Mapping', 0],
			['DUMMY_EMBL_CHR.5', 'Sense Reads Mapping', 0],
			['DUMMY_EMBL_CHR.5', 'Antisense Reads Mapping', 0],
		       );

run_rna_seq('t/data/gffs_sams/one_read_mapping_one_gene_embl.sam','t/data/gffs_sams/multipurpose_3_cds_embl.gff', \@expected_results_library);



#Failing firstly because it doesn't hadle gene feature type properly. If ran with the CDS feature type IDs is as a similar result to the above tests.
@expected_results_library = (
			['ENSMUSG00000094722', 'Total Reads Mapping', 1],
			['ENSMUSG00000094722', 'Sense Reads Mapping', 1],
			['ENSMUSG00000094722', 'Antisense Reads Mapping', 0],
			['ENSMUSG00000094723;', 'Total Reads Mapping', 0],
			['ENSMUSG00000094723;', 'Sense Reads Mapping', 0],
			['ENSMUSG00000094723;', 'Antisense Reads Mapping', 0],
		       );

run_rna_seq('t/data/gffs_sams/one_read_mapping_one_gene_mammal.sam','t/data/gffs_sams/multipurpose_3_genes_mammal_gtf2gff3.gff', \@expected_results_library);
#END 1 read mapping


#3 Reads mapping - 1 partly flanking to the left, 1 straight inside, 1 slightly flanking to the right
#For Chado gff's we should test for the gene feature types and not for the CDS feature types
@expected_results_library = (
			['GreatCurl.1:exon:1', 'Total Reads Mapping', 3],
			['GreatCurl.1:exon:1', 'Sense Reads Mapping', 3],
			['GreatCurl.1:exon:1', 'Antisense Reads Mapping', 0],
			['GreatCurl.3:exon:3', 'Total Reads Mapping', 0],
			['GreatCurl.3:exon:3', 'Sense Reads Mapping', 0],
			['GreatCurl.3:exon:3', 'Antisense Reads Mapping', 0],
		       );

run_rna_seq('t/data/gffs_sams/mapping_to_one_feature_chado.sam','t/data/gffs_sams/multipurpose_3_cds_chado.gff', \@expected_results_library);

@expected_results_library = (
			['Clostridium_difficile_630_v1.9_00001', 'Total Reads Mapping', 3],
			['Clostridium_difficile_630_v1.9_00001', 'Sense Reads Mapping', 3],
			['Clostridium_difficile_630_v1.9_00001', 'Antisense Reads Mapping', 0],
			['Clostridium_difficile_630_v1.9_00002', 'Total Reads Mapping', 0],
			['Clostridium_difficile_630_v1.9_00002', 'Sense Reads Mapping', 0],
			['Clostridium_difficile_630_v1.9_00002', 'Antisense Reads Mapping', 0],
		       );

run_rna_seq('t/data/gffs_sams/mapping_to_one_feature_annot.sam','t/data/gffs_sams/multipurpose_3_cds_annot.gff', \@expected_results_library);

@expected_results_library = (
			['DUMMY_EMBL_CHR.5', 'Total Reads Mapping', 3],
			['DUMMY_EMBL_CHR.5', 'Sense Reads Mapping', 3],
			['DUMMY_EMBL_CHR.5', 'Antisense Reads Mapping', 0],
			['DUMMY_EMBL_CHR.1', 'Total Reads Mapping', 0],
			['DUMMY_EMBL_CHR.1', 'Sense Reads Mapping', 0],
			['DUMMY_EMBL_CHR.1', 'Antisense Reads Mapping', 0],
		       );

run_rna_seq('t/data/gffs_sams/one_read_mapping_one_gene_embl.sam','t/data/gffs_sams/multipurpose_3_cds_embl.gff', \@expected_results_library);
#END 3 reads mapping


#No reads mapping  - Tests will pass, simply because the code isn't working properly and is not generating any read counts. 
#For Chado gff's we should test for the gene feature types and not for the CDS feature types
@expected_results_library = (
			['GreatCurl.1:exon:1', 'Total Reads Mapping', 0],
			['GreatCurl.1:exon:1', 'Sense Reads Mapping', 0],
			['GreatCurl.1:exon:1', 'Antisense Reads Mapping', 0],
			['GreatCurl.3:exon:3', 'Total Reads Mapping', 0],
			['GreatCurl.3:exon:3', 'Sense Reads Mapping', 0],
			['GreatCurl.3:exon:3', 'Antisense Reads Mapping', 0],
		       );

run_rna_seq('t/data/gffs_sams/nothing_to_map_chado.sam','t/data/gffs_sams/multipurpose_3_cds_chado.gff', \@expected_results_library);

@expected_results_library = (
			['Clostridium_difficile_630_v1.9_00001', 'Total Reads Mapping', 0],
			['Clostridium_difficile_630_v1.9_00001', 'Sense Reads Mapping', 0],
			['Clostridium_difficile_630_v1.9_00001', 'Antisense Reads Mapping', 0],
			['Clostridium_difficile_630_v1.9_00002', 'Total Reads Mapping', 0],
			['Clostridium_difficile_630_v1.9_00002', 'Sense Reads Mapping', 0],
			['Clostridium_difficile_630_v1.9_00002', 'Antisense Reads Mapping', 0],
		       );

run_rna_seq('t/data/gffs_sams/nothing_to_map_annot.sam','t/data/gffs_sams/multipurpose_3_cds_annot.gff', \@expected_results_library);

@expected_results_library = (
			['DUMMY_EMBL_CHR.5', 'Total Reads Mapping', 0],
			['DUMMY_EMBL_CHR.5', 'Sense Reads Mapping', 0],
			['DUMMY_EMBL_CHR.5', 'Antisense Reads Mapping', 0],
			['DUMMY_EMBL_CHR.1', 'Total Reads Mapping', 0],
			['DUMMY_EMBL_CHR.1', 'Sense Reads Mapping', 0],
			['DUMMY_EMBL_CHR.1', 'Antisense Reads Mapping', 0],
		       );

run_rna_seq('t/data/gffs_sams/nothing_to_map_embl.sam','t/data/gffs_sams/multipurpose_3_cds_embl.gff', \@expected_results_library);
##END No reads mapping


#Split Reads
#For Chado gff's we should test for the gene feature types and not for the CDS feature types
@expected_results_library = (
			['GreatCurl.1:exon:1', 'Total Reads Mapping', 1],
			['GreatCurl.1:exon:1', 'Sense Reads Mapping', 1],
			['GreatCurl.1:exon:1', 'Antisense Reads Mapping', 0],
			['GreatCurl.3:exon:3', 'Total Reads Mapping', 1],
			['GreatCurl.3:exon:3', 'Sense Reads Mapping', 1],
			['GreatCurl.3:exon:3', 'Antisense Reads Mapping', 0],
		       );

run_rna_seq('t/data/gffs_sams/split_read_mapping_to_2_cds_chado.sam','t/data/gffs_sams/split_reads_chado.gff', \@expected_results_library);

@expected_results_library = (
			['GreatCurl', 'Total Reads Mapping', 1],
			['GreatCurl', 'Sense Reads Mapping', 1],
			['GreatCurl', 'Antisense Reads Mapping', 0],
			['SplitHair', 'Total Reads Mapping', 1],
			['SplitHair', 'Sense Reads Mapping', 1],
			['SplitHair', 'Antisense Reads Mapping', 0],
		       );

run_rna_seq('t/data/gffs_sams/split_read_mapping_to_2_cds_chado.sam','t/data/gffs_sams/split_reads_chado.gff', \@expected_results_library);

@expected_results_library = (
			['Great', 'Total Reads Mapping', 1],
			['Great', 'Sense Reads Mapping', 1],
			['Great', 'Antisense Reads Mapping', 0],
			['Split', 'Total Reads Mapping', 1],
			['Split', 'Sense Reads Mapping', 1],
			['Split', 'Antisense Reads Mapping', 0],
		       );

run_rna_seq('t/data/gffs_sams/split_read_mapping_to_2_cds_chado.sam','t/data/gffs_sams/split_reads_chado.gff', \@expected_results_library);

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

run_rna_seq('t/data/gffs_sams/split_read_mapping_to_2_cds_annot.sam','t/data/gffs_sams/split_reads_annot.gff', \@expected_results_library);

@expected_results_library = (
			['DUMMY_EMBL_CHR.1', 'Total Reads Mapping', 1],
			['DUMMY_EMBL_CHR.1', 'Sense Reads Mapping', 1],
			['DUMMY_EMBL_CHR.1', 'Antisense Reads Mapping', 0],
			['DUMMY_EMBL_CHR.5', 'Total Reads Mapping', 2],
			['DUMMY_EMBL_CHR.5', 'Sense Reads Mapping', 2],
			['DUMMY_EMBL_CHR.5', 'Antisense Reads Mapping', 0],
			['DUMMY_EMBL_CHR.9', 'Total Reads Mapping', 2],
			['DUMMY_EMBL_CHR.9', 'Sense Reads Mapping', 2],
			['DUMMY_EMBL_CHR.9', 'Antisense Reads Mapping', 0],
			['DUMMY_EMBL_CHR.10', 'Total Reads Mapping', 1],
			['DUMMY_EMBL_CHR.10', 'Sense Reads Mapping', 1],
			['DUMMY_EMBL_CHR.10', 'Antisense Reads Mapping', 0],
		       );

run_rna_seq('t/data/gffs_sams/split_read_mapping_to_2_cds_embl.sam','t/data/gffs_sams/split_reads_embl.gff', \@expected_results_library);
##END Split Reads

done_testing();





sub run_rna_seq {

    my ( $sam_file, $annotation_file, $results_library ) = @_;

    my $bam_file = $sam_file;
    $bam_file =~ s/sam$/bam/;

    system("samtools view -bS $sam_file > $bam_file");

    my $file_temp_obj = File::Temp->newdir( DIR => File::Spec->curdir(), CLEANUP => 1 );

    my $output_base_filename = $file_temp_obj->dirname() . '/test_';

    print " $output_base_filename\n";

    my $protocol           = 'StandardProtocol';
    my $intergenic_regions = 1;
    my %filters            = ( mapping_quality => 1 );

    ok(
        my $expression_results = Bio::RNASeq->new(
            sequence_filename    => $bam_file,
            annotation_filename  => $annotation_file,
            filters              => \%filters,
            protocol             => $protocol,
            output_base_filename => $output_base_filename,
            intergenic_regions   => $intergenic_regions,
        ),
        'expression_results object creation'
    );

    ok(
        $expression_results->output_spreadsheet(),
        'expression reuslts spreadsheet creation'
    );
    #print Dumper($expression_results);
    ok( -e $output_base_filename . '.corrected.bam',     'corrected bam' );
    ok( -e $output_base_filename . '.corrected.bam.bai', 'corrected bai' );
    ok(
        -e $output_base_filename
          . '.corrected.bam.intergenic.DUMMY_CHADO_CHR.tab.gz',
        'intergenic gz'
    );
    ok( -e $output_base_filename . '.expression.csv', 'expression results' );

    my $filename = $output_base_filename . '.expression.csv';

    for my $set_of_expected_results(@$results_library) {
      parseExpressionResultsFile ( $filename, $set_of_expected_results );
    }
    print "$output_base_filename\n";

}


sub parseExpressionResultsFile {

    my ( $filename, $set_of_expected_results ) = @_;


    my $csv = Text::CSV->new();
    open( my $fh, "<:encoding(utf8)", $filename ) or die("$filename: $!");

    my $headers = $csv->getline($fh);

    my $column_index = 0;
    for my $header (@$headers) {

        if ( $header =~ /$set_of_expected_results->[1]/ ) {
            last;
        }
        $column_index++;
    }

    while ( my $row = $csv->getline($fh) ) {
        unless ( $row->[1] =~ /$set_of_expected_results->[0]/ ) {
            next;
        }
        is( $row->[$column_index], $set_of_expected_results->[2],
            "match $set_of_expected_results->[1] - $set_of_expected_results->[0]" );
        last;
    }
    $csv->eof or $csv->error_diag();
    close $fh;

}
