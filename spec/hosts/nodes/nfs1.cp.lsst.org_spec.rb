# frozen_string_literal: true

require 'spec_helper'

describe 'nfs1.cp.lsst.org', :sitepp do
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

      it { is_expected.to contain_class('nfs::server').with_nfs_v4(true) }

      it do
        is_expected.to contain_nfs__client__mount('/net/self/data/rsphome').with(
          share: 'rsphome',
          server: facts[:networking]['fqdn'],
          atboot: true
        )
      end

      it do
        is_expected.to contain_nfs__client__mount('/net/self/data/project').with(
          share: 'project',
          server: facts[:networking]['fqdn'],
          atboot: true
        )
      end

      it do
        is_expected.to contain_nfs__client__mount('/net/self/data/scratch').with(
          share: 'scratch',
          server: facts[:networking]['fqdn'],
          atboot: true
        )
      end
    end # on os
  end # on_supported_os
end
