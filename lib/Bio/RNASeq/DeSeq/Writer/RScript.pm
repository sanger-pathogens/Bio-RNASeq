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
  #$self->_print_r_script();

}

sub _set_rscript {

  my ( $self ) = @_;

  my $input_file = $self->deseq_ff;
  my $analysis_result_file = $self->deseq_file . '_result_table.csv';
  my $conditions = $self->r_conditions;
  my $lib_types = $self->r_lib_types;

  my $rscript = 'source("http://bioconductor.org/biocLite.R")' . "\n";
  $rscript .= 'biocLite("DESeq")' . "\n";
  $rscript .= 'library(DESeq)' . "\n";
  $rscript .= 'datafile = system.file( "' . $self->deseq_ff . '")' . "\n";
  $rscript .= 'thisCountTable = read.table( datafile, header=TRUE, row.names=1 )' . "\n";
  $rscript .= 'thisDesign = data.frame(' . "\n";
  $rscript .= 'row.names = colnames(thisCountTable),' . "\n";
  $rscript .= 'condition = ' . $self->r_conditions . ",\n";
  $rscript .= 'libType = ' . $self->r_lib_types . ")\n";
  $rscript .= 'pairedSamples = thisDesign$libType == "paired-end"' . "\n";
  $rscript .= 'countTable = thisCountTable[, pairedSamples]' . "\n";
  $rscript .= 'condition = thisDesign$condition[ pairedSamples ]' . "\n";
  $rscript .= qq/cds = newCountDataSet( countTable, condition )\n/;
  $rscript .= qq/cds = estimateSizeFactors( cds )\n/;
  $rscript .= qq/sizeFactors( cds )\n/;
  $rscript .= qq/cds = estimateDispersions(cds)\n/;
  $rscript .= qq/str( fitInfo(cds) )\n/;
  $rscript .= qq/res = nbinomTest( cds, "untreated", "treated" )\n/;
  $rscript .= 'write.csv( res, file="' . $self->deseq_file . '_result_table.csv")' . "\n";



=head



head(res)
"My_Pasilla_Analysis_Result_Table.csv")
plotMA(res)
hist(res$pval, breaks=100, col="skyblue", border = "slateblue", main="")


END_OF_R_SCRIPT

=cut

  print "$rscript\n";
  $self->rscript($rscript);

}


1;
