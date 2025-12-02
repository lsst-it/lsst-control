# frozen_string_literal: true

require 'spec_helper'

describe 'tel-hw1.cp.lsst.org', :sitepp do
  on_supported_os.each do |os, os_facts|
    next unless os =~ %r{almalinux-9-x86_64}

    context "on #{os}" do
      let(:facts) do
        lsst_override_facts(os_facts,
                            is_virtual: true,
                            virtual: 'vmware',
                            dmi: {
                              'product' => {
                                'name' => 'VMware7,1',
                              },
                            })
      end
      let(:node_params) do
        {
          role: 'dco',
          site: 'cp',
        }
      end

      it { is_expected.to compile.with_all_deps }

      it { is_expected.to contain_class('nfs').with_server_enabled(false) }
      it { is_expected.to contain_class('nfs').with_client_enabled(true) }

      include_context 'with nm interface'
      it { is_expected.to have_nm__connection_resource_count(1) }

      context 'with ens192' do
        let(:interface) { 'ens192' }

        it_behaves_like 'nm enabled interface'
        it_behaves_like 'nm ethernet interface'
        it_behaves_like 'nm dhcp interface'
      end

      it do
        is_expected.to contain_nfs__client__mount('/net/obs-env').with(
          share: 'obs-env',
          server: 'nfs-obs-env.cp.lsst.org',
          atboot: true
        )
      end

      it do
        is_expected.to contain_nfs__client__mount('/net/scratch').with(
          share: 'scratch',
          server: 'nfs-scratch.cp.lsst.org',
          atboot: true
        )
      end

      it do
        is_expected.to contain_nfs__client__mount('/project').with(
          share: 'project',
          server: 'nfs-project.cp.lsst.org',
          atboot: true
        )
      end
    end # on os
  end # on_supported_os
end
