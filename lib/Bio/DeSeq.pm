package Bio::DeSeq;

use Moose;
use Bio::RNASeq::DeSeq::Parser::SamplesFile;
use Bio::RNASeq::DeSeq::Parser::RNASeqOutput;
use Bio::RNASeq::DeSeq::Writer::DeseqInputFile;

has 'samples_file' => ( is => 'rw', isa => 'Str', required => 1 );
has 'deseq_file'   => ( is => 'rw', isa => 'Str', required => 1 );

has 'samples'  => ( is => 'rw', isa => 'HashRef' );
has 'genes'    => ( is => 'rw', isa => 'ArrayRef' );



sub run {

  my ($self) = @_;
  $self->_set_deseq();
  
  my $deseq_input_writer = Bio::RNASeq::DeSeq::Writer::DeseqInputFile->new(
									   deseq_file => $self->deseq_file, 
									   samples => $self->samples,
									   genes => $self->genes,
									  );

  $deseq_input_writer->run;
  if ( $deseq_input_writer->exit_c ) {
    print "Deseq input file is ready to run\n";
  }


}

sub _set_deseq {

    my ($self) = @_;

    my $parser =
      Bio::RNASeq::DeSeq::Parser::SamplesFile->new(
        samples_file => $self->samples_file );

    $self->samples( $parser->parse() );

    my $rso =
      Bio::RNASeq::DeSeq::Parser::RNASeqOutput->new(
        samples => $self->samples );

    $rso->get_read_counts();

    $self->samples( $rso->samples );
    $self->genes( $rso->genes );
}



no Moose;
__PACKAGE__->meta->make_immutable;
1;
