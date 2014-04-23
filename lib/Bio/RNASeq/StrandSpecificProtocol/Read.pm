package Bio::RNASeq::StrandSpecificProtocol::Read;

# ABSTRACT: Functionality for the strand specific protocol for reads

=head1 SYNOPSIS
Functionality for the strand specific protocol for reads
	use Bio::RNASeq::StrandSpecificProtocol::Read;
	my $alignment_slice = Bio::RNASeq::StrandSpecificProtocol::Read->new(
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
  $read_details->{flag} = Bio::RNASeq::Read->_unmark_duplicates($read_details->{flag});
}

sub _calculate_bitwise_flag
{
	my ($self, $flag) = @_;
	if ($flag & 128 && $flag & 2) 
  {
    if ($flag & 16) 
    {
      $flag = $flag - 16;     
    } 
    else 
    {
      $flag = $flag + 16;
    }
  }
  $flag = Bio::RNASeq::Read->_unmark_duplicates($flag);
  
  return $flag;
}


1;
