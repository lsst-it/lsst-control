# frozen_string_literal: true

require 'spec_helper'

describe 'lsstcam-mcm.cp.lsst.org', :sitepp do
  on_supported_os.each do |os, os_facts|
    next if os =~ %r{centos-7-x86_64}

    context "on #{os}" do
      let(:facts) do
        override_facts(os_facts,
                       fqdn: 'lsstcam-mcm.cp.lsst.org',
                       is_virtual: false,
                       virtual: 'physical',
                       dmi: {
                         'product' => {
                           'name' => 'PowerEdge R640',
                         },
                       })
      end
      let(:node_params) do
        {
          role: 'ccs-mcm',
          cluster: 'lsstcam-ccs',
          site: 'cp',
        }
      end

      it { is_expected.to compile.with_all_deps }

      include_examples 'baremetal'
      include_context 'with nm interface'

      it { is_expected.to have_nm__connection_resource_count(8) }

      %w[
        eno2
        eno3
        eno4
        ens1f0
        ens1f1
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
        it { expect(nm_keyfile['ipv4']['address1']).to eq('139.229.175.76/26,139.229.175.126') }
        it { expect(nm_keyfile['ipv4']['dns']).to eq('139.229.160.53;139.229.160.54;139.229.160.55;') }
        it { expect(nm_keyfile['ipv4']['dns-search']).to eq('cp.lsst.org;') }
        it { expect(nm_keyfile['ipv4']['method']).to eq('manual') }
      end

      context 'with ens1f0.1400' do
        let(:interface) { 'ens1f0.1400' }

        it_behaves_like 'nm enabled interface'
        it_behaves_like 'nm vlan interface', id: 1400, parent: 'ens1f0'
        it_behaves_like 'nm bridge slave interface', master: 'dds'
      end

      context 'with dds' do
        let(:interface) { 'dds' }

        it_behaves_like 'nm enabled interface'
        it_behaves_like 'nm no default route'
        it_behaves_like 'nm bridge interface'
        it { expect(nm_keyfile['ipv4']['method']).to eq('manual') }
        it { expect(nm_keyfile['ipv4']['address1']).to eq('139.229.170.4/24,139.229.170.254') }
      end
    end # on os
  end # on_supported_os
end
