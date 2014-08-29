package Bio::RNASeq::GeneModelHandlers::OldChadoFormatGeneModelHandler;

# ABSTRACT: OldChadoFormat class for handling gene models where genes and exons are CDS features

=head1 SYNOPSIS
OldChadoFormat class for handling gene models where genes and exons are CDS features
	use Bio::RNASeq::GeneModelHandlers::OldChadoFormatGeneModelHandler;
	my $gene_model_handler = Bio::RNASeq::GeneModelHandlers::OldChadoFormatGeneModelHandler->new(

	  );
=cut

use Moose;
extends('Bio::RNASeq::GeneModelHandlers::GeneModelHandler');



no Moose;
__PACKAGE__->meta->make_immutable;
1;
