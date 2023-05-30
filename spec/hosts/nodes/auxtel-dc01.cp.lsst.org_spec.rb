# frozen_string_literal: true

require 'spec_helper'

describe 'auxtel-dc01.cp.lsst.org', :sitepp do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts.merge(
          fqdn: 'auxtel-dc01.cp.lsst.org',
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

      it do
        is_expected.to contain_nfs__client__mount('/data').with(
          share: 'data',
          server: 'auxtel-fp01.cp.lsst.org',
          atboot: true,
        )
      end

      it do
        is_expected.to contain_nfs__client__mount('/repo').with(
          share: 'repo',
          server: 'auxtel-archiver.cp.lsst.org',
          atboot: true,
        )
      end
    end # on os
  end # on_supported_os
end # role
