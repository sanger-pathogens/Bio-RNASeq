package Bio::DeSeq;

use Moose;
use List::MoreUtils qw(uniq);

has 'samples_file' => ( is => 'rw', isa => 'Str', required => 1 );
has 'deseq_file'   => ( is => 'rw', isa => 'Str', required => 1 );

has 'samples'            => ( is => 'rw', isa => 'HashRef' );
has 'content'            => ( is => 'rw', isa => 'HashRef' );
has 'valid_samples_file' => ( is => 'rw', isa => 'Bool' );
has 'deseq_setup'        => ( is => 'rw', isa => 'HashRef' );

sub set_deseq {

    my ($self) = @_;

    $self->_validate_samples_file();

    return;
}

sub _validate_samples_file {

    my ($self) = @_;
    if ( -e $self->samples_file ) {

        $self->_check_content_set_samples();
        for my $file ( keys %{ $self->content } ) {
            unless ( $file eq 'conditions' ) {
                my $samples_file = $self->samples_file;
                if (   $self->content->{conditions} == 2
                    && $self->content->{$file}->{exists}
                    && $self->content->{$file}->{condition}
                    && $self->content->{$file}->{replicate} )
                {
                    $self->valid_samples_file(1);

                }
                else {
                    $self->valid_samples_file(0);
                }
            }
        }
        return;
    }
}

sub _check_content_set_samples {

    my ($self) = @_;

    my %samples;
    my %content;
    my @condition_validation;

    open( my $sf_fh, '<', $self->samples_file );

    while ( my $line = <$sf_fh> ) {

        my @data = split( /,/, $line );

        if ( defined $data[0] ) {

            if ( -e $data[0] ) {

                $content{ $data[0] }{exists} = 1;

                if ( defined $data[1] ) {

                    $samples{ $data[0] }{condition} = $data[1];
                    $content{ $data[0] }{condition} = 1;
                    push( @condition_validation, $data[1] );

                }
                else {

                    $samples{ $data[0] }{condition} = 'undefined';
                    $content{ $data[0] }{condition} = 0;
                    push( @condition_validation, 'undefined' );

                }

                if ( defined $data[2] ) {
                    if ( $data[2] =~ m/\d+/ ) {

                        $samples{ $data[0] }{replicate} = $data[2];
                        $content{ $data[0] }{replicate} = 1;
                    }
                    else {

                        $samples{ $data[0] }{replicate} =
                          'not a positive integer';
                        $content{ $data[0] }{replicate} = 0;

                    }
                }
                else {

                    $samples{ $data[0] }{replicate} = 'undefined';
                    $content{ $data[0] }{replicate} = 0;

                }
            }
            else {

                $samples{ $data[0] }{condition} = 'NA';
                $samples{ $data[0] }{replicate} = 'NA';

                $content{ $data[0] }{exists}    = 0;
                $content{ $data[0] }{condition} = 0;
                $content{ $data[0] }{replicate} = 0;

                push( @condition_validation, 'NA' );

            }
        }
        else {

            $samples{'mock_filename'}{condition} = 'NA';
            $samples{'mock_filename'}{replicate} = 'NA';

            $content{'mock_filename'}{exists}    = 0;
            $content{'mock_filename'}{condition} = 0;
            $content{'mock_filename'}{replicate} = 0;

        }
    }
    close($sf_fh);

    my @unique_conditions = uniq(@condition_validation);

    if ( scalar @unique_conditions == 2 ) {
        $content{conditions} = 2;
    }
    elsif ( scalar @unique_conditions > 2 ) {
        $content{conditions} = 3;
    }
    else {
        unless ( scalar @unique_conditions == 0 ) {
            $content{conditions} = 1;
        }
        else {
            $content{conditions} = 0;
        }
    }

    $self->samples( \%samples );
    $self->content( \%content );

    return;
}

1;
