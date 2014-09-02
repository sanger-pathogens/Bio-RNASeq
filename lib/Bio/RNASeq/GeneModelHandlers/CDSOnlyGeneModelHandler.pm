package Bio::RNASeq::GeneModelHandlers::CDSOnlyGeneModelHandler;

# ABSTRACT: CDSOnly class for handling gene models

=head1 SYNOPSIS
CDSOnly class for handling gene models
	use Bio::RNASeq::GeneModelHandlers::CDSOnlyGeneModelHandler;
	my $gene_model_handler = Bio::RNASeq::GeneModelHandlers::CDSOnlyGeneModelHandler->new(

	  );
=cut

use Moose;
extends('Bio::RNASeq::GeneModelHandlers::GeneModelHandler');

has 'tags_of_interest'          => ( is => 'rw', isa => 'ArrayRef', default => sub { ['CDS'] } );


override 'gene_models' => sub {

    my ($self) = @_;

    my $features = super();

    while ( my $raw_feature = $self->_gff_parser->next_feature() ) {

        last unless defined($raw_feature);    # No more features

        next
          unless (
            $self->is_tag_of_interest(
                $raw_feature->primary_tag
            )
          );

        my $feature_object =
          Bio::RNASeq::Feature->new( raw_feature => $raw_feature );

        $features->{ $feature_object->gene_id } = $feature_object;

    }

    return $features;
};

no Moose;
__PACKAGE__->meta->make_immutable;
1;
