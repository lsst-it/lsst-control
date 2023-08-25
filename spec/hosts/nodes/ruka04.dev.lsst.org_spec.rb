# frozen_string_literal: true

require 'spec_helper'

#
# primarily testing cluster/ruka/variant/r430; for ruka cluster layer spec see
# ruka01.dev.lsst.org.yaml
#
describe 'ruka04.dev.lsst.org', :sitepp do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        override_facts(facts,
                       fqdn: 'ruka04.dev.lsst.org',
                       is_virtual: false,
                       virtual: 'physical',
                       dmi: {
                         'product' => {
                           'name' => 'PowerEdge R430',
                         },
                       })
      end
      let(:node_params) do
        {
          role: 'rke',
          site: 'dev',
          cluster: 'ruka',
          variant: 'r430',
        }
      end
      let(:vlan_id) { 2505 }

      it { is_expected.to compile.with_all_deps }

      include_examples 'baremetal'

      if facts[:os]['release']['major'] == '7'
        it { is_expected.to contain_kmod__load('dummy') }

        it do
          is_expected.to contain_kmod__install('dummy').with(
            command: '"/sbin/modprobe --ignore-install dummy; /sbin/ip link set name lhnrouting dev dummy0"',
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
          is_expected.to contain_network__interface('p1p1').with(
            bootproto: 'dhcp',
            defroute: 'yes',
            onboot: 'yes',
            type: 'Ethernet',
          )
        end

        it do
          is_expected.to contain_network__interface('p1p2').with(
            bootproto: 'none',
            onboot: 'no',
            type: 'Ethernet',
          )
        end

        it do
          is_expected.to contain_network__interface("p1p2.#{vlan_id}").with(
            bootproto: 'none',
            defroute: 'no',
            nozeroconf: 'yes',
            onboot: 'yes',
            type: 'none',
            vlan: 'yes',
            bridge: "br#{vlan_id}",
          )
        end
      else
        include_context 'with nm interface'

        it { is_expected.to have_nm__connection_resource_count(8) }

        %w[
          eno1
          eno2
          eno3
          eno4
          enp5s0f1
        ].each do |i|
          context "with #{i}" do
            let(:interface) { i }

            it_behaves_like 'nm disabled interface'
          end
        end

        context 'with enp5s0f0' do
          let(:interface) { 'enp5s0f0' }

          it_behaves_like 'nm enabled interface'
          it_behaves_like 'nm dhcp interface'
          it_behaves_like 'nm ethernet interface'
        end

        context 'with enp5s0f1.2505' do
          let(:interface) { 'enp5s0f1.2505' }

          it_behaves_like 'nm enabled interface'
          it_behaves_like 'nm vlan interface', id: 2505, parent: 'enp5s0f1'
          it_behaves_like 'nm bridge slave interface', master: 'br2505'
        end

        context 'with br2505' do
          let(:interface) { 'br2505' }

          it_behaves_like 'nm enabled interface'
          it_behaves_like 'nm no-ip interface'
          it_behaves_like 'nm bridge interface'
          it { expect(nm_keyfile['ipv4']['route1']).to eq('139.229.153.0/24') }
          it { expect(nm_keyfile['ipv4']['route1_options']).to eq('table=2505') }
          it { expect(nm_keyfile['ipv4']['route2']).to eq('0.0.0.0/0,139.229.153.254') }
          it { expect(nm_keyfile['ipv4']['route2_options']).to eq('table=2505') }
          it { expect(nm_keyfile['ipv4']['routing-rule1']).to eq('priority 100 from 139.229.153.64/26 table 2505') }
        end
      end
    end # on os
  end # on_supported_os
end
