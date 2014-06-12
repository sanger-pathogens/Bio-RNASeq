package Bio::DeSeq;

use Moose;
use Bio::RNASeq::DeSeq::Parser::SamplesFile;
use Bio::RNASeq::DeSeq::Parser::RNASeqOutput;
use Bio::RNASeq::DeSeq::Writer::DeseqInputFile;

has 'samples_file' => ( is => 'rw', isa => 'Str', required => 1 );
has 'deseq_file'   => ( is => 'rw', isa => 'Str', required => 1 );
has 'read_count_a_index'   => ( is => 'rw', isa => 'Int', required => 1 );

has 'samples'  => ( is => 'rw', isa => 'HashRef' );
has 'genes'    => ( is => 'rw', isa => 'ArrayRef' );



sub run {

  my ($self) = @_;

  $self->_set_deseq();
  
  my $ds_iwriter = Bio::RNASeq::DeSeq::Writer::DeseqInputFile->new(
									   deseq_file => $self->deseq_file, 
									   samples => $self->samples,
									   genes => $self->genes,
									  );

  $ds_iwriter->run;

=head

  if ( $ds_iwriter->exit_c ) {
    print "Deseq input file is ready to run\n";
    my $rscript_writer = Bio::RNASeq::DeSeq::Writer::RScript->new(
								  deseq_ff => $self->deseq_file, 
								 );
    $rscript_writer->run;
  }

=cut

}

sub _set_deseq {

    my ($self) = @_;

    my $parser =
      Bio::RNASeq::DeSeq::Parser::SamplesFile->new(
        samples_file => $self->samples_file );

    $self->samples( $parser->parse() );

    my $rso =
      Bio::RNASeq::DeSeq::Parser::RNASeqOutput->new(
						    samples => $self->samples,
						    read_count_a_index => $self->read_count_a_index,
						   );

    $rso->get_read_counts();

    $self->samples( $rso->samples );
    $self->genes( $rso->genes );
}



no Moose;
__PACKAGE__->meta->make_immutable;
1;
