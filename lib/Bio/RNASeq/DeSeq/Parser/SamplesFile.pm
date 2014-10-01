package Bio::RNASeq::DeSeq::Parser::SamplesFile;

use Moose;
use Bio::RNASeq::Types;
use Bio::RNASeq::Exceptions;
use Bio::RNASeq::DeSeq::Validate::SamplesFile;

has 'samples_file' => ( is => 'rw', isa => 'Bio::RNASeq::File', required => 1 );

has 'samples'   => ( is => 'rw', isa => 'HashRef', default => sub { {} } );
has 'exit_c' => ( is => 'rw', isa => 'Bool', default => 1 );

sub parse {

  my ($self) = @_;
# if ( -e $self->samples_file ) {

   print "Hello\n";
    my $validator = Bio::RNASeq::DeSeq::Validate::SamplesFile->new( samples_file => $self->samples_file );
    $validator->validate_content_set_samples();
    $self->samples( $validator->samples );

    unless ( $validator->is_samples_file_valid ) {
      $self->exit_c(0);
    }
 # } else {
   #$self->exit_c(0);
 # }
}

1;
