# frozen_string_literal: true

require 'spec_helper'

describe 'foreman.tuc.lsst.cloud', :sitepp do
  on_supported_os.each do |os, os_facts|
    next unless os =~ %r{almalinux-9-x86_64}

    context "on #{os}" do
      let(:facts) do
        lsst_override_facts(os_facts,
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
          enp1s0
        ]
      end

      include_context 'with nm interface'

      it { is_expected.to compile.with_all_deps }

      it_behaves_like 'vm'
      it_behaves_like 'dhcp server'

      context 'with enp1s0' do
        let(:interface) { 'enp1s0' }

        it_behaves_like 'nm enabled interface'
        it_behaves_like 'nm ethernet interface'
        it { expect(nm_keyfile['ipv4']['address1']).to eq('140.252.146.80/27,140.252.146.65') }
        it { expect(nm_keyfile['ipv4']['dns']).to eq('140.252.146.71;140.252.146.72;140.252.146.73;') }
        it { expect(nm_keyfile['ipv4']['dns-search']).to eq('tu.lsst.org;') }
        it { expect(nm_keyfile['ipv4']['method']).to eq('manual') }
      end

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
        is_expected.to contain_dhcp__pool('vlan3070').with(
          network: '140.252.147.32',
          mask: '255.255.255.240',
          range: ['140.252.147.44 140.252.147.46'],
          gateway: '140.252.147.33',
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
        is_expected.to contain_dhcp__pool('vlan3090').with(
          network: '140.252.147.96',
          mask: '255.255.255.224',
          range: [
            '140.252.147.109 140.252.147.113',
            '140.252.147.124 140.252.147.126',
          ],
          gateway: '140.252.147.97',
        )
      end
    end # on os
  end # on_supported_os
end # role
