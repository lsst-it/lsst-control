# frozen_string_literal: true

require 'spec_helper'

shared_examples 'generic auxtel-mcm' do
  it { is_expected.to contain_class('ccs_sal') }
end

describe 'atsccs role' do
  let(:node_params) do
    {
      role: 'atsccs',
      cluster: 'auxtel-ccs',
      ipa_force_join: false, # easy_ipa
    }
  end

  let(:facts) { { fqdn: self.class.description } }

  context 'with tu site' do
    let(:node_params) do
      super().merge(
        site: 'tu',
      )
    end

    describe 'auxtel-mcm.tu.lsst.org', :site do
      it { is_expected.to compile.with_all_deps }

      include_examples 'generic auxtel-mcm'
    end
  end # site

  context 'with cp site' do
    let(:node_params) do
      super().merge(
        site: 'cp',
      )
    end

    describe 'auxtel-mcm.cp.lsst.org', :site do
      it { is_expected.to compile.with_all_deps }

      include_examples 'generic auxtel-mcm'
    end
  end # site
end
