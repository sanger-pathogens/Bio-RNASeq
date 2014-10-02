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
ok( my $good_samples_parser = Bio::RNASeq::DeSeq::Parser::SamplesFile->new( samples_file => 't/data/good_samples_file'), 'Valid samples file object initialised' );
ok( $good_samples_parser->samples(), 'Validating valid samples file');
ok( my $bad_samples_parser = Bio::RNASeq::DeSeq::Parser::SamplesFile->new( samples_file => 't/data/bad_samples_file'), 'Invalid samples file object initialised' );
throws_ok { $bad_samples_parser->samples() } qr/Validation failed/, 'Throw exception if invalid samples file is invalid';


done_testing();
