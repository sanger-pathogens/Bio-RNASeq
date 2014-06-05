package Bio::DeSeq;

use Moose;
use Bio::RNASeq::DeSeq::Parser::SamplesFile;
use Data::Dumper;

has 'samples_file' => ( is => 'rw', isa => 'Str', required => 1 );
has 'deseq_file'   => ( is => 'rw', isa => 'Str', required => 1 );

has 'samples'     => ( is => 'rw', isa => 'HashRef' );
has 'deseq_setup' => ( is => 'rw', isa => 'HashRef' );

sub set_deseq {

    my ($self) = @_;

    my $parser =
      Bio::RNASeq::DeSeq::Parser::SamplesFile->new(
        samples_file => $self->samples_file );
    $self->samples( $parser->parse() );
    #print Dumper($self);

    return;
}

no Moose;
__PACKAGE__->meta->make_immutable;
1;
