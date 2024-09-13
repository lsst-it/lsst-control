# frozen_string_literal: true

require 'spec_helper'

role = 'amor'

describe "#{role} role" do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      lsst_sites.each do |site|
        describe "#{role}.#{site}.lsst.org", :sitepp do
          let(:node_params) do
            {
              role:,
              site:,
              cluster: role,
            }
          end
          let(:facts) { lsst_override_facts(os_facts) }

          it { is_expected.to compile.with_all_deps }

          include_examples('common', os_facts:, site:)
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
              group: 'dco'
            )
          end

          it { is_expected.to contain_package('docker-compose-plugin') }
        end # host
      end # lsst_sites
    end # on os
  end # on_supported_os
end # role
