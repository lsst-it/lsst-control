# frozen_string_literal: true

require 'spec_helper'

role = 'ccs-dc'

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
          include_examples('ccs common', os_facts:)
          include_examples('x2go packages', os_facts:)
          include_examples 'lhn sysctls'

          %w[
            ccs_daq
            profile::ccs::common
            profile::core::common
            profile::core::debugutils
            profile::core::nfsclient
          ].each do |cls|
            it { is_expected.to contain_class(cls) }
          end
          it { is_expected.to contain_host('sdfembs3.sdf.slac.stanford.edu').with_ip('172.24.7.249') }
        end # host
      end # lsst_sites
    end # on os
  end # on_supported_os
end # role
