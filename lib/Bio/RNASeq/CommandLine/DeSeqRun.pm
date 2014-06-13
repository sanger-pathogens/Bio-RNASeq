package Bio::RNASeq::CommandLine::DeSeqRun;

# ABSTRACT: Run DeSeq analysis given a list of samples and their corresponding expression values

=head1 SYNOPSIS


=cut

use Moose;
use Getopt::Long qw(GetOptionsFromArray);
use Bio::DeSeq;

has 'args'        => ( is => 'ro', isa => 'ArrayRef', required => 1 );
has 'script_name' => ( is => 'ro', isa => 'Str',      required => 1 );
has 'help'        => ( is => 'rw', isa => 'Bool',     default  => 0 );

has 'samples_file' => ( is => 'rw', isa => 'Str' );
has 'deseq_file'   => ( is => 'rw', isa => 'Str' );
has 'read_count_a_index'   => ( is => 'rw', isa => 'Int', default => 1 );

sub BUILD {

    my ($self) = @_;

    my ( $samples_file, $deseq_file, $expression_file_column, $help );

    GetOptionsFromArray(
			$self->args,
			'i|input=s' => \$samples_file,
			'o|output=s'   => \$deseq_file,
			'c|column:i' =>\$expression_file_column,
			'h|help'           => \$help,
    );

    $self->samples_file($samples_file) if ( defined($samples_file) );
    $self->deseq_file($deseq_file)     if ( defined($deseq_file) );
    $self->read_count_a_index($expression_file_column - 1)     if ( defined($expression_file_column) );

}

sub run {
    my ($self) = @_;

    ( $self->samples_file && $self->deseq_file ) or die <<USAGE;
	
Usage:

  -i|input         <A file with the list of samples to analyse and their corresponding files of expression values in the format ("filepath","condition","replicate","lib_type"). lib_type defaults to paried-end if not specified on the samples file>

  -o|output        <The name of the file that will be used as the DeSeq analysis input. NOTE - The file will be writen wherever you're running deseq_run from>

  -c|column        <Optional: Number of the column you want to use as your read count from your expression files. Defaults to the second column in the expression file if no value is specified> 

  -h|help          <print this message>


USAGE

    my $deseq_setup = Bio::DeSeq->new(
				      samples_file => $self->samples_file,
				      deseq_file   => $self->deseq_file,
				      read_count_a_index => $self->read_count_a_index,
				     );

    $deseq_setup->run;
   

}

1;
