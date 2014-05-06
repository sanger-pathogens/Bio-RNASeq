package Bio::RNASeq::SequenceFile;

# ABSTRACT: Represents a SequenceFile file for use in RNASeq

=head1 SYNOPSIS

use Bio::RNASeq::SequenceFile;
Represents a SequenceFile file for use in RNASeq
	my $rna_seq_bam = Bio::RNASeq::SequenceFile->new(
	  filename => '/abc/my_file.bam'
	  );
	  $rna_seq_bam->total_mapped_reads;

=cut

use Moose;
extends 'Bio::RNASeq::BAMStats';

has 'filename'           => ( is => 'rw', isa => 'Str', required   => 1 );

no Moose;
__PACKAGE__->meta->make_immutable;
1;
