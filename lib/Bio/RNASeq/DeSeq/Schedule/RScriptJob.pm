package Bio::RNASeq::DeSeq::Schedule::RScriptJob;

use Moose;

has 'rscript_path'   => ( is => 'rw', isa => 'Str', required => 1 );
has 'job_name'   => ( is => 'rw', isa => 'Str', required => 1 );
has 'log_error_path'   => ( is => 'rw', isa => 'Str', required => 1 );


has 'bsub_command' => ( is => 'rw', isa => 'Str' );


sub submit_deseq_job {


  my ( $self ) = @_; 
  my $bsub_command = 'bsub -J ' . $self->job_name ;
  $bsub_command .= ' -o ' . $self->log_error_path . '.log ';
  $bsub_command .= '-e ' . $self->log_error_path;
  $bsub_command .= '.err -M5000 -R "select[mem>5000] rusage[mem=5000]" ';
  $bsub_command .= '"' . $self->rscript_path . '"';
  
  system($bsub_command) == 0 or die "system $bsub_command failed: $?";

}




1;
