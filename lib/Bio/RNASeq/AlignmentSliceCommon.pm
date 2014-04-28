package Bio::RNASeq::AlignmentSlice;

# ABSTRACT: Extract a slice of reads for a sequence file within a specific region

=head1 SYNOPSIS

Extract a slice of reads for a sequence file within a specific region
	use Bio::RNASeq::AlignmentSlice;
	my $alignment_slice = Bio::RNASeq::AlignmentSlice->new(
	  filename => '/abc/my_file.bam',
	  window_margin => 10,
	  total_mapped_reads => 1234,
	  );
	  my %rpkm_values = $alignment_slice->rpkm_values;
	  $rpkm_values{rpkm_sense};
	  $rpkm_values{rpkm_antisense};
	  $rpkm_values{mapped_reads_sense};
	  $rpkm_values{mapped_reads_antisense};
	
	  $rpkm_values{mapped_reads_forward};
	  $rpkm_values{mapped_reads_reverse};

=cut

use Moose;
use Bio::RNASeq::Exceptions;
use Bio::RNASeq::Read;
use Data::Dumper;

# required inputs
has 'filename' => ( is => 'rw', isa => 'Str', required => 1 );
has 'feature' => ( is => 'rw', required => 1 );
has 'total_mapped_reads' => ( is => 'rw', isa => 'Int', required => 1 );
has 'turn' => (is => 'rw', isa => 'Int', required => 1);

#optional input
has 'total_mapped_reads_to_gene_models' => ( is => 'rw', isa => 'Int', default => 0);
has 'samtools_exec' => ( is => 'rw', isa => 'Str', default => "samtools" );
has 'protocol' =>
  ( is => 'rw', isa => 'Str', default => 'Bio::RNASeq::StandardProtocol' );
has 'window_margin' => ( is => 'rw', isa => 'Int', default => 50 );
has 'filters' => ( is => 'rw', isa => 'Maybe[HashRef]' );
has '_input_slice_filename' => ( is => 'rw', isa => 'Str' )
  ;    # allow for testing and for using VR samtools view output file

# output variable
has 'rpkm_values' => ( is => 'rw', isa => 'HashRef', lazy_build => 1 );
has 'rpkm_values_gene_models' => ( is => 'rw', isa => 'HashRef', lazy_build => 1 );

# internal variables
has '_slice_file_handle' => ( is => 'rw', lazy_build => 1 );
has '_window_start' => ( is => 'rw', isa => 'Int', lazy_build => 1 );
has '_window_end' => ( is => 'rw', isa => 'Int', lazy_build => 1 );
has '_read_protocol_class' => ( is => 'rw', lazy_build => 1 );

sub _build__window_start {
    my ($self) = @_;
    my $window_start = $self->feature->gene_start - $self->window_margin;
    $window_start = $window_start < 1 ? 1 : $window_start;
    return $window_start;
}

sub _build__window_end {
    my ($self) = @_;
    $self->feature->gene_end + $self->window_margin;
}

sub _build__slice_file_handle {
    my ($self) = @_;
    my $slice_file_handle;
    open( $slice_file_handle, $self->_slice_stream )
      || Bio::RNASeq::Exceptions::FailedToOpenAlignmentSlice->throw(
            error => "Cant view slice for "
          . $self->filename . " "
          . $self->_window_start . " "
          . $self->_window_end );
    return $slice_file_handle;
}

sub _slice_stream {
    my ($self) = @_;
    if ( $self->_input_slice_filename ) {
        return $self->_input_slice_filename;
    }
    else {
        return
            $self->samtools_exec
          . " view "
          . $self->filename . " "
          . $self->feature->seq_id . ":"
          . $self->_window_start . "-"
          . $self->_window_end . " |";
    }
}

sub _build__read_protocol_class {
    my ($self) = @_;
    my $read_protocol_class;
    if ( $self->protocol =~ m/^Bio::RNASeq::/ ) {

        $read_protocol_class = $self->protocol . '::Read';

    }
    else {

        $read_protocol_class = 'Bio::RNASeq::' . $self->protocol . '::Read';

    }

    eval("use $read_protocol_class");
    return $read_protocol_class;
}

sub _build_rpkm_values {
    my ($self) = @_;
    my %rpkm_values;

    $rpkm_values{mapped_reads_sense}     = 0;
    $rpkm_values{mapped_reads_antisense} = 0;
    $rpkm_values{mapped_reads_forward}   = 0;
    $rpkm_values{mapped_reads_reverse}   = 0;
    $rpkm_values{total_rpkm}             = 0;
    $rpkm_values{total_mapped_reads}     = 0;
    $rpkm_values{total_rpkm_gene_models}             = 0;
    $rpkm_values{total_mapped_reads_gene_models}     = 0;

    my $file_handle = $self->_slice_file_handle;

    while ( my $line = <$file_handle> ) {
        my $sequence_reads = $self->_read_protocol_class->new(
            alignment_line => $line,
            exons          => $self->feature->exons,
            gene_strand    => $self->feature->gene_strand,
            filters        => $self->filters
        );
        my $mapped_reads = $sequence_reads->mapped_reads;

        $rpkm_values{mapped_reads_sense}     += $mapped_reads->{sense};
        $rpkm_values{mapped_reads_antisense} += $mapped_reads->{antisense};

        if ( $sequence_reads->read_strand == 0 ) {
            $rpkm_values{mapped_reads_forward} += $mapped_reads->{sense};
            $rpkm_values{mapped_reads_reverse} += $mapped_reads->{antisense};
        }
        else {
            $rpkm_values{mapped_reads_forward} += $mapped_reads->{antisense};
            $rpkm_values{mapped_reads_reverse} += $mapped_reads->{sense};
        }
    }

    $rpkm_values{rpkm_sense} =
      $self->_calculate_rpkm( $rpkm_values{mapped_reads_sense} );
    $rpkm_values{rpkm_antisense} =
      $self->_calculate_rpkm( $rpkm_values{mapped_reads_antisense} );

    $rpkm_values{total_rpkm} =
      $rpkm_values{rpkm_sense} + $rpkm_values{rpkm_antisense};
    $rpkm_values{total_mapped_reads} =
      $rpkm_values{mapped_reads_antisense} + $rpkm_values{mapped_reads_sense};
	  
	  if ($self->turn == 2) {
	  
      $rpkm_values{rpkm_sense} =
        $self->_calculate_rpkm_gene_models( $rpkm_values{mapped_reads_sense} );
      $rpkm_values{rpkm_antisense} =
        $self->_calculate_rpkm_gene_models( $rpkm_values{mapped_reads_antisense} );

      $rpkm_values{total_rpkm_gene_models} =
        $rpkm_values{rpkm_sense} + $rpkm_values{rpkm_antisense};
      $rpkm_values{total_mapped_reads_gene_models} =
        $rpkm_values{mapped_reads_antisense} + $rpkm_values{mapped_reads_sense};
	}

    return \%rpkm_values;
}

sub _calculate_rpkm {
    my ( $self, $mapped_reads ) = @_;

#print Dumper($self);
#my $rpkm  = $mapped_reads / ( ($self->feature->exon_length/1000) * ($self->total_mapped_reads/1000000) );
# same equation, rewritten
    my $rpkm =
      ( $mapped_reads / $self->feature->exon_length ) *
      ( 1000000000 / $self->total_mapped_reads );

    return $rpkm;
}

sub _calculate_rpkm_gene_models {
    my ( $self, $mapped_reads ) = @_;

#print Dumper($self);
#my $rpkm  = $mapped_reads / ( ($self->feature->exon_length/1000) * ($self->total_mapped_reads/1000000) );
# same equation, rewritten
    my $rpkm =
      ( $mapped_reads / $self->feature->exon_length ) *
      ( 1000000000 / $self->total_mapped_reads_to_gene_models );

    return $rpkm;
}

1;
