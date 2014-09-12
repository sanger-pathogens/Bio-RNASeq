package Bio::RNASeq::GeneModelHandlers::ChadoGeneModelHandler;

# ABSTRACT: Chado class for handling gene models

=head1 SYNOPSIS
Chado class for handling gene models
	use Bio::RNASeq::GeneModelHandlers::ChadoGeneModelHandler;
	my $gene_model_handler = Bio::RNASeq::GeneModelHandlers::ChadoGeneModelHandler->new(

	  );
=cut

use Moose;
use Bio::RNASeq::Exceptions;
extends('Bio::RNASeq::GeneModelHandlers::GeneModelHandler');

has 'tags_of_interest' => (
    is      => 'rw',
    isa     => 'ArrayRef',
    default => sub { ['mRNA', 'CDS' ] }
);


has 'tags_to_ignore' => 
(
    is      => 'rw',
    isa     => 'ArrayRef',
     default => sub { ['centromere','gap','gene', 'ncRNA','polypeptide','pseudogene','pseudogenic_exon','pseudogenic_transcript','region','repeat_region','rRNA','snoRNA','snRNA','tRNA',
     ] }
  );


has 'exon_tag' => ( is => 'rw', isa => 'Str', default => 'CDS' );

sub _build_gene_models {

  my ($self) = @_;

  $self->_three_layer_gene_model();
  
}


no Moose;
__PACKAGE__->meta->make_immutable;
1;
