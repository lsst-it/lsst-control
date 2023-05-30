# frozen_string_literal: true

require 'spec_helper'

describe 'tel-hw1.tu.lsst.org', :sitepp do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts.merge(
          fqdn: 'tel-hw1.tu.lsst.org',
        )
      end

      let(:node_params) do
        {
          role: 'amor',
          site: 'tu',
        }
      end

      it { is_expected.to compile.with_all_deps }

      it do
        is_expected.to contain_nfs__client__mount('/net/obs-env').with(
          share: 'obs-env',
          server: 'nfs-obsenv.tu.lsst.org',
          atboot: true,
        )
      end

      it do
        is_expected.to contain_k5login('/home/saluser/.k5login').with(
          ensure: 'present',
          principals: ['saluser/tel-lt1.tu.lsst.org@LSST.CLOUD'],
        )
      end
    end # on os
  end # on_supported_os
end # role
