#!/usr/bin/env perl
use Moose;
use Data::Dumper;
use File::Slurp;
use File::Path qw( remove_tree);
use Cwd;

BEGIN { unshift( @INC, './lib' ) }
BEGIN { unshift( @INC, './t/lib' ) }
with 'TestHelper';

BEGIN {
    use Test::Most;
    use_ok('Bio::RNASeq::DeSeq::Writer::RScript');
}

my $rscript = Bio::RNASeq::DeSeq::Writer::RScript->new(
    deseq_file      => 'deseq_test',
    deseq_file_path => 'tester/deseq_test',
    r_conditions    => 'c( "treated","treated","treated","untreated","untreated")',
    r_lib_types     => 'c( "paired-end","paired-end","paired-end","paired-end","paired-end"',
    mode            => 'test'
);

$rscript->set_r_script();

my $expected_rscript = q{#!/usr/bin/env Rscript
library(DESeq)
thisCountTable = read.table( "tester/deseq_test", header=TRUE, row.names=1 )
thisDesign = data.frame(
row.names = colnames(thisCountTable),
condition = c( "treated","treated","treated","untreated","untreated"),
libType = c( "paired-end","paired-end","paired-end","paired-end","paired-end")
pairedSamples = thisDesign$libType == "paired-end"
countTable = thisCountTable[, pairedSamples]
condition = thisDesign$condition[ pairedSamples ]
cds = newCountDataSet( countTable, condition )
cds = estimateSizeFactors( cds )
cds = estimateDispersions(cds, fitType="local")
res = nbinomTest( cds, "untreated", "treated" )
write.csv( res, file="deseq_test_result_table.csv")
};

is($rscript->rscript, $expected_rscript, 'Generated rscript test mode');


$rscript = Bio::RNASeq::DeSeq::Writer::RScript->new(
    deseq_file      => 'deseq_test',
    deseq_file_path => 'tester/deseq_test',
    r_conditions    => 'c( "treated","treated","treated","untreated","untreated")',
    r_lib_types     => 'c( "paired-end","paired-end","paired-end","paired-end","paired-end"'
);

$rscript->set_r_script();

$expected_rscript = q{#!/usr/bin/env Rscript
library(DESeq)
thisCountTable = read.table( "tester/deseq_test", header=TRUE, row.names=1 )
thisDesign = data.frame(
row.names = colnames(thisCountTable),
condition = c( "treated","treated","treated","untreated","untreated"),
libType = c( "paired-end","paired-end","paired-end","paired-end","paired-end")
pairedSamples = thisDesign$libType == "paired-end"
countTable = thisCountTable[, pairedSamples]
condition = thisDesign$condition[ pairedSamples ]
cds = newCountDataSet( countTable, condition )
cds = estimateSizeFactors( cds )
cds = estimateDispersions(cds)
res = nbinomTest( cds, "untreated", "treated" )
write.csv( res, file="deseq_test_result_table.csv")
};

is($rscript->rscript, $expected_rscript, 'Generated rscript normal mode');

done_testing();
