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

# This filters out the tags from the gff file with awk to reduce the amount going into Bio::Tools::GFF, which is very slow
has 'tags_to_ignore' => 
(
  is      => 'rw',
  isa     => 'ArrayRef',
   default => sub { ['gene', 'stop_codon', 'start_codon', 'three_prime_UTR', 'five_prime_UTR', 'CDS'] }
  );
  
has 'exon_tag' => ( is => 'rw', isa => 'Str', default => 'exon' );


sub _build_gene_models {

  my ($self) = @_;

  $self->_three_layer_gene_model();

}

no Moose;
__PACKAGE__->meta->make_immutable;
1;
