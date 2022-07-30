# frozen_string_literal: true

require 'spec_helper'

describe 'profile::core::nm_dispatch' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context 'with no params' do
        it { is_expected.to have_file_resource_count(0) }
      end

      context 'with interfaces param' do
        let(:params) do
          {
            interfaces:
              {
                eth0: [
                  '/sbin/ethtool --set-ring ${DEV} rx 4096 tx 4096',
                ],
                eth1: [
                  'tc filter del dev ${DEV} chain 0 || true',
                ],
              },
          }
        end

        it { is_expected.to have_file_resource_count(2) }

        it do
          is_expected.to contain_file('/etc/NetworkManager/dispatcher.d/50-eth0')
            .that_notifies('Class[network]')
        end

        it do
          is_expected.to contain_file('/etc/NetworkManager/dispatcher.d/50-eth1')
            .that_notifies('Class[network]')
        end
      end
    end
  end
end
