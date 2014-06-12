package  Bio::RNASeq::DeSeq::Writer::RScript;

use Moose;

has 'deseq_ff' => ( is => 'rw', isa => 'Str', required => 1 );

has 'rscript' => ( is => 'rw', isa => 'Str' );
has 'rscript_fh' => ( is => 'rw', isa => 'FileHandle' );
has 'exit_c' => ( is => 'rw', isa => 'Bool', default => 1 );

sub run {

  my ( $self ) = @_;
  


}


1;
