# frozen_string_literal: true

require 'spec_helper'

describe 'profile::core::rucio' do
  on_supported_os.each do |os, os_facts|
    next unless os =~ %r{almalinux-9-x86_64}

    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile.with_all_deps }

      it do
        is_expected.to contain_exec('import_xrootd_gpg_key').with(
          command: '/usr/bin/rpm --import https://xrootd.web.cern.ch/repo/RPM-GPG-KEY.txt',
        )
      end

      it do
        is_expected.to contain_exec('fetch_xrootd_repo').with(
          command: '/usr/bin/curl -L https://cern.ch/xrootd/xrootd.repo -o /etc/yum.repos.d/xrootd.repo',
          creates: '/etc/yum.repos.d/xrootd.repo',
          require: 'Exec[import_xrootd_gpg_key]',
          subscribe: 'Exec[import_xrootd_gpg_key]',
        )
      end

      ['/lib/systemd/system/xrootd@.service', '/lib/systemd/system/cmsd@.service'].each do |path|
        it do
          is_expected.to contain_file(path).with(
            ensure: 'file',
            mode: '0644',
            owner: 'saluser',
            group: 'saluser',
          )
        end
      end

      it do
        is_expected.to contain_file('/etc/xrootd').with(
          ensure: 'directory',
          mode: '0644',
          owner: 'saluser',
          group: 'saluser',
        )
      end

      ['/var/log', '/var/run', '/var/spool'].each do |path|
        it do
          is_expected.to contain_file(path).with(
            ensure: 'directory',
            mode: '0644',
            owner: 'saluser',
            group: 'saluser',
          )
        end
      end
    end
  end
end
