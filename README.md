Bio-RNASeq
==========


Allows the analysis of RNA-Seq data from BAM files all the way to
Differential Gene Expression.

There are three components to this application.

Calculating Read Counts -

The main component is accessed through the rna_seq_expression command.
This component is responsible for calculating expression values, in
the form of RPKM (reads per kilobase per million) from any given BAM file.

rna_seq_expression takes in an aligned sequence file (BAM) and a
corresponding annotation file (GFF) and creates a spreadsheet (.csv) with expression values.
The BAM must be aligned to the same reference that the annotation refers to and must be sorted.

The RPKM values are calculated according to two different methodologies:

1) total number of reads on the bam file that mapped to the reference genome;

2) total number of reads on the bam file that mapped to gene models in the reference genome.

The *expression.csv file will contain both datasets. 

Coverage plots compatible with Artemis will also be produced. You can download Artemis here:

http://www.sanger.ac.uk/resources/software/artemis/

Merging GFF Files -

rna_seq_expression can only handle a single GFF file. If the
annotation is broken up into several files, Bio-RNASeq provides a
utility to merge the annotation into one single GFF3 compatible file.

Access to this utility (the second component) is done through the gff3_concat command.

It takes as input the location of the GFF files to merge. The path
where  the final concatenated GFF file should be written to. And a
customised tag for the newly created GFF file.

Quantifying Differential Gene Expression -

Last but not least, the third component in this application suite
allows analysis of differential gene expression directly from the
output of rna_seq_expression or from a bespoke expression dataset.
It makes use of the DESeq Bioconductor R package to carry out differential gene
expression analysis.

Simon Anders and Wolfgang Huber (2010): Differential expression
  analysis for sequence count data. Genome Biology 11:R106

It takes as input a file with the list of samples to analyse and their
corresponding files of expression values in the format
("filepath","condition","replicate","lib_type"). It parses this file
and accesses all the files defined in the first column and parses
them. It generates a matrix ready for DESeq analysis. It's final
output will be a spreadsheet (.csv) that can be loaded subsequently
into a DESeq session or can be visualised in Excel.

  

SYNOPSIS
========

Calculating Read Counts -

rna_seq_expression -s [filename.bam] -a [filename.gff] -p [standard|strand_specific] -o [./foobar]

Merging GFF Files -

gff3_concat -i [full path to directory of gff files] -o
[full path to output directory] -t [name of the newly merged GFF file]


Quantifying Differential Gene Expression -

differential_expression_with_deseq -i
[file containing list of files to analyse and key descriptions] -o
[name to be used for all the output files generated] -c
[Number of the read count column (1-1000)] 


USAGE
=====

Calculating Read Counts -

rna_seq_expression

-s|sequence_file             - aligned BAM file

-a|annotation_file           - annotation file (GFF)

-p|protocol                  - standard|strand_specific

-o|output_base_filename      - Optional: base name and location to use for output files

-q|minimum_mapping_quality   - Optional: minimum mapping quality

-c|no_coverage_plots         - Optional: Dont create Artemis coverage plots

-i|intergenic_regions        - Optional: Include intergenic regions

-b|bitwise_flag              - Optional: Only include reads which pass filter

-h|help                    - print this message


Merging GFF Files -

gff3_concat

-i|input_dir        - full path to the directory containing the gff files to concatenate
-o|output_dir       - full path to the directory where the concatenated gff file will be written to
-t|tag              - the name to tag the concatenated gff file with
 -h|help             - print this message


Quantifying Differential Gene Expression -

differential_expression_with_deseq

  -i|input         - A file with the list of samples to analyse and their corresponding files of expression values
                    in the format ("filepath","condition","replicate","lib_type"). lib_type defaults to paired-end
                    if not specified on the samples file
  -o|output        - The name of the file that will be used as the DeSeq analysis input. NOTE - The file will be
                    writen wherever you're running deseq_run from
  -c|column        - Optional: Number of the column you want to use as your read count from your expression files.
                              Defaults to the second column in the expression file if no value is specified>
  -h|help           - print this message
  

REQUIRES
========

The samtools executable must be set in your path. You can download samtools here:

https://github.com/samtools


You will also need to download samtools v0.1.18 and build it on your system. Bio-RNASeq makes use of the Samtools v0.1.18 C API. You can get it here:

https://github.com/samtools/samtools/tree/0.1.18

Once you've downloaded this, in a bash terminal, in the samtools v0.1.18 directory, run

	~$ make

__NOTE:__ You don't need to run `make install`. You don't need to install the older version of samtools on your system.

Requires the R programming language:

http://www.r-project.org/

The R framework Bioconductor:

http://www.bioconductor.org/

And the Bioconductor package DESeq:

http://bioconductor.org/packages/release/bioc/html/DESeq.html
