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
has '_gff_parser'       => ( is => 'rw', isa => 'Bio::Tools::GFF', lazy_build => 1 );
has 'tags_of_interest'          => ( is => 'rw', isa => 'ArrayRef', default => sub { [] } );
has 'gene_models'          => ( is => 'rw', isa => 'HashRef', lazy => 1, builder => '_build_gene_models');
has 'exon_tag' => ( is => 'rw', isa => 'Str', default => 'CDS' );

sub _build_gene_models {

  my ($self) = @_;
  return {};

}

sub is_tag_of_interest {

  my ($self,$input_tag) = @_;
  for my $tag( @{ $self->tags_of_interest() } ) {

    if( $tag eq $input_tag ) {
      return 1;
    }
  }
  return 0;
}

sub _three_layer_gene_model {

    my ($self) = @_;

    my %features;
    my %gene_id_lookup;


    while ( my $raw_feature = $self->_gff_parser->next_feature() ) {

        last unless defined($raw_feature);    # No more features

        next unless ( $self->is_tag_of_interest( $raw_feature->primary_tag ) );

        if ( $raw_feature->primary_tag eq 'gene' ) {

            my $gene_feature_object =
              Bio::RNASeq::Feature->new( raw_feature => $raw_feature );

            Bio::RNASeq::Exceptions::DuplicateFeatureID->throw(
                error => $self->filename . ' contains duplicate gene ids' )
              if ( defined $features{ $gene_feature_object->gene_id() } );

            $features{ $gene_feature_object->gene_id } = $gene_feature_object
              unless (
                defined( $features{ $gene_feature_object->gene_id } ) );

        }

        elsif ( $raw_feature->primary_tag eq 'mRNA' ) {

            my ( $mrna_parent, $mrna_id, @junk );

            next
              unless ( $raw_feature->has_tag('ID')
                && $raw_feature->has_tag('Parent') );

            ( $mrna_id,     @junk ) = $raw_feature->get_tag_values('ID');
            ( $mrna_parent, @junk ) = $raw_feature->get_tag_values('Parent');
            $gene_id_lookup{$mrna_id} = $mrna_parent;

        }
        elsif ( $raw_feature->primary_tag eq $self->exon_tag() ) {

            my ( $exon_parent, @junk );

            next
              unless ( $raw_feature->has_tag('Parent') );

            my $exon_feature_object =
              Bio::RNASeq::Feature->new( raw_feature => $raw_feature );

            ( $exon_parent, @junk ) = $raw_feature->get_tag_values('Parent');

            next unless ( defined $gene_id_lookup{$exon_parent} );

            $features{ $gene_id_lookup{$exon_parent} }
              ->add_discontinuous_feature($raw_feature);

        }

    }
    return \%features;

}


sub _build__gff_parser
{
  my ($self) = @_;

  Bio::Tools::GFF->new(-gff_version => 3, -file => $self->filename);
}


no Moose;
__PACKAGE__->meta->make_immutable;
1;