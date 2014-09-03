package Bio::RNASeq::Exceptions;

# ABSTRACT: Exception handler for the Bio:RNASeq application

=head1 SYNOPSIS
Exception handler for the Bio:RNASeq application
my $a_slice = '';
if( $a_slice == 0) {
	Bio::RNASeq::Exceptions::FailedToOpenAlignmentSlice->throw( error => "Input files invalid: ".$self->sequence_filename." ".$self->annotation_filename."\n" );
}
=cut


use Exception::Class (
				   Bio::RNASeq::Exceptions::FailedToOpenAlignmentSlice => { description => 'Couldnt get reads from alignment slice. Error with Samtools or BAM' },
				   Bio::RNASeq::Exceptions::FailedToOpenExpressionResultsSpreadsheetForWriting => { description => 'Couldnt write out the results for expression' },
				   Bio::RNASeq::Exceptions::InvalidInputFiles => { description => 'Invalid inputs, sequence names or lengths are incorrect' },
				   Bio::RNASeq::Exceptions::FailedToCreateNewBAM => { description => 'Couldnt create a new bam file' },
				   Bio::RNASeq::Exceptions::FailedToCreateMpileup => { description => 'Couldnt create an mpileup' },
				   Bio::RNASeq::Exceptions::FailedToOpenFeaturesTabFileForWriting => { description => 'Couldnt write tab file' },
				   Bio::RNASeq::Exceptions::InvalidTotalMappedReadsMethod => { description => 'Invalid total mapped reads method option' },
				   Bio::RNASeq::Exceptions::NonExistentFile => { description => 'File doesnt exist' },
				   Bio::RNASeq::Exceptions::DuplicateFeatureID => { description => 'Duplicate feature id in gff file' },
);

1;
