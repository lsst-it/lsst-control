# frozen_string_literal: true

require 'spec_helper'

describe 'core01.dev.lsst.org', :sitepp do
  on_supported_os.each do |os, os_facts|
    next unless os =~ %r{almalinux-9-x86_64}

    context "on #{os}" do
      let(:facts) do
        override_facts(os_facts,
                       fqdn: 'core01.dev.lsst.org',
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
          site: 'dev',
          variant: '1114S-rev_1.01',
        }
      end

      it { is_expected.to compile.with_all_deps }

      include_examples('baremetal',
                       bmc: {
                         lan1: {
                           ip: '139.229.134.35',
                           netmask: '255.255.255.0',
                           gateway: '139.229.134.254',
                           type: 'static',
                         },
                       })
      include_context 'with nm interface'

      it { is_expected.to have_nm__connection_resource_count(4) }

      context 'with enp1s0f0' do
        let(:interface) { 'enp1s0f0' }

        it_behaves_like 'nm enabled interface'
        it_behaves_like 'nm ethernet interface'
        it { expect(nm_keyfile['ipv4']['address1']).to eq('139.229.134.32/24,139.229.134.254') }
        it { expect(nm_keyfile['ipv4']['dns']).to eq('139.229.134.53;') }
        it { expect(nm_keyfile['ipv4']['dns-search']).to eq('dev.lsst.org;') }
        it { expect(nm_keyfile['ipv4']['method']).to eq('manual') }
      end

      context 'with enp1s0f1' do
        let(:interface) { 'enp1s0f1' }

        it_behaves_like 'nm enabled interface'
        it_behaves_like 'nm ethernet interface'
        it { expect(nm_keyfile['ipv4']['method']).to eq('disabled') }
        it { expect(nm_keyfile['ipv6']['method']).to eq('disabled') }
      end

      context 'with enp1s0f1.2101' do
        let(:interface) { 'enp1s0f1.2101' }

        it_behaves_like 'nm enabled interface'
        it { expect(nm_keyfile['vlan']['id']).to eq(2101) }
        it { expect(nm_keyfile['vlan']['parent']).to eq('enp1s0f1') }
        it { expect(nm_keyfile['connection']['master']).to eq('br2101') }
        it { expect(nm_keyfile['connection']['slave-type']).to eq('bridge') }
      end

      context 'with br2101' do
        let(:interface) { 'br2101' }

        it_behaves_like 'nm enabled interface'
        it { expect(nm_keyfile['ipv4']['method']).to eq('disabled') }
        it { expect(nm_keyfile['ipv6']['method']).to eq('disabled') }
        it { expect(nm_keyfile['bridge']['stp']).to be(false) }
      end
    end # on os
  end # on_supported_os
end
