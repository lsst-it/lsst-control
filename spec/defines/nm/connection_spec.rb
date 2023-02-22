# frozen_string_literal: true

require 'spec_helper'

describe 'profile::nm::connection' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }
      let(:title) { 'foo' }
      let(:params) { { content: 'bar' } }

      let(:pre_condition) do
        <<~PP
          include profile::nm
        PP
      end

      it { is_expected.to compile.with_all_deps }

      it do
        is_expected.to contain_file('/etc/NetworkManager/system-connections/foo.nmconnection').with(
          ensure: 'file',
          mode: '0600',
          content: 'bar',
        ).that_notifies('Exec[nmcli conn reload]')
      end

      context 'with ensure =>' do
        context 'with absent' do
          let(:params) { { content: 'bar', ensure: 'absent' } }

          it do
            is_expected.to contain_file('/etc/NetworkManager/system-connections/foo.nmconnection').with(
              ensure: 'absent',
            )
          end
        end

        context 'with absent and without content' do
          let(:params) { { ensure: 'absent' } }

          it do
            is_expected.to contain_file('/etc/NetworkManager/system-connections/foo.nmconnection').with(
              ensure: 'absent',
            )
          end
        end

        context 'with present' do
          let(:params) { { content: 'bar', ensure: 'present' } }

          it do
            is_expected.to contain_file('/etc/NetworkManager/system-connections/foo.nmconnection').with(
              ensure: 'file',
            )
          end
        end
      end
    end
  end
end
