# frozen_string_literal: true

require 'spec_helper'

role = 'htcondor'

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

      fqdn = "#{role}.dev.lsst.org"
      describe fqdn, :sitepp do
        override_facts(os_facts, fqdn: fqdn, networking: { fqdn => fqdn })
        let(:site) { 'dev' }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_yumrepo('condor') }

        it do
          is_expected.to contain_package('condor')
            .that_requires('Yumrepo[condor]')
        end

        it { is_expected.to contain_file('/etc/condor/condor_config.local') }

        it { is_expected.to contain_file('/etc/condor/config.d/schedd').with_content(%r{^DAEMON_LIST = MASTER, SCHEDD}) }

        it do
          is_expected.to contain_service('condor').with(
            ensure: 'running',
            enable: true,
          )
        end

        it do
          is_expected.to contain_nfs__client__mount('/mnt/rsphome').with(
            share: 'rsphome',
            server: 'nfs-rsphome.ls.lsst.org',
            atboot: true,
          )
        end

        it do
          is_expected.to contain_nfs__client__mount('/mnt/project').with(
            share: 'project',
            server: 'nfs-project.ls.lsst.org',
            atboot: true,
          )
        end

        %w[
          profile::core::common
          profile::core::htcondor
          profile::core::nfsclient
        ].each do |c|
          it { is_expected.to contain_class(c) }
        end

        it { is_expected.to contain_class('profile::core::htcondor').with_htcondor_version('23.0') }

        it { is_expected.to contain_class('profile::core::htcondor').with_htcondor_host('htcondor-cm.dev.lsst.org') }
      end # host
    end # on os
  end # on_supported_os
end # role
