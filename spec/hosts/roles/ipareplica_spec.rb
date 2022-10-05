# frozen_string_literal: true

require 'spec_helper'

IPA_SERVER_VERSION = '4.6.8'
IPA_SERVER_RELEASE = '5.EL.centos.7'

role = 'ipareplica'

describe "#{role} role" do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts.merge(
          fqdn: self.class.description,
        )
      end

      let(:node_params) do
        {
          role: role,
          site: site,
        }
      end

      lsst_sites.each do |site|
        describe "#{role}.#{site}.lsst.org", :site do
          let(:site) { site }

          it { is_expected.to compile.with_all_deps }

          include_examples 'common', facts: facts, no_auth: true

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
        end # host
      end # lsst_sites
    end # on os
  end # on_supported_os
end # role
