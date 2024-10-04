# frozen_string_literal: true

require 'spec_helper'

describe 'dimm.cp.lsst.org', :sitepp do
  on_supported_os.each do |os, os_facts|
    next if os =~ %r{centos-7-x86_64}

    context "on #{os}" do
      let(:facts) do
        lsst_override_facts(os_facts,
                            is_virtual: false,
                            virtual: 'physical',
                            dmi: {
                              'product' => {
                                'name' => 'PH12LI',
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

      include_examples 'baremetal no bmc'
      include_context 'with nm interface'
      it { is_expected.to have_nm__connection_resource_count(2) }

      context 'with eno1' do
        let(:interface) { 'eno1' }

        it_behaves_like 'nm enabled interface'
        it_behaves_like 'nm dhcp interface'
        it_behaves_like 'nm ethernet interface'
      end

      context 'with enp2s0' do
        let(:interface) { 'enp2s0' }

        it_behaves_like 'nm disabled interface'
      end
    end # on os
  end # on_supported_os
end
