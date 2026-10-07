# frozen_string_literal: true

require 'spec_helper'

role = 'ipamaster'

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

          include_examples 'common', os_facts:, site:, no_auth: true

          # it do
          #   is_expected.to contain_class('tailscale').with_up_options(
          #     'accept-dns' => false,
          #     'hostname' => facts[:networking]['fqdn']
          #   )
          # end

          it { is_expected.to contain_class('hosts').with_manage_fqdn(false) }

          {
            'ipa1.dev.lsst.org': '100.76.95.74',
            'ipa2.dev.lsst.org': '100.77.145.58',
            'ipa3.dev.lsst.org': '100.66.153.135',
            'ipa1.tu.lsst.org': '100.110.133.58',
            'ipa2.tu.lsst.org': '100.127.11.142',
            'ipa3.tu.lsst.org': '100.126.127.154',
            'ipa1.ls.lsst.org': '100.76.175.89',
            'ipa2.ls.lsst.org': '100.81.221.120',
            'ipa3.ls.lsst.org': '100.80.142.127',
            'ipa1.cp.lsst.org': '100.97.236.28',
            'ipa2.cp.lsst.org': '100.91.143.57',
            'ipa3.cp.lsst.org': '100.94.76.56',
          }.each do |host, ip|
            it do
              is_expected.to contain_host(host).with(
                ip:
              )
            end
          end

          it do
            is_expected.to contain_ini_setting('/etc/ipa/default.conf [global] host').with_value(facts[:networking]['fqdn'])
          end

          it do
            is_expected.to contain_ini_setting('/etc/ipa/default.conf [global] server').with_value(facts[:networking]['fqdn'])
          end

          it do
            is_expected.to contain_ini_setting('/etc/ipa/default.conf [global] xmlrpc_uri').with_value("https://#{facts[:networking]['fqdn']}/ipa/xml")
          end

          it do
            is_expected.to contain_class('openldap::client').with_uri("ldaps://#{facts[:networking]['fqdn']}")
          end

          it { is_expected.to contain_exec('ipa-server-install').with(command: %r{--hostname=#{facts[:networking]['fqdn']}}) }
          it { is_expected.to contain_exec('ipa-server-install').with(command: %r{--realm=LSST.CLOUD}) }
          it { is_expected.to contain_exec('ipa-server-install').with(command: %r{--domain=lsst.cloud}) }
          it { is_expected.to contain_exec('ipa-server-install').with(command: %r{--no-ntp}) }
          it { is_expected.to contain_exec('ipa-server-install').with(command: %r{--idstart=70000}) }
          it { is_expected.to contain_exec('ipa-server-install').with(command: %r{--idmax=79999}) }
        end # host
      end # lsst_sites
    end # on os
  end # on_supported_os
end # role
