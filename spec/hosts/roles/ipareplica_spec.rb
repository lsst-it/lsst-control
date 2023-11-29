# frozen_string_literal: true

require 'spec_helper'

role = 'ipareplica'

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
        override_facts(os_facts, fqdn: fqdn, networking: { fqdn => fqdn })

        describe fqdn, :sitepp do
          let(:site) { site }

          it { is_expected.to compile.with_all_deps }

          include_examples 'common', os_facts: os_facts, no_auth: true

          it do
            is_expected.to contain_class('tailscale').with_up_options(
              'accept-dns' => false,
              'hostname' => facts[:fqdn],
            )
          end

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
                ip: ip,
              )
            end
          end

          it do
            is_expected.to contain_ini_setting('/etc/ipa/default.conf [global] host').with_value(facts[:fqdn])
          end

          it do
            is_expected.to contain_ini_setting('/etc/ipa/default.conf [global] server').with_value(facts[:fqdn])
          end

          it do
            is_expected.to contain_ini_setting('/etc/ipa/default.conf [global] xmlrpc_uri').with_value("https://#{facts[:fqdn]}/ipa/xml")
          end

          it do
            is_expected.to contain_class('openldap::client').with_uri("ldaps://#{facts[:fqdn]}")
          end

          case os
          when 'centos-7-x86_64'
            %w[
              ipa-client
              ipa-client-common
              ipa-common
              ipa-server
              ipa-server-common
              python2-ipaclient
              python2-ipalib
              python2-ipaserver
            ].each do |pkg|
              it do
                is_expected.to contain_yum__versionlock(pkg).with(
                  version: '4.6.8',
                  release: '5.el7.centos.15',
                )
              end
            end
            %w[
              389-ds-base
              389-ds-base-libs
            ].each do |pkg|
              it do
                is_expected.to contain_yum__versionlock(pkg).with(
                  version: '1.3.11.1',
                  release: '3.el7_9',
                )
              end
            end
          end
        end # host
      end # lsst_sites
    end # on os
  end # on_supported_os
end # role
