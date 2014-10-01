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
    use_ok('Bio::RNASeq::DeSeq::Parser::SamplesFile');
}


throws_ok { Bio::RNASeq::DeSeq::Parser::SamplesFile->new( samples_file => 'non_existent_samples_file' ) } qr/Validation failed/, 'Throw exception if file doesnt exist';

done_testing();
