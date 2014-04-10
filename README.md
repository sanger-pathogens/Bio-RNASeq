Bio-RNASeq
==========

Bio-RNASeq calculates expression values from any given BAM file.  
This application takes in an aligned sequence file (BAM) and a corresponding annotation file (GFF) and creates a spreadsheet with expression values.
The BAM must be aligned to the same reference that the annotation refers to and must be sorted.


SYNOPSIS
========

rna_seq_expression -s [filename.bam] -a [filename.gff] -p [standard|nc_protocol|tradis] -o [./foobar] -t [a|b]

USAGE
=====

-s|sequence_file             - aligned BAM file

-a|annotation_file           - annotation file (GFF)

-p|protocol                  - standard|strand_specific|tradis

-o|output_base_filename      - Optional: base name and location to use for output files

-q|minimum_mapping_quality   - Optional: minimum mapping quality

-c|no_coverage_plots         - Optional: Dont create Artemis coverage plots

-i|intergenic_regions        - Optional: Include intergenic regions

-b|bitwise_flag              - Optional: Only include reads which pass filter

-t|total_mapped_reads_method - Optional: a|b - If not set, defaults to total reads mapped to the ref sequence in the bam file (no quality filters applied to the reads)

-h|help                    - print this message
