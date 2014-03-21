package Exceptions;

use Exception::Class (
    Exceptions::FailedToOpenAlignmentSlice => { description => 'Couldnt get reads from alignment slice. Error with Samtools or BAM' },
    Exceptions::FailedToOpenExpressionResultsSpreadsheetForWriting => { description => 'Couldnt write out the results for expression' },
		Exceptions::InvalidInputFiles => { description => 'Invalid inputs, sequence names or lengths are incorrect' },
		Exceptions::FailedToCreateNewBAM => { description => 'Couldnt create a new bam file' },
		Exceptions::FailedToCreateMpileup => { description => 'Couldnt create an mpileup' },
		Exceptions::FailedToOpenFeaturesTabFileForWriting => { description => 'Couldnt write tab file' },
);

1;
