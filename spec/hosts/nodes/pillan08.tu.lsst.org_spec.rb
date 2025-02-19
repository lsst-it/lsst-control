# frozen_string_literal: true

require 'spec_helper'

#
# pillan08 is "special" and has different PCI bus addresses for the X550T NIC.
#
describe 'pillan08.tu.lsst.org', :sitepp do
  on_supported_os.each do |os, os_facts|
    next unless os =~ %r{almalinux-9-x86_64}

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
          role: 'rke2agent',
          cluster: 'pillan',
          site: 'tu',
        }
      end

      it { is_expected.to compile.with_all_deps }

      include_examples 'baremetal'
      include_context 'with nm interface'
      include_examples 'ceph cluster'

      it do
        expect(catalogue.resource('class', 'rke2')[:config]).to include(
          'node-label' => include('role=storage-node')
        )
      end

      it do
        is_expected.to contain_class('profile::core::sysctl::rp_filter').with_enable(false)
      end

      it do
        is_expected.to contain_class('clustershell').with(
          groupmembers: {
            'pillan' => {
              'group' => 'pillan',
              'member' => 'pillan[01-09]',
            },
          }
        )
      end

      it do
        is_expected.to contain_class('rke2').with(
          node_type: 'agent',
          release_series: '1.30',
          version: '1.30.7~rke2r1'
        )
      end

      it do
        expect(catalogue.resource('class', 'nm')[:conf]).to include(
          'device' => {
            'keep-configuration' => 'no',
            'allowed-connections' => 'except:origin:nm-initrd-generator',
          }
        )
      end

      it { is_expected.to contain_class('cni::plugins::dhcp') }
      it { is_expected.to contain_class('profile::core::ospl').with_enable_rundir(true) }

      # 2 extra instances in the catalog for the rename interfaces
      it { is_expected.to have_nm__connection_resource_count(14 + 2) }

      %w[
        enp4s0f3u2u2c2
      ].each do |i|
        context "with #{i}" do
          let(:interface) { i }

          it_behaves_like 'nm disabled interface'
        end
      end

      %w[
        eno1np0
        eno2np1
        enp197s0f0
        enp197s0f1
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
        it_behaves_like 'nm dhcp interface'
        it_behaves_like 'nm bond interface'
      end

      Hash[*%w[
        bond0.3035 br3035
        bond0.3065 br3065
        bond0.3075 br3075
        bond0.3085 br3085
      ]].each do |slave, master|
        context "with #{slave}" do
          let(:interface) { slave }

          it_behaves_like 'nm enabled interface'
          it_behaves_like 'nm bridge slave interface', master:
        end
      end

      %w[
        br3065
        br3065
        br3085
      ].each do |i|
        context "with #{i}" do
          let(:interface) { i }

          it_behaves_like 'nm enabled interface'
          it_behaves_like 'nm bridge interface'
          it_behaves_like 'nm no-ip interface'
        end
      end

      context 'with br3035' do
        let(:interface) { 'br3035' }
        let(:vlan) { '3035' }

        it_behaves_like 'nm enabled interface'
        it_behaves_like 'nm no-ip interface'
        it_behaves_like 'nm bridge interface'
      end
    end # on os
  end # on_supported_os
end
