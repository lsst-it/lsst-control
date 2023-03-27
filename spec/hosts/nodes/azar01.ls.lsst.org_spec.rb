# frozen_string_literal: true

require 'spec_helper'

describe 'azar01.ls.lsst.org', :site do
  alma8 = FacterDB.get_facts({ operatingsystem: 'AlmaLinux', operatingsystemmajrelease: '8' }).first
  # rubocop:disable Naming/VariableNumber
  { 'almalinux-8-x86_64': alma8 }.each do |os, facts|
    # rubocop:enable Naming/VariableNumber
    context "on #{os}" do
      let(:facts) do
        facts.merge(
          fqdn: 'azar01.ls.lsst.org',
        )
      end

      let(:node_params) do
        {
          role: 'dco',
          site: 'ls',
        }
      end

      it { is_expected.to compile.with_all_deps }

      it do
        is_expected.to contain_class('docker::networks').with(
          'networks' => {
            'dds-network' => {
              'ensure' => 'present',
              'driver' => 'macvlan',
              'subnet' => '139.229.152.0/25',
              'gateway' => '139.229.152.126',
              'options' => ['parent=dds'],
            },
          },
        )
      end

      include_context 'with nm interface'

      it { is_expected.to have_network__interface_resource_count(0) }
      it { is_expected.to have_profile__nm__connection_resource_count(7) }

      %w[
        eno1np0
        eno2np1
        enp4s0f3u2u2c2
        enp129s0f1
      ].each do |i|
        context "with #{name}" do
          let(:interface) { i }

          it_behaves_like 'nm disabled interface'
        end
      end

      context 'with enp129s0f0' do
        let(:interface) { 'enp129s0f0' }

        it_behaves_like 'nm named interface'
        it_behaves_like 'nm dhcp interface'
        it { expect(nm_keyfile['connection']['type']).to eq('ethernet') }
        it { expect(nm_keyfile['connection']['autoconnect']).to be_nil }
      end

      context 'with enp129s0f1.2502' do
        let(:interface) { 'enp129s0f1.2502' }

        it_behaves_like 'nm named interface'
        it { expect(nm_keyfile['connection']['type']).to eq('vlan') }
        it { expect(nm_keyfile['connection']['autoconnect']).to be_nil }
        it { expect(nm_keyfile['connection']['master']).to eq('dds') }
        it { expect(nm_keyfile['connection']['slave-type']).to eq('bridge') }
      end

      context 'with dds' do
        let(:interface) { 'dds' }

        it_behaves_like 'nm named interface'
        it { expect(nm_keyfile['connection']['type']).to eq('bridge') }
        it { expect(nm_keyfile['connection']['autoconnect']).to be_nil }
        it { expect(nm_keyfile['bridge']['stp']).to be false }
        it { expect(nm_keyfile['ipv4']['method']).to eq('auto') }
        it { expect(nm_keyfile['ipv6']['method']).to eq('disabled') }
      end
    end # on os
  end # on_supported_os
end
