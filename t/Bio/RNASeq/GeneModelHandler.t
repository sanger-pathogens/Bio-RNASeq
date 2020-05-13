#!/usr/bin/env perl
use strict;
use warnings;
use Data::Dumper;

BEGIN {
    use Test::Most;
    use_ok('Bio::RNASeq::GeneModelHandlers::GeneModelHandler');
    use_ok('Bio::RNASeq::GeneModelHandlers::EnsemblGeneModelHandler');
    use_ok('Bio::RNASeq::GeneModelHandlers::ChadoGeneModelHandler');
    use_ok('Bio::RNASeq::GeneModelHandlers::CDSOnlyGeneModelHandler');
    use_ok('Bio::RNASeq::GeneModelHandlers::OldChadoFormatGeneModelHandler');
}



ok( my $generic_gene_model_handler = Bio::RNASeq::GeneModelHandlers::GeneModelHandler->new( filename=>'t/data/gffs_sams/multipurpose_3_genes_mammal_gtf2gff3.gff'), 'Object initialised' );
is_deeply( $generic_gene_model_handler->tags_of_interest(), [], 'If GFF can\'t be detected, there are no tags of interest' ) ;
is( $generic_gene_model_handler->is_tag_of_interest('CDS'), 0, 'There should be no tags of interest' );
is_deeply( $generic_gene_model_handler->gene_models(), {}, 'No gene models are returned. GFF Gene Model is Invalid' );


ok( my $ensembl_gene_model_handler = Bio::RNASeq::GeneModelHandlers::EnsemblGeneModelHandler->new( filename=>'t/data/gffs_sams/multipurpose_3_genes_mammal_gtf2gff3.gff'), 'Object initialised' );
is_deeply( $ensembl_gene_model_handler->tags_of_interest(), ['mRNA','transcript','exon'], 'Ensembl - Array of tags should be the same' ) ;
is( $ensembl_gene_model_handler->is_tag_of_interest('mRNA'), 1, 'mRNA is a valid type for Ensembl' );
is( $ensembl_gene_model_handler->is_tag_of_interest('exon'), 1, 'Exon is a valid type for Ensembl' );
is( $ensembl_gene_model_handler->is_tag_of_interest('CDS'), 0, 'CDS is not a valid type for Ensembl' );

ok( $ensembl_gene_model_handler->gene_models()->{'Gene1'}, 'Should be of type Feature' );
is( $ensembl_gene_model_handler->gene_models()->{'Gene1'}->gene_start(), 528, 'Gene start should match');
is( $ensembl_gene_model_handler->gene_models()->{'Gene1'}->gene_end(), 3623, 'Gene end should match');
is( $ensembl_gene_model_handler->gene_models()->{'Gene1'}->gene_strand(), 1, 'Gene strand should match');
is( $ensembl_gene_model_handler->gene_models()->{'Gene1'}->exon_length(), 1443, 'Exon length should match');
is_deeply( $ensembl_gene_model_handler->gene_models()->{'Gene1'}->exons(), [ [528, 814], [1480, 2070], [3056, 3623] ], 'Exons should be the same');
is($ensembl_gene_model_handler->_awk_filter, 'awk \'BEGIN {FS="\t"};{ if ($3 ~/gene|stop_codon|start_codon|three_prime_UTR|five_prime_UTR|CDS/) ; else print $0;}\' ', 'awk filter for ensembl');

ok( my $ensembl_gene_model_handler2 = Bio::RNASeq::GeneModelHandlers::EnsemblGeneModelHandler->new( filename=>'t/data/gffs_sams/mammal_gene_multiple_mrna.gff'), 'Object initialised' );
is_deeply( $ensembl_gene_model_handler2->tags_of_interest(), ['mRNA','transcript','exon'], 'Ensembl - Array of tags should be the same' ) ;
is( $ensembl_gene_model_handler2->is_tag_of_interest('mRNA'), 1, 'mRNA is a valid type for Ensembl' );
is( $ensembl_gene_model_handler2->is_tag_of_interest('transcript'), 1, 'transcript is a valid type for Ensembl' );
is( $ensembl_gene_model_handler2->is_tag_of_interest('exon'), 1, 'Exon is a valid type for Ensembl' );
is( $ensembl_gene_model_handler2->is_tag_of_interest('CDS'), 0, 'CDS is not a valid type for Ensembl' );

ok( $ensembl_gene_model_handler2->gene_models()->{'Gene1'}, 'Should be of type Feature' );
is( $ensembl_gene_model_handler2->gene_models()->{'Gene1'}->gene_start(), 528, 'Gene start should match');
is( $ensembl_gene_model_handler2->gene_models()->{'Gene1'}->gene_end(), 9623, 'Gene end should match');
is( $ensembl_gene_model_handler2->gene_models()->{'Gene1'}->gene_strand(), 1, 'Gene strand should match');
is( $ensembl_gene_model_handler2->gene_models()->{'Gene1'}->exon_length(), 4329, 'Exon length should match');
is_deeply( $ensembl_gene_model_handler2->gene_models()->{'Gene1'}->exons(), [ [528, 814], [1480, 2070], [3056, 3623], [4028, 4314], [4480, 5070], [6056, 6623], [7028, 7314], [7480, 8070], [9056, 9623] ], 'Exons should be the same');


ok( my $ensembl_gene_model_handler3 = Bio::RNASeq::GeneModelHandlers::EnsemblGeneModelHandler->new( filename=>'t/data/gffs_sams/mm10_no_mrna_only_transcript.gff'), 'Object initialised' );
is_deeply( $ensembl_gene_model_handler3->tags_of_interest(), ['mRNA','transcript','exon'], 'Ensembl - Array of tags should be the same' ) ;
is( $ensembl_gene_model_handler3->is_tag_of_interest('mRNA'), 1, 'mRNA is a valid type for Ensembl' );
is( $ensembl_gene_model_handler3->is_tag_of_interest('transcript'), 1, 'transcript is a valid type for Ensembl' );
is( $ensembl_gene_model_handler3->is_tag_of_interest('exon'), 1, 'exon is a valid type for Ensembl' );
is( $ensembl_gene_model_handler3->is_tag_of_interest('CDS'), 0, 'CDS is not a valid type for Ensembl' );

ok( $ensembl_gene_model_handler3->gene_models()->{'ENSMUSG00000096707'}, 'Should be of type Feature' );
is( $ensembl_gene_model_handler3->gene_models()->{'ENSMUSG00000096707'}->gene_start(), 8801136, 'Gene start should match');
is( $ensembl_gene_model_handler3->gene_models()->{'ENSMUSG00000096707'}->gene_end(), 8825685, 'Gene end should match');
is( $ensembl_gene_model_handler3->gene_models()->{'ENSMUSG00000096707'}->gene_strand(), -1, 'Gene strand should match');
is( $ensembl_gene_model_handler3->gene_models()->{'ENSMUSG00000096707'}->exon_length(), 2406, 'Exon length should match');
is_deeply( $ensembl_gene_model_handler3->gene_models()->{'ENSMUSG00000096707'}->exons(), [ [8825489, 8825685], [8822346, 8822638], [8813464, 8814276], [8811706, 8811933], [8805937, 8806060], [8801136, 8801892] ], 'Exons should be the same');


ok( my $chado_gene_model_handler = Bio::RNASeq::GeneModelHandlers::ChadoGeneModelHandler->new( filename=>'t/data/gffs_sams/multipurpose_3_cds_chado.gff'), 'Chado Object initialised' );
is_deeply( $chado_gene_model_handler->tags_of_interest(), ['mRNA','CDS'], 'Chado - Array of tags should be the same' ) ;
is( $chado_gene_model_handler->is_tag_of_interest('mRNA'), 1, 'mRNA is a valid type for Chado' );
is( $chado_gene_model_handler->is_tag_of_interest('exon'), 0, 'Exon is not a valid type for Chado' );
is( $chado_gene_model_handler->is_tag_of_interest('CDS'), 1, 'CDS is a valid type for Chado' );

ok( $chado_gene_model_handler->gene_models()->{'GreatCurl'}, 'Should be of type Feature' );
is( $chado_gene_model_handler->gene_models()->{'GreatCurl'}->gene_start(), 1053, 'Gene start should match');
is( $chado_gene_model_handler->gene_models()->{'GreatCurl'}->gene_end(), 2474, 'Gene end should match');
is( $chado_gene_model_handler->gene_models()->{'GreatCurl'}->gene_strand(), 1, 'Gene strand should match');
is( $chado_gene_model_handler->gene_models()->{'GreatCurl'}->exon_length(), 1071, 'CDS length should match');
is_deeply( $chado_gene_model_handler->gene_models()->{'GreatCurl'}->exons(), [ [1053, 1500], [1650, 1900], [2100, 2474] ], 'CDSs should be the same');


ok( my $cds_only_gene_model_handler = Bio::RNASeq::GeneModelHandlers::CDSOnlyGeneModelHandler->new( filename=>'t/data/gffs_sams/multipurpose_3_cds_annot.gff'), 'Object initialised' );
is_deeply( $cds_only_gene_model_handler->tags_of_interest(), ['CDS'], 'CDSOnly - Array of tags should be the same' ) ;
is( $cds_only_gene_model_handler->is_tag_of_interest('gene'), 0, 'Gene is not a valid type for CDSOnly' );
is( $cds_only_gene_model_handler->is_tag_of_interest('mRNA'), 0, 'mRNA is not a valid type for CDSOnly' );
is( $cds_only_gene_model_handler->is_tag_of_interest('exon'), 0, 'Exon is not a valid type for CDSOnly' );
is( $cds_only_gene_model_handler->is_tag_of_interest('CDS'), 1, 'CDS is a valid type for CDSOnly' );


ok( $cds_only_gene_model_handler->gene_models()->{'Clostridium_difficile_630_v1.9_00001'}, 'CDS should exist as a feature' );
isa_ok( $cds_only_gene_model_handler->gene_models()->{'Clostridium_difficile_630_v1.9_00001'}, 'Bio::RNASeq::Feature', 'Should be of type Feature' );
is( $cds_only_gene_model_handler->gene_models()->{'Clostridium_difficile_630_v1.9_00001'}->gene_start(), 200, 'CDS start should match');
is( $cds_only_gene_model_handler->gene_models()->{'Clostridium_difficile_630_v1.9_00001'}->gene_end(), 1000, 'CDS end should match');
is( $cds_only_gene_model_handler->gene_models()->{'Clostridium_difficile_630_v1.9_00001'}->gene_strand(), 1, 'CDS strand should match');
is( $cds_only_gene_model_handler->gene_models()->{'Clostridium_difficile_630_v1.9_00001'}->exon_length(), 800, 'Exon length should match');
is_deeply( $cds_only_gene_model_handler->gene_models()->{'Clostridium_difficile_630_v1.9_00001'}->exons(), [ [200,1000] ], 'Exons should be the same');


ok( my $old_chado_format_gene_model_handler = Bio::RNASeq::GeneModelHandlers::OldChadoFormatGeneModelHandler->new( filename=>'t/data/gffs_sams/old_style_chado.gff'), 'Object initialised' );
is_deeply( $old_chado_format_gene_model_handler->tags_of_interest(), ['CDS'], 'Old Chado Format - Array of tags should be the same' ) ;
is( $old_chado_format_gene_model_handler->is_tag_of_interest('gene'), 0, 'Gene is not a valid type for OldChadoFormat' );
is( $old_chado_format_gene_model_handler->is_tag_of_interest('mRNA'), 0, 'mRNA is not a valid type for OldChadoFormat' );
is( $old_chado_format_gene_model_handler->is_tag_of_interest('exon'), 0, 'Exon is not a valid type for OldChadoFormat' );
is( $old_chado_format_gene_model_handler->is_tag_of_interest('CDS'), 1, 'CDS is a valid type for OldChadoFormat' );

ok( $old_chado_format_gene_model_handler->gene_models()->{'Schisto_mansoni.Chr_1.unplaced.SC_0010.248'}, 'Should be of type Feature' );
is( $old_chado_format_gene_model_handler->gene_models()->{'Schisto_mansoni.Chr_1.unplaced.SC_0010.248'}->gene_start(), 1043973, 'CDS start should match');
is( $old_chado_format_gene_model_handler->gene_models()->{'Schisto_mansoni.Chr_1.unplaced.SC_0010.248'}->gene_end(), 1046287, 'CDS end should match');
is( $old_chado_format_gene_model_handler->gene_models()->{'Schisto_mansoni.Chr_1.unplaced.SC_0010.248'}->gene_strand(), 1, 'CDS strand should match');
is( $old_chado_format_gene_model_handler->gene_models()->{'Schisto_mansoni.Chr_1.unplaced.SC_0010.248'}->exon_length(), 546, 'Exon length should match');
is_deeply( $old_chado_format_gene_model_handler->gene_models()->{'Schisto_mansoni.Chr_1.unplaced.SC_0010.248'}->exons(), [ [1043973,1044041], [1044079,1044183], [1044222,1044315], [1044355,1044427], [1044463,1044598], [1046213,1046287] ], 'Exons should be the same');


done_testing();
