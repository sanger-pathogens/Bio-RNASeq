package Bio::RNASeq::DeSeq::Validate::RNASeqOutput;

# ABSTRACT: Parses a list of expression files created by the RNASeq pipeline into a single file fit for running a DeSeq analysis on

=head1 SYNOPSIS


=cut

use Moose;

has 'file_number'   => ( is => 'rw', isa => 'Int', required => 1 );
has 'genes'   => ( is => 'rw', isa => 'ArrayRef', required => 1 );


sub is_gene_universe_shared_by_all_files {

  my ( $self ) = @_;

  map($hash{$_}++, @array);
  print join(' ',map($_.':'.$hash{$_}, sort {$hash{$a}<=>$hash{$b}} keys %hash));

}



1;
