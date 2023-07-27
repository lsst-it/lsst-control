# frozen_string_literal: true

require 'spec_helper'

#
# testing cluster/ruka & cluster/ruka/variant/r440
#
describe 'ruka01.dev.lsst.org', :sitepp do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        override_facts(facts,
                       fqdn: 'ruka01.dev.lsst.org',
                       is_virtual: false,
                       dmi: {
                         'product' => {
                           'name' => 'PowerEdge R440',
                         },
                       })
      end
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
            'ruka' => {
              'group' => 'ruka',
              'member' => 'ruka[01-05]',
            },
          },
        )
      end

      it do
        is_expected.to contain_class('profile::core::rke').with(
          enable_dhcp: true,
          version: '1.4.6-rc4',
        )
      end

      it do
        is_expected.to contain_class('cni::plugins').with(
          version: '1.2.0',
          checksum: 'f3a841324845ca6bf0d4091b4fc7f97e18a623172158b72fc3fdcdb9d42d2d37',
          enable: ['macvlan'],
        )
      end

      if facts[:os]['release']['major'] == '7'
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
            bridge: "br#{vlan_id}",
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
            iprule: ["priority 100 from 139.229.153.0/26 lookup #{rt_id}"],
          )
        end

        it do
          is_expected.to contain_network__routing_table('lhn').with(
            table_id: rt_id,
          )
        end

        it do
          is_expected.to contain_network__mroute('lhnrouting').with(
            table: rt_id,
            routes: [
              '139.229.153.0/24' => "br#{vlan_id}",
              'default' => '139.229.153.254',
            ],
          )
        end
      else
        include_context 'with nm interface'

        it { is_expected.to have_nm__connection_resource_count(2) }

        %w[
          eno1
          eno2
        ].each do |i|
          context "with #{i}" do
            let(:interface) { i }

            it_behaves_like 'nm disabled interface'
          end
        end
      end
    end # on os
  end # on_supported_os
end
