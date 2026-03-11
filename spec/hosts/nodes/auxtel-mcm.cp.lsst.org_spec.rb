# frozen_string_literal: true

require 'spec_helper'

describe 'auxtel-mcm.cp.lsst.org', :sitepp do
  on_supported_os.each do |os, os_facts|
    next unless os =~ %r{almalinux-9-x86_64}

    context "on #{os}" do
      let(:facts) do
        lsst_override_facts(os_facts,
                            fqdn: 'auxtel-mcm.cp.lsst.org',
                            is_virtual: false,
                            virtual: 'physical',
                            dmi: {
                              'product' => {
                                'name' => 'PowerEdge R630',
                              },
                            })
      end
      let(:node_params) do
        {
          role: 'ccs-mcm',
          cluster: 'auxtel-ccs',
          site: 'cp',
        }
      end

      it { is_expected.to compile.with_all_deps }

      it_behaves_like 'baremetal'
      include_context 'with nm interface'

      it { is_expected.to have_nm__connection_resource_count(5) }

      %w[
        eno2
        eno3
      ].each do |i|
        context "with #{i}" do
          let(:interface) { i }

          it_behaves_like 'nm disabled interface'
        end
      end

      context 'with eno1' do
        let(:interface) { 'eno1' }

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
        it { expect(nm_keyfile['ipv4']['address1']).to eq('139.229.170.33/24') }
        it { expect(nm_keyfile['ipv4']['dns']).to eq('139.229.160.53;139.229.160.54;139.229.160.55;') }
        it { expect(nm_keyfile['ipv4']['dns-search']).to eq('cp.lsst.org;') }
        it { expect(nm_keyfile['ipv4']['route1']).to eq('139.229.147.0/24,139.229.170.254') }
        it { expect(nm_keyfile['ipv4']['route2']).to eq('139.229.166.0/24,139.229.170.254') }
        it { expect(nm_keyfile['ipv4']['route3']).to eq('139.229.167.0/24,139.229.170.254') }
        it { expect(nm_keyfile['ipv4']['route4']).to eq('139.229.178.0/24,139.229.170.254') }
      end

      context 'with eno4' do
        let(:interface) { 'eno4' }

        it_behaves_like 'nm enabled interface'
        it_behaves_like 'nm dhcp interface'
        it_behaves_like 'nm ethernet interface'
      end
    end
  end # on os
end # on_supported_os
