package  Bio::RNASeq::DeSeq::Writer::RScript;

use Moose;

has 'deseq_file' => ( is => 'rw', isa => 'Str', required => 1 );
has 'deseq_ff' => ( is => 'rw', isa => 'Str', required => 1 );
has 'r_conditions' => ( is => 'rw', isa => 'Str', required => 1 );
has 'r_lib_types' => ( is => 'rw', isa => 'Str', required => 1 );

has 'rscript' => ( is => 'rw', isa => 'Str' );
has 'rscript_fh' => ( is => 'rw', isa => 'FileHandle' );
has 'exit_c' => ( is => 'rw', isa => 'Bool', default => 1 );

sub run {

  my ( $self ) = @_;

  $self->_set_rscript();
  $self->_print_r_script();

}

sub _set_rscript {

  my ( $self ) = @_;

  my $rscript = '#!/usr/bin/env Rscript' . "\n";
  $rscript .= 'source("http://bioconductor.org/biocLite.R")' . "\n";
  $rscript .= 'biocLite("DESeq")' . "\n";
  $rscript .= 'library(DESeq)' . "\n";
  $rscript .= 'thisCountTable = read.table( "' . $self->deseq_ff . '", header=TRUE, row.names=1 )' . "\n";
  $rscript .= 'thisDesign = data.frame(' . "\n";
  $rscript .= 'row.names = colnames(thisCountTable),' . "\n";
  $rscript .= 'condition = ' . $self->r_conditions . ",\n";
  $rscript .= 'libType = ' . $self->r_lib_types . ")\n";
  $rscript .= 'pairedSamples = thisDesign$libType == "paired-end"' . "\n";
  $rscript .= 'countTable = thisCountTable[, pairedSamples]' . "\n";
  $rscript .= 'condition = thisDesign$condition[ pairedSamples ]' . "\n";
  $rscript .= qq/cds = newCountDataSet( countTable, condition )\n/;
  $rscript .= qq/cds = estimateSizeFactors( cds )\n/;
  $rscript .= qq/cds = estimateDispersions(cds)\n/;
  $rscript .= qq/res = nbinomTest( cds, "untreated", "treated" )\n/;
  $rscript .= 'write.csv( res, file="' . $self->deseq_file . '_result_table.csv")' . "\n";

  $self->rscript($rscript);

}

sub _print_r_script {

  my ( $self ) = @_;

  open ( my $fh, '>', $self->deseq_file . '.r' );

  $self->rscript_fh( $fh );

  $self->rscript_fh->print( $self->rscript );

  close( $self->rscript_fh );
  
}


1;
