package Bio::DeSeq;

use Moose;
use Bio::RNASeq::DeSeq::Parser::SamplesFile;
use Bio::RNASeq::DeSeq::Parser::RNASeqOutput;

has 'samples_file' => ( is => 'rw', isa => 'Str', required => 1 );
has 'deseq_file'   => ( is => 'rw', isa => 'Str', required => 1 );

has 'samples'  => ( is => 'rw', isa => 'HashRef' );
has 'genes'    => ( is => 'rw', isa => 'ArrayRef' );
has 'deseq_fh' => ( is => 'rw', isa => 'FileHandle' );

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

    $self->deseq_fh($fh);
}

no Moose;
__PACKAGE__->meta->make_immutable;
1;
