# frozen_string_literal: true

require 'spec_helper'

describe 'yepun01.cp.lsst.org', :sitepp do
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
          role: 'rke',
          site: 'cp',
          cluster: 'yepun',
        }
      end

      it { is_expected.to compile.with_all_deps }

      include_examples 'docker', docker_version: '25.0.3'
      include_examples 'baremetal'
      include_context 'with nm interface'
      include_examples 'ceph cluster'

      it do
        is_expected.to contain_class('clustershell').with(
          groupmembers: {
            'yepun' => {
              'group' => 'yepun',
              'member' => 'yepun[01-05]',
            },
          }
        )
      end

      it do
        is_expected.to contain_class('rke').with(
          version: '1.8.0',
          checksum: '8815da0452ae14a45566b534c48a2af6286ee73f800208ba6ec59188cb9a8d25'
        )
      end

      it { is_expected.to have_nm__connection_resource_count(0) }
    end # on os
  end # on_supported_os
end
