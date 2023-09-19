# frozen_string_literal: true

require 'spec_helper'

describe 'lukay01.cp.lsst.org', :sitepp do
  alma9 = FacterDB.get_facts({ operatingsystem: 'AlmaLinux', operatingsystemmajrelease: '9' }).first
  # rubocop:disable Naming/VariableNumber
  { 'almalinux-9-x86_64': alma9 }.each do |os, facts|
    # rubocop:enable Naming/VariableNumber
    context "on #{os}" do
      let(:facts) do
        override_facts(facts,
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

      it { is_expected.to have_network__interface_resource_count(0) }
      it { is_expected.to have_nm__connection_resource_count(0) }
    end # on os
  end # on_supported_os
end
