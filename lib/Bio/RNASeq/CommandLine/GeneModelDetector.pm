package Bio::RNASeq::CommandLine::GeneModelDetector;

# ABSTRACT: Take in a list of GFF files and outputs the gene model they conform to
# PODNAME: which_gene_model

=head1 SYNOPSIS

This script takes in a list of GFF files and outputs the gene model each of them conform to

=cut

use Moose;
use Getopt::Long qw(GetOptionsFromArray);
use Bio::RNASeq::GeneModelDetector;

has 'args' => ( is => 'ro', isa => 'ArrayRef', required => 1 );
has 'script_name' => ( is => 'ro', isa => 'Str', required => 1 );
has 'help' => ( is => 'rw', isa => 'Bool', default => 0 );

sub BUILD {

	my ($self) =@_;
	
	my $help;

	GetOptionsFromArray(
	$self->args,
	'h|help'                                 => \$help,
    );

	$self->help($help) if ( defined($help) );
	
}

sub run {
	my ($self) = @_;
	
	if ($self->help) {  print <<USAGE;

which_gene_model 1.gff 2.gff	
Usage:
  -h|help                    <print this message>

This script takes in a list of GFF files and outputs the gene model each of them conform to.

USAGE
			  }
	my @files;
	for my $file( @{ $self->args } ) {

	  if ( -e $file ) {
	    push(@files, $file);
	  }
	  else {
	    print "$file\tUnavailable\n";
	  }

	}

	my %simplified_gff_gene_model_type = (
					      'Bio::RNASeq::GeneModelHandlers::ChadoGeneModelHandler' => 'Chado',
					      'Bio::RNASeq::GeneModelHandlers::CDSOnlyGeneModelHandler' => 'Bacteria',
					      'Bio::RNASeq::GeneModelHandlers::GeneModelHandler' => 'Invalid',
					      'Bio::RNASeq::GeneModelHandlers::EnsemblGeneModelHandler' => 'Ensembl',
					      'Bio::RNASeq::GeneModelHandlers::OldChadoFormatGeneModelHandler' => 'OldChado'
					     );

	for my $file( @files ) {

	  eval {
	    
	    my $gene_model_detector = Bio::RNASeq::GeneModelDetector->new( filename => $file );

	    print "$file\t" . $simplified_gff_gene_model_type{ $gene_model_detector->gene_model_handler()->meta->name } . "\n";   

	  };
	  print "$file\tError\n" if( $@ );
	}
}

1;
