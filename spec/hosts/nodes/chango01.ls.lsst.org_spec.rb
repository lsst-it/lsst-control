# frozen_string_literal: true

require 'spec_helper'

describe 'chango01.ls.lsst.org', :sitepp do
  on_supported_os.each do |os, os_facts|
    next unless os =~ %r{almalinux-9-x86_64}

    context "on #{os}" do
      let(:facts) do
        lsst_override_facts(os_facts,
                            is_virtual: false,
                            virtual: 'physical',
                            dmi: {
                              'product' => {
                                'name' => 'SSG-640SP-E1CR90',
                              },
                            })
      end
      let(:node_params) do
        {
          role: 'rke2server',
          site: 'ls',
          cluster: 'chango',
        }
      end

      it { is_expected.to compile.with_all_deps }

      it_behaves_like 'baremetal'
      include_context 'with nm interface'

      it do
        expect(catalogue.resource('class', 'rke2')[:config]).to include(
          'kubelet-arg' => ['system-reserved=memory=4Gi', 'kube-reserved=memory=4Gi', 'image-gc-high-threshold=70', 'image-gc-low-threshold=60'],
          'node-label' => ['role=storage-node'],
        )
      end

      it do
        is_expected.to contain_class('clustershell').with(
          groupmembers: {
            'chango' => {
              'group' => 'chango',
              'member' => 'chango[01-03]',
            },
          },
        )
      end

      it do
        is_expected.to contain_class('rke2').with(
          node_type: 'server',
          release_series: '1.35',
          version: '1.35.3~rke2r1',
        )
      end

      it { is_expected.to have_nm__connection_resource_count(5) }

      %w[
        eno1
        eno2
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

      context 'with bond0.2144' do
        let(:interface) { 'bond0.2144' }

        it_behaves_like 'nm enabled interface'
        it_behaves_like 'nm vlan interface', id: 2144, parent: 'bond0'
        it_behaves_like 'nm bridge slave interface', master: 'br2144'
      end

      context 'with br2144' do
        let(:interface) { 'br2144' }

        it_behaves_like 'nm enabled interface'
        it_behaves_like 'nm bridge interface'
        it_behaves_like 'nm dhcp interface'
      end
    end # on os
  end # on_supported_os
end
