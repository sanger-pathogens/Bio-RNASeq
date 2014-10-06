package Bio::RNASeq::DeSeq::Parser::RNASeqOutput;

# ABSTRACT: Parses a list of expression files created by the RNASeq pipeline into a single file fit for running a DeSeq analysis on

=head1 SYNOPSIS


=cut

use Moose;
use List::MoreUtils qw(uniq);
use Bio::RNASeq::Types;
use Bio::RNASeq::Exceptions;
use Bio::RNASeq::DeSeq::Validate::RNASeqOutput;

has 'samples' => ( is => 'rw', isa => 'Bio::RNASeq::DeSeq::SamplesHashRef', required => 1 );
has 'read_count_a_index'   => ( is => 'rw', isa => 'Int', required => 1 );

has 'gene_universe'   => ( is => 'rw', isa => 'Bio::RNASeq::DeSeq::GeneUniverseArrayRef', lazy => 1, builder => '_build_gene_universe' );


sub _build_gene_universe {

    my ($self) = @_;

    my ($genes, $file_number) = $self->_set_gene_universe_for_samples();

    my $validator = Bio::RNASeq::DeSeq::Validate::RNASeqOutput->new(
								    file_number => $file_number,
								    genes => $genes,
								   );


    if( $validator->is_gene_universe_in_all_files() ) {

      my @gene_universe = sort( uniq(@$genes) );
      return( \@gene_universe );
    }
    else {

      Bio::RNASeq::Exceptions::InvalidGeneUniverse->throw( error => 'Invalid gene universe' );


    }
    
}

sub _set_gene_universe_for_samples {

  my ($self) = @_;

  my @genes;
  my $file_number = 0;
  for my $file ( keys $self->samples ) {

    open( my $fh, '<', $file );
    my $counter = 0;
    while ( my $line = <$fh> ) {
      if ( $counter > 0 ) {
	my @row = split( /,/, $line );
	$self->samples->{$file}->{read_counts}->{ $row[1] } = $row[$self->read_count_a_index];
	push( @genes, $row[1] );
      }
      $counter++;
    }
    $file_number++;
  }

  return(\@genes, $file_number);

}

no Moose;
__PACKAGE__->meta->make_immutable;
1;

