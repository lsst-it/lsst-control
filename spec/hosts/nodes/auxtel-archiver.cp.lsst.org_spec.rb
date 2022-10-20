# frozen_string_literal: true

require 'spec_helper'

describe 'auxtel-archiver.cp.lsst.org', :site do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts.merge(
          fqdn: 'auxtel-archiver.cp.lsst.org',
        )
      end

      let(:node_params) do
        {
          role: 'auxtel-archiver',
          site: 'cp',
          cluster: 'auxtel-archiver',
        }
      end

      it { is_expected.to compile.with_all_deps }

      it { is_expected.to contain_class('nfs::server').with_nfs_v4(true) }
      it { is_expected.to contain_nfs__server__export('/data/lsstdata') }
      it { is_expected.to contain_nfs__server__export('/data/repo') }
      it { is_expected.to contain_nfs__server__export('/data/allsky') }

      it do
        is_expected.to contain_nfs__client__mount('/net/self/data/lsstdata').with(
          share: 'lsstdata',
          server: 'auxtel-archiver.cp.lsst.org',
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

      it do
        is_expected.to contain_nfs__client__mount('/net/dimm').with(
          share: 'dimm',
          server: 'nfs1.cp.lsst.org',
          atboot: true,
        )
      end
    end # on os
  end # on_supported_os
end # role
