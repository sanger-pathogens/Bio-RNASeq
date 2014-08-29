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

no Moose;
__PACKAGE__->meta->make_immutable;
1;
