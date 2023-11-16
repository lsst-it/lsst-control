# frozen_string_literal: true

require 'spec_helper'

PUPPETDB_VERSION = '7.14.0'

shared_examples 'puppetdb' do
  it { is_expected.to contain_yum__versionlock('puppetdb').with_version(PUPPETDB_VERSION) }
  it { is_expected.to contain_class('puppetdb::globals').with_version(PUPPETDB_VERSION) }
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

          include_examples 'common', os_facts: os_facts
          include_examples 'puppetdb'
        end # host
      end # lsst_sites
    end
  end
end
