# frozen_string_literal: true

require 'spec_helper'

describe 'kona01.dev.lsst.org', :sitepp do
  on_supported_os.each do |os, os_facts|
    next unless os =~ %r{almalinux-9-x86_64}

    context "on #{os}" do
      let(:facts) do
        lsst_override_facts(os_facts,
                            is_virtual: false,
                            virtual: 'physical',
                            dmi: {
                              'product' => {
                                'name' => 'PowerEdge C6420',
                              },
                            })
      end
      let(:node_params) do
        {
          role: 'rke2server',
          site: 'dev',
          cluster: 'kona',
          variant: 'c6420',
        }
      end

      it { is_expected.to compile.with_all_deps }

      include_examples 'baremetal'

      it do
        expect(catalogue.resource('class', 'rke2')[:config]).to include(
          'node-label' => ['role=storage-node']
        )
      end

      it do
        is_expected.to contain_class('profile::core::sysctl::rp_filter').with_enable(false)
      end

      it do
        is_expected.to contain_class('clustershell').with(
          groupmembers: {
            'kona' => {
              'group' => 'kona',
              'member' => 'kona[01-04]',
            },
          }
        )
      end

      it do
        is_expected.to contain_class('rke2').with(
          node_type: 'server',
          release_series: '1.32',
          version: '1.32.10~rke2r1'
        )
      end

      it { is_expected.to contain_class('cni::plugins::dhcp::service') }

      include_context 'with nm interface'

      it { is_expected.to have_nm__connection_resource_count(2) }

      %w[
        ens4f0
      ].each do |i|
        context "with #{i}" do
          let(:interface) { i }

          it_behaves_like 'nm disabled interface'
        end
      end

      context 'with eno16' do
        let(:interface) { 'eno16' }

        it_behaves_like 'nm enabled interface'
        it_behaves_like 'nm dhcp interface'
        it_behaves_like 'nm ethernet interface'
      end
    end # on os
  end # on_supported_os
end
