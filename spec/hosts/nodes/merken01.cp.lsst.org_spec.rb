# frozen_string_literal: true

require 'spec_helper'

describe 'merken01.cp.lsst.org', :sitepp do
  on_supported_os.each do |os, os_facts|
    next unless os =~ %r{almalinux-9-x86_64}

    context "on #{os}" do
      let(:facts) do
        lsst_override_facts(os_facts,
                            is_virtual: false,
                            virtual: 'physical',
                            dmi: {
                              'product' => {
                                'name' => 'AS -1115HS-TNR',
                              },
                            })
      end
      let(:node_params) do
        {
          role: 'rke2server',
          site: 'cp',
          cluster: 'merken',
        }
      end

      it { is_expected.to compile.with_all_deps }

      it_behaves_like 'baremetal'
      include_context 'with nm interface'
      it_behaves_like 'ceph cluster'

      it { is_expected.to contain_class('tuned').with_active_profile('latency-performance') }

      it do
        is_expected.to contain_class('clustershell').with(
          groupmembers: {
            'merken' => {
              'group' => 'merken',
              'member' => 'merken[01-04]',
            },
          },
        )
      end

      it do
        is_expected.to contain_class('rke2').with(
          node_type: 'server',
          release_series: '1.33',
          version: '1.33.0~rke2r1',
        )
      end

      it do
        # Ensure the storage role label is applied to the RKE2 server node
        expect(catalogue.resource('class', 'rke2')[:config]['node-label']).to include('role=storage-node')
      end

      it do
        expect(catalogue.resource('class', 'nm')[:conf]).to include(
          'device' => {
            'keep-configuration' => 'no',
            'allowed-connections' => 'except:origin:nm-initrd-generator',
          },
        )
      end

      it { is_expected.to have_nm__connection_resource_count(8) }

      %w[
        enp12s0f4u1u2c2
      ].each do |i|
        context "with #{i}" do
          let(:interface) { i }

          it_behaves_like 'nm disabled interface'
        end
      end

      %w[
        enp65s0f0
        enp65s0f1
      ].each do |i|
        context "with #{i}" do
          let(:interface) { i }

          it_behaves_like 'nm named interface'
          it_behaves_like 'nm ethernet interface'
          it_behaves_like 'nm no-ip interface'
          it { expect(nm_keyfile['connection']['master']).to eq('bond0') }
          it { expect(nm_keyfile['connection']['slave-type']).to eq('bond') }
          it { expect(nm_keyfile_raw).to match(%r{^\[ethernet\]$}) }
          it { expect(nm_keyfile_raw).to match(%r{^\[ipv4\]$}) }
          it { expect(nm_keyfile_raw).to match(%r{^\[ipv6\]$}) }
        end
      end

      context 'with bond0' do
        let(:interface) { 'bond0' }

        it_behaves_like 'nm named interface'
        it_behaves_like 'nm no-ip interface'
        it { expect(nm_keyfile['connection']['type']).to eq('bond') }
        it { expect(nm_keyfile['bond']['miimon']).to eq(100) }
        it { expect(nm_keyfile['bond']['mode']).to eq('802.3ad') }
        it { expect(nm_keyfile['bond']['xmit_hash_policy']).to eq('layer3+4') }
        it { expect(nm_keyfile_raw).to match(%r{^\[ethernet\]$}) }
        it { expect(nm_keyfile_raw).not_to match(%r{^\[proxy\]$}) }
      end

      %w[
        1131
      ].each do |vlan|
        iface = "bond0.#{vlan}"

        context "with #{iface}" do
          let(:interface) { iface }

          it_behaves_like 'nm enabled interface'
          it_behaves_like 'nm vlan interface', id: vlan.to_i, parent: 'bond0'
          it_behaves_like 'nm bridge slave interface', master: "br#{vlan}"
        end
      end

      context 'with br1131' do
        let(:interface) { 'br1131' }

        it_behaves_like 'nm enabled interface'
        it_behaves_like 'nm bridge interface'
        it_behaves_like 'nm dhcp interface'
      end
    end # on os
  end # on_supported_os
end
