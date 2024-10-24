# frozen_string_literal: true

require 'spec_helper'

describe 'profile::core::rucio' do
  on_supported_os.each do |os, os_facts|
    next unless os =~ %r{almalinux-9-x86_64}

    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile.with_all_deps }

      it do
        is_expected.to contain_yumrepo('xrootd-stable').with(
          descr: 'XRootD Stable Repository',
          baseurl: 'https://xrootd.web.cern.ch/repo/stable/el$releasever/$basearch',
          skip_if_unavailable: 'true',
          gpgcheck: '1',
          gpgkey: 'https://xrootd.web.cern.ch/repo/RPM-GPG-KEY.txt',
          enabled: '1',
          target: '/etc/yum.repo.d/xrootd.repo'
        )
      end

      ['/lib/systemd/system/xrootd@.service', '/lib/systemd/system/cmsd@.service'].each do |path|
        it do
          is_expected.to contain_file(path).with(
            ensure: 'file',
            mode: '0644',
            owner: 'saluser',
            group: 'saluser'
          )
        end
      end

      ['/etc/xrootd', '/var/log/xrootd', '/var/run/xrootd', '/var/spool/xrootd'].each do |path|
        it do
          is_expected.to contain_file(path).with(
            ensure: 'directory',
            mode: '0644',
            owner: 'saluser',
            group: 'saluser'
          )
        end
      end
    end
  end
end
