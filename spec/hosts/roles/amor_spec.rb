# frozen_string_literal: true

require 'spec_helper'

role = 'amor'

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
          cluster: role,
        }
      end

      lsst_sites.each do |site|
        describe "#{role}.#{site}.lsst.org", :site do
          let(:site) { site }

          it { is_expected.to compile.with_all_deps }

          include_examples 'common', facts: facts
          include_examples 'docker'
          include_examples 'dco'

          it do
            is_expected.to contain_vcsrepo('/home/dco/LOVE-integration-tools').with(
              ensure: 'present',
              provider: 'git',
              source: 'https://github.com/lsst-ts/LOVE-integration-tools.git',
              keep_local_changes: true,
              user: 'dco',
              owner: 'dco',
              group: 'dco',
            )
          end

          it { is_expected.to contain_package('docker-compose-plugin') }
        end # host
      end # lsst_sites
    end # on os
  end # on_supported_os
end # role
