# frozen_string_literal: true

require 'spec_helper'

describe 'comcam-archiver.cp.lsst.org', :sitepp do
  on_supported_os.each do |os, os_facts|
    next unless os =~ %r{almalinux-9-x86_64}

    context "on #{os}" do
      let(:facts) do
        lsst_override_facts(os_facts,
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
          role: 'nfsclient',
          cluster: 'comcam-archive',
          site: 'cp',
        }
      end

      it { is_expected.to compile.with_all_deps }

      include_examples 'baremetal'
      include_context 'with nm interface'

      it { is_expected.to have_nm__connection_resource_count(6) }

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
        it_behaves_like 'nm dhcp interface'
        it_behaves_like 'nm ethernet interface'
      end

      it { is_expected.to contain_class('nfs').with_client_enabled(true) }

      it do
        is_expected.to contain_nfs__client__mount('/data').with(
          share: 'comcam',
          server: 'nfs3.cp.lsst.org',
          atboot: true
        )
      end
    end
  end # on os
end # on_supported_os
