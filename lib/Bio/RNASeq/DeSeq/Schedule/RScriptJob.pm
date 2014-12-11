package Bio::RNASeq::DeSeq::Schedule::RScriptJob;

use Moose;
use Capture::Tiny ':all';
use Bio::RNASeq::Exceptions;

has 'rscript_path'   => ( is => 'rw', isa => 'Str', required => 1 );
has 'job_name'   => ( is => 'rw', isa => 'Str', required => 1 );
has 'log_error_path'   => ( is => 'rw', isa => 'Str', required => 1 );
has 'mode'   => ( is => 'rw', isa => 'Str', default => '' );
has 'bsub_command' => ( is => 'rw', isa => 'Str', lazy => 1, builder => '_build_bsub_command' );

has 'r_session_log' => ( is => 'rw', isa => 'Str' );


sub submit_deseq_job {


  my ( $self ) = @_;

  if ($self->mode eq 'test') {

    my $command = $self->rscript_path;

    my ($stdout, $stderr, $exit) = capture {
      system( $command );
    };

    $self->r_session_log($stderr);

  } else {

    my ($stdout, $stderr, $exit) = capture {
      system( $self->bsub_command() );
    };


    if ( $exit ) {

       Bio::RNASeq::Exceptions::FailedBsubCommand->throw( error => 'Bsub command failed' . $self->bsub_command() . "failed: $!" )

    }

  }
}

sub _build_bsub_command {

  my ($self) = @_;

  my $bsub_command = 'bsub -J ' . $self->job_name ;
  $bsub_command .= ' -o ' . $self->log_error_path . '.log ';
  $bsub_command .= '-e ' . $self->log_error_path;
  $bsub_command .= '.err -M5000 -R "select[mem>5000] rusage[mem=5000]" ';
  $bsub_command .= '"' . $self->rscript_path . '"';
  $bsub_command .= ' 2>/dev/null';

  return( $bsub_command );

}

no Moose;
__PACKAGE__->meta->make_immutable;
1;
