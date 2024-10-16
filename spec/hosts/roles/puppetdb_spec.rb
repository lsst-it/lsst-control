# frozen_string_literal: true

require 'spec_helper'

PUPPETDB_VERSION = '7.14.0'

shared_examples 'puppetdb' do
  %w[
    apache
    apache::mod::authnz_ldap
    apache::mod::ldap
    puppetdb
  ].each do |c|
    it { is_expected.to contain_class(c) }
  end

  it do
    is_expected.to contain_letsencrypt__certonly(facts[:networking]['fqdn']).with(
      plugin: 'dns-route53',
      manage_cron: true
    )
  end

  it { is_expected.to contain_cron__job('restart-apache-on-letsencrypt-renewal') }
  it { is_expected.to contain_apache__vhost('redirect-https').with_port(80) }
  it { is_expected.to contain_apache__vhost('puppetboard-proxy').with_port(443) }
  it { is_expected.to contain_apache__vhost('puppetdb-proxy').with_port(8443) }

  it { is_expected.to contain_class('puppetdb::globals').with_version(PUPPETDB_VERSION) }
  it { is_expected.to contain_yum__versionlock('puppetdb').with_version(PUPPETDB_VERSION) }

  it do
    is_expected.to contain_class('puppetdb').with(
      listen_address: 'localhost',
      java_args: {
        '-Xmx' => '1g',
        '-Xms' => '512m',
      }
    )
  end

  it do
    is_expected.to contain_class('postgresql::globals').with(
      manage_package_repo: false,
      manage_dnf_module: true,
      version: '15'
    )
  end

  it do
    is_expected.to contain_firewall('250 accept http - redirect to 443').with(
      proto: 'tcp',
      state: 'NEW',
      dport: '80',
      jump: 'accept'
    )
  end

  it do
    is_expected.to contain_firewall('251 accept https - puppetboard ldap').with(
      proto: 'tcp',
      state: 'NEW',
      dport: '443',
      jump: 'accept'
    )
  end

  it do
    is_expected.to contain_firewall('252 accept https - puppetdb x509').with(
      proto: 'tcp',
      state: 'NEW',
      dport: '8081',
      jump: 'accept'
    )
  end

  it do
    is_expected.to contain_firewall('253 accept https - puppetdb ldap').with(
      proto: 'tcp',
      state: 'NEW',
      dport: '8443',
      jump: 'accept'
    )
  end
end

shared_examples 'puppetboard' do
  it { is_expected.to contain_docker__image('ghcr.io/voxpupuli/puppetboard') }

  it do
    is_expected.to contain_docker__run('puppetboard').with(
      image: 'ghcr.io/voxpupuli/puppetboard',
      volumes: [
        '/etc/puppetlabs/puppet/ssl:/etc/puppetlabs/puppet/ssl:ro',
      ],
      net: 'host',
      env: [
        'PUPPETDB_HOST=127.0.0.1',
        'PUPPETDB_PORT=8081',
        'PUPPETBOARD_PORT=8088',
        'ENABLE_CATALOG=true',
        'PUPPETDB_SSL_VERIFY=false',
        "PUPPETDB_KEY=/etc/puppetlabs/puppet/ssl/private_keys/#{facts[:networking]['fqdn']}.pem",
        "PUPPETDB_CERT=/etc/puppetlabs/puppet/ssl/certs/#{facts[:networking]['fqdn']}.pem",
        'SECRET_KEY=foo',
        'DEFAULT_ENVIRONMENT=*',
      ]
    )
  end
end

role = 'puppetdb'

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

          include_examples('common', os_facts:, site:)
          include_examples 'docker'
          it { is_expected.to contain_cron__job('docker_prune') }

          include_examples 'ipset'
          include_examples('firewall default', os_facts:)
          include_examples('firewall node_exporter scraping', site:)
          include_examples 'puppetdb'
          include_examples 'puppetboard'

          case site
          when 'dev', 'ls'
            it do
              expect(catalogue.resource('apache::vhost', 'puppetboard-proxy')[:directories].first).to include(
                'auth_ldap_url' => '"ldaps://ipa1.ls.lsst.org ipa2.ls.lsst.org ipa3.ls.lsst.org/cn=users,cn=accounts,dc=lsst,dc=cloud?uid?sub?(objectClass=posixAccount)"'
              )
            end
          when 'tu'
            it do
              expect(catalogue.resource('apache::vhost', 'puppetboard-proxy')[:directories].first).to include(
                'auth_ldap_url' => '"ldaps://ipa1.tu.lsst.org ipa2.tu.lsst.org ipa3.tu.lsst.org/cn=users,cn=accounts,dc=lsst,dc=cloud?uid?sub?(objectClass=posixAccount)"'
              )
            end
          when 'cp'
            it do
              expect(catalogue.resource('apache::vhost', 'puppetboard-proxy')[:directories].first).to include(
                'auth_ldap_url' => '"ldaps://ipa1.cp.lsst.org ipa2.cp.lsst.org ipa3.cp.lsst.org/cn=users,cn=accounts,dc=lsst,dc=cloud?uid?sub?(objectClass=posixAccount)"'
              )
            end
          end
        end # host
      end # lsst_sites
    end
  end
end
