package Bio::RNASeq::ExpressionStatsSpreadsheet;

# ABSTRACT: Builds a spreadsheet of expression results

=head1 SYNOPSIS
Builds a spreadsheet of expression results
	use Bio::RNASeq::ExpressionStatsSpreadsheet;
	my $expression_results = Bio::RNASeq::ExpressionStatsSpreadsheet->new(
	  output_filename => '/abc/my_results.csv',
	  );
	$expression_results->add_result($my_rpkm_values);
	$expression_results->add_result($more_rpkm_values);
	$expression_results->build_and_close();
=cut

use Moose;
extends 'Bio::RNASeq::CommonSpreadsheet';

sub _result_rows {
    my ($self) = @_;
    my @denormalised_results;
    for my $result_set ( @{ $self->_results } ) {
        push(
            @denormalised_results,
            [
	     $result_set->{seq_id},
	     $result_set->{gene_id},
	     $result_set->{locus_tag},
	     $result_set->{feature_type},
	     $result_set->{total_mapped_reads},
	     $result_set->{total_rpkm},
	     $result_set->{total_mapped_reads_gene_model},
	     $result_set->{total_rpkm_gene_model},
	     $result_set->{mapped_reads_sense},
	     $result_set->{rpkm_sense},
	     $result_set->{rpkm_sense_gene_model},
	     $result_set->{mapped_reads_antisense},
	     $result_set->{rpkm_antisense},
	     $result_set->{rpkm_antisense_gene_model},
            ]
        );
    }

    return \@denormalised_results;
}


sub _header {
    my ($self) = @_;
    my @header;

    if ( $self->protocol eq "StrandSpecificProtocol" ) {

        @header = [
		   "Seq ID",
		   "GeneID",
		   "Locus Tag",
		   "Feature Type",
		   "Total Reads Mapping",
		   "Total RPKM (Reads Mapped)",
		   "Total Reads Mapping (Reads Mapped to Gene Models)",
		   "Total RPKM (Reads Mapped to Gene Models)",
		   "Antisense Reads Mapping",
		   "Antisense RPKM (Reads Mapped)",
		   "Antisense RPKM (Reads Mapped to Gene Models)",
		   "Sense Reads Mapping",
		   "Sense RPKM (Reads Mapped)",
		   "Sense RPKM (Reads Mapped to Gene Models)",
		  ];
      } else {
        @header = [
		   "Seq ID",
		   "GeneID",
		   "Locus Tag",
		   "Feature Type",
		   "Total Reads Mapping",
		   "Total RPKM (Reads Mapped)",
		   "Total Reads Mapping (Reads Mapped to Gene Models)",
		   "Total RPKM (Reads Mapped to Gene Models)",
		   "Sense Reads Mapping",
		   "Sense RPKM (Reads Mapped)",
		   "Sense RPKM (Reads Mapped to Gene Models)",
		   "Antisense Reads Mapping",
		   "Antisense RPKM (Reads Mapped)",
		   "Antisense RPKM (Reads Mapped to Gene Models)",
		  ];
      }

    return \@header;
}

no Moose;
__PACKAGE__->meta->make_immutable;
1;
