package  Bio::RNASeq::DeSeq::Writer::RScript;

use Moose;

has 'deseq_file' => ( is => 'rw', isa => 'Str', required => 1 );
has 'deseq_file_path' => ( is => 'rw', isa => 'Str', required => 1 );
has 'r_conditions' => ( is => 'rw', isa => 'Str', required => 1 );
has 'r_lib_types' => ( is => 'rw', isa => 'Str', required => 1 );
has 'mode'   => ( is => 'rw', isa => 'Str', default => '' );

has 'rscript' => ( is => 'rw', isa => 'Str' );
has 'rscript_fh' => ( is => 'rw', isa => 'FileHandle' );
has 'rscript_name' => ( is => 'rw', isa => 'Str' );


sub set_r_script {

  my ( $self ) = @_;

  my $rscript = '#!/software/pathogen/external/apps/usr/local/bin/R' . "\n";
  $rscript .= 'library(DESeq)' . "\n";
  $rscript .= 'thisCountTable = read.table( "' . $self->deseq_file_path . '", header=TRUE, row.names=1 )' . "\n";
  $rscript .= 'thisDesign = data.frame(' . "\n";
  $rscript .= 'row.names = colnames(thisCountTable),' . "\n";
  $rscript .= 'condition = ' . $self->r_conditions . ",\n";
  $rscript .= 'libType = ' . $self->r_lib_types . ")\n";
  $rscript .= 'pairedSamples = thisDesign$libType == "paired-end"' . "\n";
  $rscript .= 'countTable = thisCountTable[, pairedSamples]' . "\n";
  $rscript .= 'condition = thisDesign$condition[ pairedSamples ]' . "\n";
  $rscript .= qq/cds = newCountDataSet( countTable, condition )\n/;
  $rscript .= qq/cds = estimateSizeFactors( cds )\n/;

  $rscript .= $self->mode eq 'test' ? qq/cds = estimateDispersions(cds, fitType="local")\n/ : qq/cds = estimateDispersions(cds)\n/; #Do local fit if running in test mode

  $rscript .= qq/res = nbinomTest( cds, "untreated", "treated" )\n/;
  $rscript .= 'write.csv( res, file="' . $self->deseq_file . '_result_table.csv")' . "\n";

  $self->rscript($rscript);

}

sub write_r_script {

  my ( $self ) = @_;

  my $rscript_name = $self->deseq_file . '.r';
  $self->exit_code(0) unless open ( my $fh, '>',  $rscript_name);

  $self->rscript_fh( $fh );

  $self->rscript_fh->print( $self->rscript );

  close( $self->rscript_fh );

  $self->rscript_name($rscript_name);

  my $mode = "0775";
  chmod oct($mode), $self->rscript_name;

  
}

no Moose;
__PACKAGE__->meta->make_immutable;
1;
