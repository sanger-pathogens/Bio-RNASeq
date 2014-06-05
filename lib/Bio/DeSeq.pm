package Bio::DeSeq;

use Moose;
use Bio::RNASeq::DeSeq::Parser::SamplesFile;
use Bio::RNASeq::DeSeq::Parser::RNASeqOutput;
use Data::Dumper;

has 'samples_file' => ( is => 'rw', isa => 'Str', required => 1 );
has 'deseq_file'   => ( is => 'rw', isa => 'Str', required => 1 );

has 'samples' => ( is => 'rw', isa => 'HashRef' );
has 'genes'   => ( is => 'rw', isa => 'ArrayRef' );

sub set_deseq {

    my ($self) = @_;

    my $parser =
      Bio::RNASeq::DeSeq::Parser::SamplesFile->new(
        samples_file => $self->samples_file );

    $self->samples( $parser->parse() );

    my $rso =
      Bio::RNASeq::DeSeq::Parser::RNASeqOutput->new(
        samples => $self->samples );

    $rso->get_read_counts();

    $self->samples( $rso->samples );
    $self->genes( $rso->genes );
}

sub write_deseq_input_file {

    my ($self) = @_;

	#print Dumper($self);
    open( my $fh, '>', './' . $self->deseq_file );

    my $file_content = "gene_id\t";

    for my $file ( sort keys $self->samples ) {

        $file_content .= $self->samples->{$file}->{condition}
          . $self->samples->{$file}->{replicate} . "\t";

    }
	$file_content =~ s/\t$//;
    $file_content .= "\n";

    for my $gene ( @{ $self->genes } ) {

        $file_content .= "$gene\t";

        for my $file ( sort keys $self->samples ) {

            $file_content .=
              $self->samples->{$file}->{read_counts}->{$gene} . "\t";

        }
		$file_content =~ s/\t$//;
        $file_content .= "\n";
    }

    print $fh "$file_content";

    close($fh);
}

no Moose;
__PACKAGE__->meta->make_immutable;
1;
