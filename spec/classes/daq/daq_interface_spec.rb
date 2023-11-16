# frozen_string_literal: true

require 'spec_helper'

describe 'profile::daq::daq_interface' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      context 'with no params' do
        it { is_expected.to compile.with_all_deps }
        it { is_expected.not_to contain_network__interface('lsst-daq') }
        it { is_expected.not_to contain_network__interface('eth1') }
        it { is_expected.not_to contain_reboot('lsst-daq') }
        it { is_expected.not_to contain_file('/etc/NetworkManager/dispatcher.d/30-ethtool') }
      end

      context 'with param mode => dhcp-client' do
        let(:params) { { mode: 'dhcp-client' } }

        it { is_expected.to compile.and_raise_error(%r{hwaddr param is required}) }

        context 'with hwaddr, uuid, and was params' do
          let(:params) do
            super().merge(
              hwaddr: 'aa:bb:cc:dd:ee:ff',
              uuid: '46f0198b-bf60-4331-82ba-9e29104b5efb',
              was: 'eth1',
            )
          end

          if os_facts[:os]['release']['major'] == '7'
            it { is_expected.to compile.with_all_deps }

            it do
              is_expected.to contain_network__interface('lsst-daq').with(
                hwaddr: 'aa:bb:cc:dd:ee:ff',
                uuid: '46f0198b-bf60-4331-82ba-9e29104b5efb',
                bootproto: 'dhcp',
              )
            end

            it { is_expected.to contain_network__interface('eth1').with_ensure('absent') }
            it { is_expected.to contain_reboot('lsst-daq') }
            it { is_expected.to contain_file('/etc/NetworkManager/dispatcher.d/30-ethtool') }
          else
            # el8+
            it { is_expected.to compile.and_raise_error(%r{unsupported on EL8+}) }
          end
        end
      end

      context 'with param mode => dhcp-server' do
        let(:params) { { mode: 'dhcp-server' } }

        it { is_expected.to compile.and_raise_error(%r{hwaddr param is required}) }

        context 'with hwaddr, uuid, and was params' do
          let(:params) do
            super().merge(
              hwaddr: 'aa:bb:cc:dd:ee:ff',
              uuid: '46f0198b-bf60-4331-82ba-9e29104b5efb',
              was: 'eth1',
            )
          end

          if os_facts[:os]['release']['major'] == '7'
            it { is_expected.to compile.with_all_deps }

            it do
              is_expected.to contain_network__interface('lsst-daq').with(
                hwaddr: 'aa:bb:cc:dd:ee:ff',
                uuid: '46f0198b-bf60-4331-82ba-9e29104b5efb',
                bootproto: 'none',
                ipaddress: '192.168.100.1',
                netmask: '255.255.255.0',
              )
            end

            it { is_expected.to contain_network__interface('eth1').with_ensure('absent') }
            it { is_expected.to contain_reboot('lsst-daq') }
            it { is_expected.to contain_file('/etc/NetworkManager/dispatcher.d/30-ethtool') }
          else
            # el8+
            it { is_expected.to compile.and_raise_error(%r{unsupported on EL8+}) }
          end
        end
      end
    end
  end
end
