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
        describe "#{role}.#{site}.lsst.org", :site do
          let(:site) { site }
          let(:fqdn) { facts[:fqdn] }
          let(:le_root) { "/etc/letsencrypt/live/#{fqdn}" }
          let(:perfsonar_version) { '4.4.0' }

          it { is_expected.to compile.with_all_deps }

          include_examples 'common', facts: facts
          include_examples 'generic perfsonar', facts: facts

          it do
            is_expected.to contain_yum__versionlock('perfsonar-toolkit').with(
              version: perfsonar_version,
            )
          end
        end # host
      end # lsst_sites
    end # on os
  end # on_supported_os
end # role
