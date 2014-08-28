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



no Moose;
__PACKAGE__->meta->make_immutable;
1;
