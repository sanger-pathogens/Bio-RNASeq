#!/usr/bin/env perl
use strict;
use warnings;
use Data::Dumper;

BEGIN { unshift( @INC, './lib' ) }

BEGIN {
    use Test::Most;
    use_ok('Bio::RNASeq::AlignmentSliceRPKMGeneModel');
}
use Bio::RNASeq::GFF;

ok( 0, 'Fix me please! - RT Ticket 417421' );

done_testing();

