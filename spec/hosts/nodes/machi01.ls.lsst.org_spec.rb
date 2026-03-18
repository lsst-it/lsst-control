# frozen_string_literal: true

require 'spec_helper'

describe 'machi01.ls.lsst.org', :sitepp do
  on_supported_os.each do |os, os_facts|
    next unless os =~ %r{almalinux-9-x86_64}

    context "on #{os}" do
      let(:facts) do
        lsst_override_facts(os_facts,
                            is_virtual: false,
                            virtual: 'physical',
                            dmi: {
                              'product' => {
                                'name' => 'ASG-2015S-E1CR24H',
                              },
                            })
      end
      let(:node_params) do
        {
          role: 'rke2server',
          cluster: 'machi',
          site: 'ls',
          variant: '2015s',
        }
      end

      it { is_expected.to compile.with_all_deps }

      it_behaves_like 'baremetal'
      include_context 'with nm interface'
      it_behaves_like 'ceph cluster'
      it_behaves_like 'lhn sysctls'

      it do
        expect(catalogue.resource('class', 'rke2')[:config]).to include(
          'node-label' => ['role=storage-node'],
        )
      end

      it do
        is_expected.to contain_class('profile::core::sysctl::rp_filter').with_enable(false)
      end

      it do
        is_expected.to contain_class('clustershell').with(
          groupmembers: {
            'machi' => {
              'group' => 'machi',
              'member' => 'machi[01-48]',
            },
            'toki' => {
              'group' => 'toki',
              'member' => 'toki[01-18]',
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
        expect(catalogue.resource('class', 'nm')[:conf]).to include(
          'device' => {
            'keep-configuration' => 'no',
            'allowed-connections' => 'except:origin:nm-initrd-generator',
          },
        )
      end

      it { is_expected.to have_nm__connection_resource_count(10) }

      %w[
        usb0
        enp129s0f0
        enp129s0f1
      ].each do |i|
        context "with #{i}" do
          let(:interface) { i }

          it_behaves_like 'nm disabled interface'
        end
      end

      %w[
        enp130s0f0np0
        enp130s0f1np1
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
        2141
        2505
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
        br2141
        br2505
      ].each do |i|
        context "with #{i}" do
          let(:interface) { i }

          it_behaves_like 'nm enabled interface'
          it_behaves_like 'nm bridge interface'

          if i == 'br2141'
            it_behaves_like 'nm dhcp interface'
          else
            it_behaves_like 'nm no-ip interface'
          end
        end
      end
    end # on os
  end # on_supported_os
end
