package Bio::RNASeq::StrandSpecificProtocol::AlignmentSlice;

# ABSTRACT: Strand specific protocol, just inherits from the base class

=head1 SYNOPSIS
Strand specific protocol, just inherits from the base class
=cut

use Moose;
extends 'Bio::RNASeq::AlignmentSlice';

no Moose;
__PACKAGE__->meta->make_immutable;
1;
