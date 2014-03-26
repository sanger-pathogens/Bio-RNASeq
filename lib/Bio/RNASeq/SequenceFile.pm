#PODNAME: Bio::RNASeq

=head1 NAME

SequenceFile.pm   - Represents a SequenceFile file for use in RNASeq

=head1 SYNOPSIS

use Bio::RNASeq::SequenceFile;
my $rna_seq_bam = Bio::RNASeq::SequenceFile->new(
  filename => '/abc/my_file.bam'
  );
  $rna_seq_bam->total_mapped_reads;

=cut
package Bio::RNASeq::SequenceFile;
use Moose;
extends 'Bio::RNASeq::BAMStats';

has 'filename'           => ( is => 'rw', isa => 'Str', required   => 1 );
1;
