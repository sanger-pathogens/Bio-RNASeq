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
    use_ok('Bio::RNASeq::DeSeq::Validate::SamplesFile');
}

throws_ok { Bio::RNASeq::DeSeq::Validate::SamplesFile->new( samples_file => 'non_existent_samples_file' ) } qr/Validation failed/, 'Throw exception if file doesnt exist';

ok( my $good_samples_validator = Bio::RNASeq::DeSeq::Validate::SamplesFile->new( samples_file => 't/data/good_samples_file'), 'Valid samples file object initialised' );

ok( $good_samples_validator->validate_content_set_samples(), 'Validating valid samples file');

ok( my $bad_samples_validator = Bio::RNASeq::DeSeq::Validate::SamplesFile->new( samples_file => 't/data/bad_samples_file'), 'Invalid samples file object initialised' );

ok( $bad_samples_validator->validate_content_set_samples(), 'Validating Invalid samples file' );

is( $bad_samples_validator->is_samples_file_valid(), 0, 'Invalid file is invalid' );

done_testing();
