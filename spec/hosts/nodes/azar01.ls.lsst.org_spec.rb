# frozen_string_literal: true

require 'spec_helper'

#
# note that this hosts has interfaces with an mtu of 9000
#
describe 'azar01.ls.lsst.org', :site do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts.merge(
          fqdn: 'azar01.ls.lsst.org',
        )
      end

      let(:node_params) do
        {
          role: 'dco',
          site: 'ls',
        }
      end

      it { is_expected.to compile.with_all_deps }

      it do
        is_expected.to contain_class('docker::networks').with(
          'networks' => {
            'dds-network' => {
              'ensure' => 'present',
              'driver' => 'macvlan',
              'subnet' => '139.229.152.0/25',
              'gateway' => '139.229.152.126',
              'options' => ['parent=dds'],
            },
          },
        )
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
        is_expected.to contain_network__interface('enp129s0f1.2502').with(
          bootproto: 'none',
          bridge: 'dds',
          nozeroconf: 'yes',
          onboot: 'yes',
          type: 'none',
          vlan: 'yes',
        )
      end

      it do
        is_expected.to contain_network__interface('dds').with(
          bootproto: 'dhcp',
          onboot: 'yes',
          type: 'bridge',
        )
      end
    end # on os
  end # on_supported_os
end
