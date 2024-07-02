# frozen_string_literal: true

require 'spec_helper'

describe 'luan01.ls.lsst.org', :sitepp do
  on_supported_os.each do |os, os_facts|
    next unless os =~ %r{almalinux-9-x86_64}

    context "on #{os}" do
      let(:facts) do
        override_facts(os_facts,
                       fqdn: 'luan01.ls.sst.org',
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
          cluster: 'luan',
        }
      end

      it { is_expected.to compile.with_all_deps }

      include_examples 'baremetal'
      include_context 'with nm interface'
      include_examples 'docker', docker_version: '24.0.9'

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
        is_expected.to contain_class('rke').with(
          version: '1.5.10',
          checksum: 'cd5d3e8cd77f955015981751c30022cead0bd78f14216fcd1c827c6a7e5cc26e',
        )
      end

      it { is_expected.to have_nm__connection_resource_count(0) }
    end # on os
  end # on_supported_os
end
