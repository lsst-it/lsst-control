# frozen_string_literal: true

require 'spec_helper'

describe 'nfs3.cp.lsst.org', :sitepp do
  on_supported_os.each do |os, os_facts|
    next if os =~ %r{centos-7-x86_64}

    context "on #{os}" do
      let(:facts) do
        lsst_override_facts(os_facts,
                            is_virtual: false,
                            virtual: 'physical',
                            dmi: {
                              'product' => {
                                'name' => 'AS -1114S-WN10RT',
                              },
                            })
      end
      let(:node_params) do
        {
          role: 'nfsserver',
          site: 'cp',
        }
      end

      it { is_expected.to compile.with_all_deps }

      include_examples 'baremetal'
      include_context 'with nm interface'

      it do
        expect(catalogue.resource('class', 'nfs')[:nfs_v4_export_root_clients]).to include(
          '139.229.160.0/24(rw,fsid=root,insecure,no_subtree_check,async,root_squash)',
          '139.229.165.0/24(rw,fsid=root,insecure,no_subtree_check,async,root_squash)',
          'azar03.cp.lsst.org(rw,fsid=root,insecure,no_subtree_check,async,root_squash)'
        )
      end

      it { is_expected.to contain_class('nfs::server').with_nfs_v4(true) }

      it do
        expect(catalogue.resource('nfs::server::export', '/comcam')[:clients])
          .to include(
            '139.229.160.0/24(rw,nohide,insecure,no_subtree_check,async,root_squash)',
            '139.229.165.0/24(rw,nohide,insecure,no_subtree_check,async,root_squash)',
            'azar03.cp.lsst.org(rw,nohide,insecure,no_subtree_check,async,root_squash)',
            'comcam-archiver.cp.lsst.org(rw,nohide,insecure,no_subtree_check,async,no_root_squash)'
          )
      end

      it do
        expect(catalogue.resource('nfs::server::export', '/lsstcam')[:clients])
          .to include(
            '139.229.160.0/24(rw,nohide,insecure,no_subtree_check,async,root_squash)',
            '139.229.165.0/24(rw,nohide,insecure,no_subtree_check,async,root_squash)',
            'azar03.cp.lsst.org(rw,nohide,insecure,no_subtree_check,async,root_squash)'
          )
      end

      it do
        is_expected.to contain_nfs__client__mount('/net/self/comcam').with(
          share: 'comcam',
          server: facts[:networking]['fqdn'],
          atboot: true
        )
      end

      it do
        is_expected.to contain_nfs__client__mount('/net/self/lsstcam').with(
          share: 'lsstcam',
          server: facts[:networking]['fqdn'],
          atboot: true
        )
      end
    end # on os
  end # on_supported_os
end
