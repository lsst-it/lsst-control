# frozen_string_literal: true

require 'spec_helper'

describe 'perfsonar1.cp.lsst.org', :sitepp do
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
                                'name' => 'AS -1114S-WN10RT',
                              },
                            })
      end
      let(:node_params) do
        {
          role: 'perfsonar',
          site: 'cp',
        }
      end
      let(:lhn_vlan_id) { 1120 }

      it { is_expected.to compile.with_all_deps }

      include_examples 'baremetal'

      it { is_expected.to contain_class('Profile::Core::Nm_dispatch') }
      it { is_expected.to contain_file('/etc/NetworkManager/dispatcher.d/50-eno1').with_content(%r{.*rx 2047 tx 2047.*}) }
      it { is_expected.to contain_file('/etc/NetworkManager/dispatcher.d/50-enp1s0f0').with_content(%r{.*rx 4096 tx 4096.*}) }
      it { is_expected.to contain_file('/etc/NetworkManager/dispatcher.d/50-enp1s0f1').with_content(%r{.*rx 4096 tx 4096.*}) }

      it do
        is_expected.to contain_network__interface('enp1s0f0').with(
          bootproto: 'none',
          onboot: 'yes',
          type: 'Ethernet',
          mtu: '9000',
        )
      end

      it do
        is_expected.to contain_network__interface('enp1s0f1').with(
          bootproto: 'none',
          onboot: 'yes',
          type: 'Ethernet',
          mtu: '9000',
        )
      end

      it do
        is_expected.to contain_network__interface("enp1s0f0.#{lhn_vlan_id}").with(
          bootproto: 'none',
          onboot: 'yes',
          type: 'vlan',
          vlan: 'yes',
          ipaddress: '139.229.164.220',
          netmask: '255.255.255.254',
          nozeroconf: 'yes',
          mtu: '9000',
        )
      end

      it do
        is_expected.to contain_network__mroute("enp1s0f0.#{lhn_vlan_id}").with(
          routes: [
            '139.229.164.0/24' => "enp1s0f0.#{lhn_vlan_id}",
            '139.229.140.135/32' => '139.229.164.254',
            '139.229.140.137/32' => '139.229.164.254',
            '198.32.252.39/32' => '139.229.164.254',
            '198.32.252.192/31' => '139.229.164.254',
            '198.32.252.208/31' => '139.229.164.254',
            '198.32.252.210/31' => '139.229.164.254',
            '198.32.252.216/31' => '139.229.164.254',
            '198.32.252.218/31' => '139.229.164.254',
            '198.32.252.232/31' => '139.229.164.254',
            '198.32.252.234/31' => '139.229.164.254',
            '134.79.235.226/32' => '139.229.164.254',
            '134.79.235.242/32' => '139.229.164.254',
          ],
        )
      end
    end # on os
  end # on_supported_os
end
