#!/usr/bin/env perl

package Bio::RNASeq::CommandLine::GFF3Concat;

use Moose;
use Getopt::Long qw(GetOptionsFromArray);;
use Data::Dumper;


has 'args' => ( is => 'ro', isa => 'ArrayRef', required => 1 );
has 'script_name' => ( is => 'ro', isa => 'Str', required => 1 );
has 'help' => ( is => 'rw', isa => 'Bool', default => 0 );

has 'input_dir' => ( is => 'rw', isa => 'Str');
has 'output_dir' => ( is => 'rw', isa => 'Str');
has 'tag' => ( is => 'rw', isa => 'Str');



sub BUILD {

  my ($self) =@_;

  my ($username,$input_dir,$output_dir,$tag);

  GetOptionsFromArray(
		      $self->args,
		      'i|input_dir=s'                      => \$input_dir,
		      'o|output_dir=s'                     => \$output_dir,
		      't|tag=s'                            => \$tag,
		      'h|help'                             => \$help,
		     );

  $self->input_dir($input_dir) if ( defined($input_dir) );
  $self->output_dir($output_dir) if ( defined($output_dir) );
  $self->tag($tag) if ( defined($tag) );
}

sub new {

  my ($self) = @_;

  ( $self->input_dir || $self->output_dir || $self->tag ) or die <<USAGE;
Usage:
  -i|input_dir        <full path to the directory containing the gff files to concatenate>
  -o|output_dir       <full path to the directory where the concatenated gff file will be written to>
  -t|tag              <the name to tag the concatenated gff file with>
  -h|help             <print this message>

  This script will concatenate several GFF files into one, maintaining GFF3 compatibility. 
  It takes in the location of the collection of GFF files [-i|input_dir];
  The path where the final concatenated GFF file should be written to [-o|output_dir];
  A customised tag for the newly created GFF file [t|tag].

USAGE

  my $command = "ls /lustre/scratch108/parasites/lc5/knowlesi.dir/pk_embl_feb14.dir/*.gff";
  my $big_gff = "/nfs/users/nfs_j/js21/hlustre/lia_rna_seq_test/lia_Pknowlesi_concat.gff";
  my $temp_gff = "/nfs/users/nfs_j/js21/hlustre/lia_rna_seq_test/temp_concat_gff";
  my $temp_fa = "/nfs/users/nfs_j/js21/hlustre/lia_rna_seq_test/temp_concat_fa";



  my ( $gff_file_list ) = get_gff_file_list( $command );
  my ( $boundaries ) = check_gffs_boundaries( $gff_file_list );

  my ( $temp_gff_fh, $temp_fa_fh, $bgff_fh ) = get_fhs_and_initialise( $temp_gff, $temp_fa, $big_gff );

  concatenate_gffs( $gff_file_list, $bgff_fh, $temp_gff_fh, $temp_fa_fh, $boundaries, $temp_gff, $temp_fa );

  tidy_up( $bgff_fh, $temp_gff_fh, $temp_fa_fh, $temp_gff, $temp_fa );


}

sub get_gff_file_list {

  my $command = shift;
  my @gff_file_list;

  push( @gff_file_list, split( /\n/, `$command` ) );

  return( \@gff_file_list );
}

sub check_gffs_boundaries {

  my ( $gff_file_list ) = @_;

  my %boundaries;

  for my $file (@$gff_file_list) {

    open ( my $sgff_fh, "<", $file );

    my $counter = 0;

    while ( my $line = <$sgff_fh> ) {
      if ( $line =~ m/^##/ ) {
	push( @{ $boundaries{$file} }, $counter );
      }
      $counter++
    }
  }
  return( \%boundaries );
}

sub get_fhs_and_initialise {

  my ( $temp_gff, $temp_fa, $big_gff ) = @_;

  if ( -e $big_gff ) {
    `rm $big_gff`;
    print "deleted $big_gff\n";
  }

  if ( -e $temp_gff ) {
    `rm $temp_gff`;
    print "deleted $temp_gff\n";
  }

  if ( -e $temp_fa ) {
    `rm $temp_fa`;
    print "deleted $temp_fa\n";
  }

  open ( my $bgff_fh, ">>", $big_gff );

  open ( my $temp_gff_fh, ">>", $temp_gff );
  print $temp_gff_fh "##gff-version 3\n";

  open ( my $temp_fa_fh, ">>", $temp_fa );
  print $temp_fa_fh "##FASTA\n";

  return( $temp_gff_fh, $temp_fa_fh, $bgff_fh );
}


sub concatenate_gffs {

  my ( $gff_file_list, $bgff_fh, $temp_gff_fh, $temp_fa_fh, $boundaries, $temp_gff, $temp_fa ) = @_;

  for my $file (@$gff_file_list) {
    my $lines_counter = 0;
    open ( my $sgff_fh, "<", $file );

    while ( my $line = <$sgff_fh> ) {
      if ( $lines_counter > $boundaries->{$file}->[1] && $lines_counter < $boundaries->{$file}->[2]) {
	print $temp_gff_fh "$line" ;
      }
      elsif ( $lines_counter > $boundaries->{$file}->[2]) {
	print $temp_fa_fh "$line" ;
      }
      $lines_counter++
    }
  }
  close($temp_gff_fh);
  close($temp_fa_fh);
  _merge_gff_fa( $bgff_fh, $temp_gff, $temp_fa );

}

sub _merge_gff_fa {

  my ( $bgff_fh, $temp_gff, $temp_fa ) = @_;

  open ( my $r_temp_gff_fh, "<", $temp_gff );
  open ( my $r_temp_fa_fh, "<", $temp_fa );

  while ( my $line = <$r_temp_gff_fh> ) {
    $line =~ s/\n//;
    print $bgff_fh "$line\n";
  }

  print "GFF annotations merged and ported. Will merge and port the FASTA sequences now\n";

  while ( my $line = <$r_temp_fa_fh> ) {
    $line =~ s/\n//;
    print $bgff_fh "$line\n";
  }

  print "Merged and ported the FASTA sequences\n";

  close($r_temp_gff_fh);
  close($r_temp_fa_fh);

}

sub tidy_up {

  my ( $bgff_fh, $temp_gff_fh, $temp_fa_fh, $temp_gff, $temp_fa ) = @_;

  close($bgff_fh);


  if ( -e $temp_gff ) {
    `rm $temp_gff`;
    print "deleted $temp_gff\n";
  }

  if ( -e $temp_fa ) {
    `rm $temp_fa`;
    print "deleted $temp_fa\n";
  }


}

#Test subroutines to put in a proper test filein the Bio::RNASeq package

sub test_boundary_navigation {

  my ( $gff_file_list, $boundaries ) = @_;

  print Dumper($boundaries);

  my $lines_counter = 0;

  for my $file (@$gff_file_list) {

    open ( my $sgff_fh, "<", $file );

    while ( my $line = <$sgff_fh> ) {
      if ( $lines_counter > $boundaries->{$file}->[1] && $lines_counter < $boundaries->{$file}->[2] ) {
  	print "$line" ;
      }
      if ( $lines_counter > $boundaries->{$file}->[2] ) {
  	print "$line" ;
      }
      $lines_counter++
    }
  }
}

sub test_concatenate_gffs {

  my ( $gff_file_list, $bgff_fh, $temp_gff_fh, $temp_fa_fh, $boundaries, $temp_gff, $temp_fa ) = @_;

  my $file_counter = 0;

  print Dumper($boundaries);

  for my $file (@$gff_file_list) {
    my $lines_counter = 0;
    open ( my $sgff_fh, "<", $file );

    while ( my $line = <$sgff_fh> ) {
      if ( $lines_counter > $boundaries->{$file}->[1] && $lines_counter < $boundaries->{$file}->[1] + 4 ) {
	print "$file\t$lines_counter\tBanana\n";
	print $temp_gff_fh "$line" ;
      }
      elsif ( $lines_counter > $boundaries->{$file}->[2] && $lines_counter < $boundaries->{$file}->[2] + 4 ) {
	print "$file\t$lines_counter\tMonkey\n";
	print $temp_fa_fh "$line" ;
      }
      $lines_counter++
    }
    $file_counter++
  }
  close($temp_gff_fh);
  close($temp_fa_fh);
  _merge_gff_fa( $bgff_fh, $temp_gff, $temp_fa );

}

1;
