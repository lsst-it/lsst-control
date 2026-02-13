# frozen_string_literal: true

require 'spec_helper'

describe 'profile::core::openvpnas' do
  on_supported_os.each do |os, os_facts|
    next unless os =~ %r{almalinux-9-x86_64}

    context "on #{os}" do
      let(:facts) do
        os_facts.merge(
          networking: { fqdn: 'foo.example.com' }
        )
      end

      let(:fqdn) { facts[:networking][:fqdn] }
      let(:le_root) { "/etc/letsencrypt/live/#{fqdn}" }
      let(:sacli) { '/usr/local/openvpn_as/scripts/sacli' }

      context 'with default parameters' do
        let(:params) do
          { version: '3.0.2_87c70987' }
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
            version: '3.0.2_87c70987',
            versionlock_enable: true,
            versionlock_release: '1.el9',
            manage_service: true,
            manage_web_certs: true,
            cert_source_path: le_root,
            require: "Letsencrypt::Certonly[#{fqdn}]"
          )
        end

        # LDAP Configuration Tests
        it do
          is_expected.to contain_openvpnas__config__key('auth.ldap.0.enable').with(
            key: 'auth.ldap.0.enable',
            value: true
          )
        end

        it do
          is_expected.to contain_openvpnas__config__key('auth.ldap.0.users_base_dn').with(
            key: 'auth.ldap.0.users_base_dn',
            value: 'cn=accounts,dc=lsst,dc=cloud'
          )
        end

        it do
          is_expected.to contain_openvpnas__config__key('auth.ldap.0.add_req').with(
            key: 'auth.ldap.0.add_req',
            value: 'memberOf=cn=vpn,cn=groups,cn=accounts,dc=lsst,dc=cloud'
          )
        end

        it do
          is_expected.to contain_openvpnas__config__key('auth.ldap.0.uname_attr').with(
            key: 'auth.ldap.0.uname_attr',
            value: 'uid'
          )
        end

        it do
          is_expected.to contain_openvpnas__config__key('auth.module.type').with(
            key: 'auth.module.type',
            value: 'ldap'
          )
        end

        it do
          is_expected.to contain_openvpnas__config__key('auth.ldap.0.server.0.host').with(
            key: 'auth.ldap.0.server.0.host',
            value: 'ipa1.cp.lsst.org'
          )
        end

        it do
          is_expected.to contain_openvpnas__config__key('auth.ldap.0.server.1.host').with(
            key: 'auth.ldap.0.server.1.host',
            value: 'ipa1.ls.lsst.org'
          )
        end

        it do
          is_expected.to contain_openvpnas__config__key('auth.ldap.0.bind_dn').with(
            key: 'auth.ldap.0.bind_dn',
            value: 'uid=svc_openvpnas,cn=users,cn=accounts,dc=lsst,dc=cloud'
          )
        end

        it do
          is_expected.to contain_openvpnas__config__key('auth.ldap.0.bind_pw').with(
            key: 'auth.ldap.0.bind_pw',
            value: 'testpassword'
          )
        end

        # Post-auth script file
        it do
          is_expected.to contain_file('/root/ldap.py').with(
            ensure: 'file',
            owner: 'root',
            group: 'root',
            mode: '0644',
            source: 'puppet:///modules/profile/openvpnas/ldap.py'
          )
        end

        it do
          is_expected.to contain_exec('install post-auth script').with(
            command: "#{sacli} -k auth.module.post_auth_script --value_file=/root/ldap.py ConfigPut && #{sacli} start",
            refreshonly: true,
            subscribe: 'File[/root/ldap.py]',
            path: ['/usr/local/openvpn_as/scripts', '/usr/bin', '/bin'],
            require: ['Openvpnas::Config::Key[auth.module.type]']
          )
        end

        # With no groups provided, should not create any groups
        it { is_expected.not_to contain_openvpnas__config__group('vpn-default') }
        it { is_expected.not_to contain_openvpnas__config__group('vpn-it') }
      end

      context 'with vpn_groups parameter' do
        let(:params) do
          {
            version: '3.0.2_87c70987',
            vpn_groups: {
              'vpn-default' => { 'superuser' => false },
              'vpn-it' => { 'superuser' => true },
              'vpn-science' => { 'superuser' => false },
            }
          }
        end

        it { is_expected.to compile.with_all_deps }

        # Should create all groups from the hash
        it do
          is_expected.to contain_openvpnas__config__group('vpn-default').with(
            user: 'vpn-default',
            superuser: false
          )
        end

        it do
          is_expected.to contain_openvpnas__config__group('vpn-it').with(
            user: 'vpn-it',
            superuser: true
          )
        end

        it do
          is_expected.to contain_openvpnas__config__group('vpn-science').with(
            user: 'vpn-science',
            superuser: false
          )
        end

        # Should not create groups that aren't in the hash
        it { is_expected.not_to contain_openvpnas__config__group('vpn-nonexistent') }

        # Post-auth script should require all defined groups
        it do
          is_expected.to contain_exec('install post-auth script').with(
            require: [
              'Openvpnas::Config::Group[vpn-default]',
              'Openvpnas::Config::Group[vpn-it]',
              'Openvpnas::Config::Group[vpn-science]',
              'Openvpnas::Config::Key[auth.module.type]',
            ]
          )
        end
      end

      context 'with custom bind_pw' do
        let(:params) do
          {
            version: '3.0.2_87c70987',
            bind_pw: 'my-secret-password'
          }
        end

        it { is_expected.to compile.with_all_deps }

        it do
          is_expected.to contain_openvpnas__config__key('auth.ldap.0.bind_pw').with(
            key: 'auth.ldap.0.bind_pw',
            value: 'my-secret-password'
          )
        end
      end

      context 'with custom ldap_add_req' do
        let(:params) do
          {
            version: '3.0.2_87c70987',
            ldap_add_req: 'memberOf=cn=vpn-backup,cn=groups,cn=accounts,dc=lsst,dc=cloud'
          }
        end

        it { is_expected.to compile.with_all_deps }

        it do
          is_expected.to contain_openvpnas__config__key('auth.ldap.0.add_req').with(
            key: 'auth.ldap.0.add_req',
            value: 'memberOf=cn=vpn-backup,cn=groups,cn=accounts,dc=lsst,dc=cloud'
          )
        end
      end
    end
  end
end
