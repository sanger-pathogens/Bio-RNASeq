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

has 'tags_of_interest'          => ( is => 'rw', isa => 'ArrayRef', default => sub { ['gene','mRNA','exon'] } );

override 'gene_models' => sub {

  my ($self) = @_;

  my $features = super();
  my %gene_id_lookup;

  while ( my $raw_feature = $self->_gff_parser->next_feature() ) {

    last unless defined($raw_feature); # No more features

    next unless ( $self->is_tag_of_interest( $raw_feature->primary_tag ) );

    if ( $raw_feature->primary_tag eq 'gene' ) {

      my $gene_feature_object =
	Bio::RNASeq::Feature->new( raw_feature => $raw_feature );

      Bio::RNASeq::Exceptions::DuplicateFeatureID->throw(error => $self->filename . ' contains duplicate gene ids') if ( defined $features->{$gene_feature_object->gene_id()} );


      $features->{ $gene_feature_object->gene_id } = $gene_feature_object unless( defined( $features->{ $gene_feature_object->gene_id } ) );

    }

    elsif ( $raw_feature->primary_tag eq 'mRNA' ) {

      my ($mrna_parent, $mrna_id, @junk);

      next
	unless ( $raw_feature->has_tag('ID')
		 && $raw_feature->has_tag('Parent') );

	( $mrna_id, @junk ) = $raw_feature->get_tag_values('ID');
	( $mrna_parent, @junk ) = $raw_feature->get_tag_values('Parent');
	$gene_id_lookup{$mrna_id} = $mrna_parent; 

    
    }
    elsif ( $raw_feature->primary_tag eq 'exon' ) {

      my ($exon_parent, @junk);

      next
	unless ( $raw_feature->has_tag('Parent') );

      my $exon_feature_object =
	Bio::RNASeq::Feature->new( raw_feature => $raw_feature );

      ( $exon_parent, @junk ) = $raw_feature->get_tag_values('Parent');

      next unless ( defined $gene_id_lookup{$exon_parent} );

      $features->{ $gene_id_lookup{$exon_parent} }->add_discontinuous_feature($raw_feature);

    
    }

  }
  return $features;
};


no Moose;
__PACKAGE__->meta->make_immutable;
1;
