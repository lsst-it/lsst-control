# frozen_string_literal: true

require 'spec_helper'

describe 'gaw01.ls.lsst.org', :sitepp do
  on_supported_os.each do |os, os_facts|
    next unless os =~ %r{almalinux-9-x86_64}

    context "on #{os}" do
      let(:facts) do
        override_facts(os_facts,
                       fqdn: 'gaw01.ls.sst.org',
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
          role: 'rke',
          site: 'ls',
          cluster: 'gaw',
        }
      end

      it { is_expected.to compile.with_all_deps }

      include_examples 'baremetal'
      include_context 'with nm interface'

      it do
        is_expected.to contain_class('clustershell').with(
          groupmembers: {
            'gaw' => {
              'group' => 'gaw',
              'member' => 'gaw[01-05]',
            },
          },
        )
      end

      it do
        is_expected.to contain_class('rke').with(
          version: '1.4.6',
          checksum: '12d8fee6f759eac64b3981ef2822353993328f2f839ac88b3739bfec0b9d818c',
        )
      end

      it { is_expected.to have_nm__connection_resource_count(0) }
    end # on os
  end # on_supported_os
end
