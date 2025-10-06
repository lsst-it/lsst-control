# frozen_string_literal: true

require 'spec_helper'

describe 'profile::core::openvpnas' do
  on_supported_os.each do |os, os_facts|
    next unless os =~ %r{almalinux-9-x86_64}

    context "on #{os}" do
      let(:facts) do
        os_facts.merge(
          networking: {
            fqdn: 'foo.example.com',
          }
        )
      end

      let(:fqdn) { facts[:networking][:fqdn] }
      let(:le_root) { "/etc/letsencrypt/live/#{fqdn}" }
      let(:sacli) { '/usr/local/openvpn_as/scripts/sacli' }

      context 'with default parameters' do
        let(:params) do
          {
            version: '3.0.1_84b60e70',
          }
        end

        it { is_expected.to compile.with_all_deps }

        it do
          is_expected.to contain_letsencrypt__certonly(fqdn).with(
            plugin: 'dns-route53',
            manage_cron: true
          )
        end

        it do
          is_expected.to contain_class('openvpnas').with(
            manage_repo: true,
            version: '3.0.1_84b60e70',
            versionlock_enable: true,
            versionlock_release: '1.el9',
            manage_service: true,
            manage_web_certs: true,
            cert_source_path: le_root,
            require: "Letsencrypt::Certonly[#{fqdn}]"
          )
        end

        it do
          is_expected.to contain_exec('wait_for_openvpnas_socket').with(
            command: '/bin/true',
            unless: '/usr/bin/test -S /usr/local/openvpn_as/etc/sock/sagent',
            require: 'Service[openvpnas]'
          )
        end

        it do
          is_expected.to contain_exec('wait_for_openvpnas_ready').with(
            command: "#{sacli} ConfigQuery > /dev/null 2>&1",
            tries: 10,
            try_sleep: 3,
            timeout: 60,
            require: 'Exec[wait_for_openvpnas_socket]'
          )
        end

        it do
          is_expected.to contain_exec('set_auth_module_ldap').with(
            command: "#{sacli} --key 'auth.module.type' --value 'ldap' ConfigPut",
            unless: "#{sacli} ConfigQuery | grep -q '\"auth.module.type\": \"ldap\"'",
            require: 'Exec[wait_for_openvpnas_ready]'
          )
        end

        it do
          is_expected.to contain_exec('set_ldap_primary').with(
            command: "#{sacli} --key 'auth.ldap.0.server.0.host' --value 'ipa1.cp.lsst.org' ConfigPut",
            unless: "#{sacli} ConfigQuery | grep -q '\"auth.ldap.0.server.0.host\": \"ipa1.cp.lsst.org\"'",
            require: 'Exec[set_auth_module_ldap]'
          )
        end

        it do
          is_expected.to contain_exec('set_ldap_secondary').with(
            command: "#{sacli} --key 'auth.ldap.0.server.1.host' --value 'ipa1.ls.lsst.org' ConfigPut",
            unless: "#{sacli} ConfigQuery | grep -q '\"auth.ldap.0.server.1.host\": \"ipa1.ls.lsst.org\"'",
            require: 'Exec[set_ldap_primary]'
          )
        end

        it do
          is_expected.to contain_exec('enable_ldap_auth').with(
            command: "#{sacli} --key 'auth.ldap.0.enable' --value 'true' ConfigPut",
            unless: "#{sacli} ConfigQuery | grep -q '\"auth.ldap.0.enable\": \"true\"'",
            require: 'Exec[set_ldap_uname_attr]'
          )
        end

        it do
          is_expected.to contain_exec('restart_openvpnas_after_ldap').with(
            command: "#{sacli} start",
            refreshonly: true,
            subscribe: 'Exec[enable_ldap_auth]'
          )
        end

        it do
          is_expected.to contain_exec('restart_openvpnas_after_groups').with(
            command: "#{sacli} start",
            refreshonly: true,
            subscribe: ['Exec[create_group_vpn_default]', 'Exec[create_group_vpn_it]', 'Exec[grant_admin_to_vpn_it]'],
            path: ['/usr/local/openvpn_as/scripts', '/usr/bin', '/bin']
          )
        end

        it do
          is_expected.to contain_file('/root/ldap.py').with(
            ensure: 'file',
            owner: 'root',
            group: 'root',
            mode: '0644'
          ).with_content(%r{#!/usr/bin/env python3})
                                                      .with_content(%r{def post_auth\(})
                                                      .with_content(%r{group = "vpn-default"})
        end

        it do
          is_expected.to contain_exec('install_post_auth_script').with(
            command: "#{sacli} -k auth.module.post_auth_script --value_file=/root/ldap.py ConfigPut && #{sacli} start",
            refreshonly: true,
            subscribe: 'File[/root/ldap.py]',
            require: 'Exec[restart_openvpnas_after_groups]',
            path: ['/usr/local/openvpn_as/scripts', '/usr/bin', '/bin']
          )
        end
      end
    end
  end
end
