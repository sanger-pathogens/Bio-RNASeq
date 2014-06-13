package Bio::DeSeq;

use Moose;
use Bio::RNASeq::DeSeq::Parser::SamplesFile;
use Bio::RNASeq::DeSeq::Parser::RNASeqOutput;
use Bio::RNASeq::DeSeq::Writer::DeseqInputFile;
use Bio::RNASeq::DeSeq::Writer::RScript;

has 'samples_file' => ( is => 'rw', isa => 'Str', required => 1 );
has 'deseq_file'   => ( is => 'rw', isa => 'Str', required => 1 );
has 'read_count_a_index'   => ( is => 'rw', isa => 'Int', required => 1 );

has 'samples'  => ( is => 'rw', isa => 'HashRef' );
has 'genes'    => ( is => 'rw', isa => 'ArrayRef' );


sub run {

  my ($self) = @_;

  $self->_prepare_deseq_setup();
  
  my $dsi_writer = Bio::RNASeq::DeSeq::Writer::DeseqInputFile->new(
									   deseq_file => $self->deseq_file, 
									   samples => $self->samples,
									   genes => $self->genes,
									  );

  $dsi_writer->run;

  die "Couldn't write DeSeq input file"   if ( ! $dsi_writer->exit_c );

  my $rscript_writer = Bio::RNASeq::DeSeq::Writer::RScript->new(
								deseq_file => $self->deseq_file,
								deseq_ff => $dsi_writer->deseq_ff, 
								r_conditions => $dsi_writer->r_conditions,
								r_lib_types => $dsi_writer->r_lib_types,
							       );
  $rscript_writer->run;

  die "Couldn't write R script"   if ( ! $rscript_writer->exit_c );


}

sub _prepare_deseq_setup {

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
