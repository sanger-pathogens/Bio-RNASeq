#!/usr/bin/env perl
use strict;
use warnings;
use Data::Dumper;

BEGIN { unshift(@INC, './lib') }
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
is_deeply( $ensembl_gene_model_handler->tags_of_interest(), ['gene','mRNA','exon'], 'Ensembl - Array of tags should be the same' ) ;
is( $ensembl_gene_model_handler->is_tag_of_interest('gene'), 1, 'Gene is a valid type for Ensembl' );
is( $ensembl_gene_model_handler->is_tag_of_interest('mRNA'), 1, 'mRNA is a valid type for Ensembl' );
is( $ensembl_gene_model_handler->is_tag_of_interest('exon'), 1, 'Exon is a valid type for Ensembl' );
is( $ensembl_gene_model_handler->is_tag_of_interest('CDS'), 0, 'CDS is not a valid type for Ensembl' );

ok( my $chado_gene_model_handler = Bio::RNASeq::GeneModelHandlers::ChadoGeneModelHandler->new( filename=>'t/data/gffs_sams/multipurpose_3_cds_chado.gff'), 'Object initialised' );
is_deeply( $chado_gene_model_handler->tags_of_interest(), ['gene','mRNA','CDS'], 'Chado - Array of tags should be the same' ) ;
is( $chado_gene_model_handler->is_tag_of_interest('gene'), 1, 'Gene is a valid type for Chado' );
is( $chado_gene_model_handler->is_tag_of_interest('mRNA'), 1, 'mRNA is a valid type for Chado' );
is( $chado_gene_model_handler->is_tag_of_interest('exon'), 0, 'Exon is not a valid type for Chado' );
is( $chado_gene_model_handler->is_tag_of_interest('CDS'), 1, 'CDS is a valid type for Chado' );

ok( my $cds_only_gene_model_handler = Bio::RNASeq::GeneModelHandlers::CDSOnlyGeneModelHandler->new( filename=>'t/data/gffs_sams/multipurpose_3_cds_annot.gff'), 'Object initialised' );
is_deeply( $cds_only_gene_model_handler->tags_of_interest(), ['CDS'], 'CDSOnly - Array of tags should be the same' ) ;
is( $cds_only_gene_model_handler->is_tag_of_interest('gene'), 0, 'Gene is not a valid type for CDSOnly' );
is( $cds_only_gene_model_handler->is_tag_of_interest('mRNA'), 0, 'mRNA is not a valid type for CDSOnly' );
is( $cds_only_gene_model_handler->is_tag_of_interest('exon'), 0, 'Exon is not a valid type for CDSOnly' );
is( $cds_only_gene_model_handler->is_tag_of_interest('CDS'), 1, 'CDS is a valid type for CDSOnly' );
ok( $cds_only_gene_model_handler->gene_models()->{'Clostridium_difficile_630_v1.9_00001'}, 'Gene should exist as a feature' );
isa_ok( $cds_only_gene_model_handler->gene_models()->{'Clostridium_difficile_630_v1.9_00001'}, 'Bio::RNASeq::Feature', 'Should be of type Feature' );
is( $cds_only_gene_model_handler->gene_models()->{'Clostridium_difficile_630_v1.9_00001'}->gene_start(), 200, 'Gene start should match');
is( $cds_only_gene_model_handler->gene_models()->{'Clostridium_difficile_630_v1.9_00001'}->gene_end(), 1000, 'Gene end should match');
is( $cds_only_gene_model_handler->gene_models()->{'Clostridium_difficile_630_v1.9_00001'}->gene_strand(), 1, 'Gene strand should match');
is( $cds_only_gene_model_handler->gene_models()->{'Clostridium_difficile_630_v1.9_00001'}->exon_length(), 800, 'Exon length should match');
is_deeply( $cds_only_gene_model_handler->gene_models()->{'Clostridium_difficile_630_v1.9_00001'}->exons(), [ [200,1000] ], 'Exons should be the same');

ok( my $old_chado_format_gene_model_handler = Bio::RNASeq::GeneModelHandlers::OldChadoFormatGeneModelHandler->new( filename=>'t/data/gffs_sams/old_style_chado.gff'), 'Object initialised' );
is_deeply( $old_chado_format_gene_model_handler->tags_of_interest(), ['CDS'], 'Old Chado Format - Array of tags should be the same' ) ;
is( $old_chado_format_gene_model_handler->is_tag_of_interest('gene'), 0, 'Gene is not a valid type for OldChadoFormat' );
is( $old_chado_format_gene_model_handler->is_tag_of_interest('mRNA'), 0, 'mRNA is not a valid type for OldChadoFormat' );
is( $old_chado_format_gene_model_handler->is_tag_of_interest('exon'), 0, 'Exon is not a valid type for OldChadoFormat' );
is( $old_chado_format_gene_model_handler->is_tag_of_interest('CDS'), 1, 'CDS is a valid type for OldChadoFormat' );



done_testing();
