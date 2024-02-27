package TestingConfig;
use strict;
use warnings;

use FindBin qw($Bin);
use lib '/refs/loftee';
use LoF;


sub get_LoF_plugin {
    my $runner = shift;
    my $of = $runner->get_OutputFactory();
    my $ib = $runner->get_InputBuffer();
    my $vf = $ib->buffer->[0];
    my $hash = $of->VariationFeature_to_output_hash($vf);
    my %copy = %$hash;
    my $method0 =  sprintf(
        'get_all_%sOverlapAlleles',
        ref($vf) eq 'Bio::EnsEMBL::Variation::StructuralVariationFeature'
        ? 'StructuralVariation'
        : 'VariationFeature'
    );
    my $vfoa = $of->$method0($vf)->[0];
    my $method = (split('::', ref($vfoa)))[-1].'_to_output_hash';
    my $output = $of->$method($vfoa, \%copy, $vf);

    my $lof_instance = LoF->new();
    my $result = $lof_instance->run($vfoa, $output);

    return $result;
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

1;