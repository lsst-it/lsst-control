# frozen_string_literal: true

require 'spec_helper'

role = 'hexrot'

describe "#{role} role" do
  on_supported_os.each do |os, os_facts|
    next unless os =~ %r{almalinux-9-x86_64}

    context "on #{os}" do
      let(:facts) { os_facts }
      let(:node_params) do
        {
          role: role,
          site: site,
        }
      end

      lsst_sites.each do |site|
        fqdn = "#{role}.#{site}.lsst.org"
        override_facts(os_facts, fqdn: fqdn, networking: { fqdn => fqdn })

        describe fqdn, :sitepp do
          let(:site) { site }

          it { is_expected.to compile.with_all_deps }

          include_examples 'debugutils'
          include_examples 'common', os_facts: os_facts, site: site
          include_examples 'x2go packages', os_facts: os_facts
          include_examples 'ni_packages'
          include_examples 'nexusctio'
          it { is_expected.to contain_class('mate') }

          # XXX hexrot uses devicemapper, so the docker example group isn't included
          it do
            is_expected.to contain_class('docker').with(
              package_source: 'docker-ce',
              socket_group: 70_014,
              socket_override: false,
              storage_driver: 'devicemapper',
            )
          end

          it { is_expected.to contain_cron__job('docker_prune') }

          it do
            is_expected.to contain_vcsrepo('/opt/ts_config_mttcs').with(
              ensure: 'present',
              provider: 'git',
              source: 'https://github.com/lsst-ts/ts_config_mttcs.git',
              revision: 'v0.12.8',
              keep_local_changes: 'false',
            )
          end

          pkgs = {
            'pyside6' => {
              'channel' => 'conda-forge',
              'version' => '6.7.0',
            },
            'qasync' => {
              'channel' => 'conda-forge',
              'version' => '0.23.0',
            },
            'qt6-charts' => {
              'channel' => 'conda-forge',
              'version' => '6.7.0',
            },
            'ts-m2com' => {
              'channel' => 'lsstts',
              'version' => '1.5.4',
            },
            'ts-m2gui' => {
              'channel' => 'lsstts',
              'version' => '1.0.2',
            },
          }

          it do
            is_expected.to contain_class('anaconda').with(
              anaconda_version: 'Anaconda3-2023.07-2',
              python_env_name: 'py311',
              python_env_version: '3.11',
              conda_packages: pkgs,
            )
          end

          it { is_expected.to contain_package('docker-compose-plugin') }

          it do
            is_expected.to contain_file('/etc/profile.d/hexrot_path.sh').with(
              ensure: 'file',
              mode: '0644',
              content: <<~CONTENT,
              export QT_API="PySide6"
              export PYTEST_QT_API="PySide6"
              export TS_CONFIG_MTTCS_DIR="/opt/ts_config_mttcs"
              CONTENT
            )
          end

          it do
            is_expected.to contain_file('/rubin/mtm2/python').with(
              ensure: 'directory',
              owner: '73006',
              group: '73006',
            )
          end

          it do
            is_expected.to contain_file('/rubin/mtm2/python/run_m2gui').with(
              ensure: 'link',
              owner: '73006',
              group: '73006',
              target: '/opt/anaconda/envs/py311/bin/run_m2gui',
            )
          end

          ['/rubin/rotator', '/rubin/hexapod', '/rubin/mtm2'].each do |path|
            it do
              is_expected.to contain_file(path).with(
                ensure: 'directory',
                owner: '73006',
                group: '73006',
                recurse: 'true',
              )
            end
          end

          ['/rubin/rotator/log', '/rubin/hexapod/log', '/rubin/mtm2/log'].each do |path|
            it do
              is_expected.to contain_file(path).with(
                ensure: 'directory',
                mode: '0775',
              )
            end
          end
        end # host
      end # lsst_sites
    end # on os
  end # on_supported_os
end # role
