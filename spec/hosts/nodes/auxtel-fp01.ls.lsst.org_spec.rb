# frozen_string_literal: true

require 'spec_helper'

describe 'auxtel-fp01.ls.lsst.org', :site do
  alma8 = FacterDB.get_facts({ operatingsystem: 'AlmaLinux', operatingsystemmajrelease: '8' }).first
  # rubocop:disable Naming/VariableNumber
  { 'almalinux-8-x86_64': alma8 }.each do |os, facts|
    # rubocop:enable Naming/VariableNumber
    context "on #{os}" do
      let(:facts) { facts.merge(fqdn: 'auxtel-fp01.ls.lsst.org') }
      let(:node_params) do
        {
          role: 'atsdaq',
          site: 'ls',
          cluster: 'auxtel-ccs',
          variant: '1114s',
          subvariant: 'daq-lhn',
        }
      end

      it { is_expected.to compile.with_all_deps }

      include_context 'with nm interface'
      it { is_expected.to have_network__interface_resource_count(0) }
      it { is_expected.to have_profile__nm__connection_resource_count(10) }

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

        it_behaves_like 'nm named interface'
        it_behaves_like 'nm dhcp interface'
        it { expect(nm_keyfile['connection']['type']).to eq('ethernet') }
        it { expect(nm_keyfile['connection']['autoconnect']).to be_nil }
      end

      context 'with enp129s0f1.2505' do
        let(:interface) { 'enp129s0f1.2505' }

        it_behaves_like 'nm named interface'
        it { expect(nm_keyfile['connection']['type']).to eq('vlan') }
        it { expect(nm_keyfile['connection']['autoconnect']).to be_nil }
        it { expect(nm_keyfile['connection']['master']).to eq('lhn') }
        it { expect(nm_keyfile['connection']['slave-type']).to eq('bridge') }
      end

      context 'with enp197s0f0' do
        let(:interface) { 'enp197s0f0' }

        it_behaves_like 'nm named interface'
        it { expect(nm_keyfile['ethtool']['ring-rx']).to eq(4096) }
        it { expect(nm_keyfile['ethtool']['ring-tx']).to eq(4096) }
      end

      context 'with lhn' do
        let(:interface) { 'lhn' }

        it_behaves_like 'nm named interface'
        it_behaves_like 'nm bridge interface'
        it_behaves_like 'nm dhcp interface'
        it_behaves_like 'nm no default route'
        it { expect(nm_keyfile['ipv4']['route1']).to eq('139.229.153.0/24') }
        it { expect(nm_keyfile['ipv4']['route1_options']).to eq('table=2505') }
        it { expect(nm_keyfile['ipv4']['route2']).to eq('0.0.0.0/0,139.229.153.254') }
        it { expect(nm_keyfile['ipv4']['route2_options']).to eq('table=2505') }
        it { expect(nm_keyfile['ipv4']['routing-rule1']).to eq('priority 100 from 139.229.153.64/26 table 2505') }
      end

      context 'with lsst-daq' do
        let(:interface) { 'lsst-daq' }

        it_behaves_like 'nm named interface'
        it_behaves_like 'nm dhcp interface'
        it_behaves_like 'nm bridge interface'
      end

      it { is_expected.to contain_service('ats-daq-monitor') }
      it { is_expected.to contain_service('ats-fp') }
      it { is_expected.to contain_service('ats-ih') }
      it { is_expected.to contain_service('h2db') }

      it { is_expected.to contain_systemd__unit_file('ats-ih.service').with_content(%r{^User=ccs-ipa}) }

      it { is_expected.to contain_class('nfs::server').with_nfs_v4(true) }
      it { is_expected.to contain_nfs__server__export('/data') }

      it do
        is_expected.to contain_nfs__client__mount('/net/self/data').with(
          share: 'data',
          server: 'auxtel-fp01.ls.lsst.org',
          atboot: true,
        )
      end
    end # on os
  end # on_supported_os
end # role
