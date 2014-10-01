package Bio::DeSeq;

use Moose;
use Bio::RNASeq::DeSeq::Parser::SamplesFile;
use Bio::RNASeq::DeSeq::Parser::RNASeqOutput;
use Bio::RNASeq::DeSeq::Writer::DeseqInputFile;
use Bio::RNASeq::DeSeq::Writer::RScript;
use Bio::RNASeq::DeSeq::Schedule::RScriptJob;

has 'samples_file' => ( is => 'rw', isa => 'Str', required => 1 );
has 'deseq_file'   => ( is => 'rw', isa => 'Str', required => 1 );
has 'read_count_a_index'   => ( is => 'rw', isa => 'Int', required => 1 );
has 'mode'   => ( is => 'rw', isa => 'Str', default => '' );

has 'samples'  => ( is => 'rw', isa => 'HashRef' );
has 'gene_universe'    => ( is => 'rw', isa => 'ArrayRef' );
has 'rscript_path'   => ( is => 'rw', isa => 'Str' );
has 'job_log_error_path'   => ( is => 'rw', isa => 'Str' );

sub run {

  my ($self) = @_;

  $self->_prepare_deseq_setup();
  
  my $dsi_writer = Bio::RNASeq::DeSeq::Writer::DeseqInputFile->new(
								   deseq_file => $self->deseq_file, 
								   samples => $self->samples,
								   gene_universe => $self->gene_universe,
								  );

  $dsi_writer->run;

  die "Couldn't write DeSeq input file" unless ( $dsi_writer->exit_code );

  $self->job_log_error_path( $dsi_writer->deseq_ff );

  my $rscript_writer = Bio::RNASeq::DeSeq::Writer::RScript->new(
								deseq_file => $self->deseq_file,
								deseq_ff => $dsi_writer->deseq_ff, 
								r_conditions => $dsi_writer->r_conditions,
								r_lib_types => $dsi_writer->r_lib_types,
								mode => $self->mode,
							       );
  $rscript_writer->run;

  die "Couldn't write R script" unless ( $rscript_writer->exit_c );

  $self->rscript_path('./' . $rscript_writer->rscript_name);

  my $deseq_job = Bio::RNASeq::DeSeq::Schedule::RScriptJob->new(
								job_name => $self->deseq_file,
								log_error_path => $self->job_log_error_path,
								rscript_path => $self->rscript_path,
								mode => $self->mode,
							       );
  $deseq_job->submit_deseq_job();

  

}

sub _prepare_deseq_setup {

    my ($self) = @_;

    my $parser =
      Bio::RNASeq::DeSeq::Parser::SamplesFile->new(
						   samples_file => $self->samples_file
						  );

    $parser->parse();

    die "Samples file passed by the -i option is invalid" unless ( $parser->exit_code );

    $self->samples( $parser->samples );


    my $rso =
      Bio::RNASeq::DeSeq::Parser::RNASeqOutput->new(
						    samples => $self->samples,
						    read_count_a_index => $self->read_count_a_index,
						   );

    $rso->get_read_counts();

    die "The sample files defined in the sample file provided by the -i option don't share the same gene universe" unless ( $rso->exit_code );

    $self->samples( $rso->samples );
    $self->gene_universe( $rso->gene_universe );
}



no Moose;
__PACKAGE__->meta->make_immutable;
1;
