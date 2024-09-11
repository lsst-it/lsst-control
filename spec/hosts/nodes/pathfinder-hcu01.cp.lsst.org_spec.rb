# frozen_string_literal: true

require 'spec_helper'

describe 'pathfinder-hcu01.cp.lsst.org', :sitepp do
  on_supported_os.each do |os, os_facts|
    next unless os =~ %r{almalinux-9-x86_64}

    context "on #{os}" do
      let(:facts) do
        lsst_override_facts(os_facts,
                            is_virtual: false,
                            virtual: 'physical',
                            dmi: {
                              'product' => {
                                'name' => 'UNO-1483G-434AE',
                              },
                            })
      end
      let(:node_params) do
        {
          role: 'ccs-hcu',
          cluster: 'lsstcam-ccs',
          site: 'cp',
        }
      end

      it { is_expected.to compile.with_all_deps }

      include_examples 'baremetal no bmc'
      include_context 'with nm interface'

      it { is_expected.to have_nm__connection_resource_count(4) }

      context 'with enp7s0' do
        let(:interface) { 'enp7s0' }

        it_behaves_like 'nm disabled interface'
        it_behaves_like 'nm ethernet interface'
        it { expect(nm_keyfile['ipv6']['method']).to eq('disabled') }
      end

      context 'with enp8s0' do
        let(:interface) { 'enp8s0' }

        it_behaves_like 'nm disabled interface'
        it_behaves_like 'nm ethernet interface'
        it { expect(nm_keyfile['ipv6']['method']).to eq('disabled') }
      end

      context 'with eno1' do
        let(:interface) { 'eno1' }

        it_behaves_like 'nm enabled interface'
        it_behaves_like 'nm ethernet interface'
        it { expect(nm_keyfile['ipv4']['address1']).to eq('139.229.175.13/26,139.229.175.62') }
        it { expect(nm_keyfile['ipv4']['dns']).to eq('139.229.160.53;139.229.160.54;139.229.160.55;') }
        it { expect(nm_keyfile['ipv4']['dns-search']).to eq('cp.lsst.org;') }

        it_behaves_like 'nm manual interface'
      end

      context 'with enp6s0' do
        let(:interface) { 'enp6s0' }

        it_behaves_like 'nm enabled interface'
        it_behaves_like 'nm ethernet interface'
        it_behaves_like 'nm manual interface'
        it { expect(nm_keyfile['ipv4']['address1']).to eq('192.168.1.122/24') }
      end
    end
  end
end
