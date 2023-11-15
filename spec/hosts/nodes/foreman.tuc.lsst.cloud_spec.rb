# frozen_string_literal: true

require 'spec_helper'

describe 'foreman.tuc.lsst.cloud', :sitepp do
  on_supported_os.each do |os, os_facts|
    # XXX networking needs to be updated to support EL8+
    next unless os =~ %r{centos-7-x86_64}

    context "on #{os}" do
      let(:facts) do
        override_facts(os_facts,
                       fqdn: 'foreman.tuc.lsst.cloud',
                       is_virtual: true,
                       virtual: 'kvm',
                       dmi: {
                         'product' => {
                           'name' => 'KVM',
                         },
                       })
      end
      let(:node_params) do
        {
          role: 'foreman',
          site: 'tu',
        }
      end
      let(:ntpservers) do
        %w[
          140.252.1.140
          140.252.1.141
          140.252.1.142
        ]
      end
      let(:nameservers) do
        %w[
          140.252.146.71
          140.252.146.72
          140.252.146.73
        ]
      end
      let(:dhcp_interfaces) do
        %w[
          eth0
          eth1
        ]
      end

      it { is_expected.to compile.with_all_deps }

      include_examples 'vm'
      include_examples 'dhcp server'

      it do
        is_expected.to contain_dhcp__pool('vlan3030').with(
          network: '140.252.146.32',
          mask: '255.255.255.224',
          range: ['140.252.146.60 140.252.146.62'],
          gateway: '140.252.146.33',
        )
      end

      it do
        is_expected.to contain_dhcp__pool('vlan3040').with(
          network: '140.252.146.64',
          mask: '255.255.255.224',
          range: ['140.252.146.90 140.252.146.94'],
          gateway: '140.252.146.65',
        )
      end

      it do
        is_expected.to contain_dhcp__pool('vlan3050').with(
          network: '140.252.146.128',
          mask: '255.255.255.192',
          range: ['140.252.146.181 140.252.146.190'],
          gateway: '140.252.146.129',
        )
      end

      it do
        is_expected.to contain_dhcp__pool('vlan3060').with(
          network: '140.252.147.0',
          mask: '255.255.255.240',
          range: ['140.252.147.11 140.252.147.14'],
          gateway: '140.252.147.1',
        )
      end

      it do
        is_expected.to contain_dhcp__pool('vlan3065').with(
          network: '140.252.147.16',
          mask: '255.255.255.240',
          range: ['140.252.147.24 140.252.147.30'],
          gateway: '140.252.147.17',
          static_routes: [
            { 'network' => '140.252.147.48', 'mask' => '28', 'gateway' => '140.252.147.17' },
            { 'network' => '140.252.147.128', 'mask' => '27', 'gateway' => '140.252.147.17' },
          ],
        )
      end

      it do
        is_expected.to contain_dhcp__pool('vlan3070').with(
          network: '140.252.147.32',
          mask: '255.255.255.240',
          range: ['140.252.147.44 140.252.147.46'],
          gateway: '140.252.147.33',
        )
      end

      it do
        is_expected.to contain_dhcp__pool('vlan3075').with(
          network: '140.252.147.48',
          mask: '255.255.255.240',
          range: ['140.252.147.56 140.252.147.62'],
          gateway: '140.252.147.49',
          static_routes: [
            { 'network' => '140.252.147.16', 'mask' => '28', 'gateway' => '140.252.147.49' },
            { 'network' => '140.252.147.128', 'mask' => '27', 'gateway' => '140.252.147.49' },
          ],
        )
      end

      it do
        is_expected.to contain_dhcp__pool('vlan3080').with(
          network: '140.252.147.64',
          mask: '255.255.255.224',
          range: ['140.252.147.69 140.252.147.78'],
          gateway: '140.252.147.65',
        )
      end

      it do
        is_expected.to contain_dhcp__pool('vlan3085').with(
          network: '140.252.147.128',
          mask: '255.255.255.224',
          range: ['140.252.147.132 140.252.147.158'],
          gateway: '140.252.147.129',
          static_routes: [
            { 'network' => '140.252.147.16', 'mask' => '28', 'gateway' => '140.252.147.129' },
            { 'network' => '140.252.147.48', 'mask' => '28', 'gateway' => '140.252.147.129' },
          ],
        )
      end

      it do
        is_expected.to contain_dhcp__pool('vlan3090').with(
          network: '140.252.147.96',
          mask: '255.255.255.224',
          range: ['140.252.147.124 140.252.147.126'],
          gateway: '140.252.147.97',
        )
      end
    end # on os
  end # on_supported_os
end # role
