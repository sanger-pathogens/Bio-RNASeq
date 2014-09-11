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
use File::Path qw( remove_tree);
use File::Spec;
use File::Slurp;
use Parallel::ForkManager;
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
has 'parallel_processes'   => ( is => 'ro', isa => 'Int', default  => 1 );

#optional input parameters
has 'filters'                       => ( is => 'rw', isa => 'Maybe[HashRef]' );
has 'protocol'                      => ( is => 'rw', isa => 'Str', default => 'Bio::RNASeq::StandardProtocol' );
has 'samtools_exec'                 => ( is => 'rw', isa => 'Str', default => "samtools" );
has 'window_margin'                 => ( is => 'rw', isa => 'Int', default => 50 );
has 'intergenic_regions'            => ( is => 'rw', isa => 'Bool', default => 0 );
has 'minimum_intergenic_size'       => ( is => 'rw', isa => 'Int', default => 10 );
has 'total_mapped_reads_gene_model' => ( is => 'rw', isa => 'Int', lazy => 1, default => 0 );

has '_annotation_file' => ( is => 'rw', isa => 'Bio::RNASeq::GFF', lazy_build => 1 );
has 'valid_run'        => ( is => 'rw', isa => 'Bool',             builder    => '_build__sequence_file' );
has '_results_spreadsheet' => (
    is         => 'rw',
    isa        => 'Bio::RNASeq::ExpressionStatsSpreadsheet',
    lazy_build => 1
);
has '_expression_results' => ( is => 'rw', isa  => 'ArrayRef', lazy_build => 1 );
has '_temp_obj'           => ( is => 'rw', lazy => 1,          builder    => '_build__temp_obj' );
has '_temp_dirname'       => ( is => 'rw', isa  => 'Str',      lazy       => 1, builder => '_build__temp_dirname' );

has '_sequence_validator' => ( is => 'rw', isa => 'Bio::RNASeq::ValidateInputs', lazy => 1, builder => '_build__sequence_validator' );

sub _build__sequence_validator {
    my ($self) = @_;

    my $validator = Bio::RNASeq::ValidateInputs->new(
        sequence_filename   => $self->sequence_filename,
        annotation_filename => $self->annotation_filename,
    );
    return $validator;
}

sub _build__sequence_file {
    my ($self) = @_;
    unless ( $self->_sequence_validator->are_input_files_valid() ) {

        Bio::RNASeq::Exceptions::FailedToOpenAlignmentSlice->throw(
            error => "Run is invalid. Read names in " . $self->sequence_filename . " don't match the sequence region names in " . $self->annotation_filename . "\n" );
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

sub _build__temp_obj {
    my ($self) = @_;
    File::Temp->newdir(
        DIR     => File::Spec->curdir(),
        CLEANUP => 1
    );
}

sub _build__temp_dirname {
    my ($self) = @_;
    $self->_temp_obj->dirname;
}

sub _split_bam_by_chromosome {
    my ($self) = @_;
    my $pm = new Parallel::ForkManager( $self->parallel_processes );

    for my $chromosome_name ( keys %{ $self->_sequence_validator->_actual_sequence_details } ) {
        my $output_file = $self->_temp_dirname . "/" . $chromosome_name . ".bam";
        $pm->start and next;    # fork here
        system( "samtools view -hb " . $self->_corrected_sequence_filename . " $chromosome_name > " . $output_file );
        system("samtools index $output_file");

        # Only store every 50th base coordinate, then extend the gene start and end by 50 when prefiltering features
        system("samtools view -bu $output_file 2>/dev/null | samtools mpileup - 2>/dev/null | awk '{print \$2};' | grep '[05]0\$'  > $output_file.filtered.mpileup");
        $pm->finish;
    }
    $pm->wait_all_children;
    return 1;
}

# This flags features with no reads near them to get rid of the low hanging fruit. A more sensitive check happens later.
sub flag_features_with_no_annotation {
    my ($self) = @_;

    my %features_by_seq_id;
    my $offset = 50;

    for my $feature ( values %{ $self->_annotation_file->features } ) {
        $features_by_seq_id{ $feature->seq_id }->{ $feature->gene_id } = $feature;
    }

    for my $chromosome_name ( keys %{ $self->_sequence_validator->_actual_sequence_details } ) {
        my $bases_with_mapping_file = $self->_temp_dirname . "/" . $chromosome_name . ".bam.filtered.mpileup";
        my @base_coordinates = read_file( $bases_with_mapping_file, chomp => 1 );

        my @sorted_feature_keys =
          sort { $features_by_seq_id{$chromosome_name}->{$a}->gene_start <=> $features_by_seq_id{$chromosome_name}->{$b}->gene_start } keys %{ $features_by_seq_id{$chromosome_name} };

        for my $base_coord (@base_coordinates) {
            last if ( @sorted_feature_keys == 0 );
            next if ( $self->_annotation_file->features->{$sorted_feature_keys[0]}->gene_start - $offset > $base_coord );
            if ( $self->_annotation_file->features->{ $sorted_feature_keys[0] }->gene_end + $offset < $base_coord ) {
                shift(@sorted_feature_keys);
            }
            for my $gene_id (@sorted_feature_keys) {
                if ( $base_coord >= $self->_annotation_file->features->{$gene_id}->gene_start - $offset && $base_coord < $self->_annotation_file->features->{$gene_id}->gene_end + $offset ) {
                    $self->_annotation_file->features->{$gene_id}->reads_mapping(1);
                    delete( $features_by_seq_id{ $self->_annotation_file->features->{$gene_id}->seq_id }->{$gene_id} );
                    next;
                }
            }
        }

        return 1;
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

    my $pm = new Parallel::ForkManager( $self->parallel_processes );

    # Merge the results of each parallel process
    $pm->run_on_finish(
        sub {
            my ( $pid, $exit_code, $ident, $exit_signal, $core_dump, $data_structure_reference ) = @_;

            # retrieve data structure from child
            if ( defined($data_structure_reference) ) {    # children are not forced to send anything
                push( @expression_results, $data_structure_reference );
            }
            else {                                         # problems occuring during storage or retrieval will throw a warning
                print qq|No message received from child process $pid!\n|;
            }
        }
    );

    $self->flag_features_with_no_annotation();

    for my $feature_id ( sort { $self->_annotation_file->features->{$a}->seq_id cmp $self->_annotation_file->features->{$b}->seq_id } keys %{ $self->_annotation_file->features } ) {
        $pm->start and next;                               # fork here
        srand();

        my $alignment_slice_results;
        if ( $self->_annotation_file->features->{$feature_id}->reads_mapping == 0 ) {
            $alignment_slice_results = Bio::RNASeq::AlignmentSliceRPKM->_default_rpkm_values;
        }
        else {

            my $alignment_slice1 = Bio::RNASeq::AlignmentSliceRPKM->new(
                filename           => $self->_temp_obj . "/" . $self->_annotation_file->features->{$feature_id}->seq_id . ".bam",
                total_mapped_reads => $total_mapped_reads,
                feature            => $self->_annotation_file->features->{$feature_id},
                filters            => $self->filters,
                protocol           => $self->protocol,
                samtools_exec      => $self->samtools_exec,
                window_margin      => $self->window_margin,
            );
            $alignment_slice_results = $alignment_slice1->rpkm_values;

        }
        $alignment_slice_results->{gene_id}      = $feature_id;
        $alignment_slice_results->{seq_id}       = $self->_annotation_file->features->{$feature_id}->seq_id;
        $alignment_slice_results->{locus_tag}    = $self->_annotation_file->features->{$feature_id}->locus_tag;
        $alignment_slice_results->{feature_type} = $self->_annotation_file->features->{$feature_id}->feature_type;
        $pm->finish( 0, $alignment_slice_results );    # do the exit in the child process
    }
    $pm->wait_all_children;

    if ( defined( $self->intergenic_regions )
        && $self->intergenic_regions == 1 )
    {
        $self->_calculate_values_for_intergenic_regions( \@expression_results, $total_mapped_reads );
    }

    remove_tree( $self->_temp_obj );
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
            feature            => $intergenic_regions->intergenic_features->{$feature_id},
            filters            => $self->filters,
            protocol           => $self->protocol,
            samtools_exec      => $self->samtools_exec,
            window_margin      => 0,
            turn               => 1
        );
        my $alignment_slice_results = $alignment_slice->rpkm_values;

        $alignment_slice_results->{gene_id} = $feature_id;
        $alignment_slice_results->{seq_id}  = $intergenic_regions->intergenic_features->{$feature_id}->seq_id;
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

