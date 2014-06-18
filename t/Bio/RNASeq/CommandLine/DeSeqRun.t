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

my $cwd         = getcwd();
my $script_name = 'Bio::RNASeq::CommandLine::DeSeqRun';

local $ENV{PATH} = "$ENV{PATH}:./bin";
my %scripts_and_expected_files;
system('touch empty_file');

%scripts_and_expected_files = (

			       ' -i t/data/good_samples_file -o deseq_test -c 9' =>
			       [
				[ 'empty_file', 'empty_file' ],
				[ 'deseq_test', 't/data/file_for_DeSeq.deseq' ],
				[ 'deseq_test.r', 't/data/rscript.deseq.r' ]
			       ],
			       ' -i t/data/bad_samples_file -o non_existent_file -c 9' => 
			       [
				['empty_file', 'empty_file']
			       ],
			       ' -i t/data/bad_samples_file -o deseq_test -c 9' => 
			       [
				['empty_file', 'empty_file']
			       ],
);

mock_execute_script_and_check_multiple_file_output( $script_name,
    \%scripts_and_expected_files );

cleanup_files();
done_testing();

sub cleanup_files {

    unlink('deseq_test');
    unlink('deseq_test.r');

}
