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
      manage_cron: true,
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
      },
    )
  end

  it do
    is_expected.to contain_class('postgresql::globals').with(
      manage_package_repo: false,
      manage_dnf_module: true,
      version: '15',
    )
  end

  it do
    is_expected.to contain_firewall('250 accept http - redirect to 443').with(
      proto: 'tcp',
      state: 'NEW',
      dport: '80',
      action: 'accept',
    )
  end

  it do
    is_expected.to contain_firewall('251 accept https - puppetboard ldap').with(
      proto: 'tcp',
      state: 'NEW',
      dport: '443',
      action: 'accept',
    )
  end

  it do
    is_expected.to contain_firewall('252 accept https - puppetdb x509').with(
      proto: 'tcp',
      state: 'NEW',
      dport: '8081',
      action: 'accept',
    )
  end

  it do
    is_expected.to contain_firewall('253 accept https - puppetdb ldap').with(
      proto: 'tcp',
      state: 'NEW',
      dport: '8443',
      action: 'accept',
    )
  end
end

shared_examples 'puppetboard' do
  it { is_expected.to contain_docker__image('ghcr.io/voxpupuli/puppetboard') }

  it do
    is_expected.to contain_docker__run('puppetboard').with(
      image: 'ghcr.io/voxpupuli/puppetboard',
      env: [
        'PUPPETDB_HOST=127.0.0.1',
        'PUPPETDB_PORT=8080',
        'PUPPETBOARD_PORT=8088',
        'SECRET_KEY=foo',
      ],
      net: 'host',
    )
  end
end

role = 'puppetdb'

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

      lsst_sites.each do |site|
        fqdn = "#{role}.#{site}.lsst.org"
        override_facts(os_facts, fqdn: fqdn, networking: { fqdn => fqdn })

        describe fqdn, :sitepp do
          let(:site) { site }

          it { is_expected.to compile.with_all_deps }

          include_examples 'common', os_facts: os_facts, site: site
          include_examples 'docker'
          it { is_expected.to contain_cron__job('docker_prune') }

          include_examples 'ipset'
          include_examples 'firewall default', os_facts: os_facts
          include_examples 'firewall node_exporter scraping', site: site
          include_examples 'puppetdb'
          include_examples 'puppetboard'

          case site
          when 'dev', 'ls'
            it do
              expect(catalogue.resource('apache::vhost', 'puppetboard-proxy')[:directories].first).to include(
                'auth_ldap_url' => '"ldaps://ipa1.ls.lsst.org ipa2.ls.lsst.org ipa3.ls.lsst.org/cn=users,cn=accounts,dc=lsst,dc=cloud?uid?sub?(objectClass=posixAccount)"',
              )
            end
          when 'tu'
            it do
              expect(catalogue.resource('apache::vhost', 'puppetboard-proxy')[:directories].first).to include(
                'auth_ldap_url' => '"ldaps://ipa1.tu.lsst.org ipa2.tu.lsst.org ipa3.tu.lsst.org/cn=users,cn=accounts,dc=lsst,dc=cloud?uid?sub?(objectClass=posixAccount)"',
              )
            end
          when 'cp'
            it do
              expect(catalogue.resource('apache::vhost', 'puppetboard-proxy')[:directories].first).to include(
                'auth_ldap_url' => '"ldaps://ipa1.cp.lsst.org ipa2.cp.lsst.org ipa3.cp.lsst.org/cn=users,cn=accounts,dc=lsst,dc=cloud?uid?sub?(objectClass=posixAccount)"',
              )
            end
          end
        end # host
      end # lsst_sites
    end
  end
end
