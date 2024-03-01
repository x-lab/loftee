#!/usr/local/bin/perl 

use strict;
use warnings;

use Test::More;

use FindBin qw($Bin);
use FindBin;
use lib $FindBin::RealBin;
use lib '/refs/loftee';

use LoF;
use TestingConfig;

## METHOD_TESTS
###############
# use_test
use_ok('LoF');
use_ok('Bio::EnsEMBL::VEP::OutputFactory');
use_ok('Bio::EnsEMBL::VEP::Runner');

## METHOD_TESTS
###############
# SpliceAI
my $runner0 = TestingConfig::get_annotated_buffer_runner({
    input_file => './testdata/spliceAI/spliceAI.vcf'
});

my $result0 = TestingConfig::get_LoF_plugin($runner0);
is_deeply(
    $result0->{'LoF_info'},
    'SpliceAI=A|TTLL10|0.00|0.00|0.01|0.09|2|-11|12|-11'
);

# Pangolin
my $runner1 = TestingConfig::get_annotated_buffer_runner({
    input_file => './testdata/spliceAI/pangolin.vcf'
});

my $result1 = TestingConfig::get_LoF_plugin($runner1);
is_deeply(
    $result1->{'LoF_info'},
    'Pangolin=ENSG00000223972.5|-49:0.009999999776482582|-35:-0.0|Warnings:'
);