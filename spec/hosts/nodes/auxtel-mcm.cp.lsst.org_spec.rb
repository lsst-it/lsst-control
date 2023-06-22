# frozen_string_literal: true

require 'spec_helper'

describe 'auxtel-mcm.cp.lsst.org', :sitepp do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts.merge(
          fqdn: 'auxtel-mcm.cp.lsst.org',
        )
      end

      let(:node_params) do
        {
          role: 'atsccs',
          site: 'cp',
          cluster: 'auxtel-ccs',
        }
      end

      it { is_expected.to compile.with_all_deps }

      it { is_expected.to contain_class('nfs').with_server_enabled(false) }
      it { is_expected.to contain_class('nfs').with_client_enabled(false) }
    end # on os
  end # on_supported_os
end # role
