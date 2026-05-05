# frozen_string_literal: true

require 'spec_helper'

describe 'profile::core::toqui_bridge' do
  on_supported_os.each do |os, os_facts|
    next unless os =~ %r{almalinux-9-x86_64}

    context "on #{os}" do
      let(:pre_condition) { 'include nm' }

      context 'when hostname is in the IP map' do
        let(:facts) do
          override_facts(os_facts,
                         networking: {
                           hostname: 'toqui01',
                         })
        end

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_nm__connection('br2141') }

        it do
          content = catalogue.resource('Nm::Connection', 'br2141')[:content]
          expect(content['connection']['id']).to eq('br2141')
          expect(content['connection']['type']).to eq('bridge')
          expect(content['connection']['interface-name']).to eq('br2141')
          expect(content['ipv4']['method']).to eq('manual')
          expect(content['ipv4']['address1']).to eq('139.229.143.49/25,139.229.143.126')
          expect(content['ipv4']['dns']).to eq('139.229.134.53;')
          expect(content['ipv4']['dns-search']).to eq('ls.lsst.org;')
          expect(content['ipv6']['method']).to eq('disabled')
        end
      end

      context 'when hostname is not in the IP map' do
        let(:facts) do
          override_facts(os_facts,
                         networking: {
                           hostname: 'other-host',
                         })
        end

        it { is_expected.to compile.with_all_deps }
        it { is_expected.not_to contain_nm__connection('br2141') }
      end
    end
  end
end
