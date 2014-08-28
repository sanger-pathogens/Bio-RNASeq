package Bio::RNASeq::GeneModelHandlers::ChadoGeneModelHandler;

# ABSTRACT: Chado class for handling gene models

=head1 SYNOPSIS
Chado class for handling gene models
	use Bio::RNASeq::GeneModelHandlers::ChadoGeneModelHandler;
	my $gene_model_handler = Bio::RNASeq::GeneModelHandlers::ChadoGeneModelHandler->new(

	  );
=cut

use Moose;
extends('Bio::RNASeq::GeneModelHandlers::GeneModelHandler');



no Moose;
__PACKAGE__->meta->make_immutable;
1;
