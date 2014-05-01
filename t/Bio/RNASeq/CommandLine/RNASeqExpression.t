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
    use_ok('Bio::RNASeq::CommandLine::RNASeqExpression');
}
my $script_name = 'Bio::RNASeq::CommandLine::RNASeqExpression';
my $cwd         = getcwd();

local $ENV{PATH} = "$ENV{PATH}:./bin";
my %scripts_and_expected_files;
system('touch empty_file');

%scripts_and_expected_files = (

#No protocol argument, should default to standard
' -s t/data/647029.pe.markdup.bam -a t/data/CD630_updated_171212.embl.34.gff  -o ./_test '
      => [
        '_test.corrected.bam',
        '_test.corrected.bam.bai',
        '_test.expression.csv',
        '_test.CD630_updated_171212.embl.coverageplot.gz'
      ],
' -s t/data/647029.pe.markdup.bam -a t/data/CD630_updated_171212.embl.34.gff  -q 10 -o ./_test '
      => [
        '_test.corrected.bam',
        '_test.corrected.bam.bai',
        '_test.expression.csv',
        '_test.CD630_updated_171212.embl.coverageplot.gz'
      ],
' -s t/data/647029.pe.markdup.bam -a t/data/CD630_updated_171212.embl.34.gff  -b -o ./_test '
      => [
        '_test.corrected.bam',
        '_test.corrected.bam.bai',
        '_test.expression.csv',
        '_test.CD630_updated_171212.embl.coverageplot.gz'
      ],
' -s t/data/647029.pe.markdup.bam -a t/data/CD630_updated_171212.embl.34.gff  -q 10 -b -o ./_test '
      => [
        '_test.corrected.bam',
        '_test.corrected.bam.bai',
        '_test.expression.csv',
        '_test.CD630_updated_171212.embl.coverageplot.gz'
      ],

#Standard protocol tests
' -s t/data/647029.pe.markdup.bam -a t/data/CD630_updated_171212.embl.34.gff -p standard -o ./_test '
      => [
        '_test.corrected.bam',
        '_test.corrected.bam.bai',
        '_test.expression.csv',
        '_test.CD630_updated_171212.embl.coverageplot.gz'
      ],
' -s t/data/647029.pe.markdup.bam -a t/data/CD630_updated_171212.embl.34.gff -p standard -q 10 -o ./_test '
      => [
        '_test.corrected.bam',
        '_test.corrected.bam.bai',
        '_test.expression.csv',
        '_test.CD630_updated_171212.embl.coverageplot.gz'
      ],
' -s t/data/647029.pe.markdup.bam -a t/data/CD630_updated_171212.embl.34.gff -p standard -b -o ./_test '
      => [
        '_test.corrected.bam',
        '_test.corrected.bam.bai',
        '_test.expression.csv',
        '_test.CD630_updated_171212.embl.coverageplot.gz'
      ],
' -s t/data/647029.pe.markdup.bam -a t/data/CD630_updated_171212.embl.34.gff -p standard -q 10 -b -o ./_test '
      => [
        '_test.corrected.bam',
        '_test.corrected.bam.bai',
        '_test.expression.csv',
        '_test.CD630_updated_171212.embl.coverageplot.gz'
      ],
	  
#Strand-specific protocol tests
' -s t/data/647029.pe.markdup.bam -a t/data/CD630_updated_171212.embl.34.gff -p strand_specific -o ./_test '
          => [
            '_test.corrected.bam',
            '_test.corrected.bam.bai',
            '_test.expression.csv',
            '_test.CD630_updated_171212.embl.coverageplot.gz'
          ],
' -s t/data/647029.pe.markdup.bam -a t/data/CD630_updated_171212.embl.34.gff -p strand_specific -q 10 -o ./_test '
          => [
            '_test.corrected.bam',
            '_test.corrected.bam.bai',
            '_test.expression.csv',
            '_test.CD630_updated_171212.embl.coverageplot.gz'
          ],
' -s t/data/647029.pe.markdup.bam -a t/data/CD630_updated_171212.embl.34.gff -p strand_specific -b -o ./_test '
          => [
            '_test.corrected.bam',
            '_test.corrected.bam.bai',
            '_test.expression.csv',
            '_test.CD630_updated_171212.embl.coverageplot.gz'
          ],
' -s t/data/647029.pe.markdup.bam -a t/data/CD630_updated_171212.embl.34.gff -p strand_specific -q 10 -b -o ./_test '
          => [
            '_test.corrected.bam',
            '_test.corrected.bam.bai',
            '_test.expression.csv',
            '_test.CD630_updated_171212.embl.coverageplot.gz'
          ],	  

    '-h' => [ 'empty_file', 't/data/empty_file' ],
);
mock_execute_script_and_check_output( $script_name,
    \%scripts_and_expected_files );
	

cleanup_files();
done_testing();

sub cleanup_files {

    unlink('_test.corrected.bam');
    unlink('_test.corrected.bam.bai');
    unlink('_test.expression.csv');
    unlink('_test.CD630_updated_171212.embl.coverageplot.gz');

}
