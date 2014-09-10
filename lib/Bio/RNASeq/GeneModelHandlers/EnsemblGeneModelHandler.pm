package Bio::RNASeq::GeneModelHandlers::EnsemblGeneModelHandler;

# ABSTRACT: Ensembl class for handling gene models

=head1 SYNOPSIS
Ensembl class for handling gene models
	use Bio::RNASeq::GeneModelHandlers::EnsemblGeneModelHandler;
	my $gene_model_handler = Bio::RNASeq::GeneModelHandlers::EnsemblGeneModelHandler->new(

	  );
=cut

use Moose;
extends('Bio::RNASeq::GeneModelHandlers::GeneModelHandler');

has 'tags_of_interest' => (
    is      => 'rw',
    isa     => 'ArrayRef',
    default => sub { ['mRNA', 'transcript', 'exon' ] }
);

has 'exon_tag' => ( is => 'rw', isa => 'Str', default => 'exon' );


sub _build_gene_models {

  my ($self) = @_;

  $self->_three_layer_gene_model();

}

no Moose;
__PACKAGE__->meta->make_immutable;
1;
