package Bio::RNASeq::Types;

# ABSTRACT: Moose types to use for validation.

=head1 SYNOPSIS

Moose types to use for validation.

=cut

use Moose;
use Moose::Util::TypeConstraints;

subtype 'Bio::RNASeq::File',
  as 'Str',
  where { -e $_ };

subtype 'Bio::RNASeq::DeSeq::SamplesHashRef',
  as 'HashRef';

no Moose;
no Moose::Util::TypeConstraints;
__PACKAGE__->meta->make_immutable;
1;
