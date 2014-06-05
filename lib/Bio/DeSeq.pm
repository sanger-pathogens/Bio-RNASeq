package Bio::DeSeq;

use Moose;
use Bio::RNASeq::DeSeq::Parser::SamplesFile;



has 'samples_file' => ( is => 'rw', isa => 'Str', required => 1 );
has 'deseq_file'   => ( is => 'rw', isa => 'Str', required => 1 );

has 'samples'            => ( is => 'rw', isa => 'HashRef' );
has 'content'            => ( is => 'rw', isa => 'HashRef' );
has 'valid_samples_file' => ( is => 'rw', isa => 'Bool' );
has 'deseq_setup'        => ( is => 'rw', isa => 'HashRef' );

sub set_deseq {

    my ($self) = @_;

    $self->_validate_samples_file();

    return;
}



no Moose;
__PACKAGE__->meta->make_immutable;
1;
