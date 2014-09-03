#!/usr/bin/env perl
use Moose;
use Data::Dumper;
use File::Slurp;
use File::Path qw( remove_tree);
use Cwd;
use File::Temp;

BEGIN { unshift( @INC, './lib' ) }
BEGIN {
  use Test::Most;
  use Test::Output;
}

use_ok( 'Bio::RNASeq::CommandLine::GeneModelDetector' );

# test 1
my @args = qw( t/data/gffs_sams/multipurpose_3_cds_annot.gff t/data/gffs_sams/multipurpose_3_cds_chado.gff t/data/gffs_sams/multipurpose_3_cds_embl.gff t/data/gffs_sams/multipurpose_3_genes_mammal_gtf2gff3.gff t/data/gffs_sams/invalid_chado.gff t/data/gffs_sams/old_style_chado.gff);
my $obj = Bio::RNASeq::CommandLine::GeneModelDetector->new(args => \@args, script_name => 'which_gene_model');
my $exp_out = "t/data/gffs_sams/multipurpose_3_cds_annot.gff\tBacteria\nt/data/gffs_sams/multipurpose_3_cds_chado.gff\tChado\nt/data/gffs_sams/multipurpose_3_cds_embl.gff\tBacteria\nt/data/gffs_sams/multipurpose_3_genes_mammal_gtf2gff3.gff\tEnsembl\nt/data/gffs_sams/invalid_chado.gff\tInvalid\nt/data/gffs_sams/old_style_chado.gff\tOldChado\n";
my $arg_str = join(" ", @args);
stdout_is { $obj->run } $exp_out, "Correct results for '$arg_str'";

# test 2
@args = ( '-h' );
$obj = Bio::RNASeq::CommandLine::GeneModelDetector->new(args => \@args, script_name => 'which_gene_model');
$exp_out = read_file('t/data/expected_help_text_which_gene_model');
stdout_is { $obj->run } $exp_out, "Correct output for '-h'";

done_testing();
