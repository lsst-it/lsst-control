# frozen_string_literal: true

require 'spec_helper'

describe 'namkueyen01.dev.lsst.org', :sitepp do
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
          role: 'rke',
          site: 'dev',
          cluster: 'namkueyen',
        }
      end

      it { is_expected.to compile.with_all_deps }

      include_examples 'docker', docker_version: '24.0.9'
      include_examples 'baremetal'
      include_context 'with nm interface'
      include_examples 'ceph cluster'

      it do
        is_expected.to contain_class('profile::core::sysctl::rp_filter').with_enable(false)
      end

      it do
        is_expected.to contain_class('clustershell').with(
          groupmembers: {
            'namkueyen' => {
              'group' => 'namkueyen',
              'member' => 'namkueyen[01-03]',
            },
          }
        )
      end

      it do
        is_expected.to contain_class('rke').with(
          version: '1.5.12'
        )
      end

      it { is_expected.to have_nm__connection_resource_count(1) }

      context 'with eno1' do
        let(:interface) { 'eno1' }

        it_behaves_like 'nm enabled interface'
        it_behaves_like 'nm dhcp interface'
        it_behaves_like 'nm ethernet interface'
      end
    end # on os
  end # on_supported_os
end
