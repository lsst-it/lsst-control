# frozen_string_literal: true

require 'spec_helper'

role = 'nfsserver'

describe "#{role} role" do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      let(:node_params) do
        {
          role: role,
          site: site,
        }
      end

      describe 'nfsserver.cp.lsst.org', :sitepp do
        site = 'cp'
        let(:site) { site }
        let(:facts) { override_facts(os_facts, fqdn: 'nfsserver.cp.lsst.org') }

        it { is_expected.to compile.with_all_deps }

        include_examples 'common', os_facts: os_facts, site: site

        it do
          is_expected.to contain_class('nfs').with(
            server_enabled: true,
            client_enabled: true,
            nfs_v4_client: true,
          )
        end

        it do
          expect(catalogue.resource('class', 'nfs')[:nfs_v4_export_root_clients]).to include(
            '139.229.146.0/24(rw,fsid=root,insecure,no_subtree_check,async,root_squash)',
            '139.229.160.0/24(rw,fsid=root,insecure,no_subtree_check,async,root_squash)',
            '139.229.163.0/24(rw,fsid=root,insecure,no_subtree_check,async,root_squash)',
            '139.229.164.0/24(rw,fsid=root,insecure,no_subtree_check,async,root_squash)',
            '139.229.165.0/24(rw,fsid=root,insecure,no_subtree_check,async,root_squash)',
            '139.229.169.0/24(rw,fsid=root,insecure,no_subtree_check,async,root_squash)',
            '139.229.170.0/24(rw,fsid=root,insecure,no_subtree_check,async,root_squash)',
            '139.229.175.0/26(rw,fsid=root,insecure,no_subtree_check,async,root_squash)',
            '139.229.175.128/25(rw,fsid=root,insecure,no_subtree_check,async,root_squash)',
            'azar03.cp.lsst.org(rw,fsid=root,insecure,no_subtree_check,async,root_squash)',
            '139.229.191.0/25(rw,fsid=root,insecure,no_subtree_check,async,root_squash)',
          )
        end

        it { is_expected.to contain_class('nfs::server').with_nfs_v4(true) }

        it do
          expect(catalogue.resource('nfs::server::export', '/data/home')[:clients])
            .to include(
              '139.229.146.0/24(rw,nohide,insecure,no_subtree_check,async,root_squash)',
              '139.229.160.0/24(rw,nohide,insecure,no_subtree_check,async,root_squash)',
              '139.229.165.0/24(rw,nohide,insecure,no_subtree_check,async,root_squash)',
              '139.229.170.0/24(rw,nohide,insecure,no_subtree_check,async,root_squash)',
              '139.229.175.0/26(rw,nohide,insecure,no_subtree_check,async,root_squash)',
              '139.229.175.128/25(rw,nohide,insecure,no_subtree_check,async,root_squash)',
            )
        end

        it do
          expect(catalogue.resource('nfs::server::export', '/data/jhome')[:clients])
            .to include(
              '139.229.146.0/24(rw,nohide,insecure,no_subtree_check,async,root_squash)',
              '139.229.160.0/24(rw,nohide,insecure,no_subtree_check,async,no_root_squash)',
              'nfs2.cp.lsst.org(rw,nohide,insecure,no_subtree_check,async,no_root_squash)',
            )
        end

        it do
          expect(catalogue.resource('nfs::server::export', '/data/lsstdata')[:clients])
            .to include(
              '139.229.146.0/24(ro,nohide,insecure,no_subtree_check,async,root_squash)',
              '139.229.160.0/24(ro,nohide,insecure,no_subtree_check,async,root_squash)',
              '139.229.165.0/24(ro,nohide,insecure,no_subtree_check,async,root_squash)',
              '139.229.170.0/24(rw,nohide,insecure,no_subtree_check,async,root_squash)',
              '139.229.175.0/26(ro,nohide,insecure,no_subtree_check,async,root_squash)',
              '139.229.175.128/25(ro,nohide,insecure,no_subtree_check,async,root_squash)',
              'ts-csc-generic-01.cp.lsst.org(rw,nohide,insecure,no_subtree_check,async,root_squash)',
              'comcam-archiver.cp.lsst.org(rw,nohide,insecure,no_subtree_check,async,root_squash)',
            )
        end

        it { is_expected.to contain_nfs__server__export('/data/project') }

        it do
          expect(catalogue.resource('nfs::server::export', '/data/project')[:clients])
            .to include(
              '139.229.146.0/24(rw,nohide,insecure,no_subtree_check,async,root_squash)',
              '139.229.160.0/24(rw,nohide,insecure,no_subtree_check,async,root_squash)',
              '139.229.165.0/24(rw,nohide,insecure,no_subtree_check,async,root_squash)',
              '139.229.169.0/24(rw,nohide,insecure,no_subtree_check,async,root_squash)',
              '139.229.170.0/24(rw,nohide,insecure,no_subtree_check,async,root_squash)',
              '139.229.175.0/26(rw,nohide,insecure,no_subtree_check,async,root_squash)',
              '139.229.175.128/25(rw,nohide,insecure,no_subtree_check,async,root_squash)',
              'azar03.cp.lsst.org(rw,nohide,insecure,no_subtree_check,async,root_squash)',
            )
        end

        it { is_expected.to contain_nfs__server__export('/data/scratch') }

        it do
          expect(catalogue.resource('nfs::server::export', '/data/scratch')[:clients])
            .to include(
              '139.229.146.0/24(rw,nohide,insecure,no_subtree_check,async,root_squash)',
              '139.229.160.0/24(rw,nohide,insecure,no_subtree_check,async,root_squash)',
              '139.229.165.0/24(rw,nohide,insecure,no_subtree_check,async,root_squash)',
              '139.229.170.0/24(rw,nohide,insecure,no_subtree_check,async,root_squash)',
              '139.229.175.0/26(rw,nohide,insecure,no_subtree_check,async,root_squash)',
              '139.229.175.128/25(rw,nohide,insecure,no_subtree_check,async,root_squash)',
              'azar03.cp.lsst.org(rw,nohide,insecure,no_subtree_check,async,root_squash)',
            )
        end

        it do
          expect(catalogue.resource('nfs::server::export', '/data/dimm')[:clients])
            .to include(
              '139.229.160.0/24(rw,nohide,insecure,no_subtree_check,async,root_squash)',
              '139.229.163.0/24(rw,nohide,insecure,no_subtree_check,async,root_squash)',
              '139.229.164.0/24(rw,nohide,insecure,no_subtree_check,async,root_squash)',
              '139.229.165.0/24(rw,nohide,insecure,no_subtree_check,async,root_squash)',
              '139.229.170.0/24(rw,nohide,insecure,no_subtree_check,async,root_squash)',
              '139.229.191.0/25(rw,nohide,insecure,no_subtree_check,async,root_squash)',
            )
        end

        it do
          expect(catalogue.resource('nfs::server::export', '/data/rsphome')[:clients])
            .to include(
              '139.229.146.0/24(rw,nohide,insecure,no_subtree_check,async,root_squash)',
              '139.229.160.0/24(rw,nohide,insecure,no_subtree_check,async,no_root_squash)',
              'nfs2.cp.lsst.org(rw,nohide,insecure,no_subtree_check,async,no_root_squash)',
            )
        end

        it do
          is_expected.to contain_nfs__client__mount('/net/self/data/rsphome').with(
            share: 'rsphome',
            server: facts[:fqdn],
            atboot: true,
          )
        end

        it do
          is_expected.to contain_nfs__client__mount('/net/self/data/project').with(
            share: 'project',
            server: facts[:fqdn],
            atboot: true,
          )
        end

        it do
          is_expected.to contain_nfs__client__mount('/net/self/data/scratch').with(
            share: 'scratch',
            server: facts[:fqdn],
            atboot: true,
          )
        end
      end
    end # on os
  end # on_supported_os
end # role
