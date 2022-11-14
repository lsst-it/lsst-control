# frozen_string_literal: true

require 'spec_helper'

#
# note that this hosts has interfaces with an mtu of 9000
#
describe 'azar03.cp.lsst.org', :site do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts.merge(
          fqdn: 'azar03.cp.lsst.org',
        )
      end

      let(:node_params) do
        {
          role: 'dco',
          site: 'cp',
        }
      end

      it { is_expected.to compile.with_all_deps }

      it do
        is_expected.to contain_class('docker::networks').with(
          'networks' => {
            'dds-network' => {
              'ensure' => 'present',
              'driver' => 'macvlan',
              'subnet' => '139.229.178.0/24',
              'gateway' => '139.229.178.254',
              'options' => ['parent=dds'],
            },
          },
        )
      end

      it do
        is_expected.to contain_network__interface('em1').with(
          bootproto: 'none',
          bridge: 'dds',
          defroute: 'no',
          nozeroconf: 'yes',
          onboot: 'yes',
          type: 'Ethernet',
        )
      end

      it do
        is_expected.to contain_network__interface('em2').with(
          bootproto: 'none',
          bridge: 'startracker',
          defroute: 'no',
          nozeroconf: 'yes',
          onboot: 'yes',
          type: 'Ethernet',
          mtu: '9000',
        )
      end

      it do
        is_expected.to contain_network__interface('dds').with(
          bootproto: 'dhcp',
          defroute: 'yes',
          onboot: 'yes',
          type: 'bridge',
        )
      end

      it do
        is_expected.to contain_network__interface('startracker').with(
          bootproto: 'none',
          defroute: 'no',
          onboot: 'yes',
          type: 'bridge',
          ipaddress: '139.229.169.1',
          netmask: '255.255.255.0',
          mtu: '9000',
        )
      end

      it do
        is_expected.to contain_nfs__client__mount('/net/project').with(
          share: 'project',
          server: 'nfs1.cp.lsst.org',
          atboot: true,
        )
      end

      it do
        is_expected.to contain_nfs__client__mount('/net/scratch').with(
          share: 'scratch',
          server: 'nfs1.cp.lsst.org',
          atboot: true,
        )
      end
    end # on os
  end # on_supported_os
end
