package Bio::RNASeq::AlignmentSliceRPKMGeneModel;

# ABSTRACT: Calculates RPKM values based on total reads mapped to gene models

=head1 SYNOPSIS

See AlignmentSliceCommon

=cut

use Moose;
use Bio::RNASeq::AlignmentSliceCommon;

extends 'Bio::RNASeq::AlignmentSliceCommon';

has 'total_mapped_reads_gene_model' => ( is => 'rw', isa => 'Int', default => 0);

sub _postprocess_rpkm_values {
	
	    my ($self) = @_;

	
    $self->rpkm_values->{rpkm_sense_gene_model} =
      $self->_calculate( $self->rpkm_values->{mapped_reads_sense_gene_model} );
	  
	   	  #print("Mapped reads sense gene model: ", $self->rpkm_values->{mapped_reads_sense_gene_model}, "\n");
	  
    $self->rpkm_values->{rpkm_antisense_gene_model} =
      $self->_calculate( $self->rpkm_values->{mapped_reads_antisense_gene_model} );
	  
	  	#print("Mapped reads antisense gene model: ", $self->rpkm_values->{mapped_reads_antisense_gene_model}, "\n");

    $self->rpkm_values->{total_rpkm_gene_model} =
      $self->rpkm_values->{rpkm_sense_gene_model} + $self->rpkm_values->{rpkm_antisense_gene_model};
	  
 	  #print("Total RPKM gene model: ", $self->rpkm_values->{total_rpkm_gene_model}, "\n");
	  
    $self->rpkm_values->{total_mapped_reads_gene_model} =
      $self->rpkm_values->{mapped_reads_antisense_gene_model} + $self->rpkm_values->{mapped_reads_sense_gene_model};

	  #print("Total mapped reads gene model: ", $self->rpkm_values->{total_mapped_reads_gene_model}, "\n");



		
}

sub _calculate {
    my ( $self, $mapped_reads ) = @_;


	if($self->feature->exon_length == 0 || $self->total_mapped_reads_gene_model == 0) {
		return 0;
	}
    my $rpkm =
      ( $mapped_reads / $self->feature->exon_length ) *
      ( 1000000000 / $self->total_mapped_reads_gene_model );

	  #print "$rpkm\n";
    return $rpkm;
}

no Moose;
__PACKAGE__->meta->make_immutable;
1;
