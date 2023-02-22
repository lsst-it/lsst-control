# frozen_string_literal: true

require 'spec_helper'

describe 'lsstcam-mcm.ls.lsst.org', :site do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts.merge(
          fqdn: 'lsstcam-mcm.ls.lsst.org',
        )
      end

      let(:node_params) do
        {
          role: 'ccs-mcm',
          site: 'ls',
          cluster: 'lsstcam-ccs',
        }
      end

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
        is_expected.to contain_network__interface('dds').with(
          vlan: 'yes',
          type: 'Vlan',
          physdev: 'enp129s0f1',
          vlan_id: '2502',
          bootproto: 'dhcp',
          defroute: 'yes',
          name: 'dds',
          onboot: 'yes',
        )
      end

      it { is_expected.to compile.with_all_deps }

    end # on os
  end # on_supported_os
end # role
