# frozen_string_literal: true

require 'spec_helper'

shared_examples 'generic auxtel-fp' do
  include_examples 'lsst-daq client'
  # it { is_expected.to contain_class('ccs_daq') }
  # it { is_expected.to contain_class('daq::daqsdk').with_version('R5-V0.6') }
end

describe 'atsdaq role' do
  let(:node_params) do
    {
      role: 'atsdaq',
      cluster: 'auxtel-ccs',
    }
  end

  let(:facts) { { fqdn: self.class.description } }

  describe 'auxtel-fp01.cp.lsst.org', :site, :common do
    let(:node_params) do
      super().merge(
        site: 'cp',
      )
    end

    it { is_expected.to compile.with_all_deps }

    include_examples 'generic auxtel-fp'
  end # host

  describe 'auxtel-fp01.tu.lsst.org', :site, :common do
    let(:node_params) do
      super().merge(
        site: 'tu',
      )
    end

    it { is_expected.to compile.with_all_deps }

    include_examples 'generic auxtel-fp'
  end # host
end # role
