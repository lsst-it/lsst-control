# frozen_string_literal: true

require 'spec_helper'

role = 'hexrot'

describe "#{role} role" do
  on_supported_os.each do |os, os_facts|
    next unless os =~ %r{almalinux-9-x86_64}

    context "on #{os}" do
      lsst_sites.each do |site|
        describe "#{role}.#{site}.lsst.org", :sitepp do
          let(:node_params) do
            {
              role:,
              site:,
            }
          end
          let(:facts) { lsst_override_facts(os_facts) }

          it { is_expected.to compile.with_all_deps }

          include_examples 'debugutils'
          include_examples('common', os_facts:, site:)
          include_examples('x2go packages', os_facts:)
          include_examples 'ni_packages'
          include_examples 'nexusctio'
          it { is_expected.to contain_class('mate') }
          it { is_expected.to contain_class('profile::util::xfce') }
          it { is_expected.to contain_package('freeglut-devel') } # missing opengl lib

          # XXX hexrot uses devicemapper, so the docker example group isn't included
          it do
            is_expected.to contain_class('docker').with(
              package_source: 'docker-ce',
              socket_group: 70_014,
              socket_override: false,
              storage_driver: 'devicemapper'
            )
          end

          it { is_expected.to contain_cron__job('docker_prune') }

          it do
            is_expected.to contain_vcsrepo('/opt/ts_config_mttcs').with(
              ensure: 'present',
              provider: 'git',
              source: 'https://github.com/lsst-ts/ts_config_mttcs.git',
              revision: 'v0.17.1',
              keep_local_changes: 'false'
            )
          end

          pkgs = {
            'numpy' => {
              'channel' => 'conda-forge',
              'version' => '2.0.2',
            },
            'pyside6' => {
              'channel' => 'conda-forge',
              'version' => '6.8.3',
            },
            'qasync' => {
              'channel' => 'conda-forge',
              'version' => '0.27.1',
            },
            'qt6-charts' => {
              'channel' => 'conda-forge',
              'version' => '6.8.3',
            },
            'ts-guitool' => {
              'channel' => 'lsstts',
              'version' => '0.2.6',
            },
            'ts-hexgui' => {
              'channel' => 'lsstts',
              'version' => '0.4.2',
            },
            'ts-hexrotcomm' => {
              'channel' => 'lsstts',
              'version' => '1.3.5',
            },
            'ts-m2com' => {
              'channel' => 'lsstts',
              'version' => '1.5.11',
            },
            'ts-m2gui' => {
              'channel' => 'lsstts',
              'version' => '1.1.6',
            },
            'ts-mtdomecom' => {
              'channel' => 'lsstts',
              'version' => '0.2.13',
            },
            'ts-mtdomegui' => {
              'channel' => 'lsstts',
              'version' => '0.4.13',
            },
            'ts-rotgui' => {
              'channel' => 'lsstts',
              'version' => '0.4.2',
            },
            'ts-salobj' => {
              'channel' => 'lsstts',
              'version' => '8.2.1',
            },
            'ts-tcpip' => {
              'channel' => 'lsstts',
              'version' => '2.1.0',
            },
            'ts-xml' => {
              'channel' => 'lsstts',
              'version' => '23.1.0',
            },
          }

          it do
            is_expected.to contain_class('anaconda').with(
              anaconda_version: 'Anaconda3-2023.07-2',
              python_env_name: 'py312',
              python_env_version: '3.12',
              conda_packages: pkgs
            )
          end

          it { is_expected.to contain_package('docker-compose-plugin') }

          it do
            is_expected.to contain_file('/etc/profile.d/hexrot_path.sh').with(
              ensure: 'file',
              mode: '0644',
              content: <<~CONTENT
                export QT_API="PySide6"
                export PYTEST_QT_API="PySide6"
                export TS_CONFIG_MTTCS_DIR="/opt/ts_config_mttcs"
              CONTENT
            )
          end

          ['/rubin/mtm2/python', '/rubin/rotator/python', '/rubin/hexapod/python', '/rubin/mtm2/python'].each do |path|
            it do
              is_expected.to contain_file(path).with(
                ensure: 'directory',
                owner: '73006',
                group: '73006'
              )
            end
          end

          symlinks = {
            '/rubin/mtm2/python/run_m2gui' => '/opt/anaconda/envs/py311/bin/run_m2gui',
            '/rubin/hexapod/python/run_hexgui' => '/opt/anaconda/envs/py311/bin/run_hexgui',
            '/rubin/dome/python/run_mtdomegui' => '/opt/anaconda/envs/py311/bin/run_mtdomegui',
            '/rubin/rotator/python/run_rotgui' => '/opt/anaconda/envs/py311/bin/run_rotgui'
          }

          symlinks.each do |source, dst|
            it do
              is_expected.to contain_file(source).with(
                ensure: 'link',
                owner: '73006',
                group: '73006',
                target: dst
              )
            end
          end

          ['/rubin/rotator', '/rubin/hexapod', '/rubin/mtm2', '/rubin/dome'].each do |path|
            it do
              is_expected.to contain_file(path).with(
                ensure: 'directory',
                owner: '73006',
                group: '73006',
                recurse: 'true'
              )
            end
          end

          ['/rubin/rotator/log', '/rubin/hexapod/log', '/rubin/mtm2/log', '/rubin/dome/log'].each do |path|
            it do
              is_expected.to contain_file(path).with(
                ensure: 'directory',
                owner: '73006',
                group: '73006',
                mode: '0775'
              )
            end
          end
        end # host
      end # lsst_sites
    end # on os
  end # on_supported_os
end # role
