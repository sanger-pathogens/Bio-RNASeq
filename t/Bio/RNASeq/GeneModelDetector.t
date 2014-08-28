#!/usr/bin/env perl
use Moose;
use Data::Dumper;
use Test::Most;

BEGIN { unshift( @INC, './lib' ) }
BEGIN { unshift( @INC, './t/lib' ) }

BEGIN {
    use_ok("Bio::RNASeq::GeneModelDetector");
    use_ok("Bio::RNASeq::GeneModelHandlers::GeneModelHandler");
}


ok(	my $gene_model_detector = Bio::RNASeq::GeneModelDetector->new(
	  filename => 't/data/gffs_sams/multipurpose_3_genes_mammal_gtf2gff3.gff'
	  ), 'Initialized object'
	  
);

ok( -e $gene_model_detector->filename, 'File should exist' );

throws_ok { Bio::RNASeq::GeneModelDetector->new( filename => 'non_existent.gff' ) } qr/Validation failed/, 'Throw exception if file doesnt exist';

isa_ok(	$gene_model_detector->gene_model_handler(), 'Bio::RNASeq::GeneModelHandlers::GeneModelHandler', 'Should be an instance of the class' );

isa_ok(	Bio::RNASeq::GeneModelDetector->new( filename => 't/data/gffs_sams/multipurpose_3_genes_mammal_gtf2gff3.gff' )->gene_model_handler(), 'Bio::RNASeq::GeneModelHandlers::EnsemblGeneModelHandler', 'An Ensembl GFF file should return an EnsemblGeneModelHandler' );

isa_ok(	Bio::RNASeq::GeneModelDetector->new( filename => 't/data/gffs_sams/multipurpose_3_cds_chado.gff' )->gene_model_handler(), 'Bio::RNASeq::GeneModelHandlers::ChadoGeneModelHandler', 'An Chado GFF file should return a ChadoGeneModelHandler' );


done_testing();
