# frozen_string_literal: true

require 'spec_helper'

describe 'lsstcam-vs01.cp.lsst.org', :sitepp do
  on_supported_os.each do |os, os_facts|
    next if os =~ %r{centos-7-x86_64}

    context "on #{os}" do
      let(:facts) do
        lsst_override_facts(os_facts,
                            is_virtual: false,
                            virtual: 'physical',
                            dmi: {
                              'product' => {
                                'name' => 'PowerEdge R7515',
                              },
                            })
      end
      let(:node_params) do
        {
          role: 'ccs-visserver',
          cluster: 'lsstcam-ccs',
          site: 'cp',
        }
      end

      it { is_expected.to compile.with_all_deps }

      include_examples 'baremetal'
      include_context 'with nm interface'

      it { is_expected.to have_nm__connection_resource_count(1) }

      context 'with ens1f0np0' do
        let(:interface) { 'ens1f0np0' }

        it_behaves_like 'nm enabled interface'
        it_behaves_like 'nm ethernet interface'
        it { expect(nm_keyfile['ipv4']['address1']).to eq('139.229.175.75/26,139.229.175.126') }
        it { expect(nm_keyfile['ipv4']['dns']).to eq('139.229.160.53;139.229.160.54;139.229.160.55;') }
        it { expect(nm_keyfile['ipv4']['dns-search']).to eq('cp.lsst.org;') }
        it { expect(nm_keyfile['ipv4']['method']).to eq('manual') }
      end
    end # on os
  end # on_supported_os
end
