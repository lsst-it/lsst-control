# frozen_string_literal: true

require 'spec_helper'

describe 'profile::core::sysctl::rp_filter' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:net_int) do
        {
          'lo' => {
            'bindings' => [
              {
                'address' => '127.0.0.1',
                'netmask' => '255.0.0.0',
                'network' => '127.0.0.0',
              },
            ],
            'ip' => '127.0.0.1',
            'mtu' => 65_536,
            'netmask' => '255.0.0.0',
            'network' => '127.0.0.0',
          },
          'p2p1' => {
            'dhcp' => '1.2.3.4',  # this looks like a bug in facter
            'mac' => 'a0:36:9f:c7:79:d4',
            'mtu' => 1500,
          },
          'p2p1.2505' => {
            'dhcp' => '1.2.3.4',
            'mac' => 'a0:36:9f:c7:79:d4',
            'mtu' => 1500,
          },
        }
      end
      let(:facts) do
        os_facts.delete(:networking)
        override_facts(os_facts, networking: { interfaces: net_int })
      end

      interfaces = %w[
        default
        all
        lo
        p2p1
        p2p1/2505
      ]

      it { is_expected.to compile.with_all_deps }
      it { is_expected.to have_sysctl__value_resource_count(interfaces.count) }

      interfaces.each do |int|
        it { is_expected.to contain_sysctl__value("net.ipv4.conf.#{int}.rp_filter") }
      end
    end
  end
end
