# frozen_string_literal: true

require 'spec_helper'

describe 'lsstcam-fb02.cp.lsst.org', :sitepp do
  on_supported_os.each do |os, os_facts|
    next unless os =~ %r{almalinux-9-x86_64}

    context "on #{os}" do
      let(:facts) do
        lsst_override_facts(os_facts,
                            is_virtual: false,
                            virtual: 'physical',
                            dmi: {
                              'product' => {
                                'name' => 'VersaLogic Corporation',
                              },
                            })
      end
      let(:node_params) do
        {
          role: 'ccs-hcu',
          site: 'cp',
          cluster: 'lsstcam-ccs',
        }
      end

      it { is_expected.to compile.with_all_deps }

      include_examples 'baremetal no bmc'
      include_context 'with nm interface'

      it { is_expected.to have_nm__connection_resource_count(2) }

      %w[
        enp3s0
      ].each do |i|
        context "with #{i}" do
          let(:interface) { i }

          it_behaves_like 'nm disabled interface'
        end
      end

      context 'with enp0s31f6' do
        let(:interface) { 'enp0s31f6' }

        it_behaves_like 'nm enabled interface'
        it_behaves_like 'nm ethernet interface'
        it_behaves_like 'nm manual interface'
        it { expect(nm_keyfile['ipv4']['address1']).to eq('139.229.175.99/26,139.229.175.126') }
        it { expect(nm_keyfile['ipv4']['dns']).to eq('139.229.160.53;139.229.160.54;139.229.160.55;') }
        it { expect(nm_keyfile['ipv4']['dns-search']).to eq('cp.lsst.org;') }
      end
    end # on os
  end # on_supported_os
end
