Bio-RNASeq
==========

Bio-RNASeq calculates expression values (RPKM) from any given BAM file.  
This application takes in an aligned sequence file (BAM) and a corresponding annotation file (GFF) and creates a spreadsheet with expression values.
The BAM must be aligned to the same reference that the annotation refers to and must be sorted.

The RPKM values are calculated according to two different methodologies:

1) total number of reads on the bam file that mapped to the reference;

2) total number of reads on the bam file that mapped to gene models in the reference genome.

The *expression.csv file will contains both datasets. It also produces coverage plots that you can visualise with Artemis

http://www.sanger.ac.uk/resources/software/artemis/
 
  

SYNOPSIS
========

rna_seq_expression -s [filename.bam] -a [filename.gff] -p [standard|strand_specific] -o [./foobar]

USAGE
=====

-s|sequence_file             - aligned BAM file

-a|annotation_file           - annotation file (GFF)

-p|protocol                  - standard|strand_specific

-o|output_base_filename      - Optional: base name and location to use for output files

-q|minimum_mapping_quality   - Optional: minimum mapping quality

-c|no_coverage_plots         - Optional: Dont create Artemis coverage plots

-i|intergenic_regions        - Optional: Include intergenic regions

-b|bitwise_flag              - Optional: Only include reads which pass filter

-h|help                    - print this message


REQUIRES
========

The samtools executable must be set in your path. You can get it here:

https://github.com/samtools


You will also need to download samtools v0.1.18 and build it on your system. Bio-RNASeq makes use of the Samtools v0.1.18 C API. You can get it here:

https://github.com/samtools/samtools/tree/0.1.18

Once you've downloaded this, on command line prompt, run

	~$ make

When make finishes, you will need to set a couple of environment variables

	export PATH=[path_to]/Bio-RNASeq/bin:$PATH
	export PERL5LIB=[path_to]/Bio-RNASeq/lib:$PERL5LIB
	
Now set the $SAMTOOLS environment variable to point to the directory where you built samtools v0.1.18

	export SAMTOOLS=[path_to]/samtools_0.1.18/


Create a directory called - _Inline - wherever you want. And set $PERL\_INLINE\_DIRECTORY

	export PERL_INLINE_DIRECTORY=[path_to]/_Inline
	
You can easily put all these export statements into a .sh which you will need to source before you can run Bio-RNASeq.
As an example, I have created the file

	bio_rnaseq_environment_setup.sh	

This is what it looks like

	export PATH=/Users/js21/work/Bio-RNASeq/bin:$PATH
	export PERL5LIB=/Users/js21/work/Bio-RNASeq/lib:$PERL5LIB
	export PERL_INLINE_DIRECTORY=/Users/js21/test_RNASeq/_Inline
	export SAMTOOLS=/Users/js21/work/samtools/

Whenever I'm running RNA Seq analysis with Bio-RNASeq, I source this bash script

	~$ source bio_rnaseq_environment_setup.sh

Now you can run this application in your bash terminal from wherever you are.