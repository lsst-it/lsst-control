# frozen_string_literal: true

require 'spec_helper'

role = 'perfsonar'

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
        }
      end

      lsst_sites.each do |site|
        describe "#{role}.#{site}.lsst.org", :site, :common do
          let(:site) { site }

          it { is_expected.to compile.with_all_deps }

          it do
            is_expected.to contain_yum__versionlock('perfsonar-toolkit').with(
              version: '4.4.0',
            )
          end
        end # host
      end # lsst_sites
    end # on os
  end # on_supported_os
end # role
