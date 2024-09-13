# frozen_string_literal: true

require 'spec_helper'

role = 'comcam-fp'

describe "#{role} role" do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      lsst_sites.each do |site|
        describe "#{role}.#{site}.lsst.org", :sitepp do
          let(:node_params) do
            {
              role:,
              site:,
              cluster: 'comcam-ccs',
            }
          end
          let(:facts) { lsst_override_facts(os_facts) }

          it { is_expected.to compile.with_all_deps }

          include_examples('common', os_facts:, site:)
          include_examples('x2go packages', os_facts:)
          include_examples 'lhn sysctls'
          it { is_expected.not_to contain_class('dhcp') }
          it { is_expected.to contain_class('dhcp::disable') }
          it { is_expected.to contain_class('ccs_daq') }
          it { is_expected.to contain_class('daq::daqsdk') }

          it do
            is_expected.to contain_file('/home/ccs-ipa/bin/fhe').with(
              ensure: 'file',
              owner: 'ccs-ipa',
              group: 'ccs-ipa',
              mode: '0755'
            )
          end

          it { is_expected.to contain_file('/home/ccs-ipa/bin/mc-secret').with_content(%r{^foo$}) }
        end # host
      end # lsst_sites
    end # on os
  end # on_supported_os
end # role
