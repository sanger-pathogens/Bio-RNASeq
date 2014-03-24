package Bio::RNASeq::Exceptions;

use Exception::Class (
				   Bio::RNASeq::Exceptions::FailedToOpenAlignmentSlice => { description => 'Couldnt get reads from alignment slice. Error with Samtools or BAM' },
				   Bio::RNASeq::Exceptions::FailedToOpenExpressionResultsSpreadsheetForWriting => { description => 'Couldnt write out the results for expression' },
				   Bio::RNASeq::Exceptions::InvalidInputFiles => { description => 'Invalid inputs, sequence names or lengths are incorrect' },
				   Bio::RNASeq::Exceptions::FailedToCreateNewBAM => { description => 'Couldnt create a new bam file' },
				   Bio::RNASeq::Exceptions::FailedToCreateMpileup => { description => 'Couldnt create an mpileup' },
				   Bio::RNASeq::Exceptions::FailedToOpenFeaturesTabFileForWriting => { description => 'Couldnt write tab file' },
);

1;
