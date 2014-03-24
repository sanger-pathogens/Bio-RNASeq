=head1 NAME

Read.pm   - Tradis protocol, just inherits from the base read class

=head1 SYNOPSIS

use Bio::RNASeq::TradisProtocol::Read;
my $alignment_slice = Bio::RNASeq::TradisProtocol::Read->new(
  alignment_line => 'xxxxxxx',
  gene_strand => 1,
  exons => [[1,3],[4,5]]
  );
  my %mapped_reads = $alignment_slice->mapped_reads;
  $mapped_reads{sense};
  $mapped_reads{antisense};

=cut

package Bio::RNASeq::TradisProtocol::Read;
use Moose;
extends 'Bio::RNASeq::Read';

sub _process_read_details
{
  my ($self, $read_details) = @_;
  $read_details->{flag} = Bio::RNASeq::TradisProtocol::Read->_calculate_bitwise_flag($read_details->{flag});
}

sub _calculate_bitwise_flag
{
	my ($self, $flag) = @_;
  $flag = Bio::RNASeq::Read->_unmark_duplicates($flag);
  
  return $flag;
}


1;
