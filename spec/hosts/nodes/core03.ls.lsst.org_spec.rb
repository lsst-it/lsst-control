# frozen_string_literal: true

require 'spec_helper'

describe 'core03.ls.lsst.org', :sitepp do
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
          role: 'hypervisor',
          site: 'ls',
        }
      end

      it { is_expected.to compile.with_all_deps }

      include_examples('baremetal',
                       bmc: {
                         lan1: {
                           ip: '139.229.142.3',
                           netmask: '255.255.255.0',
                           gateway: '139.229.142.254',
                           type: 'static',
                         },
                       })
      include_context 'with nm interface'

      it { is_expected.to have_nm__connection_resource_count(9) }

      %w[
        eno1np0
        eno2np1
        enp4s0f3u2u2c2
      ].each do |i|
        context "with #{i}" do
          let(:interface) { i }

          it_behaves_like 'nm disabled interface'
        end
      end

      context 'with enp129s0f0' do
        let(:interface) { 'enp129s0f0' }

        it_behaves_like 'nm enabled interface'
        it_behaves_like 'nm ethernet interface'
        it { expect(nm_keyfile['ipv4']['address1']).to eq('139.229.141.35/28,139.229.141.46') }
        it { expect(nm_keyfile['ipv4']['dns']).to eq('139.229.135.53;139.229.135.54;139.229.135.55;') }
        it { expect(nm_keyfile['ipv4']['dns-search']).to eq('ls.lsst.org;') }
        it { expect(nm_keyfile['ipv4']['method']).to eq('manual') }
      end

      context 'with enp129s0f1' do
        let(:interface) { 'enp129s0f1' }

        it_behaves_like 'nm enabled interface'
        it_behaves_like 'nm ethernet interface'
        it { expect(nm_keyfile['ipv4']['method']).to eq('disabled') }
        it { expect(nm_keyfile['ipv6']['method']).to eq('disabled') }
      end

      context 'with enp129s0f1.2102' do
        let(:interface) { 'enp129s0f1.2102' }

        it_behaves_like 'nm enabled interface'
        it { expect(nm_keyfile['vlan']['id']).to eq(2102) }
        it { expect(nm_keyfile['vlan']['parent']).to eq('enp129s0f1') }
        it { expect(nm_keyfile['connection']['master']).to eq('br2102') }
        it { expect(nm_keyfile['connection']['slave-type']).to eq('bridge') }
      end

      context 'with enp129s0f1.2103' do
        let(:interface) { 'enp129s0f1.2103' }

        it_behaves_like 'nm enabled interface'
        it { expect(nm_keyfile['vlan']['id']).to eq(2103) }
        it { expect(nm_keyfile['vlan']['parent']).to eq('enp129s0f1') }
        it { expect(nm_keyfile['connection']['master']).to eq('br2103') }
        it { expect(nm_keyfile['connection']['slave-type']).to eq('bridge') }
      end

      context 'with br2102' do
        let(:interface) { 'br2102' }

        it_behaves_like 'nm enabled interface'
        it { expect(nm_keyfile['ipv4']['method']).to eq('disabled') }
        it { expect(nm_keyfile['ipv6']['method']).to eq('disabled') }
        it { expect(nm_keyfile['bridge']['stp']).to be(false) }
      end

      context 'with br2103' do
        let(:interface) { 'br2103' }

        it_behaves_like 'nm enabled interface'
        it { expect(nm_keyfile['ipv4']['method']).to eq('disabled') }
        it { expect(nm_keyfile['ipv6']['method']).to eq('disabled') }
        it { expect(nm_keyfile['bridge']['stp']).to be(false) }
      end
    end # on os
  end # on_supported_os
end # role
