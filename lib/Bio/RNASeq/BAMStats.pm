=head1 NAME

BAMStats.pm   - Functionality for Stats files for a BAM

=head1 SYNOPSIS

use Bio::RNASeq::BAM;
my $bam_container = Bio::RNASeq::BAM->new(
  filename => '/abc/my_file.bam'
  );

=cut
package Bio::RNASeq::BAMStats;
use Moose;
use Bio::RNASeq::VertRes::Parser::bas;
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

1;
