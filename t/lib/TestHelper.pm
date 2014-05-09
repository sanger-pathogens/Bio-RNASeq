package TestHelper;
use Moose::Role;
use Test::Most;
use File::Slurp;
use Data::Dumper;

sub mock_execute_script_and_check_output {
    my ( $script_name, $scripts_and_expected_files ) = @_;

    system('touch empty_file');
    open OLDOUT, '>&STDOUT';
    open OLDERR, '>&STDERR';
    eval("use $script_name ;");
    my $returned_values = 0;
    {
        local *STDOUT;
        open STDOUT, '>/dev/null' or warn "Can't open /dev/null: $!";
        local *STDERR;
        open STDERR, '>/dev/null' or warn "Can't open /dev/null: $!";

        for my $script_parameters ( sort keys %$scripts_and_expected_files ) {
            my $full_script = $script_parameters;
            my @input_args = split( " ", $full_script );

            my $cmd =
"$script_name->new(args => \\\@input_args, script_name => '$script_name')->run;";
            eval($cmd);
            warn $@ if $@;
            my $actual_output_file_name =
              $scripts_and_expected_files->{$script_parameters}->[0];
            my $expected_output_file_name =
              $scripts_and_expected_files->{$script_parameters}->[1];
			  print "$actual_output_file_name\n";

            ok( -e $actual_output_file_name,
                "Actual output file exists $actual_output_file_name" );

				
            unlink($actual_output_file_name);
        }
        close STDOUT;
        close STDERR;
    }

    # Restore stdout.
    open STDOUT, '>&OLDOUT' or die "Can't restore stdout: $!";
    open STDERR, '>&OLDERR' or die "Can't restore stderr: $!";

    # Avoid leaks by closing the independent copies.
    close OLDOUT or die "Can't close OLDOUT: $!";
    close OLDERR or die "Can't close OLDERR: $!";
    unlink('empty_file');

}

1;