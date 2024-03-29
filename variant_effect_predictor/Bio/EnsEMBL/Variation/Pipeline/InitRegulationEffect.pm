=head1 LICENSE

 Copyright (c) 1999-2013 The European Bioinformatics Institute and
 Genome Research Limited.  All rights reserved.

 This software is distributed under a modified Apache license.
 For license details, please see

   http://www.ensembl.org/info/about/legal/code_licence.html

=head1 CONTACT

 Please email comments or questions to the public Ensembl
 developers list at <dev@ensembl.org>.

 Questions may also be sent to the Ensembl help desk at
 <helpdesk@ensembl.org>.

=cut

package Bio::EnsEMBL::Variation::Pipeline::InitRegulationEffect;

use strict;
use warnings;

use base qw(Bio::EnsEMBL::Variation::Pipeline::BaseVariationProcess);

sub fetch_input {
    my $self = shift;
    my $species = $self->param_required('species');
    $self->warning($species); 

    my $cdba = $self->get_adaptor($species, 'core');
    my $fdba = $self->get_adaptor($species, 'funcgen');
    my $vdba = $self->get_adaptor($species, 'variation');

    # clear tables
    my $vdbc = $vdba->dbc();
    $vdbc->do('TRUNCATE TABLE regulatory_feature_variation');
    $vdbc->do('TRUNCATE TABLE motif_feature_variation');
    $vdbc->do('ALTER TABLE regulatory_feature_variation DISABLE KEYS');
    $vdbc->do('ALTER TABLE motif_feature_variation DISABLE KEYS');

    # get regulation object ids
    my $rfa = $fdba->get_RegulatoryFeatureAdaptor or die 'Failed to get RegulatoryFeatureAdaptor';
    my $mfa = $fdba->get_MotifFeatureAdaptor or die 'Failed to get MotifFeatureAdaptor';
    my $fsa = $fdba->get_FeatureSetAdaptor or die 'Failed to get FeatureSetAdaptor';

    my $sa = $cdba->get_SliceAdaptor or die 'Failed to get SliceAdaptor';

    my $slices = $sa->fetch_all('toplevel', undef, 0, 1);
    #if ($self->param('debug')) {
    #    my $slice = $slices->[0];    
    #    $slices = [];
    #    push @$slices, $slice;
    #}

    #my $slice = $sa->fetch_by_region('chromosome', 12);
    #my $slices = [];
    #push @$slices, $slice;

    my $regulatory_feature_set = $fsa->fetch_by_name('RegulatoryFeatures:MultiCell');
    my @external_feature_sets = @{$fsa->fetch_all_by_type('external')};

    foreach my $slice (@$slices) {
        # get all RegulatoryFeatures
        my @feature_ids = ();
        my $it = $rfa->fetch_Iterator_by_Slice_FeatureSets($slice, [$regulatory_feature_set]);
        while ($it->has_next()) {
            my $rf = $it->next();
            push @feature_ids, { feature_id => $rf->stable_id,
                                 feature_type => 'regulatory_feature',
                                 species => $species, };
        }
        # get all MotifFeatures
        my @mfs = @{$mfa->fetch_all_by_Slice($slice)};
        foreach my $mf (@mfs) {
            push @feature_ids, { feature_id => $mf->dbID,
                                 feature_type => 'motif_feature',
                                 species => $species, };  
        }
        # get all ExternalFeatures
        if ($self->param('include_external_features')) {
            foreach my $external_fset (@external_feature_sets) {
                my $feature_set = $fsa->fetch_by_name($external_fset->name);
                foreach my $external_feature (@{$feature_set->get_Features_by_Slice($slice)}) {
                    push @feature_ids, { feature_id => $external_feature->dbID,
                                         feature_type => 'external_feature', };
                }
            }
        }
        $self->dataflow_output_id(\@feature_ids, 2);
    }
}


sub write_output {
    my $self = shift;
    return;
}
1;
