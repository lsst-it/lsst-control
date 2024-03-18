# frozen_string_literal: true

require 'spec_helper'

role = 'hexrot'

describe "#{role} role" do
  on_supported_os.each do |os, os_facts|
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

          include_examples 'common', os_facts: os_facts
          include_examples 'x2go packages', os_facts: os_facts
          it { is_expected.to contain_class('mate') }

          # XXX hexrot uses devicemapper, so the docker example group isn't included
          it { is_expected.to contain_class('docker') }

          %w[
            mate
            profile::core::anaconda
            profile::core::common
            profile::core::debugutils
            profile::core::docker
            profile::core::docker::prune
            profile::core::ni_packages
            profile::core::x2go
            profile::ts::hexrot
            profile::ts::nexusctio
          ].each do |c|
            it { is_expected.to contain_class(c) }
          end

          it { is_expected.to contain_class('profile::core::anaconda').with_python_env_name('py311') }

          it { is_expected.to contain_class('profile::core::anaconda').with_python_env_version('3.11') }

          pkgs = {
            'pyside2' => {
              'channel' => 'conda-forge',
              'version' => '5.15.8',
            },
            'qasync' => {
              'channel' => 'conda-forge',
              'version' => '0.23.0',
            },
            'ts-m2com' => {
              'channel' => 'lsstts',
              'version' => '1.4.2',
            },
            'ts-m2gui' => {
              'channel' => 'lsstts',
              'version' => '0.7.2',
            },
          }

          it { is_expected.to contain_class('profile::core::anaconda').with_conda_packages(pkgs) }

          it { is_expected.to contain_package('docker-compose-plugin') }

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
