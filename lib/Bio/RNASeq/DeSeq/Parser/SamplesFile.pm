package Bio::RNASeq::DeSeq::Parser::SamplesFile;

use Moose;
use Bio::RNASeq::Types;
use Bio::RNASeq::Exceptions;
use Bio::RNASeq::DeSeq::Validate::SamplesFile;

has 'samples_file' => ( is => 'rw', isa => 'Bio::RNASeq::File', required => 1 );
has 'samples'   => ( is => 'rw', isa => 'Bio::RNASeq::DeSeq::SamplesHashRef', lazy => 1, builder => '_build_samples' );

sub _build_samples {

  my ($self) = @_;

  my $validator = Bio::RNASeq::DeSeq::Validate::SamplesFile->new( samples_file => $self->samples_file );
  $validator->validate_content_set_samples();

  if ( $validator->is_samples_file_valid ) {
    return($validator->samples);
  }
  else {
    return 0;
  }
}

no Moose;
__PACKAGE__->meta->make_immutable;
1;
