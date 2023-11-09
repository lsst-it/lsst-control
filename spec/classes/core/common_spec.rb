# frozen_string_literal: true

require 'spec_helper'

describe 'profile::core::common' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }
      let(:pre_condition) do
        <<~PP
          # change service unit name from sssd.service to sssd
          class { 'sssd': service_names => ['sssd'] }
        PP
      end

      context 'with no params' do
        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_class('auditd') }
        it { is_expected.to contain_class('hosts') }
        it { is_expected.to contain_class('resolv_conf') }
        it { is_expected.to contain_class('profile::core::keytab') }
        it { is_expected.to contain_class('profile::core::nm_dispatch') }
        it { is_expected.to contain_package('ca-certificates').with_ensure('latest') }

        if facts[:os]['release']['major'] == '7'
          it { is_expected.to contain_class('network') }
        else
          it { is_expected.not_to contain_class('network') }
        end

        it do
          is_expected.to contain_service('NetworkManager').with(ensure: 'running', enable: true)
        end

        it do
          is_expected.to contain_file('/etc/sysconfig/network-scripts/ifcfg-').with_ensure('absent')
        end
      end

      context 'with resolv_conf param' do
        context 'when false' do
          let(:params) do
            {
              manage_resolv_conf: false,
            }
          end

          it { is_expected.not_to contain_class('resolv_conf') }
        end

        context 'when true' do
          let(:params) do
            {
              manage_resolv_conf: true,
            }
          end

          it { is_expected.to contain_class('resolv_conf') }
        end
      end

      context 'with manage_node_exporter param' do
        context 'when false' do
          let(:params) do
            {
              manage_node_exporter: false,
            }
          end

          include_examples 'no node_exporter'
        end

        context 'when true' do
          let(:params) do
            {
              manage_node_exporter: true,
            }
          end

          it { is_expected.to contain_class('prometheus::node_exporter') }
        end
      end
    end
  end
end
