package Bio::RNASeq::StandardProtocol::AlignmentSlice;

# ABSTRACT: Standard protocol, just inherits from the base class

=head1 SYNOPSIS
Standard protocol, just inherits from the base class
=cut

use Moose;
extends 'Bio::RNASeq::AlignmentSlice';

no Moose;
__PACKAGE__->meta->make_immutable;
1;
