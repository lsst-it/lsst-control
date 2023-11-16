# frozen_string_literal: true

require 'spec_helper'

describe 'core02.cp.lsst.org', :sitepp do
  on_supported_os.each do |os, os_facts|
    next unless os =~ %r{almalinux-9-x86_64}

    context "on #{os}" do
      let(:facts) do
        override_facts(os_facts,
                       fqdn: 'core02.cp.lsst.org',
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
          role: 'hypervisor',
          site: 'cp',
        }
      end

      it { is_expected.to compile.with_all_deps }

      include_examples('baremetal',
                       bmc: {
                         lan1: {
                           ip: '139.229.162.2',
                           netmask: '255.255.255.0',
                           gateway: '139.229.162.254',
                           type: 'static',
                         },
                       })
      include_context 'with nm interface'

      it { is_expected.to have_nm__connection_resource_count(9) }

      %w[
        eno1np0
        eno2np1
        enp5s0f3u2u2c2
      ].each do |i|
        context "with #{i}" do
          let(:interface) { i }

          it_behaves_like 'nm disabled interface'
        end
      end

      context 'with enp1s0f0' do
        let(:interface) { 'enp1s0f0' }

        it_behaves_like 'nm enabled interface'
        it_behaves_like 'nm ethernet interface'
        it { expect(nm_keyfile['ipv4']['address1']).to eq('139.229.161.34/28,139.229.161.46') }
        it { expect(nm_keyfile['ipv4']['dns']).to eq('139.229.160.53;139.229.160.54;139.229.160.55;') }
        it { expect(nm_keyfile['ipv4']['dns-search']).to eq('cp.lsst.org;') }
        it { expect(nm_keyfile['ipv4']['method']).to eq('manual') }
      end

      context 'with enp1s0f1' do
        let(:interface) { 'enp1s0f1' }

        it_behaves_like 'nm enabled interface'
        it_behaves_like 'nm ethernet interface'
        it { expect(nm_keyfile['ipv4']['method']).to eq('disabled') }
        it { expect(nm_keyfile['ipv6']['method']).to eq('disabled') }
      end

      context 'with enp1s0f1.1101' do
        let(:interface) { 'enp1s0f1.1101' }

        it_behaves_like 'nm enabled interface'
        it { expect(nm_keyfile['vlan']['id']).to eq(1101) }
        it { expect(nm_keyfile['vlan']['parent']).to eq('enp1s0f1') }
        it { expect(nm_keyfile['connection']['master']).to eq('br1101') }
        it { expect(nm_keyfile['connection']['slave-type']).to eq('bridge') }
      end

      context 'with enp1s0f1.1102' do
        let(:interface) { 'enp1s0f1.1102' }

        it_behaves_like 'nm enabled interface'
        it { expect(nm_keyfile['vlan']['id']).to eq(1102) }
        it { expect(nm_keyfile['vlan']['parent']).to eq('enp1s0f1') }
        it { expect(nm_keyfile['connection']['master']).to eq('br1102') }
        it { expect(nm_keyfile['connection']['slave-type']).to eq('bridge') }
      end

      context 'with br1101' do
        let(:interface) { 'br1101' }

        it_behaves_like 'nm enabled interface'
        it { expect(nm_keyfile['ipv4']['method']).to eq('disabled') }
        it { expect(nm_keyfile['ipv6']['method']).to eq('disabled') }
        it { expect(nm_keyfile['bridge']['stp']).to be(false) }
      end

      context 'with br1102' do
        let(:interface) { 'br1102' }

        it_behaves_like 'nm enabled interface'
        it { expect(nm_keyfile['ipv4']['method']).to eq('disabled') }
        it { expect(nm_keyfile['ipv6']['method']).to eq('disabled') }
        it { expect(nm_keyfile['bridge']['stp']).to be(false) }
      end
    end # on os
  end # on_supported_os
end # role
