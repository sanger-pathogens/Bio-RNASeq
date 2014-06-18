package Bio::RNASeq::DeSeq::Validate::RNASeqOutput;

# ABSTRACT: Parses a list of expression files created by the RNASeq pipeline into a single file fit for running a DeSeq analysis on

=head1 SYNOPSIS


=cut

use Moose;
use List::MoreUtils qw(uniq);
use Data::Dumper;

has 'file_number'   => ( is => 'rw', isa => 'Int', required => 1 );
has 'genes'   => ( is => 'rw', isa => 'ArrayRef', required => 1 );


sub is_gene_universe_in_all_files {

  my ( $self ) = @_;

  my %validation;
  my @counts;
  map($validation{$_}++, @{ $self->genes });
  push(@counts, values %validation);

  my @unique_counts = uniq(@counts);
  if ( scalar @unique_counts == 1 ) {
    if ( $unique_counts[0] == $self->file_number ) {
      return 1;
    }
    else {
      return 0;
    }
  }
  else {
    return 0;
  }
}



1;
