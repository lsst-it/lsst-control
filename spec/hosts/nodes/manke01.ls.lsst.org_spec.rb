# frozen_string_literal: true

require 'spec_helper'

describe 'manke01.ls.lsst.org', :sitepp do
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
          role: 'rke',
          site: 'ls',
          cluster: 'manke',
        }
      end

      it { is_expected.to compile.with_all_deps }

      include_examples 'baremetal'
      include_context 'with nm interface'
      include_examples 'ceph cluster'
      include_examples 'docker', docker_version: '24.0.9'

      it do
        is_expected.to contain_class('profile::core::sysctl::rp_filter').with_enable(false)
      end

      it do
        is_expected.to contain_class('clustershell').with(
          groupmembers: {
            'manke' => {
              'group' => 'manke',
              'member' => 'manke[01-10]',
            },
          }
        )
      end

      it do
        is_expected.to contain_class('rke').with(
          version: '1.6.2',
          checksum: '68608a97432b4472d3e8f850a7bde0119582ea80fbb9ead923cd831ca97db1d7'
        )
      end

      it do
        is_expected.to contain_class('cni::plugins').with(
          version: '1.2.0',
          checksum: 'f3a841324845ca6bf0d4091b4fc7f97e18a623172158b72fc3fdcdb9d42d2d37',
          enable: ['macvlan']
        )
      end

      it { is_expected.to contain_class('cni::plugins::dhcp') }
      it { is_expected.to contain_class('profile::core::ospl').with_enable_rundir(true) }

      it { is_expected.to have_nm__connection_resource_count(11) }

      %w[
        eno1np0
        eno2np1
        enp4s0f3u2u2c2
        enp129s0f1
      ].each do |i|
        context "with #{i}" do
          let(:interface) { i }

          it_behaves_like 'nm disabled interface'
        end
      end

      context 'with enp129s0f0' do
        let(:interface) { 'enp129s0f0' }

        it_behaves_like 'nm enabled interface'
        it_behaves_like 'nm dhcp interface'
        it_behaves_like 'nm ethernet interface'
      end

      context 'with enp129s0f1.2502' do
        let(:interface) { 'enp129s0f1.2502' }

        it_behaves_like 'nm enabled interface'
        it_behaves_like 'nm vlan interface', id: 2502, parent: 'enp129s0f1'
        it_behaves_like 'nm bridge slave interface', master: 'br2502'
      end

      context 'with br2502' do
        let(:interface) { 'br2502' }

        it_behaves_like 'nm enabled interface'
        it_behaves_like 'nm no-ip interface'
        it_behaves_like 'nm bridge interface'
      end

      context 'with enp129s0f1.2504' do
        let(:interface) { 'enp129s0f1.2504' }

        it_behaves_like 'nm enabled interface'
        it_behaves_like 'nm vlan interface', id: 2504, parent: 'enp129s0f1'
        it_behaves_like 'nm bridge slave interface', master: 'br2504'
      end

      context 'with br2504' do
        let(:interface) { 'br2504' }

        it_behaves_like 'nm enabled interface'
        it_behaves_like 'nm no-ip interface'
        it_behaves_like 'nm bridge interface'
      end

      context 'with enp129s0f1.2505' do
        let(:interface) { 'enp129s0f1.2505' }

        it_behaves_like 'nm enabled interface'
        it_behaves_like 'nm vlan interface', id: 2505, parent: 'enp129s0f1'
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
    end # on os
  end # on_supported_os
end
