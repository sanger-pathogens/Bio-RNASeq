#!/usr/bin/env perl
use Moose;
use Data::Dumper;
use File::Slurp;
use File::Path qw( remove_tree);
use Cwd;

BEGIN { unshift( @INC, './t/lib' ) }
with 'TestHelper';

BEGIN {
    use Test::Most;
    use_ok('Bio::RNASeq::CommandLine::GFF3Concat');
}
my $script_name = 'Bio::RNASeq::CommandLine::GFF3Concat';
my $cwd         = getcwd();

local $ENV{PATH} = "$ENV{PATH}:./bin";
my %scripts_and_expected_files;
system('touch empty_file');

%scripts_and_expected_files = (

    #No protocol argument, should default to standard
    ' -i t/data/gff_indir -o ./  -t test ' => [ 'test.gff', ],
	'-i t/data/gff_indir' => ['empty_file'],
	'-o ./' => ['empty_file'],
	'-t test' => ['empty_file'],
	'-i t/data/gff_indir -o ./' => ['empty_file'],
	'-i t/data/gff_indir -t test' => ['empty_file'],
	'-o ./ -t test' => ['empty_file'],
	'-h' => ['empty_file']

);

mock_execute_script_and_check_output( $script_name,
    \%scripts_and_expected_files );

cleanup_files();
done_testing();

sub cleanup_files {

    unlink('empty_file');
    unlink('test.gff');
}

#Test subroutines to put in a proper test filein the Bio::RNASeq package

sub test_boundary_navigation {

    my ( $gff_file_list, $boundaries ) = @_;

    print Dumper($boundaries);

    my $lines_counter = 0;

    for my $file (@$gff_file_list) {

        open( my $sgff_fh, "<", $file );

        while ( my $line = <$sgff_fh> ) {
            if (   $lines_counter > $boundaries->{$file}->[1]
                && $lines_counter < $boundaries->{$file}->[2] )
            {
                print "$line";
            }
            if ( $lines_counter > $boundaries->{$file}->[2] ) {
                print "$line";
            }
            $lines_counter++;
        }
    }
}

sub test_concatenate_gffs {

    my (
        $gff_file_list, $bgff_fh,  $temp_gff_fh, $temp_fa_fh,
        $boundaries,    $temp_gff, $temp_fa
    ) = @_;

    my $file_counter = 0;

    print Dumper($boundaries);

    for my $file (@$gff_file_list) {
        my $lines_counter = 0;
        open( my $sgff_fh, "<", $file );

        while ( my $line = <$sgff_fh> ) {
            if (   $lines_counter > $boundaries->{$file}->[1]
                && $lines_counter < $boundaries->{$file}->[1] + 4 )
            {
                print "$file\t$lines_counter\tBanana\n";
                print $temp_gff_fh "$line";
            }
            elsif ($lines_counter > $boundaries->{$file}->[2]
                && $lines_counter < $boundaries->{$file}->[2] + 4 )
            {
                print "$file\t$lines_counter\tMonkey\n";
                print $temp_fa_fh "$line";
            }
            $lines_counter++;
        }
        $file_counter++;
    }
    close($temp_gff_fh);
    close($temp_fa_fh);
    _merge_gff_fa( $bgff_fh, $temp_gff, $temp_fa );

}
