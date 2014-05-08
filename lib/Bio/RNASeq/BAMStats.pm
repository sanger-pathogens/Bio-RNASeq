package Bio::RNASeq::BAMStats;

# ABSTRACT:  Functionality for Stats files for a BAM

=head1 SYNOPSIS

Functionality for Stats files for a BAM
	use Bio::RNASeq::BAMStats;
	my $bam_container = Bio::RNASeq::BAMStats->new(
	  filename => '/abc/my_file.bam'
	  );

=cut

use Moose;
use Bio::RNASeq::VertRes::Parser::bas;
use Bio::RNASeq::VertRes::Utils::Sam;
use Time::Format;

has 'total_mapped_reads' => ( is => 'rw', isa => 'Str', lazy_build   => 1 );
has '_parser'  => ( is => 'rw', isa => 'Bio::RNASeq::VertRes::Parser::bas', lazy_build   => 1 );

sub _build__parser
{
  my ($self) = @_;
  unless(-e $self->filename.'.bas')
  {
    $self->_create_stats_files();
  }
  
  Bio::RNASeq::VertRes::Parser::bas->new(file => $self->filename.'.bas');
}


sub _build_total_mapped_reads
{
  my ($self) = @_;
  $self->_parser->mapped_reads;
}

sub _create_stats_files
{
   my ($self) = @_;
   my $sam = Bio::RNASeq::VertRes::Utils::Sam->new();
   $sam->stats("$time{'yyyymmdd'}", $self->filename);
}


no Moose;
__PACKAGE__->meta->make_immutable;
1;
