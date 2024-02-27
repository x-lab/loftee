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
# pass
my $runner0 = TestingConfig::get_annotated_buffer_runner({
    input_file => './testdata/lastExon/50_bp_pass.vcf'
});

my $result0 = TestingConfig::get_LoF_plugin($runner0);
is_deeply(
    $result0->{'LoF_info'},
    'PERCENTILE:0.151061173533084,GERP_DIST:-304.5421182096,BP_DIST:676,DIST_FROM_LAST_EXON:663,50_BP_RULE:PASS,DIST_FROM_SECOND_LAST_EXON:653,50_BP_RULE_SECOND:PASS'
);

# fail
my $runner = TestingConfig::get_annotated_buffer_runner({
    input_file => './testdata/lastExon/50_bp_fail.vcf'
});

my $result = TestingConfig::get_LoF_plugin($runner);
is_deeply(
    $result->{'LoF_info'},
    'PERCENTILE:0.189265536723164,GERP_DIST:-399.568152523041,BP_DIST:861,DIST_FROM_LAST_EXON:-246,50_BP_RULE:FAIL,DIST_FROM_SECOND_LAST_EXON:719,50_BP_RULE_SECOND:PASS'
);

done_testing();