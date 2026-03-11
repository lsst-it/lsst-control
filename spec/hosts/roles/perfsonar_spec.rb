# frozen_string_literal: true

require 'spec_helper'

role = 'perfsonar'

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

          let(:le_root) { "/etc/letsencrypt/live/#{facts[:networking]['fqdn']}" }
          let(:perfsonar_version) { '5.1.4' }

          it { is_expected.to compile.with_all_deps }

          it_behaves_like('common', os_facts:, site:)
          it_behaves_like('generic perfsonar', os_facts:)
          it_behaves_like 'ipset'
          it_behaves_like('firewall default', os_facts:)
          it_behaves_like('firewall node_exporter scraping', site:)

          it do
            is_expected.to contain_yum__versionlock('perfsonar-toolkit').with(
              version: perfsonar_version,
            )
          end

          it do
            is_expected.to contain_file('/etc/perfsonar/psconfig/pscheduler-agent.json').with(
              ensure: 'file',
              content: <<~JSON,
                {
                  "remotes": [
                    {
                      "url": "https://ps-cma.amlight.net/psconfig/lhn-psconfig.json",
                      "configure-archives": true
                    }
                  ]
                }
              JSON
            )
          end

          it do
            is_expected.to contain_firewall('400 accept ssh').with(
              proto: 'tcp',
              state: 'NEW',
              ipset: 'aura src',
              dport: '22',
              jump: 'accept',
            )
          end
        end # host
      end # lsst_sites
    end # on os
  end # on_supported_os
end # role
