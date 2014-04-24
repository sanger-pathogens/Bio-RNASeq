#!/usr/bin/env perl

package Bio::RNASeq::Main::RNASeqExpression;

# ABSTRACT: Calculates RNASeq expression values
# PODNAME: rna_seq_expression

=head1 SYNOPSIS

This script takes in an aligned sequence file (BAM) and a corresponding annotation file (GFF) and creates a spreadsheet with expression values.
The BAM must be aligned to the same reference that the annotation refers to.

=cut

use strict;
use warnings;
no warnings 'uninitialized';
use Getopt::Long;
use Bio::RNASeq;
use Bio::RNASeq::CoveragePlot;

my($sequence_file, $annotation_file, $protocol_name, $output_base_filename, $mapping_quality, $no_coverage_plots, $intergenic_regions, $bitwise_flag, $help );

my $total_mapped_reads_method = 'default';

GetOptions(
	   's|sequence_file=s'                      => \$sequence_file,
	   'a|annotation_file=s'                    => \$annotation_file,
	   'p|protocol=s'                           => \$protocol_name,
	   'o|output_base_filename=s'               => \$output_base_filename,
	   'q|minimum_mapping_quality=s'            => \$mapping_quality,
	   'c|no_coverage_plots'                    => \$no_coverage_plots,
	   'i|intergenic_regions'                   => \$intergenic_regions,
	   'b|bitwise_flag'                         => \$bitwise_flag,
	   't|total_mapped_reads_method:s'          => \$total_mapped_reads_method,
	   'h|help'                                 => \$help,
    );

($sequence_file && $annotation_file && $protocol_name) or die <<USAGE;

Usage: $0
  -s|sequence_file         <aligned BAM file>
  -a|annotation_file       <annotation file (GFF)>
  -p|protocol              <standard|strand_specific>
  -o|output_base_filename  <Optional: base name and location to use for output files>
  -q|minimum_mapping_quality <Optional: minimum mapping quality>
  -c|no_coverage_plots     <Dont create Artemis coverage plots>
  -i|intergenic_regions    <Include intergenic regions>
  -b|bitwise_flag        <Only include reads which pass filter>
  -t|total_mapped_reads_method        <a|b - If not set defaults to total reads mapped to the ref sequence in the bam file, no quality filters applied>
  -h|help                  <print this message>

This script takes in an aligned sequence file (BAM) and a corresponding annotation file (GFF) and creates a spreadsheet with expression values.
The BAM must be aligned to the same reference that the annotation refers to and must be sorted.
USAGE

$output_base_filename ||= $sequence_file;
$mapping_quality ||= 1;
my %filters = (mapping_quality => $mapping_quality);
if(defined($bitwise_flag))
{
  $filters{bitwise_flag} = $bitwise_flag ;
}

my %protocols = ( 
	standard    => "StandardProtocol",
	strand_specific => "StrandSpecificProtocol"
);

my $expression_results = Bio::RNASeq->new(
  sequence_filename    => $sequence_file,
  annotation_filename  => $annotation_file,
  filters              => \%filters,
  protocol             => $protocols{$protocol_name},
  output_base_filename => $output_base_filename,
  intergenic_regions   => $intergenic_regions,
  total_mapped_reads_method   => $total_mapped_reads_method
  );



$expression_results->output_spreadsheet();

unless($no_coverage_plots)
{
  Bio::RNASeq::CoveragePlot->new(
    filename             => $expression_results->_corrected_sequence_filename,
    output_base_filename => $output_base_filename,
    mapping_quality      => $mapping_quality
  )->create_plots();
}
