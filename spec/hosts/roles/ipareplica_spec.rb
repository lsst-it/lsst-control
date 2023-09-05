# frozen_string_literal: true

require 'spec_helper'

IPA_SERVER_VERSION = '4.6.8'
IPA_SERVER_RELEASE = '5.EL.centos.7'

role = 'ipareplica'

describe "#{role} role" do
  on_supported_os.each do |os, facts|
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

          include_examples 'common', facts: facts, no_auth: true

          it do
            is_expected.to contain_class('tailscale').with_up_options(
              'accept-dns' => false,
              'hostname' => facts[:fqdn],
            )
          end

          %w[
            python2-ipaserver
            ipa-client-common
            python2-ipaclient
            ipa-server-common
            ipa-common
            python2-ipalib
            ipa-client
            ipa-server
          ].each do |pkg|
            it do
              el_release = "el#{facts[:os]['release']['major']}"

              is_expected.to contain_yum__versionlock(pkg).with(
                version: IPA_SERVER_VERSION,
                release: IPA_SERVER_RELEASE.gsub('EL', el_release),
              )
            end
          end
          %w[
            389-ds-base
            389-ds-base-libs
          ].each do |pkg|
            it do
              el_release = "el#{facts[:os]['release']['major']}"

              is_expected.to contain_yum__versionlock(pkg).with(
                version: '1.3.10.2',
                release: '17.el7_9'.gsub('EL', el_release),
              )
            end
          end

          {
            'ipa1.dev.lsst.org': '100.112.180.100',
            'ipa2.dev.lsst.org': '100.71.133.15',
            'ipa1.tu.lsst.org': '100.107.132.55',
            'ipa2.tu.lsst.org': '100.127.11.142',
            'ipa3.tu.lsst.org': '100.87.197.47',
            'ipa1.ls.lsst.org': '100.80.156.142',
            'ipa2.ls.lsst.org': '100.70.18.128',
            'ipa3.ls.lsst.org': '100.100.192.39',
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
        end # host
      end # lsst_sites
    end # on os
  end # on_supported_os
end # role
