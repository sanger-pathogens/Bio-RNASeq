package Bio::RNASeq::DeSeq::Parser::RNASeqOutput;

# ABSTRACT: Parses a list of expression files created by the RNASeq pipeline into a single file fit for running a DeSeq analysis on

=head1 SYNOPSIS


=cut

use Moose;
use List::MoreUtils qw(uniq);

has 'samples' => ( is => 'rw', isa => 'HashRef', required => 1 );
has 'read_count_a_index'   => ( is => 'rw', isa => 'Int', required => 1 );

has 'genes'   => ( is => 'rw', isa => 'ArrayRef' );
has 'exit_c' => ( is => 'rw', isa => 'Bool', default => 1 );

sub get_read_counts {

    my ($self) = @_;

    my @genes;
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
    }
    my @gene_universe = sort( uniq(@genes) );
    $self->genes( \@gene_universe );
}

1;

