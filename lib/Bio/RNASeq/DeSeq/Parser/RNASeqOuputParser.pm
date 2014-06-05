package Bio::RNASeq::DeSeq::Parser::RNASeqOutputParser;

# ABSTRACT: Parses a list of expression files created by the RNASeq pipeline into a single file fit for running a DeSeq analysis on

=head1 SYNOPSIS


=cut

use Moose;


has 'samples_file'                      => ( is => 'rw', isa => 'Str', required  => 1 );
has 'deseq_filename'               => ( is => 'rw', isa => 'Str', required  => 1 );


