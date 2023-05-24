# frozen_string_literal: true

require 'spec_helper'

role = 'nfsserver'

describe "#{role} role" do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }
      let(:node_params) do
        {
          role: role,
          site: site,
        }
      end

      describe 'nfsserver.cp.lsst.org', :site do
        let(:site) { 'cp' }

        facts.merge!(fqdn: 'nfsserver.cp.lsst.org')

        it { is_expected.to compile.with_all_deps }

        include_examples 'common', facts: facts

        it do
          is_expected.to contain_class('nfs').with(
            server_enabled: true,
            client_enabled: true,
            nfs_v4_client: true,
          )
        end

        it do
          expect(catalogue.resource('class', 'nfs')[:nfs_v4_export_root_clients]).to include(
            'azar03.cp.lsst.org(rw,fsid=root,insecure,no_subtree_check,async,root_squash)',
          )
        end

        it { is_expected.to contain_class('nfs::server').with_nfs_v4(true) }
        it { is_expected.to contain_nfs__server__export('/data/project') }

        it do
          expect(catalogue.resource('nfs::server::export', '/data/project')[:clients])
            .to include(
              'azar03.cp.lsst.org(rw,nohide,insecure,no_subtree_check,async,root_squash)',
            )
        end

        it { is_expected.to contain_nfs__server__export('/data/scratch') }

        it do
          expect(catalogue.resource('nfs::server::export', '/data/scratch')[:clients])
            .to include(
              'azar03.cp.lsst.org(rw,nohide,insecure,no_subtree_check,async,root_squash)',
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
