package  Bio::RNASeq::DeSeq::Writer::RScript;

use Moose;

has 'deseq_file' => ( is => 'rw', isa => 'Str', required => 1 );
has 'deseq_fh' => ( is => 'rw', isa => 'FileHandle' );
has 'rscript' => ( is => 'rw', isa => 'Str' );



1;
