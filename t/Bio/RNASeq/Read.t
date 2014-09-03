#!/usr/bin/env perl
use strict;
use warnings;
use Data::Dumper;

BEGIN { unshift(@INC, './lib') }
BEGIN {
    use Test::Most;
    use_ok('Bio::RNASeq::Read');
}

ok my $alignment_slice = Bio::RNASeq::Read->new(
    alignment_line =>
'IL25_4928:3:53:7118:13952#4	163	FN543502	66737	60	54M	=	66903	220	GGGGGGCGTTTTCCGGCGATTCTTTACTGTACATATCCAGTTGACCGTTCGGGA	BBBBBBBBBBBBBBBB@B9=B@BBBF@@@@@@@@@@@@@@@@@@?>@?@?@@B?	XT:A:U	NM:i:1	SM:i:37	AM:i:37	X0:i:1	X1:i:0	XM:i:1	XO:i:0	XG:i:0	MD:Z:0C53	RG:Z:4928_3#4',
    gene_strand => 1,
    exons       => [ [ 66337, 66937 ], [ 4, 5 ] ]
  ),
  'initialise';

is $alignment_slice->_read_position, 66737, 'read position';
is $alignment_slice->read_strand,    1,     'read strand';

ok my %mapped_reads = %{ $alignment_slice->mapped_reads },
  'build the mapped reads';
is $mapped_reads{sense},     1, 'identified mapped reads';
is $mapped_reads{antisense}, 0, 'identified antisense read';

#Skipped bases will be added to the read length
ok $alignment_slice = Bio::RNASeq::Read->new(
    alignment_line =>
'IL25_4928:3:53:7118:13952#4	163	FN543502	66737	60	28M10N26M	=	66903	220	GGGGGGCGTTTTCCGGCG..........GTACATATCCAGTTGACCGTTCGGGA	BBBBBBBBBBBBBBBB@B9=B@BBBF@@@@@@@@@@@@@@@@@@?>@?@?@@B?	XT:A:U	NM:i:1	SM:i:37	AM:i:37	X0:i:1	X1:i:0	XM:i:1	XO:i:0	XG:i:0	MD:Z:0C53	RG:Z:4928_3#4',
    gene_strand => 1,
    exons       => [ [ 66337, 66937 ], [ 4, 5 ] ]
  ),
  'initialise';

is $alignment_slice->_read_position, 66737,
  'read position with skipped bases on reference';
is $alignment_slice->read_strand, 1,
  'read strand with skipped bases on reference';

ok %mapped_reads = %{ $alignment_slice->mapped_reads },
  'build the mapped reads with skipped bases on reference';
is $mapped_reads{sense}, 1,
  'identified mapped reads with skipped bases on reference';
is $mapped_reads{antisense}, 0,
  'identified antisense read with skipped bases on reference';

# filter out low quality reads
my %filters = ( mapping_quality => 30 );
ok $alignment_slice = Bio::RNASeq::Read->new(
    alignment_line =>
'IL25_4928:3:53:7118:13952#4	163	FN543502	66737	20	54M	=	66903	220	GGGGGGCGTTTTCCGGCGATTCTTTACTGTACATATCCAGTTGACCGTTCGGGA	BBBBBBBBBBBBBBBB@B9=B@BBBF@@@@@@@@@@@@@@@@@@?>@?@?@@B?	XT:A:U	NM:i:1	SM:i:37	AM:i:37	X0:i:1	X1:i:0	XM:i:1	XO:i:0	XG:i:0	MD:Z:0C53	RG:Z:4928_3#4',
    gene_strand => 1,
    exons       => [ [ 66337, 66937 ], [ 4, 5 ] ],
    filters     => \%filters
  ),
  'initialise';
is $alignment_slice->_does_read_pass_filters, 0, 'filter low quality reads';
ok %mapped_reads = %{ $alignment_slice->mapped_reads },
  'build the mapped reads with filter';
is $mapped_reads{sense},     0, 'identified mapped reads with filter';
is $mapped_reads{antisense}, 0, 'identified antisense read with filter';

# dont filter high quality reads
%filters = ( mapping_quality => 30 );
ok $alignment_slice = Bio::RNASeq::Read->new(
    alignment_line =>
'IL25_4928:3:53:7118:13952#4	163	FN543502	66737	60	54M	=	66903	220	GGGGGGCGTTTTCCGGCGATTCTTTACTGTACATATCCAGTTGACCGTTCGGGA	BBBBBBBBBBBBBBBB@B9=B@BBBF@@@@@@@@@@@@@@@@@@?>@?@?@@B?	XT:A:U	NM:i:1	SM:i:37	AM:i:37	X0:i:1	X1:i:0	XM:i:1	XO:i:0	XG:i:0	MD:Z:0C53	RG:Z:4928_3#4',
    gene_strand => 1,
    exons       => [ [ 66337, 66937 ], [ 4, 5 ] ],
    filters     => \%filters
  ),
  'initialise';
is $alignment_slice->_does_read_pass_filters, 1,
  'dont filter high quality reads';
ok %mapped_reads = %{ $alignment_slice->mapped_reads },
  'build the mapped reads with high quality read and filter';
is $mapped_reads{sense}, 1,
  'identified mapped reads with high quality read and filter';
is $mapped_reads{antisense}, 0,
  'identified antisense read with high quality read and filter';

# Passes bitwise filter
%filters = ( bitwise_flag => 2 );
ok my $alignment_slice2 = Bio::RNASeq::Read->new(
    alignment_line =>
'IL25_4928:3:53:7118:13952#4	3	FN543502	66737	60	54M	=	66903	220	GGGGGGCGTTTTCCGGCGATTCTTTACTGTACATATCCAGTTGACCGTTCGGGA	BBBBBBBBBBBBBBBB@B9=B@BBBF@@@@@@@@@@@@@@@@@@?>@?@?@@B?	XT:A:U	NM:i:1	SM:i:37	AM:i:37	X0:i:1	X1:i:0	XM:i:1	XO:i:0	XG:i:0	MD:Z:0C53	RG:Z:4928_3#4',
    gene_strand => 1,
    exons       => [ [ 66337, 66937 ], [ 4, 5 ] ],
    filters     => \%filters
  ),
  'initialise';
ok my %mapped_reads2 = %{ $alignment_slice2->mapped_reads },
  'build the mapped reads Passes bitwise filter';
is $mapped_reads2{sense}, 1, 'identified mapped reads Passes bitwise filter';
is $mapped_reads2{antisense}, 0,
  'identified antisense read Passes bitwise filter';

# Doesnt pass bitwise filter
%filters = ( bitwise_flag => 2 );
ok my $alignment_slice3 = Bio::RNASeq::Read->new(
    alignment_line =>
'IL25_4928:3:53:7118:13952#4	13	FN543502	66737	60	54M	=	66903	220	GGGGGGCGTTTTCCGGCGATTCTTTACTGTACATATCCAGTTGACCGTTCGGGA	BBBBBBBBBBBBBBBB@B9=B@BBBF@@@@@@@@@@@@@@@@@@?>@?@?@@B?	XT:A:U	NM:i:1	SM:i:37	AM:i:37	X0:i:1	X1:i:0	XM:i:1	XO:i:0	XG:i:0	MD:Z:0C53	RG:Z:4928_3#4',
    gene_strand => 1,
    exons       => [ [ 66337, 66937 ], [ 4, 5 ] ],
    filters     => \%filters
  ),
  'initialise';
ok my %mapped_reads3 = %{ $alignment_slice3->mapped_reads },
  'build the mapped reads Doesnt pass bitwise filter';
is $mapped_reads3{sense}, 0,
  'identified mapped reads Doesnt pass bitwise filter';
is $mapped_reads3{antisense}, 0,
  'identified antisense read Doesnt pass bitwise filter';

# complex filter pass
%filters = ( bitwise_flag => 5 );
ok my $alignment_slice4 = Bio::RNASeq::Read->new(
    alignment_line =>
'IL25_4928:3:53:7118:13952#4	3	FN543502	66737	60	54M	=	66903	220	GGGGGGCGTTTTCCGGCGATTCTTTACTGTACATATCCAGTTGACCGTTCGGGA	BBBBBBBBBBBBBBBB@B9=B@BBBF@@@@@@@@@@@@@@@@@@?>@?@?@@B?	XT:A:U	NM:i:1	SM:i:37	AM:i:37	X0:i:1	X1:i:0	XM:i:1	XO:i:0	XG:i:0	MD:Z:0C53	RG:Z:4928_3#4',
    gene_strand => 1,
    exons       => [ [ 66337, 66937 ], [ 4, 5 ] ],
    filters     => \%filters
  ),
  'initialise';
ok my %mapped_reads4 = %{ $alignment_slice4->mapped_reads },
  'build the mapped reads complex filter pass';
is $mapped_reads4{sense}, 1, 'identified mapped reads complex filter pass';
is $mapped_reads4{antisense}, 0,
  'identified antisense read complex filter pass';

# complex filter fail
%filters = ( bitwise_flag => 10 );
ok my $alignment_slice5 = Bio::RNASeq::Read->new(
    alignment_line =>
'IL25_4928:3:53:7118:13952#4	21	FN543502	66737	60	54M	=	66903	220	GGGGGGCGTTTTCCGGCGATTCTTTACTGTACATATCCAGTTGACCGTTCGGGA	BBBBBBBBBBBBBBBB@B9=B@BBBF@@@@@@@@@@@@@@@@@@?>@?@?@@B?	XT:A:U	NM:i:1	SM:i:37	AM:i:37	X0:i:1	X1:i:0	XM:i:1	XO:i:0	XG:i:0	MD:Z:0C53	RG:Z:4928_3#4',
    gene_strand => 1,
    exons       => [ [ 66337, 66937 ], [ 4, 5 ] ],
    filters     => \%filters
  ),
  'initialise';
ok my %mapped_reads5 = %{ $alignment_slice5->mapped_reads },
  'build the mapped reads complex filter fail';
is $mapped_reads5{sense}, 0, 'identified mapped reads complex filter fail';
is $mapped_reads5{antisense}, 0,
  'identified antisense read complex filter fail';

# unmapped reads fail
ok my $alignment_slice6 = Bio::RNASeq::Read->new(
    alignment_line =>
'IL25_4928:3:53:7118:13952#4	7	FN543502	66737	60	54M	=	66903	220	GGGGGGCGTTTTCCGGCGATTCTTTACTGTACATATCCAGTTGACCGTTCGGGA	BBBBBBBBBBBBBBBB@B9=B@BBBF@@@@@@@@@@@@@@@@@@?>@?@?@@B?	XT:A:U	NM:i:1	SM:i:37	AM:i:37	X0:i:1	X1:i:0	XM:i:1	XO:i:0	XG:i:0	MD:Z:0C53	RG:Z:4928_3#4',
    gene_strand => 1,
    exons       => [ [ 66337, 66937 ], [ 4, 5 ] ]
  ),
  'initialise';
ok my %mapped_reads6 = %{ $alignment_slice6->mapped_reads },
  'build the mapped reads does not pass unmapped read';
is $mapped_reads6{sense}, 0,
  'identified mapped reads does not pass unmapped read';
is $mapped_reads6{antisense}, 0,
  'identified antisense read does not pass unmapped read';

#
ok my $alignment_slice7 = Bio::RNASeq::Read->new(
    alignment_line =>
      'read1	0	CHR1	40	50	10M	=	0	109	AAAAAAAAAA	BBBBBBBBBB	AS:i:0',
    gene_strand => 1,
    exons       => [ [ 1, 20 ], [ 40, 50 ] ]
  ),
'initialise - 2 exons read in exon 2, only one read should be counted in the gene';

ok my %mapped_reads7 = %{ $alignment_slice7->mapped_reads },
  'Build mapped reads - single read in exon2';
is $mapped_reads7{sense},     1, 'Sense reads - single read in exon2';
is $mapped_reads7{antisense}, 0, 'Antisense reads - single read in exon2';


ok $alignment_slice = Bio::RNASeq::Read->new(
    alignment_line =>
      'read1	0	CHR1	10	50	10M	=	0	109	AAAAAAAAAA	BBBBBBBBBB	AS:i:0',
    gene_strand => 1,
    exons       => [ [ 1, 20 ], [ 40, 50 ] ]
  ),
'initialise - 2 exons read in exon 1, only one read should be counted in the gene';

ok %mapped_reads = %{ $alignment_slice->mapped_reads },
  'Build mapped reads - single read in exon1';
is $mapped_reads{sense},     1, 'Sense reads - single read in exon1';
is $mapped_reads{antisense}, 0, 'Antisense reads - single read in exon1';

ok $alignment_slice = Bio::RNASeq::Read->new(
    alignment_line =>
      'read1	0	CHR1	10	50	10M	=	0	109	AAAAAAAAAA	BBBBBBBBBB	AS:i:0',
    gene_strand => 1,
    exons       => [ [ 40, 50 ], [ 1, 20 ] ]
  ),
  q(initialise - Order of the exons shouldn't matter);

ok %mapped_reads = %{ $alignment_slice->mapped_reads },
  'Build mapped reads - order of the exons shouldnt matter';
is $mapped_reads{sense}, 1, 'Sense reads - order of the exons shouldnt matter';
is $mapped_reads{antisense}, 0,
  'Antisense reads - order of the exons shouldnt matter';

ok $alignment_slice = Bio::RNASeq::Read->new(
    alignment_line =>
      'read1	0	CHR1	15	50	5M20N5M	=	0	109	AAAAAAAAAA	BBBBBBBBBB	AS:i:0',
    gene_strand => 1,
    exons       => [ [ 1, 20 ], [ 40, 50 ] ]
  ),
  q(initialise - Split read, single read should map);

ok %mapped_reads = %{ $alignment_slice->mapped_reads },
  'Build mapped reads - Split read, single read should map';
is $mapped_reads{sense}, 1, 'Sense reads - Split read, single read should map';
is $mapped_reads{antisense}, 0,
  'Antisense reads - Split read, single read should map';

ok $alignment_slice = Bio::RNASeq::Read->new(
    alignment_line =>
      'read1	0	CHR1	25	50	10M	=	0	109	AAAAAAAAAA	BBBBBBBBBB	AS:i:0',
    gene_strand => 1,
    exons       => [ [ 1, 20 ], [ 40, 50 ] ]
  ),
  q(initialise - Intronic read);

ok %mapped_reads = %{ $alignment_slice->mapped_reads },
  'Build mapped reads - Intronic read, no read should be counted';
is $mapped_reads{sense}, 0,
  'Sense reads -  Intronic read, no read should be counted';
is $mapped_reads{antisense}, 0,
  'Antisense reads -  Intronic read, no read should be counted';

ok $alignment_slice = Bio::RNASeq::Read->new(
    alignment_line =>
      'read1	0	CHR1	34	50	5M20N5M	=	0	109	AAAAAAAAAA	BBBBBBBBBB	AS:i:0',
    gene_strand => 1,
    exons       => [ [ 1, 20 ], [ 40, 50 ] ]
  ),
  q(initialise - Read spanning exon but not mapping);

ok %mapped_reads = %{ $alignment_slice->mapped_reads },
  'Build mapped reads - Read spanning exon but not mapping';
is $mapped_reads{sense}, 0, 'Sense reads -  Read spanning exon but not mapping';
is $mapped_reads{antisense}, 0,
  'Antisense reads -  Read spanning exon but not mapping';

ok $alignment_slice = Bio::RNASeq::Read->new(
    alignment_line =>
      'read1	0	CHR1	35	50	5M10N5M	=	0	109	AAAAAAAAAA	BBBBBBBBBB	AS:i:0',
    gene_strand => 1,
    exons       => [ [ 1, 20 ], [ 40, 50 ] ]
  ),
q(initialise - Identify minimum boundaries, no reads should be counted in the gene);

ok %mapped_reads = %{ $alignment_slice->mapped_reads },
'Build mapped reads - Identify minimum boundaries, no reads should be counted in the gene';
is $mapped_reads{sense}, 0,
'Sense reads -  Identify minimum boundaries, no reads should be counted in the gene';
is $mapped_reads{antisense}, 0,
'Antisense reads -  Identify minimum boundaries, no reads should be counted in the gene';

ok $alignment_slice = Bio::RNASeq::Read->new(
    alignment_line =>
      'read1	0	CHR1	35	50	5M10N5M	=	0	109	AAAAAAAAAA	BBBBBBBBBB	AS:i:0',
    gene_strand => -1,
    exons       => [ [ 1, 20 ], [ 40, 50 ] ]
  ),
q(initialise - Identify minimum boundaries, no reads should be counted in the gene - Antisense, negative strand);

ok %mapped_reads = %{ $alignment_slice->mapped_reads },
'Build mapped reads - Identify minimum boundaries, no reads should be counted in the gene - Antisense, negative strand';
is $mapped_reads{sense}, 0,
'Sense reads -  Identify minimum boundaries, no reads should be counted in the gene - Antisense, negative strand';
is $mapped_reads{antisense}, 0,
'Antisense reads -  Identify minimum boundaries, no reads should be counted in the gene - Antisense, negative strand';

ok $alignment_slice = Bio::RNASeq::Read->new(
    alignment_line =>
      'read1	16	CHR1	55	50	5M10N5M	=	0	109	AAAAAAAAAA	BBBBBBBBBB	AS:i:0',
    gene_strand => 1,
    exons       => [ [ 1, 20 ], [ 40, 50 ] ]
  ),
q(initialise - Identify minimum boundaries, no reads should be counted in the gene - Antisense, positive strand);

ok %mapped_reads = %{ $alignment_slice->mapped_reads },
'Build mapped reads - Identify minimum boundaries, no reads should be counted in the gene - Antisense, positive strand';
is $mapped_reads{sense}, 0,
'Sense reads -  Identify minimum boundaries, no reads should be counted in the gene - Antisense, positive strand';
is $mapped_reads{antisense}, 0,
'Antisense reads -  Identify minimum boundaries, no reads should be counted in the gene - Antisense, positive strand';

ok $alignment_slice = Bio::RNASeq::Read->new(
    alignment_line =>
      'read1	0	CHR1	40	50	10M	=	0	109	AAAAAAAAAA	BBBBBBBBBB	AS:i:0',
    gene_strand => -1,
    exons       => [ [ 1, 20 ], [ 40, 50 ] ]
  ),
'initialise - 2 exons read in exon 2, only one read should be counted in the gene - Antisense';

ok %mapped_reads = %{ $alignment_slice->mapped_reads },
  'Build mapped reads - single read in exon2 - Antisense';
is $mapped_reads{sense}, 0, 'Sense reads - single read in exon2 - Antisense';
is $mapped_reads{antisense}, 1,
  'Antisense reads - single read in exon2 - Antisense';

ok $alignment_slice = Bio::RNASeq::Read->new(
    alignment_line =>
      'read1	16	CHR1	40	50	10M	=	0	109	AAAAAAAAAA	BBBBBBBBBB	AS:i:0',
    gene_strand => 1,
    exons       => [ [ 1, 20 ], [ 40, 50 ] ]
  ),
'initialise - 2 exons read in exon 2, only one read should be counted in the gene - Antisense';

ok %mapped_reads = %{ $alignment_slice->mapped_reads },
  'Build mapped reads - single read in exon2 - Antisense';
is $mapped_reads{sense}, 0, 'Sense reads - single read in exon2 - Antisense';
is $mapped_reads{antisense}, 1,
  'Antisense reads - single read in exon2 - Antisense';

ok $alignment_slice = Bio::RNASeq::Read->new(
    alignment_line =>
      'read1	0	CHR1	1	50	3M7N3M7N4M	=	0	109	AAAAAAAAAA	BBBBBBBBBB	AS:i:0',
    gene_strand => 1,
    exons       => [ [ 1, 3 ], [ 11, 14 ], [ 21, 25 ] ]
  ),
  q(initialise - Single read mapping to 3 exons);

ok %mapped_reads = %{ $alignment_slice->mapped_reads },
  'Build mapped reads - Single read mapping to 3 exons';
is $mapped_reads{sense}, 1, 'Sense reads -  Single read mapping to 3 exons';
is $mapped_reads{antisense}, 0,
  'Antisense reads - Single read mapping to 3 exons';

done_testing();
