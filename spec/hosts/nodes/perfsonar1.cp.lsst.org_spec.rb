# frozen_string_literal: true

require 'spec_helper'

describe 'perfsonar1.cp.lsst.org', :sitepp do
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
          role: 'perfsonar',
          site: 'cp',
        }
      end

      it { is_expected.to compile.with_all_deps }

      it_behaves_like 'baremetal'
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
        it { expect(nm_keyfile['ipv4']['route1']).to eq('139.229.140.135/32,139.229.140.12') }
        it { expect(nm_keyfile['ipv4']['route2']).to eq('198.32.252.209/32,139.229.140.12') }
        it { expect(nm_keyfile['ipv4']['route3']).to eq('198.124.226.130/32,139.229.140.12') }
        it { expect(nm_keyfile['ipv4']['route4']).to eq('198.124.226.134/32,139.229.140.12') }
        it { expect(nm_keyfile['ipv4']['route5']).to eq('198.124.226.138/32,139.229.140.12') }
        it { expect(nm_keyfile['ipv4']['route6']).to eq('198.124.226.142/32,139.229.140.12') }
        it { expect(nm_keyfile['ipv4']['route7']).to eq('134.79.235.226/32,139.229.140.12') }
        it { expect(nm_keyfile['ipv4']['route8']).to eq('134.79.22.159/32,139.229.140.12') }
      end

      context 'with enp1s0f1' do
        let(:interface) { 'enp1s0f1' }

        it_behaves_like 'nm enabled interface'
        it_behaves_like 'nm manual interface'
        it_behaves_like 'nm ethernet interface'
        it { expect(nm_keyfile['ipv4']['address1']).to eq('139.229.140.15/31') }
        it { expect(nm_keyfile['ipv4']['gateway']).to eq('139.229.140.14') }
        it { expect(nm_keyfile['ethernet']['mtu']).to eq(9000) }
        it { expect(nm_keyfile['ipv4']['route1']).to eq('139.229.140.137/32,139.229.140.14') }
        it { expect(nm_keyfile['ipv4']['route2']).to eq('198.32.252.217/32,139.229.140.14') }
        it { expect(nm_keyfile['ipv4']['route3']).to eq('198.124.226.194/32,139.229.140.14') }
        it { expect(nm_keyfile['ipv4']['route4']).to eq('198.124.226.198/32,139.229.140.14') }
        it { expect(nm_keyfile['ipv4']['route5']).to eq('198.124.226.202/32,139.229.140.14') }
        it { expect(nm_keyfile['ipv4']['route6']).to eq('198.124.226.206/32,139.229.140.14') }
        it { expect(nm_keyfile['ipv4']['route7']).to eq('134.79.235.242/32,139.229.140.14') }
        it { expect(nm_keyfile['ipv4']['route8']).to eq('134.79.22.212/32,139.229.140.14') }
      end

      context 'with enp129s0f0np0' do
        let(:interface) { 'enp129s0f0np0' }

        it_behaves_like 'nm enabled interface'
        it_behaves_like 'nm manual interface'
        it_behaves_like 'nm ethernet interface'
        it { expect(nm_keyfile['ipv4']['address1']).to eq('139.229.140.9/31') }
        it { expect(nm_keyfile['ipv4']['gateway']).to eq('139.229.140.8') }
        it { expect(nm_keyfile['ethernet']['mtu']).to eq(9000) }
        it { expect(nm_keyfile['ipv4']['route1']).to eq('172.24.7.0/24,139.229.140.8') }
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
        it { expect(nm_keyfile['ipv4']['route1']).to eq('10.101.102.14/32,139.229.140.10') }
        it { expect(nm_keyfile['ethtool']['ring-rx']).to eq(8192) }
        it { expect(nm_keyfile['ethtool']['ring-tx']).to eq(8192) }
      end
    end # on os
  end # on_supported_os
end
