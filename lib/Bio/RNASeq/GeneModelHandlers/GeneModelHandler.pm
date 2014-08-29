package Bio::RNASeq::GeneModelHandlers::GeneModelHandler;

# ABSTRACT:  Base class for handling gene models

=head1 SYNOPSIS
Base class for handling gene models
	use Bio::RNASeq::GeneModelHandlers::GeneModelHandler;
	my $gene_model_handler = Bio::RNASeq::GeneModelHandlers::GeneModelHandler->new(

	  );
=cut

use Moose;
use Bio::Tools::GFF;
use Bio::RNASeq::Types;
use Bio::RNASeq::Feature;

has 'filename'          => ( is => 'rw', isa => 'Bio::RNASeq::File',             required   => 1 );
has 'tags_of_interest'          => ( is => 'rw', isa => 'ArrayRef', default => sub { [] } );
has 'gene_models'          => ( is => 'rw', isa => 'HashRef', lazy=> 1, builder => '_build_gene_models');
has '_gff_parser'       => ( is => 'rw', isa => 'Bio::Tools::GFF', lazy_build => 1 );

sub is_tag_of_interest {

  my ($self,$input_tag) = @_;
  for my $tag( @{ $self->tags_of_interest() } ) {

    if( $tag eq $input_tag ) {
      return 1;
    }
  }
  return 0;
}

sub _build_gene_models {

  my ($self) = @_;

  return {};

}

sub _build__gff_parser
{
  my ($self) = @_;

  Bio::Tools::GFF->new(-gff_version => 3, -file => $self->filename);
}


no Moose;
__PACKAGE__->meta->make_immutable;
1;
