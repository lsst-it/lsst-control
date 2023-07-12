# frozen_string_literal: true

require 'spec_helper'

describe 'perfsonar1.cp.lsst.org', :sitepp do
  on_supported_os.each do |os, facts|
    next if os =~ %r{centos-7-x86_64}

    context "on #{os}" do
      let(:facts) do
        override_facts(facts,
                       fqdn: 'perfsonar1.cp.lsst.org',
                       is_virtual: false,
                       dmi: {
                         'product' => {
                           'name' => 'AS -1114S-WN10RT',
                         },
                       })
      end
      let(:node_params) do
        {
          role: 'perfsonar',
          site: 'cp',
        }
      end

      it { is_expected.to compile.with_all_deps }

      include_examples 'baremetal'
      include_context 'with nm interface'

      it { is_expected.to contain_class('Profile::Core::Nm_dispatch') }
      it { is_expected.to contain_file('/etc/NetworkManager/dispatcher.d/50-eno1').with_content(%r{.*rx 2047 tx 2047.*}) }
      it { is_expected.to contain_file('/etc/NetworkManager/dispatcher.d/50-enp1s0f0').with_content(%r{.*rx 4096 tx 4096.*}) }
      it { is_expected.to contain_file('/etc/NetworkManager/dispatcher.d/50-enp1s0f1').with_content(%r{.*rx 4096 tx 4096.*}) }

      it { is_expected.to have_network__interface_resource_count(0) }
      it { is_expected.to have_profile__nm__connection_resource_count(9) }

      %w[
        enp5s0f3u2u2c2
        eno2np1
      ].each do |i|
        context "with #{i}" do
          let(:interface) { i }

          it_behaves_like 'nm disabled interface'
        end
      end

      context 'with eno1np0' do
        let(:interface) { 'eno1np0' }

        it_behaves_like 'nm named interface'
        it { expect(nm_keyfile['connection']['autoconnect']).to be true }

        it_behaves_like 'nm dhcp interface'
        it_behaves_like 'nm ethernet interface'
      end

      context 'with enp1s0f0' do
        let(:interface) { 'enp1s0f0' }

        it_behaves_like 'nm named interface'
        it { expect(nm_keyfile['connection']['autoconnect']).to be false }

        it_behaves_like 'nm no-ip interface'
        it_behaves_like 'nm ethernet interface'
      end

      context 'with enp1s0f0.1120' do
        let(:interface) { 'enp1s0f0.1120' }

        it_behaves_like 'nm enabled interface'
        it_behaves_like 'nm vlan interface', id: 1120, parent: 'enp1s0f0'
        it_behaves_like 'nm bridge slave interface', master: 'bra1120'
      end

      context 'with bra1120' do
        let(:interface) { 'bra1120' }

        it_behaves_like 'nm enabled interface'
        it_behaves_like 'nm dhcp interface'
        it_behaves_like 'nm bridge interface'
      end

      context 'with enp1s0f1' do
        let(:interface) { 'enp1s0f1' }

        it_behaves_like 'nm named interface'
        it { expect(nm_keyfile['connection']['autoconnect']).to be false }

        it_behaves_like 'nm no-ip interface'
        it_behaves_like 'nm ethernet interface'
      end

      context 'with enp1s0f1.1120' do
        let(:interface) { 'enp1s0f1.1120' }

        it_behaves_like 'nm enabled interface'
        it_behaves_like 'nm vlan interface', id: 1120, parent: 'enp1s0f1'
        it_behaves_like 'nm bridge slave interface', master: 'brb1120'
      end

      context 'with brb1120' do
        let(:interface) { 'brb1120' }

        it_behaves_like 'nm enabled interface'
        it_behaves_like 'nm dhcp interface'
        it_behaves_like 'nm bridge interface'
      end
    end # on os
  end # on_supported_os
end
