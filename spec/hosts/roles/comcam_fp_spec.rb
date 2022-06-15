# frozen_string_literal: true

require 'spec_helper'

shared_examples 'generic comcam-fp' do
  it { is_expected.to compile.with_all_deps }
  it { is_expected.not_to contain_class('profile::core::sysctl::lhn') }
  it { is_expected.not_to contain_class('dhcp') }
  it { is_expected.to contain_class('dhcp::disable') }
  it { is_expected.to contain_class('ccs_daq') }

  it do
    is_expected.to contain_class('profile::ccs::daq_interface').with(
      mode: 'dhcp-client',
    )
  end
end

describe 'comcam-fp role' do
  let(:node_params) do
    {
      role: 'comcam-fp',
      cluster: 'comcam-ccs',
      ipa_force_join: false, # easy_ipa
    }
  end

  describe 'comcam-fp01.cp.lsst.org', :site do
    let(:node_params) do
      super().merge(
        site: 'cp',
      )
    end

    let(:facts) { { fqdn: self.class.description } }

    it { is_expected.to compile.with_all_deps }

    include_examples 'generic comcam-fp'

    it { is_expected.to contain_class('daq::daqsdk').with_version('R5-V3.2') }
  end # host

  describe 'comcam-fp01.tu.lsst.org', :site do
    let(:node_params) do
      super().merge(
        site: 'tu',
      )
    end

    let(:facts) { { fqdn: self.class.description } }

    it { is_expected.to compile.with_all_deps }

    include_examples 'generic comcam-fp'

    it { is_expected.to contain_class('daq::daqsdk').with_version('R5-V3.2') }
  end # host
end # role
