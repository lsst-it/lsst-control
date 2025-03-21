# frozen_string_literal: true

require 'spec_helper'

describe 'profile::core::openvpn' do
  on_supported_os.each do |os, os_facts|
    next unless os =~ %r{almalinux-9-x86_64}

    context "on #{os}" do
      let(:facts) { os_facts }

      context 'with default parameters' do
        let(:params) do
          {
            version: '3.0.0_2b84043e',
            cluster: 'vpn.%{::site}.lsst.org',
          }
        end

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_class('profile::core::letsencrypt') }

        it do
          is_expected.to contain_package('openvpn-as').with(
            ensure: '3.0.0_2b84043e',
            require: 'Yumrepo[as-repo-rhel9]'
          )
        end

        it do
          is_expected.to contain_letsencrypt__certonly('vpn.%{::site}.lsst.org').with(
            plugin: 'dns-route53',
            manage_cron: true
          )
        end

        it do
          is_expected.to contain_yumrepo('as-repo-rhel9').with(
            ensure: 'present',
            name: 'openvpn-access-server',
            descr: 'OpenVPN Access Server',
            baseurl: 'http://as-repository.openvpn.net/as/yum/rhel9/',
            gpgkey: 'https://as-repository.openvpn.net/as-repo-public.gpg',
            gpgcheck: '1',
            enabled: '1'
          )
        end

        it do
          is_expected.to contain_file('/usr/local/openvpn_as/etc/web-ssl/server.crt').with(
            ensure: 'link'
          )
        end

        it do
          is_expected.to contain_file('/usr/local/openvpn_as/etc/web-ssl/server.key').with(
            ensure: 'link'
          )
        end

        it do
          is_expected.to contain_file('/usr/local/openvpn_as/etc/web-ssl/ca.crt').with(
            ensure: 'link'
          )
        end

        it do
          is_expected.to contain_service('openvpnas').with(
            ensure: 'running',
            enable: true,
            require: 'Package[openvpn-as]'
          )
        end
      end
    end
  end
end
