package gffTestHelper;
use Moose::Role;
use Test::Most;
use File::Compare;
use Data::Dumper;
use File::Slurp;
use File::Path qw( remove_tree);
use File::Spec;
use File::Temp qw/ tempdir /;
use Text::CSV;
use Cwd;

BEGIN { unshift( @INC, './lib' ) }
BEGIN { unshift( @INC, './t/lib' ) }

BEGIN {
    use Bio::RNASeq::CommandLine::RNASeqExpression;
}

our $debug = 0;

sub _run_rna_seq {

    my ( $sam_file, $annotation_file, $results_library, $protocol, $chromosome,
        $test_name, $intergenic_regions )
      = @_;

    open OLDOUT, '>&STDOUT';
    open OLDERR, '>&STDERR';

    {

        my $redirect_str_stout = '>/dev/null';
        my $redirect_str_sterr = $redirect_str_stout;

        $redirect_str_stout = '>&OLDOUT' if ($debug);
        $redirect_str_sterr = '>&OLDERR' if ($debug);

        local *STDOUT;
        open STDOUT, $redirect_str_stout
          or warn "Can't open $redirect_str_stout: $!";
        local *STDERR;
        open STDERR, $redirect_str_sterr
          or warn "Can't open $redirect_str_sterr: $!";

        my $bam_file = $sam_file;
        $bam_file =~ s/sam$/bam/;
        unlink($bam_file) if ( -e $bam_file );

        `samtools view -bS $sam_file 2>/dev/null > $bam_file`;

        my $file_temp_obj = File::Temp->newdir(
            DIR     => File::Spec->curdir(),
            CLEANUP => ( $debug ? 0 : 1 )
        );

        my $output_base_filename = $file_temp_obj->dirname() . '/test_';

        print( $file_temp_obj->dirname(), "\n" ) if ($debug);

        ( $intergenic_regions ? 0 : 1 );

        my %filters = ( mapping_quality => 1 );

        ok(
            my $expression_results = Bio::RNASeq->new(
                sequence_filename    => $bam_file,
                annotation_filename  => $annotation_file,
                window_margin        => 0,
                filters              => \%filters,
                protocol             => $protocol,
                output_base_filename => $output_base_filename,
                intergenic_regions   => $intergenic_regions,
            ),
            $test_name . ' expression_results object creation'
        );

        ok( $expression_results->output_spreadsheet(),
            $test_name . ' expression results spreadsheet creation' );

        ok( -e $output_base_filename . '.corrected.bam',
            $test_name . ' corrected bam' );
        ok( -e $output_base_filename . '.corrected.bam.bai',
            $test_name . ' corrected bai' );

        ok(
            -e $output_base_filename
              . ".corrected.bam.intergenic.$chromosome.tab.gz",
            'intergenic gz'
        ) unless ( $intergenic_regions == 0 );

        ok(
            -e $output_base_filename . '.expression.csv',
            $test_name . ' expression results'
        );

        my $filename = $output_base_filename . '.expression.csv';

        for my $set_of_expected_results (@$results_library) {
            parseExpressionResultsFile( $filename, $set_of_expected_results,
                $test_name );
        }

        close STDOUT;
        close STDERR;
        unlink($bam_file);
    }

    ## Restore stdout.
    open STDOUT, '>&OLDOUT' or die "Can't restore stdout: $!";
    open STDERR, '>&OLDERR' or die "Can't restore stderr: $!";

    # Avoid leaks by closing the independent copies.
    close OLDOUT or die "Can't close OLDOUT: $!";
    close OLDERR or die "Can't close OLDERR: $!";

}

sub _run_rna_seq_check_non_existence_of_a_feature {

    my ( $sam_file, $annotation_file, $feature_names, $protocol, $test_name, $intergenic_regions ) = @_;


    open OLDOUT, '>&STDOUT';
    open OLDERR, '>&STDERR';

    {

      my $redirect_str_stout = '>/dev/null';
      my $redirect_str_sterr = $redirect_str_stout;

      $redirect_str_stout = '>&OLDOUT' if($debug);
      $redirect_str_sterr = '>&OLDERR' if($debug);


        local *STDOUT;
        open STDOUT, $redirect_str_stout or warn "Can't open $redirect_str_stout: $!";
        local *STDERR;
      open STDERR, $redirect_str_sterr or warn "Can't open $redirect_str_sterr: $!";

        my $bam_file = $sam_file;
        $bam_file =~ s/sam$/bam/;
        unlink($bam_file) if ( -e $bam_file );

        `samtools view -bS $sam_file 2>/dev/null > $bam_file`;

      
        my $file_temp_obj =
          File::Temp->newdir( DIR => File::Spec->curdir(), CLEANUP => ($debug ? 0 : 1) );

        my $output_base_filename = $file_temp_obj->dirname() . '/test_';

      print ($file_temp_obj->dirname(), "\n") if($debug);

      ( $intergenic_regions ? 0 : 1 );

        my %filters = ( mapping_quality => 1 );


        ok(
            my $expression_results = Bio::RNASeq->new(
                sequence_filename    => $bam_file,
                annotation_filename  => $annotation_file,
                filters              => \%filters,
                protocol             => $protocol,
                output_base_filename => $output_base_filename,
                intergenic_regions   => $intergenic_regions,
            ),
            $test_name . ' expression_results object creation'
        );

        ok( $expression_results->output_spreadsheet(),
            $test_name . ' expression results spreadsheet creation' );

        my $filename = $output_base_filename . '.expression.csv';

        ok(
            -e $filename,
            $test_name . ' expression results'
        );


        for my $feature_name (@$feature_names) {
	  my $file_content = read_file($filename);
	  ok ( !( $file_content =~ m/$feature_name/ ), "$test_name - $feature_name shouldn't exist" );
        }

        close STDOUT;
        close STDERR;
        unlink($bam_file);
    }

    ## Restore stdout.
    open STDOUT, '>&OLDOUT' or die "Can't restore stdout: $!";
    open STDERR, '>&OLDERR' or die "Can't restore stderr: $!";

    # Avoid leaks by closing the independent copies.
    close OLDOUT or die "Can't close OLDOUT: $!";
    close OLDERR or die "Can't close OLDERR: $!";

}

sub run_rna_seq {
  
  my ( $sam_file, $annotation_file, $results_library, $chromosome, $test_name, $intergenic_regions ) = @_;
  return _run_rna_seq( $sam_file, $annotation_file, $results_library, 'StandardProtocol', $chromosome, $test_name, $intergenic_regions );

}

sub run_rna_seq_strand_specific {

  my ( $sam_file, $annotation_file, $results_library, $chromosome, $test_name, $intergenic_regions ) = @_;
  return _run_rna_seq( $sam_file, $annotation_file, $results_library, 'StrandSpecificProtocol', $chromosome, $test_name, $intergenic_regions );

}

sub run_rna_seq_check_non_existence_of_a_feature {

  my ( $sam_file, $annotation_file, $feature_names, $test_name, $intergenic_regions ) = @_;
  return _run_rna_seq_check_non_existence_of_a_feature( $sam_file, $annotation_file, $feature_names, 'StandardProtocol', $test_name, $intergenic_regions );
}

sub run_rna_seq_check_non_existence_of_a_feature_strand_specific {

  my ( $sam_file, $annotation_file, $feature_names, $test_name, $intergenic_regions ) = @_;
  return _run_rna_seq_check_non_existence_of_a_feature( $sam_file, $annotation_file, $feature_names, 'StrandSpecificProtocol', $test_name, $intergenic_regions );

}


sub parseExpressionResultsFile {

    my ( $filename, $set_of_expected_results, $test_name ) = @_;

    my $csv = Text::CSV->new();
    open( my $fh, "<:encoding(utf8)", $filename ) or die("$filename: $!");

    my $headers = $csv->getline($fh);

    my $column_index = 0;
    for my $header (@$headers) {

        if ( $header eq $set_of_expected_results->[1] ) {
            last;
        }
        $column_index++;
    }

    while ( my $row = $csv->getline($fh) ) {
        unless ( $row->[1] eq $set_of_expected_results->[0] ) {
            next;
        }
        is( $row->[$column_index], $set_of_expected_results->[2],
            $test_name
              . " - match $set_of_expected_results->[1] - $set_of_expected_results->[0]"
        );
        last;
    }
    $csv->eof or $csv->error_diag();
    close $fh;

}

1;
