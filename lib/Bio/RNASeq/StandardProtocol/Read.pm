package Bio::RNASeq::StandardProtocol::Read;

# ABSTRACT:  Functionality for the standard protocol

=head1 SYNOPSIS
Functionality for the standard protocol
	use Bio::RNASeq::StandardProtocol::Read;
	my $alignment_slice = Bio::RNASeq::StandardProtocol::Read->new(
	  alignment_line => 'xxxxxxx',
	  gene_strand => 1,
	  exons => [[1,3],[4,5]]
	  );
	  my %mapped_reads = $alignment_slice->mapped_reads;
	  $mapped_reads{sense};
	  $mapped_reads{antisense};

=cut

use Moose;
extends 'Bio::RNASeq::Read';

sub _process_read_details
{
  my ($self, $read_details) = @_;
  $read_details->{flag} = Bio::RNASeq::StandardProtocol::Read->_calculate_bitwise_flag($read_details->{flag});
}

sub _calculate_bitwise_flag
{
	my ($self, $flag) = @_;
  $flag = Bio::RNASeq::Read->_unmark_duplicates($flag);
  
  return $flag;
}

no Moose;
__PACKAGE__->meta->make_immutable;
1;
