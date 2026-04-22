# frozen_string_literal: true

require 'spec_helper'

describe 'auxtel-tcbp01.cp.lsst.org', :sitepp do
  on_supported_os.each do |os, os_facts|
    next unless os =~ %r{almalinux-9-x86_64}

    context "on #{os}" do
      let(:facts) do
        lsst_override_facts(os_facts,
                            is_virtual: false,
                            virtual: 'physical',
                            dmi: {
                              'product' => {
                                'name' => 'OptiPlex 7050',
                              },
                            })
      end
      let(:node_params) do
        {
          role: 'generic',
          site: 'cp',
        }
      end

      it { is_expected.to compile.with_all_deps }

      it_behaves_like 'baremetal no bmc'
      include_context 'with nm interface'

      it { is_expected.to contain_class('powertop').with_ensure('absent') }

      it { is_expected.to have_nm__connection_resource_count(2) }

      context 'with enp2s0' do
        let(:interface) { 'enp2s0' }

        it_behaves_like 'nm enabled interface'
        it_behaves_like 'nm ethernet interface'
        it_behaves_like 'nm dhcp interface'
      end

      context 'with enp0s31f6' do
        let(:interface) { 'enp0s31f6' }

        it_behaves_like 'nm enabled interface'
        it_behaves_like 'nm ethernet interface'
        it_behaves_like 'nm manual interface'
        it { expect(nm_keyfile['ipv4']['address1']).to eq('10.0.0.10/8') }
      end
    end # on os
  end # on_supported_os
end
