# frozen_string_literal: true

require 'spec_helper'

describe 'comcam-fp role' do
  %w[tu cp].each do |site|
    context "with site #{site}", :site do
      describe "comcam-fp01.#{site}.lsst.org" do
        let(:node_params) do
          {
            site: site,
            role: 'comcam-fp',
            cluster: 'comcam-ccs',
            ipa_force_join: false, # easy_ipa
          }
        end

        let(:facts) {{ fqdn: self.class.description }}

        it { is_expected.to compile.with_all_deps }
        it { is_expected.not_to contain_class('profile::core::sysctl::lhn') }
        it { is_expected.not_to contain_class('dhcp') }
        it { is_expected.to contain_class('ccs_daq') }

        it do
          is_expected.to contain_class('profile::ccs::daq_interface').with(
            mode: 'dhcp-client',
          )
        end
      end # host
    end # site
  end
end # role
