package Bio::RNASeq::GeneModelHandlers::GeneModelHandler;

# ABSTRACT:  Base class for handling gene models

=head1 SYNOPSIS
Base class for handling gene models
	use Bio::RNASeq::GeneModelHandlers::GeneModelHandler;
	my $gene_model_handler = Bio::RNASeq::GeneModelHandlers::GeneModelHandler->new(

	  );
=cut

use Moose;

has 'tags_of_interest'          => ( is => 'rw', isa => 'ArrayRef', default => sub { [] } );



sub is_tag_of_interest {

  my ($self,$input_tag) = @_;
  for my $tag( @{ $self->tags_of_interest() } ) {

    if( $tag eq $input_tag ) {
      return 1;
    }
  }
  return 0;
}


no Moose;
__PACKAGE__->meta->make_immutable;
1;
