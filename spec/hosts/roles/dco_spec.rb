# frozen_string_literal: true

require 'spec_helper'

role = 'dco'

describe "#{role} role" do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      lsst_sites.each do |site|
        describe "#{role}.#{site}.lsst.org", :sitepp do
          let(:node_params) do
            {
              role: role,
              site: site,
            }
          end
          let(:facts) { lsst_override_facts(os_facts) }

          it { is_expected.to compile.with_all_deps }

          include_examples 'common', os_facts: os_facts, site: site
          include_examples 'docker'
          include_examples 'dco'

          it do
            is_expected.to contain_file('/home/dco/docker_tmp').with(
              ensure: 'directory',
              owner: 'dco',
              group: 'dco',
              mode: '0777',
            )
          end

          if site == 'cp'
            it do
              is_expected.to contain_nfs__client__mount('/net/obs-env').with(
                share: 'obs-env',
                server: 'nfs-obsenv.cp.lsst.org',
                atboot: true,
              )
            end
          end

          it { is_expected.to contain_package('docker-compose-plugin') }
        end # host
      end # lsst_sites
    end # on os
  end # on_supported_os
end # role
