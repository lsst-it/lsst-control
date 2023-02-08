# frozen_string_literal: true

require 'spec_helper'

#
# note that this hosts has interfaces with an mtu of 9000
#
describe 'bastion01.cp.lsst.org', :site do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts.merge(
          fqdn: 'bastion01.cp.lsst.org',
        )
      end

      let(:node_params) do
        {
          role: 'bastion',
          site: 'cp',
        }
      end

      it { is_expected.to compile.with_all_deps }

      it { is_expected.to contain_class('profile::core::nfsclient') }

      it do
        is_expected.to contain_nfs__client__mount('/project').with(
          share: 'project',
          server: 'nfs1.cp.lsst.org',
          atboot: true,
        )
      end

      it do
        is_expected.to contain_nfs__client__mount('/scratch').with(
          share: 'scratch',
          server: 'nfs1.cp.lsst.org',
          atboot: true,
        )
      end

      it do
        is_expected.to contain_nfs__client__mount('/lsstdata').with(
          share: 'lsstdata',
          server: 'nfs1.cp.lsst.org',
          atboot: true,
        )
      end

      it do
        is_expected.to contain_nfs__client__mount('/readonly/lsstdata/auxtel').with(
          share: 'lsstdata',
          server: 'auxtel-archiver.cp.lsst.org',
          atboot: true,
        )
      end
    end # on os
  end # on_supported_os
end
