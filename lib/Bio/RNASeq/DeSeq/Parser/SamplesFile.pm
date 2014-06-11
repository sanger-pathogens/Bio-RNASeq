package Bio::RNASeq::DeSeq::Parser::SamplesFile;

use Moose;
use Bio::RNASeq::DeSeq::Validate::SamplesFile;

has 'samples_file' => ( is => 'rw', isa => 'Str', required => 1 );

sub parse {

    my ($self) = @_;
    if ( -e $self->samples_file ) {

        my $validator =
          Bio::RNASeq::DeSeq::Validate::SamplesFile->new(
            samples_file => $self->samples_file );
        $validator->validate_content_set_samples();

        if ( $validator->is_samples_file_valid ) {
            return ( $validator->samples );
        }
        else {
            die
"Will need to throw a proper exception here but essentially the samples file is invalid";
        }
    }
}

1;
