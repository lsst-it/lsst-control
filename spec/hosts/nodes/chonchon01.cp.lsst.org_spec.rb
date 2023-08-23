# frozen_string_literal: true

require 'spec_helper'

#
# Testing network interfaces from the chonchon cluster hiera layer. One node in
# the cluster should be sufficient.
#
describe 'chonchon01.cp.lsst.org', :sitepp do
  on_supported_os.each do |os, facts|
    # XXX networking needs to be updated to support EL8+
    next unless os =~ %r{centos-7-x86_64}

    context "on #{os}" do
      let(:facts) do
        override_facts(facts,
                       fqdn: 'chonchon01.cp.lsst.org',
                       is_virtual: false,
                       virtual: 'physical',
                       dmi: {
                         'product' => {
                           'name' => 'PowerEdge R730xd',
                         },
                       })
      end
      let(:node_params) do
        {
          role: 'rke',
          site: 'cp',
          cluster: 'chonchon',
        }
      end
      let(:lhn_vlan_id) { 1800 }

      it { is_expected.to compile.with_all_deps }

      include_examples 'baremetal'
      it { is_expected.to contain_kmod__load('dummy') }

      it do
        is_expected.to contain_kmod__install('dummy').with(
          command: '"/sbin/modprobe --ignore-install dummy; /sbin/ip link set name lhnrouting dev dummy0"',
        )
      end

      it do
        is_expected.to contain_class('profile::core::sysctl::rp_filter').with_enable(false)
      end

      it do
        is_expected.to contain_class('clustershell').with(
          groupmembers: {
            'chonchon' => {
              'group' => 'chonchon',
              'member' => 'chonchon[01-03]',
            },
          },
        )
      end

      it do
        is_expected.to contain_class('profile::core::rke').with(
          enable_dhcp: true,
          version: '1.3.12',
        )
      end

      it do
        is_expected.to contain_class('cni::plugins').with(
          version: '1.2.0',
          checksum: 'f3a841324845ca6bf0d4091b4fc7f97e18a623172158b72fc3fdcdb9d42d2d37',
          enable: ['macvlan'],
        )
      end

      it do
        is_expected.to contain_network__interface("em2.#{lhn_vlan_id}").with(
          bootproto: 'none',
          defroute: 'no',
          nozeroconf: 'yes',
          onboot: 'yes',
          type: 'none',
          vlan: 'yes',
          bridge: "br#{lhn_vlan_id}",
        )
      end

      it do
        is_expected.to contain_network__interface("br#{lhn_vlan_id}").with(
          bootproto: 'none',
          onboot: 'yes',
          type: 'Bridge',
        )
      end

      it do
        is_expected.to contain_network__interface('lhnrouting').with(
          bootproto: 'none',
          nm_controlled: 'no',
          nozeroconf: 'yes',
          onboot: 'yes',
          type: 'Ethernet',
        )
      end

      it do
        is_expected.to contain_network__rule('lhnrouting').with(
          iprule: ["priority 100 from 139.229.180.0/26 lookup #{lhn_vlan_id}"],
        )
      end

      it do
        is_expected.to contain_network__routing_table('lhn').with(
          table_id: lhn_vlan_id,
        )
      end

      it do
        is_expected.to contain_network__mroute('lhnrouting').with(
          table: lhn_vlan_id,
          routes: [
            '139.229.180.0/24' => "br#{lhn_vlan_id}",
            'default' => '139.229.180.254',
          ],
        )
      end
    end # on os
  end # on_supported_os
end
