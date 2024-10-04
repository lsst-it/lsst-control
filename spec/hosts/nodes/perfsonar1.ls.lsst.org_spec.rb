# frozen_string_literal: true

require 'spec_helper'

describe 'perfsonar1.ls.lsst.org', :sitepp do
  on_supported_os.each do |os, os_facts|
    # XXX networking needs to be updated to support EL8+
    next unless os =~ %r{centos-7-x86_64}

    context "on #{os}" do
      let(:facts) do
        lsst_override_facts(os_facts,
                            is_virtual: false,
                            virtual: 'physical',
                            dmi: {
                              'product' => {
                                'name' => 'PowerEdge R340',
                              },
                            })
      end
      let(:node_params) do
        {
          role: 'perfsonar',
          site: 'ls',
        }
      end

      it { is_expected.to compile.with_all_deps }

      include_examples 'baremetal'

      it { is_expected.to contain_file('/etc/NetworkManager/dispatcher.d/50-em1').with_content(%r{rx 2047 tx 511}) }
      it { is_expected.to contain_file('/etc/NetworkManager/dispatcher.d/50-p2p1').with_content(%r{.*rx 4096 tx 4096.*}) }
      it { is_expected.to contain_file('/etc/NetworkManager/dispatcher.d/50-p2p2').with_content(%r{.*rx 4096 tx 4096.*}) }

      %w[p2p1 p2p2].each do |i|
        it do
          is_expected.to contain_network__interface(i).with(
            bootproto: 'none',
            onboot: 'yes',
            type: 'Ethernet',
            mtu: '9000'
          )
        end
      end

      it do
        is_expected.to contain_network__interface('p2p1.360').with(
          bootproto: 'none',
          onboot: 'yes',
          vlan: 'yes',
          type: 'vlan',
          ipaddress: '139.229.140.135',
          netmask: '255.255.255.254',
          nozeroconf: 'yes',
          mtu: '9000'
        )
      end

      it do
        is_expected.to contain_network__interface('p2p1.726').with(
          bootproto: 'none',
          onboot: 'yes',
          vlan: 'yes',
          type: 'vlan',
          ipaddress: '10.7.26.2',
          netmask: '255.255.255.0',
          nozeroconf: 'yes',
          mtu: '9000'
        )
      end

      it do
        is_expected.to contain_network__interface('p2p1.728').with(
          bootproto: 'none',
          onboot: 'yes',
          vlan: 'yes',
          type: 'vlan',
          ipaddress: '10.7.28.1',
          netmask: '255.255.255.0',
          nozeroconf: 'yes',
          mtu: '9000'
        )
      end

      it do
        is_expected.to contain_network__interface('p2p2.370').with(
          bootproto: 'none',
          onboot: 'yes',
          vlan: 'yes',
          type: 'vlan',
          ipaddress: '139.229.140.137',
          netmask: '255.255.255.254',
          nozeroconf: 'yes',
          mtu: '9000'
        )
      end

      it do
        is_expected.to contain_network__interface('p2p2.727').with(
          bootproto: 'none',
          onboot: 'yes',
          vlan: 'yes',
          type: 'vlan',
          ipaddress: '10.7.27.2',
          netmask: '255.255.255.0',
          nozeroconf: 'yes',
          mtu: '9000'
        )
      end

      it do
        is_expected.to contain_network__interface('p2p2.729').with(
          bootproto: 'none',
          onboot: 'yes',
          vlan: 'yes',
          type: 'vlan',
          ipaddress: '10.7.29.1',
          netmask: '255.255.255.0',
          nozeroconf: 'yes',
          mtu: '9000'
        )
      end

      context 'with p2p1.360 routes' do
        let(:via) { '139.229.140.134' }

        it do
          is_expected.to contain_network__mroute('p2p1.360').with(
            routes: [
              '139.229.140.134/31' => 'p2p1.360',
              '139.229.140.0/22' => via,
              '139.229.144.248/32' => via,
              '10.128.0.0/20' => via,
              '10.125.0.0/20' => via,
              '198.17.196.0/24' => via,
              '198.32.252.39/32' => via,
              '198.32.252.192/31' => via,
              '198.32.252.208/31' => via,
              '198.32.252.210/31' => via,
              '198.32.252.216/31' => via,
              '198.32.252.218/31' => via,
              '198.32.252.232/31' => via,
              '198.32.252.234/31' => via,
              '199.36.153.8/30' => via,
              '134.79.235.226/32' => via,
              '134.79.235.242/32' => via,
              '198.124.226.194/32' => via,
              '198.124.226.198/32' => via,
              '198.124.226.202/32' => via,
              '198.124.226.206/32' => via,
            ]
          )
        end
      end

      context 'with p2p2.370 routes' do
        let(:via) { '139.229.140.136' }

        it do
          is_expected.to contain_network__mroute('p2p2.370').with(
            routes: [
              '139.229.140.136/31' => 'p2p2.370',
              '139.229.140.0/22' => via,
              '139.229.144.248/32' => via,
              '10.128.0.0/20' => via,
              '10.125.0.0/20' => via,
              '198.17.196.0/24' => via,
              '198.32.252.194/31' => via,
              '199.36.153.8/30' => via,
              '134.79.235.226/32' => via,
              '134.79.235.242/32' => via,
              '198.124.226.130/32' => via,
              '198.124.226.134/32' => via,
              '198.124.226.138/32' => via,
              '198.124.226.142/32' => via,
            ]
          )
        end
      end
    end # on os
  end # on_supported_os
end
