package Bio::RNASeq::DeSeq::Writer::DeseqInputFile;

use Moose;
use Bio::RNASeq::DeSeq::Validate::DeseqOutputFilePath;

has 'deseq_file' => ( is => 'rw', isa => 'Str', required => 1 );
has 'samples'  => ( is => 'rw', isa => 'HashRef', required => 1 );
has 'gene_universe'    => ( is => 'rw', isa => 'ArrayRef', required => 1 );

has 'deseq_ff' => ( is => 'rw', isa => 'Str');
has 'deseq_fh' => ( is => 'rw', isa => 'FileHandle' );
has 'r_conditions' => ( is => 'rw', isa => 'Str' );
has 'r_lib_types' => ( is => 'rw', isa => 'Str' );
has 'exit_c' => ( is => 'rw', isa => 'Bool', default => 1 );

sub run {

  my ($self) = @_;
  
  $self->_create_ff;

  my $validator = Bio::RNASeq::DeSeq::Validate::DeseqOutputFilePath->new(
									 deseq_ff => $self->deseq_ff,
									);
  if ( $validator->is_path_valid ) {

    $self->_write;
    close( $self->deseq_fh );

  }
  else {

    my $exception = 'The file path specified in the -d option => ' . $self->deseq_file . ' , does not exist';
    die "$exception";

  }
}

sub _write {

  my ($self) = @_;

  my $r_conditions = q/c( /;
  my $r_lib_types = q/c( /;

  open( my $fh, '>', $self->deseq_ff );

  my $file_content = "gene_id\t";

  for my $file ( sort keys $self->samples ) {

    $file_content .= $self->samples->{$file}->{condition}
      . $self->samples->{$file}->{replicate} . "\t";
    $r_conditions .= q/"/ . $self->samples->{$file}->{condition} . q/",/;
    $r_lib_types .= q/"/ . $self->samples->{$file}->{lib_type} . q/",/;

  }
  $file_content =~ s/\t$//;
  $file_content .= "\n";
  
  $r_conditions =~ s/,$//;
  $r_lib_types =~ s/,$//;

  $r_conditions .= q/ )/;
  $r_lib_types .= q/ )/;

  for my $gene ( @{ $self->gene_universe } ) {

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
  $self->r_conditions($r_conditions);
  $self->r_lib_types($r_lib_types);

}

sub _create_ff {

  my ($self) = @_;

  my $deseq_ff = './' . $self->deseq_file;

  $self->deseq_ff($deseq_ff);

}

1;
