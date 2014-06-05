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
    use_ok('Bio::RNASeq::CommandLine::DeSeqRun');
}

my $cwd = getcwd();
my $script_name = 'Bio::RNASeq::CommandLine::DeSeqRun';

local $ENV{PATH} = "$ENV{PATH}:./bin";
my %scripts_and_expected_files;
system('touch empty_file');

%scripts_and_expected_files = (

' -s t/data/samples_file -d deseq_test'
      => [ 'empty_file' ],
' -s t/data/bad_samples_file -d deseq_test'
	  => [ 'empty_file' ],
);

mock_execute_script_and_check_output( $script_name,
      \%scripts_and_expected_files );

cleanup_files();
done_testing();

sub cleanup_files {


	  
}
