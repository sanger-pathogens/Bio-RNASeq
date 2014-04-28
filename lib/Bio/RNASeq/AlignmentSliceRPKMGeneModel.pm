package Bio::RNASeq::AlignmentSliceRPKMGeneModel;

# ABSTRACT: Calculates RPKM values based on total reads mapped to gene models

=head1 SYNOPSIS

See AlignmentSliceCommon

=cut

use Moose;
use Bio::RNASeq::AlignmentSliceCommon;

extends 'Bio::RNASeq::AlignmentSliceCommon';

has 'total_mapped_reads_to_gene_models' => ( is => 'rw', isa => 'Int', default => 0);

sub _calculate {
    my ( $self, $mapped_reads ) = @_;

	if($self->feature->exon_length == 0 || $self->total_mapped_reads_to_gene_models == 0) {
		return 0;
	}
    my $rpkm =
      ( $mapped_reads / $self->feature->exon_length ) *
      ( 1000000000 / $self->total_mapped_reads_to_gene_models );

    return $rpkm;
}

no Moose;
__PACKAGE__->meta->make_immutable;
1;
