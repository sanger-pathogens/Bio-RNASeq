package Bio::RNASeq::AlignmentSliceRPKM;

# ABSTRACT: Calculates RPKM values

=head1 SYNOPSIS

See AlignmentSliceCommon

=cut

use Moose;
use Bio::RNASeq::AlignmentSliceCommon;

extends 'Bio::RNASeq::AlignmentSliceCommon';

sub _postprocess_rpkm_values {
	
	my ($self) = @_;
	
    $self->rpkm_values->{rpkm_sense} =
      $self->_calculate( $self->rpkm_values->{mapped_reads_sense} );
	  
	  	   	  #print("Mapped reads sense: ", $self->rpkm_values->{mapped_reads_sense}, "\n");
	  
    $self->rpkm_values->{rpkm_antisense} =
      $self->_calculate( $self->rpkm_values->{mapped_reads_antisense} );
	  
	  	  	#print("Mapped reads antisense: ", $self->rpkm_values->{mapped_reads_antisense}, "\n");

    $self->rpkm_values->{total_rpkm} =
      $self->rpkm_values->{rpkm_sense} + $self->rpkm_values->{rpkm_antisense};
	  
	   	  #print("Total RPKM: ", $self->rpkm_values->{total_rpkm}, "\n");
		  
    $self->rpkm_values->{total_mapped_reads} =
      $self->rpkm_values->{mapped_reads_antisense} + $self->rpkm_values->{mapped_reads_sense};
	  
	  	  #print("Total mapped reads: ", $self->rpkm_values->{total_mapped_reads}, "\n");
		
}

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
