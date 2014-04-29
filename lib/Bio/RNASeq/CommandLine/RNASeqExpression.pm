#!/usr/bin/env perl

package Bio::RNASeq::CommandLine::RNASeqExpression;

# ABSTRACT: Calculates RNASeq expression values

=head1 SYNOPSIS

Takes in an aligned sequence file (BAM) and a corresponding annotation file (GFF) and creates a spreadsheet with expression values.
The BAM must be aligned to the same reference that the annotation refers to.

=cut

use Moose;
use Getopt::Long qw(GetOptionsFromArray);
use Bio::RNASeq;
use Bio::RNASeq::CoveragePlot;


has 'args' => ( is => 'ro', isa => 'ArrayRef', required => 1 );
has 'script_name' => ( is => 'ro', isa => 'Str', required => 1 );
has 'help' => ( is => 'rw', isa => 'Bool', default => 0 );

has 'sequence_file' => ( is => 'rw', isa => 'Str');
has 'annotation_file' => ( is => 'rw', isa => 'Str');
has 'protocol' => ( is => 'rw', isa => 'Str', default => 'standard');
has 'output_base_filename' => ( is => 'rw', isa => 'Str');
has 'minimum_mapping_quality' => ( is => 'rw', isa => 'Int', default => 1);
has 'no_coverage_plots' => ( is => 'rw', isa => 'Bool', default => 0);
has 'intergenic_regions' => ( is => 'rw', isa => 'Bool', default => 0);
has 'bitwise_flag' => ( is => 'rw', isa => 'Bool', default => 1);

has '_filters' => ( is => 'rw', isa => 'HashRef', lazy => 1, builder => '_build__filters');
has '_protocols' => ( is => 'rw', isa => 'HashRef', lazy => 1, builder => '_build__protocols');
has 'expression_results' => (is => 'rw', isa => 'Object');



sub BUILD {

	my ($self) =@_;
	
	my($sequence_file, $annotation_file, $protocol_name, $output_base_filename, $minimum_mapping_quality, $no_coverage_plots, $intergenic_regions, $bitwise_flag, $help );

	GetOptionsFromArray(
	$self->args,
	's|sequence_file=s'                      => \$sequence_file,
	'a|annotation_file=s'                    => \$annotation_file,
	'p|protocol=s'                           => \$protocol_name,
	'o|output_base_filename=s'               => \$output_base_filename,
	'q|minimum_mapping_quality=s'            => \$minimum_mapping_quality,
	'c|no_coverage_plots'                    => \$no_coverage_plots,
	'i|intergenic_regions'                   => \$intergenic_regions,
	'b|bitwise_flag'                         => \$bitwise_flag,
	'h|help'                                 => \$help,
    );
	
	$self->sequence_file($sequence_file) if ( defined($sequence_file) );
	$self->annotation_file($annotation_file) if ( defined($annotation_file) );
	$self->protocol($protocol_name) if ( defined($protocol_name) );
	$self->output_base_filename($output_base_filename) if ( defined($output_base_filename) );
	$self->minimum_mapping_quality($minimum_mapping_quality) if ( defined($minimum_mapping_quality) );
	$self->no_coverage_plots($no_coverage_plots) if ( defined($no_coverage_plots) );
	$self->intergenic_regions($intergenic_regions) if ( defined($intergenic_regions) );
	$self->bitwise_flag($bitwise_flag) if ( defined($bitwise_flag) );

}

sub run {
	my ($self) = @_;
	
	($self->sequence_file && $self->annotation_file && $self->protocol) or die <<USAGE;
	
Usage:
  -s|sequence_file         <aligned BAM file>
  -a|annotation_file       <annotation file (GFF)>
  -p|protocol              <standard|strand_specific>
  -o|output_base_filename  <Optional: base name and location to use for output files>
  -q|minimum_mapping_quality <Optional: minimum mapping quality>
  -c|no_coverage_plots     <Dont create Artemis coverage plots>
  -i|intergenic_regions    <Include intergenic regions>
  -b|bitwise_flag        <Only include reads which pass filter>
  -h|help                  <print this message>

This script takes in an aligned sequence file (BAM) and a corresponding annotation file (GFF) and creates a spreadsheet with expression values.
The BAM must be aligned to the same reference that the annotation refers to and must be sorted.
USAGE

	$self->output_base_filename($self->sequence_file) unless (defined$self->output_base_filename);
	
	
	my $expression_results = Bio::RNASeq->new(
	  sequence_filename    => $self->sequence_file,
	  annotation_filename  => $self->annotation_file,
	  filters              => $self->_filters,
	  protocol             => $self->_protocols->{$self->protocol},
	  output_base_filename => $self->output_base_filename,
	  intergenic_regions   => $self->intergenic_regions,
	  );
	
	$expression_results->output_spreadsheet();
	
	unless($self->no_coverage_plots)
	{
	  Bio::RNASeq::CoveragePlot->new(
	    filename             => $expression_results->_corrected_sequence_filename,
	    output_base_filename => $self->output_base_filename,
	    mapping_quality      => $self->minimum_mapping_quality
	  )->create_plots();
	}
}


sub _build__filters {

	my ($self) = @_;
	my %filters = (mapping_quality => $self->minimum_mapping_quality);
	if(defined($self->bitwise_flag))
	{
	  $filters{bitwise_flag} = $self->bitwise_flag;
	}
	return \%filters;
}

sub _build__protocols {

	my ($self) = @_;
	my %protocols = (
		standard  => 'StandardProtocol',
		strand_specific => 'StrandSpecificProtocol'
		);
		
	return \%protocols;
}

1;