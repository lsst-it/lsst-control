# frozen_string_literal: true

require 'spec_helper'

describe 'comcam-db02.cp.lsst.org', :sitepp do
  on_supported_os.each do |os, os_facts|
    next unless os =~ %r{almalinux-9-x86_64}

    context "on #{os}" do
      let(:facts) do
        lsst_override_facts(os_facts,
                            is_virtual: false,
                            virtual: 'physical',
                            dmi: {
                              'product' => {
                                'name' => 'PowerEdge R6515',
                              },
                            })
      end
      let(:node_params) do
        {
          role: 'ccs-database',
          cluster: 'comcam-ccs',
          site: 'cp',
        }
      end

      it { is_expected.to compile.with_all_deps }

      it_behaves_like 'baremetal'
      include_context 'with nm interface'
      it { is_expected.to have_nm__connection_resource_count(6) }

      %w[
        ens1f1np1
        eno1
        eno2
        ens3f0np0
        ens3f1np1
      ].each do |i|
        context "with #{i}" do
          let(:interface) { i }

          it_behaves_like 'nm disabled interface'
        end
      end

      context 'with ens1f0np0' do
        let(:interface) { 'ens1f0np0' }

        it_behaves_like 'nm enabled interface'
        it_behaves_like 'nm ethernet interface'
        it_behaves_like 'nm dhcp interface'
      end
    end
  end # on_supported_os
end
