# frozen_string_literal: true

require 'spec_helper'

role = 'tang'

describe "#{role} role" do
  on_supported_os.each do |os, facts|
    next unless os =~ %r{almalinux-9-x86_64}

    context "on #{os}" do
      let(:facts) { facts }
      let(:node_params) do
        {
          role: role,
          site: site,
        }
      end

      lsst_sites.each do |site|
        fqdn = "#{role}.#{site}.lsst.org"
        override_facts(facts, fqdn: fqdn, networking: { fqdn => fqdn })

        describe fqdn, :sitepp do
          let(:site) { site }

          it { is_expected.to compile.with_all_deps }

          include_examples 'common', facts: facts
          include_examples 'ipset'
          include_examples 'firewall default', facts: facts
          include_examples 'firewall node_exporter scraping', site: site

          it { is_expected.to contain_class('tang') }
          it { is_expected.to contain_package('jose') }

          case site
          when 'dev'
            it do
              is_expected.to contain_firewall('200 accept tang').with(
                proto: 'tcp',
                state: 'NEW',
                ipset: 'dev src',
                dport: '7500',
                action: 'accept',
                require: 'Ipset::Set[dev]',
              )
            end
          end
        end # host
      end # lsst_sites
    end # on os
  end # on_supported_os
end # role
