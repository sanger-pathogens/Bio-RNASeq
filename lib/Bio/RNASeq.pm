package Bio::RNASeq;

# ABSTRACT: Find the expression when given an input aligned file and an annotation file

=head1 SYNOPSIS

Find the expression when given an input aligned file and an annotation file
	use Bio::RNASeq;
	my $expression_results = Bio::RNASeq->new(
	  sequence_filename => 'my_aligned_sequence.bam',
	  annotation_filename => 'my_annotation_file.gff',
	  output_base_filename => 'my_alignement_basename'
	  );
	
	$expression_results->output_spreadsheet();

=cut

use Moose;
use File::Temp qw/ tempdir /;
use Bio::RNASeq::GFF;
use Bio::RNASeq::AlignmentSliceRPKM;
use Bio::RNASeq::AlignmentSliceRPKMGeneModel;
use Bio::RNASeq::ExpressionStatsSpreadsheet;
use Bio::RNASeq::ValidateInputs;
use Bio::RNASeq::Exceptions;
use Bio::RNASeq::BitWise;
use Bio::RNASeq::IntergenicRegions;
use Bio::RNASeq::FeaturesTabFile;

has 'sequence_filename'    => ( is => 'rw', isa => 'Str', required => 1 );
has 'annotation_filename'  => ( is => 'rw', isa => 'Str', required => 1 );
has 'output_base_filename' => ( is => 'rw', isa => 'Str', required => 1 );

#optional input parameters
has 'filters' => ( is => 'rw', isa => 'Maybe[HashRef]' );
has 'protocol' =>
  ( is => 'rw', isa => 'Str', default => 'Bio::RNASeq::StandardProtocol' );
has 'samtools_exec' => ( is => 'rw', isa => 'Str', default => "samtools" );
has 'window_margin' => ( is => 'rw', isa => 'Int', default => 50 );
has 'intergenic_regions'      => ( is => 'rw', isa => 'Bool', default => 0 );
has 'minimum_intergenic_size' => ( is => 'rw', isa => 'Int',  default => 10 );
has 'total_mapped_reads_gene_model' =>
  ( is => 'rw', isa => 'Int', lazy => 1, default => 0 );

has '_annotation_file' =>  ( is => 'rw', isa => 'Bio::RNASeq::GFF', lazy_build => 1 );
has 'valid_run' => (is => 'rw', isa => 'Bool', builder => '_build__sequence_file' );
has '_results_spreadsheet' => (
    is         => 'rw',
    isa        => 'Bio::RNASeq::ExpressionStatsSpreadsheet',
    lazy_build => 1
);
has '_expression_results' => ( is => 'rw', isa => 'ArrayRef', lazy_build => 1 );
has '_temp_obj' => (is => 'rw', lazy => 1, builder => '_build__temp_obj' );
has '_sequence_validator' => (is => 'rw', isa => 'Bio::RNASeq::ValidateInputs', lazy => 1, builder => '_build__sequence_validator' );

sub _build__sequence_validator
{
   my ($self) = @_;

    my $validator = Bio::RNASeq::ValidateInputs->new(
        sequence_filename   => $self->sequence_filename,
        annotation_filename => $self->annotation_filename,
    );
    return $validator ;
}

sub _build__sequence_file {
    my ($self) = @_;
    unless ( $self->_sequence_validator->are_input_files_valid() ) {

        Bio::RNASeq::Exceptions::FailedToOpenAlignmentSlice->throw(
                error => "Run is invalid. Read names in "
              . $self->sequence_filename . " don't match the sequence region names in "
              . $self->annotation_filename
              . "\n"
        );
	die;
    }
}

sub _build__annotation_file {
    my ($self) = @_;
    Bio::RNASeq::GFF->new( filename => $self->annotation_filename );
}

sub _build__results_spreadsheet {
    my ($self) = @_;
    Bio::RNASeq::ExpressionStatsSpreadsheet->new(
        output_filename => $self->output_base_filename . ".expression.csv",
        protocol        => $self->protocol
    );
}

sub _corrected_sequence_filename {
    my ($self) = @_;
    return $self->output_base_filename . ".corrected.bam";
}

sub _build__temp_obj
{
  my($self) = @_;
  File::Temp->newdir(
     DIR     => File::Spec->curdir(),
     CLEANUP => 1
  ); 
}

sub _split_bam_by_chromosome
{
  my($self) = @_;
  
  for my $chromosome_name (keys %{$self->_sequence_validator->_actual_sequence_details})
  {
    system("samtools view -hb ".$self->_corrected_sequence_filename." $chromosome_name > ".$self->_temp_obj."/".$chromosome_name.".bam");
    system("samtools index ".$self->_temp_obj."/".$chromosome_name.".bam");
  }
}

sub _build__expression_results {
    my ($self) = @_;

    my $bitWise = Bio::RNASeq::BitWise->new(
					    filename        => $self->sequence_filename,
					    output_filename => $self->_corrected_sequence_filename,
					    protocol        => $self->protocol,
					    samtools_exec   => $self->samtools_exec
					   );
    $bitWise->update_bitwise_flags();
    my $total_mapped_reads = $bitWise->_total_mapped_reads;

    my @expression_results            = ();
    my @expression_results_gene_model = ();

    $self->_split_bam_by_chromosome;
    for my $feature_id (sort {$self->_annotation_file->features->{$a}->seq_id cmp $self->_annotation_file->features->{$b}->seq_id}  keys %{ $self->_annotation_file->features } ) {
      my $alignment_slice1 = Bio::RNASeq::AlignmentSliceRPKM->new(
								  filename           => $self->_temp_obj."/".$self->_annotation_file->features->{$feature_id}->seq_id.".bam",
								  total_mapped_reads => $total_mapped_reads,
								  feature       => $self->_annotation_file->features->{$feature_id},
								  filters       => $self->filters,
								  protocol      => $self->protocol,
								  samtools_exec => $self->samtools_exec,
								  window_margin => $self->window_margin,
								 );
      my $alignment_slice_results = $alignment_slice1->rpkm_values;

      $alignment_slice_results->{gene_id} = $feature_id;
      $alignment_slice_results->{seq_id} =
	$self->_annotation_file->features->{$feature_id}->seq_id;
      $alignment_slice_results->{locus_tag} =
	$self->_annotation_file->features->{$feature_id}->locus_tag;
      $alignment_slice_results->{feature_type} =
	$self->_annotation_file->features->{$feature_id}->feature_type;
      push( @expression_results, $alignment_slice_results );
    }

    if ( defined( $self->intergenic_regions )
	 && $self->intergenic_regions == 1 ) {
      $self->_calculate_values_for_intergenic_regions( \@expression_results,
						       $total_mapped_reads );
    }

    $self->_total_mapped_reads_gene_model_method( \@expression_results );

    for my $feature_id ( keys %{ $self->_annotation_file->features } ) {
      my $alignment_slice = Bio::RNASeq::AlignmentSliceRPKMGeneModel->new(
									  filename           => $self->_corrected_sequence_filename,
									  total_mapped_reads => $total_mapped_reads,
									  total_mapped_reads_gene_model =>
									  $self->total_mapped_reads_gene_model,
									  feature       => $self->_annotation_file->features->{$feature_id},
									  filters       => $self->filters,
									  protocol      => $self->protocol,
									  samtools_exec => $self->samtools_exec,
									  window_margin => $self->window_margin,
									 );
      my $alignment_slice_results_gene_model = $alignment_slice->rpkm_values;
      $alignment_slice_results_gene_model->{total_mapped_reads_gene_model} =
	$self->total_mapped_reads_gene_model;
      $alignment_slice_results_gene_model->{gene_id} = $feature_id;
      $alignment_slice_results_gene_model->{seq_id} =
	$self->_annotation_file->features->{$feature_id}->seq_id;
      $alignment_slice_results_gene_model->{locus_tag} =
	$self->_annotation_file->features->{$feature_id}->locus_tag;
      $alignment_slice_results_gene_model->{feature_type} =
	$self->_annotation_file->features->{$feature_id}->feature_type;

      push( @expression_results_gene_model,
	    $alignment_slice_results_gene_model );
    }

    $self->_merge_expression_results( \@expression_results,
				      \@expression_results_gene_model );

    return \@expression_results;
}

sub _calculate_values_for_intergenic_regions {
    my ( $self, $expression_results, $total_mapped_reads ) = @_;

    # get intergenic regions
    my $intergenic_regions = Bio::RNASeq::IntergenicRegions->new(
        features         => $self->_annotation_file->features,
        window_margin    => $self->window_margin,
        minimum_size     => $self->minimum_intergenic_size,
        sequence_lengths => $self->_annotation_file->sequence_lengths
    );

    # print out the features into a tab file for loading into Artemis
    my $tab_file_results = Bio::RNASeq::FeaturesTabFile->new(
        output_filename => $self->_corrected_sequence_filename . ".intergenic",
        features        => $intergenic_regions->intergenic_features,
        sequence_names  => $intergenic_regions->sequence_names
    );
    $tab_file_results->create_files;

    for my $feature_id ( keys %{ $intergenic_regions->intergenic_features } ) {
        my $alignment_slice = Bio::RNASeq::AlignmentSliceRPKM->new(
            filename           => $self->_corrected_sequence_filename,
            total_mapped_reads => $total_mapped_reads,
            feature  => $intergenic_regions->intergenic_features->{$feature_id},
            filters  => $self->filters,
            protocol => $self->protocol,
            samtools_exec => $self->samtools_exec,
            window_margin => 0,
            turn          => 1
        );
        my $alignment_slice_results = $alignment_slice->rpkm_values;

        $alignment_slice_results->{gene_id} = $feature_id;
        $alignment_slice_results->{seq_id} =
          $intergenic_regions->intergenic_features->{$feature_id}->seq_id;
        push( @{$expression_results}, $alignment_slice_results );
    }

    return $expression_results;
}

sub _total_mapped_reads_gene_model_method {

    my ( $self, $expression_results ) = @_;

    my $total_mapped_reads_gene_model = 0;
    for my $array (@$expression_results) {

        $total_mapped_reads_gene_model += ${$array}{total_mapped_reads};

    }

    $self->total_mapped_reads_gene_model($total_mapped_reads_gene_model);

}

sub _merge_expression_results {

    my ( $self, $expression_results, $expression_results_gene_model ) = @_;

    for ( my $i = 0 ; $i < scalar @$expression_results ; $i++ ) {
        $expression_results->[$i]->{rpkm_sense_gene_model} =
          $expression_results_gene_model->[$i]->{rpkm_sense_gene_model};
        $expression_results->[$i]->{rpkm_antisense_gene_model} =
          $expression_results_gene_model->[$i]->{rpkm_antisense_gene_model};
        $expression_results->[$i]->{total_mapped_reads_gene_model} =
          $expression_results_gene_model->[$i]->{total_mapped_reads_gene_model};
        $expression_results->[$i]->{total_rpkm_gene_model} =
          $expression_results_gene_model->[$i]->{total_rpkm_gene_model};
    }

}

sub output_spreadsheet {
    my ($self) = @_;

    for my $expression_result ( @{ $self->_expression_results } ) {
        $self->_results_spreadsheet->add_result($expression_result);
    }
    $self->_results_spreadsheet->build_and_close();
    return 1;
}

1;

