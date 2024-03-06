# frozen_string_literal: true

require 'spec_helper'

describe 'lukay01.cp.lsst.org', :sitepp do
  on_supported_os.each do |os, os_facts|
    next unless os =~ %r{almalinux-9-x86_64}

    context "on #{os}" do
      let(:facts) do
        override_facts(os_facts,
                       fqdn: 'lukay01.cp.lsst.org',
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
          cluster: 'lukay',
        }
      end

      it { is_expected.to compile.with_all_deps }

      include_examples 'docker', docker_version: '24.0.9'
      include_examples 'baremetal'
      include_context 'with nm interface'

      it do
        is_expected.to contain_class('clustershell').with(
          groupmembers: {
            'lukay' => {
              'group' => 'lukay',
              'member' => 'lukay[01-04]',
            },
          },
        )
      end

      it do
        is_expected.to contain_class('profile::core::rke').with(
          version: '1.3.12',
        )
      end

      it { is_expected.to have_nm__connection_resource_count(0) }
    end # on os
  end # on_supported_os
end
