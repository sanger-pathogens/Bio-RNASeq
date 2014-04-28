package Bio::RNASeq::AlignmentSliceRPKM;

# ABSTRACT: Calculates RPKM values

=head1 SYNOPSIS

See AlignmentSliceCommon

=cut

use Moose;
use Bio::RNASeq::AlignmentSliceCommon;

extends 'Bio::RNASeq::AlignmentSliceCommon';

sub _calculate {
    my ( $self, $mapped_reads ) = @_;

	if($self->feature->exon_length == 0 || $self->total_mapped_reads == 0) {
		return 0;
	}
    my $rpkm =
      ( $mapped_reads / $self->feature->exon_length ) *
      ( 1000000000 / $self->total_mapped_reads );

    return $rpkm;
}

no Moose;
__PACKAGE__->meta->make_immutable;
1;
