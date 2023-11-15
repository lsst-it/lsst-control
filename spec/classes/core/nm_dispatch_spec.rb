# frozen_string_literal: true

require 'spec_helper'

describe 'profile::core::nm_dispatch' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      let(:pre_condition) do
        <<~PP
          if fact('os.release.major') == '7' {
            include network
          } else {
            include nm
          }
        PP
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

        let(:net_class) do
          if os_facts[:os]['release']['major'] == '7'
            'Class[network]'
          else
            'Class[nm]'
          end
        end

        it do
          is_expected.to contain_file('/etc/NetworkManager/dispatcher.d/50-eth0')
            .that_notifies(net_class)
        end

        it do
          is_expected.to contain_file('/etc/NetworkManager/dispatcher.d/50-eth1')
            .that_notifies(net_class)
        end
      end
    end
  end
end
