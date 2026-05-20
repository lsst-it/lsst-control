# frozen_string_literal: true

require 'spec_helper'

describe 'luan01.ls.lsst.org', :sitepp do
  on_supported_os.each do |os, os_facts|
    next unless os =~ %r{almalinux-9-x86_64}

    context "on #{os}" do
      let(:facts) do
        lsst_override_facts(os_facts,
                            is_virtual: false,
                            virtual: 'physical',
                            dmi: {
                              'product' => {
                                'name' => 'Super Server',
                              },
                              'board' => {
                                'product' => 'H12SSL-NT',
                              },
                            })
      end
      let(:node_params) do
        {
          role: 'rke2server',
          site: 'ls',
          cluster: 'luan',
        }
      end

      it { is_expected.to compile.with_all_deps }

      it_behaves_like 'baremetal'
      include_context 'with nm interface'
      it_behaves_like 'ceph cluster'

      it do
        expect(catalogue.resource('class', 'rke2')[:config]).to include(
          'kubelet-arg' => ['system-reserved=memory=4Gi', 'kube-reserved=memory=4Gi', 'image-gc-high-threshold=70', 'image-gc-low-threshold=60'],
          'node-label' => ['role=storage-node'],
        )
      end

      it do
        is_expected.to contain_class('profile::core::sysctl::rp_filter').with_enable(false)
      end

      it do
        is_expected.to contain_class('clustershell').with(
          groupmembers: {
            'luan' => {
              'group' => 'luan',
              'member' => 'luan[01-05]',
            },
          },
        )
      end

      it do
        is_expected.to contain_class('rke2').with(
          node_type: 'server',
          release_series: '1.34',
          version: '1.34.7~rke2r1',
        )
      end

      it { is_expected.to have_nm__connection_resource_count(3) }

      %w[
        eno2np1
        enp71s0f3u1u2c2
      ].each do |i|
        context "with #{i}" do
          let(:interface) { i }

          it_behaves_like 'nm disabled interface'
        end
      end

      context 'eno1np0' do
        let(:interface) { 'eno1np0' }

        it_behaves_like 'nm enabled interface'
        it_behaves_like 'nm dhcp interface'
        it_behaves_like 'nm ethernet interface'
      end
    end # on os
  end # on_supported_os
end
