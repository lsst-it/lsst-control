# frozen_string_literal: true

require 'spec_helper'

role = 'comcam-fp'

describe "#{role} role" do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts.merge(
          fqdn: self.class.description,
        )
      end

      let(:node_params) do
        {
          role: role,
          site: site,
          cluster: 'comcam-ccs',
        }
      end

      lsst_sites.each do |site|
        describe "comcam-fp01.#{site}.lsst.org", :site do
          let(:site) { site }

          it { is_expected.to compile.with_all_deps }

          include_examples 'common', facts: facts
          include_examples 'x2go packages'

          case site
          when 'tu', 'cp'
            include_examples 'lsst-daq client', facts: facts
          end

          it { is_expected.not_to contain_class('profile::core::sysctl::lhn') }
          it { is_expected.not_to contain_class('dhcp') }
          it { is_expected.to contain_class('dhcp::disable') }
          it { is_expected.to contain_class('ccs_daq') }
          it { is_expected.to contain_class('daq::daqsdk') }
        end # host
      end # lsst_sites
    end # on os
  end # on_supported_os
end # role
