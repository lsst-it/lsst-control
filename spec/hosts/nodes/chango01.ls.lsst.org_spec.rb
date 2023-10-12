# frozen_string_literal: true

require 'spec_helper'

describe 'chango01.ls.lsst.org', :sitepp do
  alma9 = FacterDB.get_facts({ operatingsystem: 'AlmaLinux', operatingsystemmajrelease: '9' }).first
  # rubocop:disable Naming/VariableNumber
  { 'almalinux-9-x86_64': alma9 }.each do |os, facts|
    # rubocop:enable Naming/VariableNumber
    context "on #{os}" do
      let(:facts) { override_facts(facts, fqdn: 'chango01.ls.lsst.org') }
      let(:node_params) do
        {
          role: 'rke',
          site: 'ls',
          cluster: 'chango',
        }
      end

      include_context 'with nm interface'

      it { is_expected.to compile.with_all_deps }

      it do
        is_expected.to contain_class('clustershell').with(
          groupmembers: {
            'chango' => {
              'group' => 'chango',
              'member' => 'chango[01-03]',
            },
          },
        )
      end

      it do
        is_expected.to contain_class('profile::core::rke').with(
          version: '1.4.6',
        )
      end

      it { is_expected.to have_nm__connection_resource_count(0) }
    end # on os
  end # on_supported_os
end
