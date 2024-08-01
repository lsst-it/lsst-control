# frozen_string_literal: true

require 'spec_helper'

describe 'profile::core::openvpnas' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      context 'with default parameters' do
        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_exec('install_openvpn_repo').with(command: '/bin/rpm -Uvh https://as-repository.openvpn.net/as-repo-rhel9.rpm') }

        it do
          is_expected.to contain_package('openvpn-as').with(
            ensure: 'present',
            require: 'Exec[install_openvpn_repo]',
          )
        end

        it do
          is_expected.to contain_service('openvpnas').with(
            ensure: 'running',
            enable: true,
            require: 'Package[openvpn-as]',
          )
        end
      end
    end
  end
end
