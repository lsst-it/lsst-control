# frozen_string_literal: true

require 'spec_helper'

PUPPETDB_VERSION = '7.14.0'

shared_examples 'puppetdb' do
  it { is_expected.to contain_class('puppetdb::globals').with_version(PUPPETDB_VERSION) }
  it { is_expected.to contain_yum__versionlock('puppetdb').with_version(PUPPETDB_VERSION) }

  it do
    is_expected.to contain_class('puppetdb').with(
      listen_address: '0.0.0.0',
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
end

shared_examples 'puppetboard' do
  it { is_expected.to contain_class('docker') }
  it { is_expected.to contain_cron__job('docker_prune') }
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
          include_examples 'puppetdb'
          include_examples 'puppetboard'
        end # host
      end # lsst_sites
    end
  end
end
