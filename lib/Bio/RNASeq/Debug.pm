package Bio::RNASeq::Debug;

use Moose;

has 'sr' => (
	     is => 'rw',
	     isa => 'Str'
	     );

has 'where' => (
	     is => 'rw',
	     isa => 'Str'
	     );

sub print_where {

  my $self = shift;
  print($self->where, ' sub ', $self->sr, "\n");
  return 1;

}


no Moose;
__PACKAGE__->meta->make_immutable;

1;
