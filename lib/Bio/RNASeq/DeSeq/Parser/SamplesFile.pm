package Bio::RNASeq::DeSeq::Parser::SamplesFile;

use Moose;
use Bio::RNASeq::DeSeq::Validate::Samples;



has 'samples'            => ( is => 'rw', isa => 'HashRef' );
has 'content'            => ( is => 'rw', isa => 'HashRef' );
has 'valid_samples_file' => ( is => 'rw', isa => 'Bool' );




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

	my $undefined_filename_counter = 1;
    while ( my $line = <$sf_fh> ) {
		$line =~ s/\n//;
        my @data = split( /,/, $line );

        if ( defined $data[0] && $data[0] ne q// ) {

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

                if ( defined $data[2] && $data[2] ne q// ) {
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
			my $filename = "mock_$undefined_filename_counter";
            $samples{$filename}{condition} = 'NA';
            $samples{$filename}{replicate} = 'NA';

            $content{$filename}{exists}    = 0;
            $content{$filename}{condition} = 0;
            $content{$filename}{replicate} = 0;
			
			$undefined_filename_counter++;
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