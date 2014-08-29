package Bio::RNASeq::GeneModelDetector;

# ABSTRACT:  Detects gene models given a GFF file and decides how a gene model is represented

=head1 SYNOPSIS
Detects gene models given a GFF file and decides how a gene model is represented
	use Bio::RNASeq::GeneModelDetector;
	my $gene_model_detector = Bio::RNASeq::GeneModelDetector->new(
	  filename => 'my_file.gff'
	  );
	  
	$gene_model_detector->gene_model_handler();

=cut

use Moose;
use Bio::Tools::GFF;
use Bio::RNASeq::Feature;
use Bio::RNASeq::Exceptions;
use Bio::RNASeq::Types;
use Bio::RNASeq::GeneModelHandlers::GeneModelHandler;
use Bio::RNASeq::GeneModelHandlers::EnsemblGeneModelHandler;
use Bio::RNASeq::GeneModelHandlers::ChadoGeneModelHandler;
use Bio::RNASeq::GeneModelHandlers::CDSOnlyGeneModelHandler;
use Bio::RNASeq::GeneModelHandlers::OldChadoFormatGeneModelHandler;


has 'filename'          => ( is => 'rw', isa => 'Bio::RNASeq::File',             required   => 1 );
has 'gene_model_handler' => (is => 'rw', isa => 'Bio::RNASeq::GeneModelHandlers::GeneModelHandler', lazy => 1, builder => '_build_gene_model_handler' );
has '_maximum_number_of_features'  => (is => 'rw', isa => 'Int', default => 100 );

sub _build_gene_model_handler {

    my ($self) = @_;

    
    if ( $self->_is_ensembl_gff() ) {
      return Bio::RNASeq::GeneModelHandlers::EnsemblGeneModelHandler->new();
    }
    elsif ( $self->_is_chado_gff() ) {
      return Bio::RNASeq::GeneModelHandlers::ChadoGeneModelHandler->new();
    }
    elsif ( $self->_is_old_chado_format_gff() ) {
      return Bio::RNASeq::GeneModelHandlers::OldChadoFormatGeneModelHandler->new();
    }
    elsif ( $self->_is_cds_only_gff() ) {
      return Bio::RNASeq::GeneModelHandlers::CDSOnlyGeneModelHandler->new();
    }    
    else {
      return Bio::RNASeq::GeneModelHandlers::GeneModelHandler->new();
    }

}


sub _is_ensembl_gff {

  my ($self) = @_;

  my ( $gene_id, $mrna_id, $mrna_parent, $exon_parent, @junk );

  my $number_of_features = 0;
  my $gff_parser = Bio::Tools::GFF->new(-gff_version => 3, -file => $self->filename);
  while ( my $gene_feature = $gff_parser->next_feature() ) {

    $number_of_features++;
    return 0 if ( $number_of_features > $self->_maximum_number_of_features() );

    next unless ( $gene_feature->primary_tag eq 'gene' );
    next unless ( $gene_feature->has_tag('ID') );

    ($gene_id, @junk) = $gene_feature->get_tag_values('ID');

    while ( my $mrna_feature = $gff_parser->next_feature() ) {

      $number_of_features++;
      return 0 if ( $number_of_features > $self->_maximum_number_of_features() );

      next unless ( $mrna_feature->primary_tag eq 'mRNA' );
      next unless ( $mrna_feature->has_tag('ID') && $mrna_feature->has_tag('Parent') );

      ($mrna_parent, @junk) = $mrna_feature->get_tag_values('Parent');
      ($mrna_id, @junk) = $mrna_feature->get_tag_values('ID');

      next unless( $gene_id eq $mrna_parent );

      while ( my $exon_feature = $gff_parser->next_feature() ) {

	$number_of_features++;
	return 0 if ( $number_of_features > $self->_maximum_number_of_features() );

	next unless ( $exon_feature->primary_tag eq 'exon' );
	next unless ( $exon_feature->has_tag('Parent') );
	
	($exon_parent, @junk) = $exon_feature->get_tag_values('Parent');
	
	next unless( $mrna_id eq $exon_parent );
	return 1;
      }
    }
  }
  
  return 0;
}

sub _is_chado_gff {

    my ($self) = @_;

    my ( $gene_id, $mrna_id, $mrna_parent, $cds_parent, @junk );

    my $number_of_features = 0;
    my $gff_parser =
      Bio::Tools::GFF->new( -gff_version => 3, -file => $self->filename );
    while ( my $gene_feature = $gff_parser->next_feature() ) {

        $number_of_features++;
        return 0
          if ( $number_of_features > $self->_maximum_number_of_features() );

        next unless ( $gene_feature->primary_tag eq 'gene' );
        next unless ( $gene_feature->has_tag('ID') );

        ( $gene_id, @junk ) = $gene_feature->get_tag_values('ID');

        while ( my $mrna_feature = $gff_parser->next_feature() ) {

            $number_of_features++;
            return 0
              if ( $number_of_features > $self->_maximum_number_of_features() );

            next unless ( $mrna_feature->primary_tag eq 'mRNA' );
            next
              unless ( $mrna_feature->has_tag('ID')
                && $mrna_feature->has_tag('Parent') );

            ( $mrna_parent, @junk ) = $mrna_feature->get_tag_values('Parent');
            ( $mrna_id,     @junk ) = $mrna_feature->get_tag_values('ID');

            next unless ( $gene_id eq $mrna_parent );

            while ( my $cds_feature = $gff_parser->next_feature() ) {

                $number_of_features++;
                return 0
                  if ( $number_of_features >
                    $self->_maximum_number_of_features() );

                next unless ( $cds_feature->primary_tag eq 'CDS' );
                next unless ( $cds_feature->has_tag('Parent') );

                ( $cds_parent, @junk ) = $cds_feature->get_tag_values('Parent');

                next unless ( $mrna_id eq $cds_parent );
                return 1;
            }
        }
    }

    return 0;
}

sub _is_cds_only_gff {

    my ($self) = @_;

    my %feature_type_count;

    my $number_of_features = 0;
    my $gff_parser =
      Bio::Tools::GFF->new( -gff_version => 3, -file => $self->filename );
    while ( my $feature = $gff_parser->next_feature() ) {
        $number_of_features++;
        last if ( $number_of_features > $self->_maximum_number_of_features() );

        $feature_type_count{ $feature->primary_tag }++;

    }

    if ( defined($feature_type_count{'gene'}) || defined($feature_type_count{'mRNA'}) || defined($feature_type_count{'exon'}) ) {
      return 0;
    }
    elsif( defined($feature_type_count{'CDS'}) && $feature_type_count{'CDS'} > 0 )
    {
        return 1;
    }
    else {
      return 0;
    }
    

}

sub _is_old_chado_format_gff {

    my ($self) = @_;

    my ( $cds_id, $next_cds_parent, @junk );

    my $number_of_features = 0;
    my $gff_parser =
      Bio::Tools::GFF->new( -gff_version => 3, -file => $self->filename );
    while ( my $cds_feature = $gff_parser->next_feature() ) {

      $number_of_features++;
      return 0
	if ( $number_of_features > $self->_maximum_number_of_features() );

      next unless ( $cds_feature->primary_tag eq 'CDS' );
      next unless ( $cds_feature->has_tag('ID') );
      next if ( $cds_feature->has_tag('Parent') );

      ( $cds_id, @junk ) = $cds_feature->get_tag_values('ID');

      while ( my $next_cds_feature = $gff_parser->next_feature() ) {

	$number_of_features++;
	return 0
	  if ( $number_of_features >
	       $self->_maximum_number_of_features() );

	next unless ( $next_cds_feature->primary_tag eq 'CDS' );
	next unless ( $next_cds_feature->has_tag('Parent') );

	( $next_cds_parent, @junk ) = $next_cds_feature->get_tag_values('Parent');

	next unless ( $cds_id eq $next_cds_parent );
	return 1;
      }
    }
}


no Moose;
__PACKAGE__->meta->make_immutable;
1;
