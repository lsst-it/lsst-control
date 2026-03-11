# frozen_string_literal: true

require 'spec_helper'

describe 'auxtel-ill-control.cp.lsst.org', :sitepp do
  on_supported_os.each do |os, os_facts|
    next unless os =~ %r{almalinux-9-x86_64}

    context "on #{os}" do
      let(:facts) do
        lsst_override_facts(os_facts,
                            is_virtual: false,
                            virtual: 'physical',
                            dmi: {
                              'product' => {
                                'name' => 'CBxx63',
                              },
                            })
      end
      let(:node_params) do
        {
          role: 'fiberspec',
          site: 'cp',
        }
      end

      it { is_expected.to compile.with_all_deps }

      it_behaves_like 'baremetal no bmc'
      include_context 'with nm interface'
      it { is_expected.to have_nm__connection_resource_count(3) }

      context 'with enp1s0' do
        let(:interface) { 'enp1s0' }

        it_behaves_like 'nm enabled interface'
        it_behaves_like 'nm dhcp interface'
        it_behaves_like 'nm ethernet interface'
      end

      context 'with enp2s0' do
        let(:interface) { 'enp2s0' }

        it_behaves_like 'nm enabled interface'
        it_behaves_like 'nm ethernet interface'
        it_behaves_like 'nm bridge slave interface', master: 'dds'
      end

      context 'with dds' do
        let(:interface) { 'dds' }

        it_behaves_like 'nm enabled interface'
        it_behaves_like 'nm bridge interface'
        it_behaves_like 'nm manual interface'
        it_behaves_like 'nm no default route'
        it { expect(nm_keyfile['ipv4']['address1']).to eq('139.229.170.14/24,139.229.170.254') }
        it { expect(nm_keyfile['ipv4']['dns']).to eq('139.229.160.53;139.229.160.54;139.229.160.55;') }
        it { expect(nm_keyfile['ipv4']['dns-search']).to eq('cp.lsst.org;') }
        it { expect(nm_keyfile['ipv4']['route1']).to eq('139.229.147.0/24,139.229.170.254') }
        it { expect(nm_keyfile['ipv4']['route2']).to eq('139.229.166.0/24,139.229.170.254') }
        it { expect(nm_keyfile['ipv4']['route3']).to eq('139.229.167.0/24,139.229.170.254') }
        it { expect(nm_keyfile['ipv4']['route4']).to eq('139.229.178.0/24,139.229.170.254') }
      end

      it do
        is_expected.to contain_nfs__client__mount('/net/obs-env').with(
          share: 'obs-env',
          server: 'nfs-obs-env.cp.lsst.org',
          atboot: true,
        )
      end
    end # on os
  end # on_supported_os
end
