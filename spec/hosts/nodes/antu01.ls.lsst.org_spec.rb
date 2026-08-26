# frozen_string_literal: true

require 'spec_helper'

describe 'antu01.ls.lsst.org', :sitepp do
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
          site: 'ls',
          cluster: 'antu',
        }
      end

      it { is_expected.to compile.with_all_deps }

      it_behaves_like 'baremetal'
      include_context 'with nm interface'
      it_behaves_like 'ceph cluster'

      it do
        expect(catalogue.resource('class', 'rke2')[:config]).to include(
          'kubelet-arg' => ['system-reserved=memory=4Gi', 'kube-reserved=memory=4Gi', 'image-gc-high-threshold=70', 'image-gc-low-threshold=60'],
          'node-label' => ['role=storage-node'],
        )
      end

      it do
        is_expected.to contain_class('profile::core::sysctl::rp_filter').with_enable(false)
      end

      it do
        is_expected.to contain_class('clustershell').with(
          groupmembers: {
            'antu' => {
              'group' => 'antu',
              'member' => 'antu[01-04]',
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

          it_behaves_like 'nm enabled interface'
          it_behaves_like 'nm ethernet interface'
          it_behaves_like 'nm bond slave interface', master: 'bond0'
        end
      end

      context 'with bond0' do
        let(:interface) { 'bond0' }

        it_behaves_like 'nm enabled interface'
        it_behaves_like 'nm bond interface'
        it_behaves_like 'nm no-ip interface'
      end

      %w[
        2130
        2131
      ].each do |vlan|
        iface = "bond0.#{vlan}"
        context "with #{iface}" do
          let(:interface) { iface }

          it_behaves_like 'nm enabled interface'
          it_behaves_like 'nm vlan interface', id: vlan.to_i, parent: 'bond0'
          it_behaves_like 'nm bridge slave interface', master: "br#{vlan}"
        end
      end

      %w[
        br2130
        br2131
      ].each do |i|
        context "with #{i}" do
          let(:interface) { i }

          it_behaves_like 'nm enabled interface'
          it_behaves_like 'nm bridge interface'

          if i == 'br2131'
            it_behaves_like 'nm dhcp interface'
          else
            it_behaves_like 'nm no-ip interface'
          end
        end
      end
    end # on os
  end # on_supported_os
end
