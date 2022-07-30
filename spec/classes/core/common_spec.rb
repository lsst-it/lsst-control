# frozen_string_literal: true

require 'spec_helper'

describe 'profile::core::common' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      it { is_expected.to compile.with_all_deps }
      it { is_expected.to contain_class('hosts') }
      it { is_expected.to contain_class('network') }
      it { is_expected.to contain_class('profile::core::nm_dispatch') }
      it { is_expected.to contain_package('ca-certificates').with_ensure('latest') }

      it do
        is_expected.to contain_service('NetworkManager').with(ensure: 'running', enable: true)
      end

      it do
        is_expected.to contain_file('/etc/sysconfig/network-scripts/ifcfg-').with_ensure('absent')
      end
    end
  end
end
