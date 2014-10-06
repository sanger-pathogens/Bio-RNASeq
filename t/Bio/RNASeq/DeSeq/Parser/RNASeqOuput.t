#!/usr/bin/env perl
use Moose;
use Data::Dumper;
use File::Slurp;
use File::Path qw( remove_tree);
use Cwd;

BEGIN { unshift( @INC, './lib' ) }
BEGIN { unshift( @INC, './t/lib' ) }
with 'TestHelper';

BEGIN {
    use Test::Most;
    use_ok('Bio::RNASeq::DeSeq::Parser::RNASeqOutput');

}

my $read_count_a_index = 5;

my ($valid_initial_samples, $valid_final_samples ) = load_valid_data_structures();

ok(
    my $valid_rna_seq_output = Bio::RNASeq::DeSeq::Parser::RNASeqOutput->new(
        samples            => $valid_initial_samples,
        read_count_a_index => $read_count_a_index
    ),
    'Valid object initialised'
);


$valid_rna_seq_output->gene_universe();

is_deeply(
    $valid_rna_seq_output->gene_universe(),
    [
        'Armor', 'Beast',   'Firestar',     'Iceman',
        'M',     'Magneto', 'Nightcrawler', 'Rogue',
        'Wolverine'
    ],
    'Valid samples gene universe'
);

is_deeply($valid_rna_seq_output->samples(), $valid_final_samples, 'Valid samples final samples');


my ($invalid_initial_samples ) = load_invalid_data_structures();

ok(
    my $invalid_rna_seq_output = Bio::RNASeq::DeSeq::Parser::RNASeqOutput->new(
        samples            => $invalid_initial_samples,
        read_count_a_index => $read_count_a_index
    ),
    'Invalid object initialised'
);

throws_ok { $invalid_rna_seq_output->gene_universe() } qr/Invalid gene universe/, 'Throw exception if gene universe is different for the files specified in the samples file';


done_testing();



sub load_valid_data_structures {

    my %initial_samples = (
        't/data/rna_seq_output_files/u2_expression.csv' => {
            'lib_type'  => 'paired-end',
            'replicate' => '2',
            'condition' => 'untreated'
        },
        't/data/rna_seq_output_files/t1_expression.csv' => {
            'lib_type'  => 'paired-end',
            'replicate' => '1',
            'condition' => 'treated'
        },
        't/data/rna_seq_output_files/t3_expression.csv' => {
            'lib_type'  => 'paired-end',
            'replicate' => '3',
            'condition' => 'treated'
        },
        't/data/rna_seq_output_files/u1_expression.csv' => {
            'lib_type'  => 'paired-end',
            'replicate' => '1',
            'condition' => 'untreated'
        },
        't/data/rna_seq_output_files/t2_expression.csv' => {
            'lib_type'  => 'paired-end',
            'replicate' => '2',
            'condition' => 'treated'
        }
    );

    my %valid_final_samples = (
        't/data/rna_seq_output_files/u2_expression.csv' => {
            'lib_type'    => 'paired-end',
            'replicate'   => '2',
            'read_counts' => {
                'Nightcrawler' => '46.5466006412446',
                'Firestar'     => '14.7319621807429',
                'Wolverine'    => '1.96941356051477',
                'Iceman'       => '78.6863726642518',
                'Beast'        => '10.1612204266444',
                'Magneto'      => '31.924579093194',
                'Rogue'        => '33.5006053678341',
                'M'            => '5.84368831067064',
                'Armor'        => '23.1478205875585'
            },
            'condition' => 'untreated'
        },
        't/data/rna_seq_output_files/t1_expression.csv' => {
            'lib_type'    => 'paired-end',
            'replicate'   => '1',
            'read_counts' => {
                'Nightcrawler' => '10.1612204266444',
                'Firestar'     => '33.5006053678341',
                'Wolverine'    => '23.1478205875585',
                'Iceman'       => '78.6863726642518',
                'Beast'        => '46.5466006412446',
                'Magneto'      => '5.84368831067064',
                'Rogue'        => '14.7319621807429',
                'M'            => '31.924579093194',
                'Armor'        => '1.96941356051477'
            },
            'condition' => 'treated'
        },
        't/data/rna_seq_output_files/t3_expression.csv' => {
            'lib_type'    => 'paired-end',
            'replicate'   => '3',
            'read_counts' => {
                'Nightcrawler' => '10.1612204266444',
                'Firestar'     => '33.5006053678341',
                'Wolverine'    => '23.1478205875585',
                'Iceman'       => '78.6863726642518',
                'Beast'        => '46.5466006412446',
                'Magneto'      => '5.84368831067064',
                'Rogue'        => '14.7319621807429',
                'M'            => '31.924579093194',
                'Armor'        => '1.96941356051477'
            },
            'condition' => 'treated'
        },
        't/data/rna_seq_output_files/u1_expression.csv' => {
            'lib_type'    => 'paired-end',
            'replicate'   => '1',
            'read_counts' => {
                'Nightcrawler' => '31.924579093194',
                'Firestar'     => '46.5466006412446',
                'Wolverine'    => '1.96941356051477',
                'Iceman'       => '10.1612204266444',
                'Beast'        => '33.5006053678341',
                'Magneto'      => '14.7319621807429',
                'Rogue'        => '5.84368831067064',
                'M'            => '78.6863726642518',
                'Armor'        => '23.1478205875585'
            },
            'condition' => 'untreated'
        },
        't/data/rna_seq_output_files/t2_expression.csv' => {
            'lib_type'    => 'paired-end',
            'replicate'   => '2',
            'read_counts' => {
                'Nightcrawler' => '10.1612204266444',
                'Firestar'     => '33.5006053678341',
                'Wolverine'    => '23.1478205875585',
                'Iceman'       => '78.6863726642518',
                'Beast'        => '46.5466006412446',
                'Magneto'      => '5.84368831067064',
                'Rogue'        => '14.7319621807429',
                'M'            => '31.924579093194',
                'Armor'        => '1.96941356051477'
            },
            'condition' => 'treated'
        }
    );

    return( \%initial_samples, \%valid_final_samples );
}


sub load_invalid_data_structures {


    my %initial_samples = (
        't/data/rna_seq_output_files/diff_gene_universe_t_1_expression.csv' => {
            'lib_type'  => 'paired-end',
            'replicate' => '2',
            'condition' => 'untreated'
        },
        't/data/rna_seq_output_files/diff_gene_universe_t_2_expression.csv' => {
            'lib_type'  => 'paired-end',
            'replicate' => '1',
            'condition' => 'treated'
        },
        't/data/rna_seq_output_files/diff_gene_universe_t_3_expression.csv' => {
            'lib_type'  => 'paired-end',
            'replicate' => '3',
            'condition' => 'treated'
        },
        't/data/rna_seq_output_files/diff_gene_universe_u_1_expression.csv' => {
            'lib_type'  => 'paired-end',
            'replicate' => '1',
            'condition' => 'untreated'
        },
        't/data/rna_seq_output_files/diff_gene_universe_u_2_expression.csv' => {
            'lib_type'  => 'paired-end',
            'replicate' => '2',
            'condition' => 'treated'
        }
    );

    return( \%initial_samples);

}
