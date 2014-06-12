package Bio::RNASeq::DeSeq::Writer::DeseqInputFile;

use Moose;
use Bio::RNASeq::DeSeq::Validate::DeseqOutputFilePath;

has 'deseq_file' => ( is => 'rw', isa => 'Str', required => 1 );
has 'samples'  => ( is => 'rw', isa => 'HashRef', required => 1 );
has 'genes'    => ( is => 'rw', isa => 'ArrayRef', required => 1 );

has 'deseq_ff' => ( is => 'rw', isa => 'Str');
has 'deseq_fh' => ( is => 'rw', isa => 'FileHandle' );
has 'exit_c' => ( is => 'rw', isa => 'Bool', default => 0 );

sub run {

  my ($self) = @_;
  
  $self->_create_ff;

  my $validator = Bio::RNASeq::DeSeq::Validate::DeseqOutputFilePath->new(
									 deseq_ff => $self->deseq_ff,
									);
  if ( $validator->is_path_valid ) {

    $self->_write;
    close( $self->deseq_fh );
    $self->exit_c(1);

  }
  else {

    my $exception = 'The file path specified in the -d option => ' . $self->deseq_file . ' , does not exist';
    die "$exception";

  }
}

sub _write {

  my ($self) = @_;

  open( my $fh, '>', $self->deseq_ff );

  my $file_content = "gene_id\t";

  for my $file ( sort keys $self->samples ) {

    $file_content .= $self->samples->{$file}->{condition}
      . $self->samples->{$file}->{replicate} . "\t";

  }
  $file_content =~ s/\t$//;
  $file_content .= "\n";

  for my $gene ( @{ $self->genes } ) {

    $file_content .= "$gene\t";

    for my $file ( sort keys $self->samples ) {

      $file_content .=
	$self->samples->{$file}->{read_counts}->{$gene} . "\t";

    }
    $file_content =~ s/\t$//;
    $file_content .= "\n";
  }

  print $fh "$file_content";

  $self->deseq_fh($fh);

}

sub _create_ff {

  my ($self) = @_;

  my $deseq_ff = './' . $self->deseq_file;

  $self->deseq_ff($deseq_ff);

}

1;
