# frozen_string_literal: true

require 'spec_helper'

describe 'auxtel-dc01.tu.lsst.org', :sitepp do
  on_supported_os.each do |os, os_facts|
    next unless os =~ %r{almalinux-9-x86_64}

    context "on #{os}" do
      let(:facts) do
        lsst_override_facts(os_facts,
                            is_virtual: false,
                            virtual: 'physical',
                            dmi: {
                              'product' => {
                                'name' => 'PowerEdge R440',
                              },
                            })
      end
      let(:node_params) do
        {
          role: 'generic',
          site: 'tu',
        }
      end

      it { is_expected.to compile.with_all_deps }

      include_examples 'baremetal'
      include_context 'with nm interface'
      it { is_expected.to have_nm__connection_resource_count(3) }

      context 'with ens2f0' do
        let(:interface) { 'ens2f0' }

        it_behaves_like 'nm enabled interface'
        it_behaves_like 'nm dhcp interface'
        it_behaves_like 'nm ethernet interface'
      end

      context 'with ens2f1' do
        let(:interface) { 'ens2f1' }

        it_behaves_like 'nm enabled interface'
        it_behaves_like 'nm ethernet interface'
        it_behaves_like 'nm bridge slave interface', master: 'lsst-daq'
        it { expect(nm_keyfile['ethtool']['ring-rx']).to eq(4096) }
        it { expect(nm_keyfile['ethtool']['ring-tx']).to eq(4096) }
      end

      context 'with lsst-daq' do
        let(:interface) { 'lsst-daq' }

        it_behaves_like 'nm enabled interface'
        it_behaves_like 'nm dhcp interface'
        it_behaves_like 'nm bridge interface'
        it { expect(nm_keyfile['ipv4']['ignore-auto-dns']).to be true }
      end
    end # on os
  end # on_supported_os
end
