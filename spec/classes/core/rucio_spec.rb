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
          ensure: 'absent',
          target: '/etc/yum.repos.d/xrootd.repo',
        )
      end

      %w[
        xrootd
        xrootd-libs
        xrootd-server
        xrootd-server-libs
        xrootd-client
        xrootd-client-libs
        xrootd-selinux
        xrdcl-http
      ].each do |pkg|
        it do
          is_expected.to contain_package(pkg).with(
            ensure: '1:5.9.6-1.el9',
          )
        end
      end

      it do
        is_expected.to contain_package('davix').with(
          ensure: '0.8.10-1.el9',
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

      ['/etc/xrootd', '/var/log/xrootd', '/var/run/xrootd', '/var/spool/xrootd'].each do |path|
        it do
          is_expected.to contain_file(path).with(
            ensure: 'directory',
            mode: '0755',
            owner: 'saluser',
            group: 'saluser',
          )
        end
      end
    end
  end
end
