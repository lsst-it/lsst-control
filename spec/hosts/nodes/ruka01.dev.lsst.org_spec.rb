# frozen_string_literal: true

require 'spec_helper'

#
# testing cluster/ruka & cluster/ruka/variant/r440
#
describe 'ruka01.dev.lsst.org', :site do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { override_facts(facts, fqdn: 'ruka01.dev.lsst.org') }

      let(:node_params) do
        {
          role: 'rke',
          site: 'dev',
          cluster: 'ruka',
          variant: 'r440',
        }
      end
      let(:vlan_id) { 2505 }
      let(:rt_id) { vlan_id }

      it { is_expected.to compile.with_all_deps }
      it { is_expected.to contain_class('profile::core::ifdown').with_interface('em1') }

      it do
        is_expected.to contain_class('profile::core::rke').with(
          enable_dhcp: true,
          version: '1.3.12',
        )
      end

      it do
        is_expected.to contain_class('cni::plugins').with(
          checksum: '962100bbc4baeaaa5748cdbfce941f756b1531c2eadb290129401498bfac21e7',
          version: '0.9.1',
          enable: ['macvlan'],
        )
      end

      it do
        is_expected.to contain_network__interface('em1').with(
          bootproto: 'none',
          onboot: 'no',
          type: 'Ethernet',
        )
      end

      it do
        is_expected.to contain_network__interface('p2p2').with(
          bootproto: 'dhcp',
          defroute: 'yes',
          onboot: 'yes',
          type: 'Ethernet',
        )
      end

      it do
        is_expected.to contain_network__interface('p2p1').with(
          bootproto: 'none',
          onboot: 'no',
          type: 'Ethernet',
        )
      end

      it do
        is_expected.to contain_network__interface("p2p1.#{vlan_id}").with(
          bootproto: 'none',
          defroute: 'no',
          nozeroconf: 'yes',
          onboot: 'yes',
          type: 'none',
          vlan: 'yes',
        )
      end

      it do
        is_expected.to contain_network__rule("p2p1.#{vlan_id}").with(
          iprule: ["priority 100 from 139.229.153.0/25 lookup #{rt_id}"],
        )
      end

      it do
        is_expected.to contain_network__routing_table('lhn').with(
          table_id: rt_id,
        )
      end

      it do
        is_expected.to contain_network__mroute("p2p1.#{vlan_id}").with(
          table: rt_id,
          routes: [
            '139.229.153.0/24' => "p2p1.#{vlan_id}",
            'default' => '139.229.153.251',
          ],
        )
      end
    end # on os
  end # on_supported_os
end
