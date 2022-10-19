# frozen_string_literal: true

require 'spec_helper'

role = 'hexrot'

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

          it { is_expected.to compile.with_all_deps }

          include_examples 'common', facts: facts

          # XXX hexrot uses devicemapper, so the docker example group isn't included
          it { is_expected.to contain_class('docker') }

          %w[
            profile::core::common
            profile::core::debugutils
            profile::core::docker
            profile::core::docker::prune
            profile::core::ni_packages
            profile::core::x2go_agent
            python
          ].each do |c|
            it { is_expected.to contain_class(c) }
          end
        end # host
      end # lsst_sites
    end # on os
  end # on_supported_os
end # role
