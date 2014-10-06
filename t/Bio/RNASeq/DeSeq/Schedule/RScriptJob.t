#!/usr/bin/env perl
use Moose;
use Data::Dumper;
use File::Slurp;
use File::Path qw( remove_tree);
use File::Compare;
use Cwd;

BEGIN { unshift( @INC, './lib' ) }
BEGIN { unshift( @INC, './t/lib' ) }
with 'TestHelper';

BEGIN {
    use Test::Most;
    use_ok('Bio::RNASeq::DeSeq::Schedule::RScriptJob');
}   




ok( my $deseq_job = Bio::RNASeq::DeSeq::Schedule::RScriptJob->new(
							      job_name => 'blah',
							      log_error_path => 'blah',
							      rscript_path => 'blah',
							     ), "Invalid RScriptJob1 initialised");


ok( $deseq_job->bsub_command(), 'Build bsub command string');

throws_ok { $deseq_job->submit_deseq_job() }  qr/system bsub/, 'Throw exception if invalid samples file is invalid';

ok ( $deseq_job = Bio::RNASeq::DeSeq::Schedule::RScriptJob->new(
							      job_name => 'blah',
							      log_error_path => 'blah',
							      rscript_path => 'blah',
							   mode => 'test'
							     ), "Invalid RScriptJob2 initialised");

ok( $deseq_job->submit_deseq_job(), 'Run invalid local R session');
ok( grep(q{Can't exec "blah": No such file or directory}, $deseq_job->r_session_log()), "Failed job result");

ok( $deseq_job = Bio::RNASeq::DeSeq::Schedule::RScriptJob->new(
							      job_name => 'deseq_test',
							      log_error_path => 'deseq_test_log_error',
							      rscript_path => 't/data/rscript2.deseq.r',
							   mode => 'test'
							     ), "Valid RScriptJob initialised");

ok( $deseq_job->submit_deseq_job(), 'Run valid local R session');

my $expected_output_file_path = 't/data/deseq_test_results_table.csv';
my $actual_output_file_path = './new_deseq_test_result_table.csv';

is(compare($actual_output_file_path,$expected_output_file_path), 0, "Files are equal");

cleanup_files();


done_testing();


sub cleanup_files {

    unlink('./new_deseq_test_result_table.csv');

}
