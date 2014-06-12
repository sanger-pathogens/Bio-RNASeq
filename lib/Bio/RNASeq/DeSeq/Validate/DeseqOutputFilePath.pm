package Bio::RNASeq::DeSeq::Validate::DeseqOutputFilePath;

use Moose;
use File::Basename;

has 'deseq_ff' => ( is => 'rw', isa => 'Str', required => 1 );

sub is_path_valid {

  my ($self) = @_;

  my ( $name,$directories,$suffix ) = fileparse( $self->deseq_ff );

  if ( -e $directories ) {

    return 1;

  }
  else {

    return 0;

  }

}

1;
