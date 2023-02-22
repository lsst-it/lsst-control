# frozen_string_literal: true

require 'spec_helper'

describe 'auxtel-dc01.ls.lsst.org', :site do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts.merge(
          fqdn: 'auxtel-dc01.ls.lsst.org',
        )
      end

      let(:node_params) do
        {
          role: 'atsccs',
          site: 'ls',
          cluster: 'auxtel-ccs',
        }
      end

      it { is_expected.to compile.with_all_deps }

      it do
        is_expected.to contain_network__interface('enp129s0f0').with(
          bootproto: 'dhcp',
          defroute: 'yes',
          nozeroconf: 'yes',
          onboot: 'yes',
          type: 'Ethernet',
        )
      end

      it do
        is_expected.to contain_network__interface('enp129s0f1').with(
          bootproto: 'none',
          nozeroconf: 'yes',
          onboot: 'yes',
          type: 'Ethernet',
        )
      end

      it do
        is_expected.to contain_network__interface('lhn').with(
          vlan: 'yes',
          type: 'Vlan',
          physdev: 'enp129s0f1',
          vlan_id: '2505',
          bootproto: 'dhcp',
          defroute: 'yes',
          name: 'dds',
          onboot: 'yes',
        )
      end

      it do
        is_expected.to contain_nfs__client__mount('/data').with(
          share: 'data',
          server: 'auxtel-fp01.ls.lsst.org',
          atboot: true,
        )
      end

      it do
        is_expected.to contain_nfs__client__mount('/repo').with(
          share: 'repo',
          server: 'auxtel-archiver.ls.lsst.org',
          atboot: true,
        )
      end
    end # on os
  end # on_supported_os
end # role
