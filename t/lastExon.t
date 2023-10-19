#!/usr/local/bin/perl 

use strict;
use warnings;
use Test::More;

use FindBin qw($Bin);
use lib '/refs/loftee';
use LoF;


my $lof_instance = LoF->new();
ok($lof_instance, 'new is defined');

## METHOD_TESTS
###############

# pass
my $runner = get_annotated_buffer_runner({
    input_file => '/opt/vep/.vep/test/testdata/lastExon/50_bp_pass.vcf'
});

my $result = get_LoF_plugin($runner);
is_deeply(
    $result->{'LoF_info'},
    'IMPACT=HIGH;STRAND=-1;LoF=HC;LoF_info=PERCENTILE:0.940548340548341,GERP_DIST:198.468841362,BP_DIST:205,DIST_FROM_LAST_EXON:110,50_BP_RULE:PASS,PHYLOCSF_TOO_SHORT'
);

# fail
my $runner = get_annotated_buffer_runner({
    input_file => '/opt/vep/.vep/test/testdata/lastExon/50_bp_pass.vcf'
});

my $result = get_LoF_plugin($runner);
print($result);
# is_deeply(
#     $result->{'LoF_info'},
# );

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