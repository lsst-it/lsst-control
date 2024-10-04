# frozen_string_literal: true

require 'spec_helper'

describe 'lsstcam-vw03.ls.lsst.org', :sitepp do
  on_supported_os.each do |os, os_facts|
    next unless os =~ %r{almalinux-9-x86_64}

    context "on #{os}" do
      let(:facts) do
        lsst_override_facts(os_facts,
                            is_virtual: false,
                            virtual: 'physical',
                            dmi: {
                              'product' => {
                                'name' => 'MS-7E25',
                              },
                            })
      end
      let(:node_params) do
        {
          role: 'ccs-desktop',
          site: 'ls',
        }
      end

      it { is_expected.to compile.with_all_deps }

      include_examples 'baremetal no bmc'
      include_context 'with nm interface'
      it { is_expected.to have_nm__connection_resource_count(1) }

      context 'with enp3s0' do
        let(:interface) { 'enp3s0' }

        it_behaves_like 'nm enabled interface'
        it_behaves_like 'nm ethernet interface'
        it_behaves_like 'nm dhcp interface'
      end
    end # on os
  end # on_supported_os
end
