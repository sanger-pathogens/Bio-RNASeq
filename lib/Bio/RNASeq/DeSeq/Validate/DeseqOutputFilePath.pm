package Bio::RNASeq::DeSeq::Validate::DeseqOutputFilePath;

use Moose;
use File::Basename;

has 'deseq_file_path' => ( is => 'rw', isa => 'Str', required => 1 );

sub is_path_valid {

  my ($self) = @_;

  my ( $name,$directories,$suffix ) = fileparse( $self->deseq_file_path );

  if ( -e $directories ) {

    return 1;

  }
  else {

    return 0;

  }

}

no Moose;
__PACKAGE__->meta->make_immutable;
1;
