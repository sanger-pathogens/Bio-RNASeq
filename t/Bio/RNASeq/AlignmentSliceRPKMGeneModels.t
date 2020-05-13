#!/usr/bin/env perl
use strict;
use warnings;
use Data::Dumper;

BEGIN {
    use Test::Most;
    use_ok('Bio::RNASeq::AlignmentSliceRPKMGeneModel');
}
use Bio::RNASeq::GFF;

done_testing();

