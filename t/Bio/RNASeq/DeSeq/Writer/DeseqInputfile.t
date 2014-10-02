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
    use_ok('Bio::RNASeq::DeSeq::Writer::DeseqInputFile');
}

throws_ok { Bio::RNASeq::DeSeq::Writer::DeseqInputFile->new( deseq_file => 'blah/non_existent_samples_file', samples => {}, gene_universe => [] )->run() } qr/Non existent file/, 'Throw exception if filepath doesnt exist';

done_testing();
