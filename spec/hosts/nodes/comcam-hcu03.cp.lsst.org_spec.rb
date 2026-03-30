# frozen_string_literal: true

require 'spec_helper'

describe 'comcam-hcu03.cp.lsst.org', :sitepp do
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
          site: 'cp',
          cluster: 'comcam-ccs',
        }
      end

      it { is_expected.to compile.with_all_deps }

      it_behaves_like 'baremetal no bmc'
      include_context 'with nm interface'

      it { is_expected.to have_nm__connection_resource_count(4) }

      context 'with eno1' do
        let(:interface) { 'eno1' }

        it_behaves_like 'nm enabled interface'
        it_behaves_like 'nm ethernet interface'
        it_behaves_like 'nm manual interface'

        it { expect(nm_keyfile['ipv4']['address1']).to eq('139.229.175.4/26,139.229.175.60') }
        it { expect(nm_keyfile['ipv4']['dns']).to eq('139.229.160.53;139.229.160.54;139.229.160.55;') }
        it { expect(nm_keyfile['ipv4']['dns-search']).to eq('cp.lsst.org;') }
      end

      %w[
        enp6s0
        enp7s0
        enp8s0
      ].each do |i|
        context "with #{i}" do
          let(:interface) { i }

          it_behaves_like 'nm disabled interface'
        end

        it { is_expected.to contain_class('ccs_hcu').with(filter_changer: true) }
        it { is_expected.to contain_class('ccs_hcu').with(advec: true) }
        it { is_expected.to contain_class('ccs_software') }
      end
    end # on os
  end # on_supported_os
end
