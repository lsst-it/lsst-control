# frozen_string_literal: true

require 'spec_helper'

role = 'perfsonar'

describe "#{role} role" do
  on_supported_os.each do |os, os_facts|
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
        override_facts(os_facts, fqdn: fqdn, networking: { 'fqdn' => fqdn })

        describe fqdn, :sitepp do
          let(:site) { site }

          let(:le_root) { "/etc/letsencrypt/live/#{facts[:fqdn]}" }
          let(:perfsonar_version) { '4.4.6' }

          it { is_expected.to compile.with_all_deps }

          include_examples 'common', os_facts: os_facts, site: site
          include_examples 'generic perfsonar', os_facts: os_facts
          include_examples 'ipset'
          include_examples 'firewall default', os_facts: os_facts
          include_examples 'firewall node_exporter scraping', site: site

          it do
            is_expected.to contain_yum__versionlock('perfsonar-toolkit').with(
              version: perfsonar_version,
            )
          end

          it do
            is_expected.to contain_firewall('400 accept ssh').with(
              proto: 'tcp',
              state: 'NEW',
              ipset: 'aura src',
              dport: '22',
              action: 'accept',
            )
          end
        end # host
      end # lsst_sites
    end # on os
  end # on_supported_os
end # role
