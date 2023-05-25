# frozen_string_literal: true

require 'spec_helper'

role = 'ccs-dc'

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
        describe "comcam-dc01.#{site}.lsst.org", :site do
          let(:site) { site }

          it { is_expected.to compile.with_all_deps }

          include_examples 'common', facts: facts
          include_examples 'ccs common', facts: facts
          include_examples 'x2go packages'
          include_examples 'lsst-daq sysctls', facts: facts

          %w[
            ccs_daq
            profile::ccs::common
            profile::core::common
            profile::core::debugutils
            profile::core::nfsclient
          ].each do |cls|
            it { is_expected.to contain_class(cls) }
          end
        end # host
      end # lsst_sites
    end # on os
  end # on_supported_os
end # role
