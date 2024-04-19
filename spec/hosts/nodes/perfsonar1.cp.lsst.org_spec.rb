# frozen_string_literal: true

require 'spec_helper'

describe 'perfsonar1.cp.lsst.org', :sitepp do
  on_supported_os.each do |os, os_facts|
    next unless os =~ %r{almalinux-9-x86_64}

    context "on #{os}" do
      let(:facts) do
        override_facts(os_facts,
                       fqdn: 'perfsonar1.cp.lsst.org',
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
          role: 'perfsonar',
          site: 'cp',
        }
      end

      it { is_expected.to compile.with_all_deps }

      include_examples 'baremetal'

      include_context 'with nm interface'
      it { is_expected.to have_nm__connection_resource_count(5) } 

      context 'with eno1np0' do
        let(:interface) { 'eno1np0' }

        it_behaves_like 'nm enabled interface'
        it_behaves_like 'nm dhcp interface'
        it_behaves_like 'nm ethernet interface'
        it { expect(nm_keyfile['ethtool']['ring-rx']).to eq(2047) }
        it { expect(nm_keyfile['ethtool']['ring-tx']).to eq(2047) }
      end

      context 'with enp1s0f0' do
        let(:interface) { 'enp1s0f0' }

        it_behaves_like 'nm enabled interface'
        it_behaves_like 'nm manual interface'
        it_behaves_like 'nm ethernet interface'
        it { expect(nm_keyfile['ipv4']['address1']).to eq('139.229.140.13/31') }
        it { expect(nm_keyfile['ipv4']['gateway']).to eq('139.229.140.12') }
        it { expect(nm_keyfile['ethernet']['mtu']).to eq(9000) }
      end

      context 'with enp1s0f1' do
        let(:interface) { 'enp1s0f1' }

        it_behaves_like 'nm enabled interface'
        it_behaves_like 'nm manual interface'
        it_behaves_like 'nm ethernet interface'
        it { expect(nm_keyfile['ipv4']['address1']).to eq('139.229.140.15/31') }
        it { expect(nm_keyfile['ipv4']['gateway']).to eq('139.229.140.14') }
        it { expect(nm_keyfile['ethernet']['mtu']).to eq(9000) }
      end

      context 'with enp129s0f0np0' do
        let(:interface) { 'enp129s0f0np0' }

        it_behaves_like 'nm enabled interface'
        it_behaves_like 'nm manual interface'
        it_behaves_like 'nm ethernet interface'
        it { expect(nm_keyfile['ipv4']['address1']).to eq('139.229.140.9/31') }
        it { expect(nm_keyfile['ipv4']['gateway']).to eq('139.229.140.8') }
        it { expect(nm_keyfile['ethernet']['mtu']).to eq(9000) }
        it { expect(nm_keyfile['ethtool']['ring-rx']).to eq(8192) }
        it { expect(nm_keyfile['ethtool']['ring-tx']).to eq(8192) }
      end

      context 'with enp129s0f1np1' do
        let(:interface) { 'enp129s0f1np1' }

        it_behaves_like 'nm enabled interface'
        it_behaves_like 'nm manual interface'
        it_behaves_like 'nm ethernet interface'
        it { expect(nm_keyfile['ipv4']['address1']).to eq('139.229.140.11/31') }
        it { expect(nm_keyfile['ipv4']['gateway']).to eq('139.229.140.10') }
        it { expect(nm_keyfile['ethernet']['mtu']).to eq(9000) }
        it { expect(nm_keyfile['ethtool']['ring-rx']).to eq(8192) }
        it { expect(nm_keyfile['ethtool']['ring-tx']).to eq(8192) }
      end
    end # on os
  end # on_supported_os
end
