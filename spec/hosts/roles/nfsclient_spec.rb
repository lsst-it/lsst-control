# frozen_string_literal: true

require 'spec_helper'

role = 'nfsclient'

describe "#{role} role" do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      describe 'nfsclient.cp.lsst.org', :sitepp do
        site = 'cp'
        let(:site) { site }
        let(:node_params) do
          {
            role:,
            site:,
          }
        end
        let(:facts) { lsst_override_facts(os_facts) }

        it { is_expected.to compile.with_all_deps }

        include_examples('common', os_facts:, site:)

        it do
          is_expected.to contain_class('nfs').with(
            server_enabled: false,
            client_enabled: true,
            nfs_v4_client: true
          )
        end
      end
    end # on os
  end # on_supported_os
end # role
