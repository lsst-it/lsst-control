# frozen_string_literal: true

require 'spec_helper'

describe 'profile::daq::daq_interface' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

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

          it { is_expected.to compile.with_all_deps }

          if facts[:os]['release']['major'] == '7'
            it do
              is_expected.to contain_network__interface('lsst-daq').with(
                hwaddr: 'aa:bb:cc:dd:ee:ff',
                uuid: '46f0198b-bf60-4331-82ba-9e29104b5efb',
                bootproto: 'dhcp',
              )
            end

            it { is_expected.to contain_network__interface('eth1').with_ensure('absent') }
            it { is_expected.to contain_reboot('lsst-daq') }
          else
            # el8+
            let(:interface) { 'lsst-daq' }
            include_context 'with nm interface'
            include_examples 'nm named interface'
            include_examples 'nm dhcp interface'
            it { expect(nm_keyfile['connection']['uuid']).to eq(params[:uuid]) }
            it { expect(nm_keyfile['ethernet']['mac-address']).to eq(params[:hwaddr]) }

            it do
              is_expected.to contain_profile__nm__connection('eth1').with_ensure('absent')
            end
          end

          it { is_expected.to contain_file('/etc/NetworkManager/dispatcher.d/30-ethtool') }
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

          it { is_expected.to compile.with_all_deps }

          if facts[:os]['release']['major'] == '7'
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
          else
            # el8+
            let(:interface) { 'lsst-daq' }
            include_context 'with nm interface'
            include_examples 'nm named interface'
            it { expect(nm_keyfile['connection']['uuid']).to eq(params[:uuid]) }
            it { expect(nm_keyfile['ethernet']['mac-address']).to eq(params[:hwaddr]) }
            it { expect(nm_keyfile['ipv4']['method']).to eq('manual') }
            it { expect(nm_keyfile['ipv4']['address1']).to eq('192.168.100.1/24') }
            it { expect(nm_keyfile['ipv6']['method']).to eq('disabled') }

            it do
              is_expected.to contain_profile__nm__connection('eth1').with_ensure('absent')
            end
          end

          it { is_expected.to contain_file('/etc/NetworkManager/dispatcher.d/30-ethtool') }
        end
      end
    end
  end
end
