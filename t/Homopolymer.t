#!/usr/local/bin/perl 

use strict;
use warnings;

use Test::More;

use FindBin qw($Bin);
use lib '/refs/loftee';
use LoF;

## BASIC TESTS
##############

# use_test
use_ok('LoF');
use_ok('Bio::EnsEMBL::VEP::OutputFactory');
use_ok('Bio::EnsEMBL::VEP::Runner');

my $header=LoF->get_header_info();
ok($header, 'get_header_info is defined');
is_deeply(
    $header,
    bless({
        LoF => "Loss-of-function annotation (HC = High Confidence; LC = Low Confidence)",
        LoF_filter => "Reason for LoF not being HC",
        LoF_flags => "Possible warning flags for LoF",
        LoF_info => "Info used for LoF annotation",
    })
);

my $type=LoF->feature_types();
ok($type, 'feature_types is defined');
is_deeply(
    $type,
    bless(['Transcript'])
);

my $lof_instance = LoF->new();
ok($lof_instance, 'new is defined');

## METHOD_TESTS
###############

# test_none
my $runner = get_annotated_buffer_runner({
    input_file => '/opt/vep/.vep/test/testdata/Homopolymer/test_none.vcf'
});
my $result = get_LoF_plugin($runner);
is_deeply(
    $result->{'LoF_info'},
    'PERCENTILE:0.151061173533084,GERP_DIST:-304.5421182096,BP_DIST:676,DIST_FROM_LAST_EXON:663,50_BP_RULE:PASS'
);


# test_alt_ref
my $runner = get_annotated_buffer_runner({
    input_file => '/opt/vep/.vep/test/testdata/Homopolymer/test_ref_alt.vcf'
});
my $result = get_LoF_plugin($runner);
is_deeply(
    $result->{'LoF_info'},
    'Homopolymer_flag:Homopolymer,PERCENTILE:0.151061173533084,GERP_DIST:-304.5421182096,BP_DIST:676,DIST_FROM_LAST_EXON:663,50_BP_RULE:PASS'
);

#test_alt
my $runner = get_annotated_buffer_runner({
    input_file => '/opt/vep/.vep/test/testdata/Homopolymer/test_alt.vcf'
});
my $result = get_LoF_plugin($runner);
is_deeply(
    $result->{'LoF_info'},
    'Homopolymer_flag:Homopolymer,PERCENTILE:0.151061173533084,GERP_DIST:-304.5421182096,BP_DIST:676,DIST_FROM_LAST_EXON:663,50_BP_RULE:PASS'
);

#test_ref
my $runner = get_annotated_buffer_runner({
    input_file => '/opt/vep/.vep/test/testdata/Homopolymer/test_ref.vcf'
});
my $result = get_LoF_plugin($runner);
is_deeply(
    $result->{'LoF_info'},
    'Homopolymer_flag:Homopolymer,PERCENTILE:0.151061173533084,GERP_DIST:-304.5421182096,BP_DIST:676,DIST_FROM_LAST_EXON:663,50_BP_RULE:PASS'
);


done_testing();

## Function
###############

sub get_LoF_plugin {
    $runner = shift;

    my $of = $runner->get_OutputFactory();
    my $ib = $runner->get_InputBuffer();
    my $vf = $ib->buffer->[0];
    my $hash = $of->VariationFeature_to_output_hash($vf);
    my %copy = %$hash;
    my $method =  sprintf(
        'get_all_%sOverlapAlleles',
        ref($vf) eq 'Bio::EnsEMBL::Variation::StructuralVariationFeature'
        ? 'StructuralVariation'
        : 'VariationFeature'
    );
    my $vfoa = $of->$method($vf)->[0];
    my $method = (split('::', ref($vfoa)))[-1].'_to_output_hash';
    my $output = $of->$method($vfoa, \%copy, $vf);
    
    my $result = $lof_instance->run($vfoa, $output);

    return $result
}


sub get_annotated_buffer_runner {
  my $tmp_cfg = shift;

  my $runner = Bio::EnsEMBL::VEP::Runner->new({
    %$tmp_cfg,
    database => 0,
    dir => '/refs/cache-109',
    stats_file => '/result/output/loftee_summary.html',
    dir_plugins => '/refs/loftee',
    cache => '',
    output_file => '/result/output/loftee_out.tsv',
    plugin => [
     'LoF,loftee_path:/refs/loftee,human_ancestor_fa:/refs/human_ancestor.fa.gz,gerp_bigwig:/refs/gerp_conservation_scores.homo_sapiens.GRCh38.bw,conservation_file:/refs/loftee.sql'
    ],
    force_overwrite => 1
  });

  $runner->init;

  my $ib = $runner->get_InputBuffer;
  $ib->next();
  $_->annotate_InputBuffer($ib) for @{$runner->get_all_AnnotationSources};
  $ib->finish_annotation();

  return $runner;
}