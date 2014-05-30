#!/usr/bin/env perl

package Bio::RNASeq::CommandLine::GFF3Concat;

# ABSTRACT: Concatenates GFF files into one GFF3 compatible file

use Moose;
use Getopt::Long qw(GetOptionsFromArray);
use Data::Dumper;

has 'args'        => ( is => 'ro', isa => 'ArrayRef', required => 1 );
has 'script_name' => ( is => 'ro', isa => 'Str',      required => 1 );
has 'help'        => ( is => 'rw', isa => 'Bool',     default  => 0 );

has 'input_dir'  => ( is => 'rw', isa => 'Str' );
has 'output_dir' => ( is => 'rw', isa => 'Str' );
has 'tag'        => ( is => 'rw', isa => 'Str' );

has 'command'   => ( is => 'rw', isa => 'Str', lazy_build => 1 );
has 'final_gff' => ( is => 'rw', isa => 'Str', lazy_build => 1 );
has 'temp_gff'  => ( is => 'rw', isa => 'Str', lazy_build => 1 );
has 'temp_fa'   => ( is => 'rw', isa => 'Str', lazy_build => 1 );

has 'gff_file_list' => ( is => 'rw', isa => 'ArrayRef', lazy_build => 1 );
has 'boundaries'    => ( is => 'rw', isa => 'HashRef',  lazy_build => 1 );
has 'file_handles'  => ( is => 'rw', isa => 'HashRef',  lazy_build => 1 );

sub BUILD {

    my ($self) = @_;

    my ( $username, $input_dir, $output_dir, $tag, $help );

    GetOptionsFromArray(
        $self->args,
        'i|input_dir=s'  => \$input_dir,
        'o|output_dir=s' => \$output_dir,
        't|tag=s'        => \$tag,
        'h|help'         => \$help,
    );

    $self->input_dir($input_dir)   if ( defined($input_dir) );
    $self->output_dir($output_dir) if ( defined($output_dir) );
    $self->tag($tag)               if ( defined($tag) );
}

sub run {

    my ($self) = @_;

    ( $self->input_dir && $self->output_dir && $self->tag ) or die <<USAGE;

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

    $self->_set_command_and_filepaths();
    $self->_get_gff_file_list();
    $self->_set_gff_files_boundaries();
    $self->_get_fhs_and_initialise();
    $self->_concatenate_gffs();
    $self->_tidy_up();
}

sub _set_command_and_filepaths {

    my ($self) = @_;
    $self->command( 'ls ' . $self->input_dir . '/*.gff' );
    $self->final_gff( $self->output_dir . '/' . $self->tag . '.gff' );
    $self->temp_gff( $self->output_dir . '/temp_' . $self->tag . '_gff' );
    $self->temp_fa( $self->output_dir . '/temp_' . $self->tag . '_fa' );
    return;

}

sub _get_gff_file_list {

    my ($self) = @_;

    my @gff_file_list;
    my $cmd = $self->command;
    push( @gff_file_list, split( /\n/, `$cmd` ) );
    $self->gff_file_list( \@gff_file_list );

    return;
}

sub _set_gff_files_boundaries {

    my ($self) = @_;

    my %boundaries;

    for my $file ( @{ $self->gff_file_list } ) {

        open( my $sgff_fh, "<", $file );

        my $counter = 0;

        while ( my $line = <$sgff_fh> ) {
            if ( $line =~ m/^##/ ) {
                push( @{ $boundaries{$file} }, $counter );
            }
            $counter++;
        }
    }
    $self->boundaries( \%boundaries );
    return;
}

sub _get_fhs_and_initialise {

    my ($self) = @_;

    if ( -e $self->final_gff ) {
        my $final_gff = $self->final_gff;
        `rm $final_gff`;
        print "deleted $final_gff\n";
    }

    if ( -e $self->temp_gff ) {
        my $temp_gff = $self->temp_gff;
        `rm $temp_gff`;
        print "deleted $temp_gff\n";
    }

    if ( -e $self->temp_fa ) {
        my $temp_fa = $self->temp_fa;
        `rm $temp_fa`;
        print "deleted $temp_fa\n";
    }

    my %file_handles;

    open( my $fgff_fh, ">>", $self->final_gff );

    open( my $tgff_fh, ">>", $self->temp_gff );
    print $tgff_fh "##gff-version 3\n";

    open( my $tfa_fh, ">>", $self->temp_fa );
    print $tfa_fh "##FASTA\n";

    $file_handles{final_gff} = $fgff_fh;
    $file_handles{temp_gff}  = $tgff_fh;
    $file_handles{temp_fa}   = $tfa_fh;

    $self->file_handles( \%file_handles );
    return;
}

sub _concatenate_gffs {

    my ($self) = @_;

    for my $file ( @{ $self->gff_file_list } ) {
        my $lines_counter = 0;
        open( my $sgff_fh, "<", $file );

        while ( my $line = <$sgff_fh> ) {
            if (   $lines_counter > $self->boundaries->{$file}->[1]
                && $lines_counter < $self->boundaries->{$file}->[2] )
            {
                $self->_print_to_file( 'temp_gff', $line, 0 );
            }
            elsif ( $lines_counter > $self->boundaries->{$file}->[2] ) {
                $self->_print_to_file( 'temp_fa', $line, 0 );
            }
            $lines_counter++;
        }
    }
    close( ${ $self->file_handles->{'temp_gff'} } );
    close( ${ $self->file_handles->{'temp_fa'} } );
    $self->_merge_gff_fa();
    return;
}

sub _merge_gff_fa {

    my ($self) = @_;

    open( my $r_temp_gff_fh, "<", $self->temp_gff );
    open( my $r_temp_fa_fh,  "<", $self->temp_fa );

    while ( my $line = <$r_temp_gff_fh> ) {
        $self->_print_to_file( 'final_gff', $line, 1 );
    }

    print
"GFF annotations merged and ported. Will merge and port the FASTA sequences now\n";

    while ( my $line = <$r_temp_fa_fh> ) {
        $line =~ s/\n//;
        $self->_print_to_file( 'final_gff', $line, 1 );
    }

    print "Merged and ported the FASTA sequences\n";

    close($r_temp_gff_fh);
    close($r_temp_fa_fh);
    return;
}

sub _print_to_file {

    my ( $self, $file, $line, $new_line ) = @_;
	
    if ($new_line) {
        $line =~ s/\n//;
        print { ${ $self->file_handles->{$file} } } "$line\n";

    }
    else {
        print { ${ $self->file_handles->{$file} } } "$line";
    }

    return;
}

sub _tidy_up {

    my ($self) = @_;

    if ( -e $self->temp_gff ) {
        my $temp_gff = $self->temp_gff;
        `rm $temp_gff`;
        print "deleted $temp_gff\n";
    }

    if ( -e $self->temp_fa ) {
        my $temp_fa = $self->temp_fa;
        `rm $temp_fa`;
        print "deleted $temp_fa\n";
    }

    close( ${ $self->file_handles->{final_gff} } );
    return;
}

1;
