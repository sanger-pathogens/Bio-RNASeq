package Bio::RNASeq::Read;

# ABSTRACT: Extract a slice of reads for a sequence file within a specific region

=head1 SYNOPSIS
Extract a slice of reads for a sequence file within a specific region
	use Bio::RNASeq::Read;
	my $alignment_slice = Bio::RNASeq::Read->new(
	  alignment_line => 'xxxxxxx',
	  gene_strand => 1,
	  exons => [[1,3],[4,5]]
	  );
	  my %mapped_reads = $alignment_slice->mapped_reads;
	  $mapped_reads{sense};
	  $mapped_reads{antisense};

=cut

use Moose;
use File::Spec;
use File::Temp qw/ tempfile /;
use Bio::RNASeq::Exceptions;

has 'alignment_line' => ( is => 'rw', isa => 'Str',      required   => 1 );
has 'exons'          => ( is => 'rw', isa => 'ArrayRef', required   => 1 );
has 'gene_strand'    => ( is => 'rw', isa => 'Int',      required   => 1 );

#optional filters
has 'filters'        => ( is => 'rw', isa => 'Maybe[HashRef]'            );

has '_read_details'  => ( is => 'rw', isa => 'HashRef',  lazy_build   => 1 );
has '_read_position' => ( is => 'rw', isa => 'Int',      lazy_build   => 1 );

has 'read_strand'   => ( is => 'rw', isa => 'Int',      lazy_build   => 1 );
has 'mapped_reads' => ( is => 'rw', isa => 'HashRef',  lazy_build   => 1 );
has '_base_positions' => ( is => 'rw', isa => 'ArrayRef', lazy   => 1, builder => '_build__base_positions' );


sub _build__read_details
{
  my ($self) = @_;
  
  my($qname, $flag, $chromosome_name, $read_position, $mapq, $cigar, $mrnm, $mpos, $isize, $seq, $qual) = split(/\t/,$self->alignment_line);
  
  my $read_details = {
    mapping_quality => $mapq,
    cigar           => $cigar,
    read_position   => $read_position,
    flag            => $flag,
    chromosome_name => $chromosome_name,
  };
  # hook to allow for reads to be altered for different protocols
  $self->_process_read_details($read_details);
  
  return $read_details;
}

sub _build_read_strand
{
  my ($self) = @_;
  my $read_strand = $self->_read_details->{flag} & 16 ? -1:1; # $flag bit set to 0 for forward 1 for reverse.
  return $read_strand;
}

sub _build__read_position
{
  my ($self) = @_;
  $self->_read_details->{read_position};
}


sub _build_mapped_reads
{
    my ($self) = @_;

    my %mapped_reads;
    $mapped_reads{sense}     = 0;
    $mapped_reads{antisense} = 0;

    return \%mapped_reads unless ( $self->_does_read_pass_filters() == 1 );

    for my $base_position ( @{ $self->_base_positions } ) {
        for my $exon ( @{ $self->exons } ) {
            my ( $exon_start, $exon_end ) = @{$exon};
            if ( $base_position >= $exon_start && $base_position < $exon_end ) {
                if ( $self->read_strand == $self->gene_strand ) {
                    $mapped_reads{sense}++;
                }
                else {
                    $mapped_reads{antisense}++;
                }
		return \%mapped_reads;
            }
        }
    }

    return \%mapped_reads;
}

sub _process_read_details
{
  # hook to allow for reads to be altered for different protocols
}

sub _does_read_pass_filters
{
  my ($self) = @_;
  
  # filter unmapped read
  if( ($self->_read_details->{flag} & 4) == 4)
  {
  	return 0;
  }
  return 1 unless(defined($self->filters));
  
  if(defined($self->filters->{mapping_quality}) && ($self->_read_details->{mapping_quality}  <= $self->filters->{mapping_quality}) )
  {
     return 0;
  }
  
  if(defined($self->filters->{bitwise_flag}) && ( ($self->_read_details->{flag} & $self->filters->{bitwise_flag})  == 0 ))
  {
    return 0;
  }
  
  return 1;
}

sub _simple_positions
{
  my ($self,$read_length) = @_;
  my @bases ;
  for(my $i = $self->_read_position; $i < $self->_read_position+$read_length; $i++)
  {
    push(@bases, $i);
  }
  return \@bases;
}

sub _build__base_positions {

  my ($self) = @_;
  
  if( $self->_read_details->{cigar} =~ /^([\d]+)M$/)
  {
    return $self->_simple_positions($1);
  }

  my $bam_file_string = $self->_dummy_seq_line() . $self->alignment_line() . "\n";
 
  my ($fh, $filename) = tempfile();
  print {$fh} $bam_file_string;
  close($fh);

  my $mpileup_cmd = "samtools view -buhS $filename 2>/dev/null | samtools mpileup - 2>/dev/null | awk '{if (\$5 ~ /[ACGTacgt]/) print \$2};' | xargs";
  my $output = '';

  open OLDERR, '>&STDERR';
  {
    local *STDERR;
    open STDERR, '>/dev/null' or warn "Can't open >/dev/null: $!"; 
    $output = `$mpileup_cmd`;

    close STDERR;
  }
  open STDERR, '>&OLDERR' or die "Can't restore stderr: $!";
  close OLDERR or die "Can't close OLDERR: $!";

  my @base_positions = split(/\s+/, $output);
  unlink($filename) if(-e $filename);
  return \@base_positions;

}


sub _dummy_seq_line {

  my ($self) = @_;
  
  return '@SQ	SN:' . $self->_read_details->{chromosome_name} . '	LN:' . ( $self->_read_details->{read_position} + 1000000 ) . "\n";

}

# class method
sub _unmark_duplicates
{
  my ($self, $flag) = @_;
  if ($flag & 1024) 
  {
    $flag = $flag - 1024;     
  }
  return $flag;
}

sub _calculate_bitwise_flag
{
	# hook for protocols to update the bitwise flag
	my ($self, $flag) = @_;
	return $flag;
}

no Moose;
__PACKAGE__->meta->make_immutable;
1;
