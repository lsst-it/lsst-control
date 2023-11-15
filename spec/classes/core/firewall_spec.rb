# frozen_string_literal: true

require 'spec_helper'

describe 'profile::core::firewall' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      it { is_expected.to compile.with_all_deps }
      it { is_expected.to contain_class('firewall') }
      it { is_expected.to contain_class('ipset').that_comes_before('Class[firewall]') }
      it { is_expected.to have_resources_resource_count(0) }
      it { is_expected.to have_firewall_resource_count(0) }

      context 'with purge_firewall param' do
        let(:params) { { purge_firewall: true } }

        it { is_expected.to contain_resources('firewall').with_purge(true) }
      end

      context 'with firewall param' do
        let(:params) do
          {
            firewall: {
              '001 accept all icmp' => {
                'proto' => 'icmp',
                'action' => 'accept',
              },
            },
          }
        end

        it do
          is_expected.to contain_firewall('001 accept all icmp').with(
            'proto' => 'icmp',
            'action' => 'accept',
          )
        end
      end
    end
  end
end
