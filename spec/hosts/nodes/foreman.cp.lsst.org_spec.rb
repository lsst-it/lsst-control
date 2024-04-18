# frozen_string_literal: true

require 'spec_helper'

describe 'foreman.cp.lsst.org', :sitepp do
  on_supported_os.each do |os, os_facts|
    # XXX networking needs to be updated to support EL8+
    next unless os =~ %r{centos-7-x86_64}

    context "on #{os}" do
      let(:facts) do
        override_facts(os_facts,
                       fqdn: 'foreman.cp.lsst.org',
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
          site: 'cp',
        }
      end
      let(:ntpservers) do
        %w[
          ntp.cp.lsst.org
          ntp.shoa.cl
          1.cl.pool.ntp.org
          1.south-america.pool.ntp.org
        ]
      end
      let(:nameservers) do
        %w[
          139.229.160.53
          139.229.160.54
          139.229.160.55
        ]
      end
      let(:dhcp_interfaces) do
        %w[
          eth0
        ]
      end

      it { is_expected.to compile.with_all_deps }

      include_examples 'vm'
      include_examples 'dhcp server'

      it do
        is_expected.to contain_network__interface('eth0').with(
          ipaddress: '139.229.160.5',
        )
      end

      it do
        is_expected.to contain_dhcp__pool('IT-GSS').with(
          network: '139.229.160.0',
          mask: '255.255.255.0',
          range: ['139.229.160.115 139.229.160.126'],
          gateway: '139.229.160.254',
        )
      end

      it do
        # VLAN1102
        is_expected.to contain_dhcp__pool('IT-CORE-SERVICES').with(
          network: '139.229.161.0',
          mask: '255.255.255.224',
          range: ['139.229.161.20 139.229.161.26'],
          gateway: '139.229.161.30',
        )
      end

      it do
        # VLAN1103
        is_expected.to contain_dhcp__pool('IT-HYPERVISOR').with(
          network: '139.229.161.32',
          mask: '255.255.255.240',
          range: ['139.229.161.40 139.229.161.42'],
          gateway: '139.229.161.46',
        )
      end

      it do
        # VLAN1104
        is_expected.to contain_dhcp__pool('IT-BMC').with(
          network: '139.229.162.0',
          mask: '255.255.255.0',
          range: ['139.229.162.230 139.229.162.250'],
          gateway: '139.229.162.254',
        )
      end

      it do
        is_expected.to contain_dhcp__pool('Summit-Wireless').with(
          network: '139.229.163.0',
          mask: '255.255.255.0',
          range: ['139.229.163.1 139.229.163.239'],
          gateway: '139.229.163.254',
        )
      end

      it do
        is_expected.to contain_dhcp__pool('RubinObs-LHN').with(
          network: '139.229.164.0',
          mask: '255.255.255.0',
          range: ['139.229.164.1 139.229.164.200'],
          gateway: '139.229.164.254',
        )
      end

      it do
        is_expected.to contain_dhcp__pool('CDS-ARCH').with(
          network: '139.229.165.0',
          mask: '255.255.255.0',
          range: ['139.229.165.200 139.229.165.249'],
          gateway: '139.229.165.254',
        )
      end

      it do
        is_expected.to contain_dhcp__pool('CDS-ARCH-DDS').with(
          network: '139.229.166.0',
          mask: '255.255.255.0',
          range: ['139.229.166.200 139.229.166.249'],
          gateway: '139.229.166.254',
          static_routes: [
            { 'network' => '139.229.147', 'mask' => '24', 'gateway' => '139.229.166.254' },
            { 'network' => '139.229.167', 'mask' => '24', 'gateway' => '139.229.166.254' },
            { 'network' => '139.229.170', 'mask' => '24', 'gateway' => '139.229.166.254' },
            { 'network' => '139.229.178', 'mask' => '24', 'gateway' => '139.229.166.254' },
          ],
        )
      end

      it do
        is_expected.to contain_dhcp__pool('ESS-Sensors').with(
          network: '139.229.168.0',
          mask: '255.255.255.128',
          range: ['139.229.168.100 139.229.168.125'],
          gateway: '139.229.168.126',
        )
      end

      it do
        is_expected.to contain_dhcp__pool('Dome-Calibrations').with(
          network: '139.229.168.128',
          mask: '255.255.255.192',
          range: ['139.229.168.140 139.229.168.189'],
          gateway: '139.229.168.190',
        )
      end

      it do
        is_expected.to contain_dhcp__pool('MTDome-Hardware').with(
          network: '139.229.168.192',
          mask: '255.255.255.192',
          range: ['139.229.168.243 139.229.168.249'],
          gateway: '139.229.168.254',
        )
      end

      it do
        is_expected.to contain_dhcp__pool('Startracker').with(
          network: '139.229.169.0',
          mask: '255.255.255.0',
          range: ['139.229.169.200 139.229.169.249'],
          gateway: '139.229.169.254',
          mtu: 9000,
        )
      end

      it do
        is_expected.to contain_dhcp__pool('DDS-Auxtel').with(
          network: '139.229.170.0',
          mask: '255.255.255.0',
          range: ['139.229.170.64 139.229.170.191'],
          gateway: '139.229.170.254',
        )
      end

      it do
        is_expected.to contain_dhcp__pool('TMA-Network').with(
          network: '139.229.171.0',
          mask: '255.255.255.0',
          range: ['139.229.171.150 139.229.171.180'],
          gateway: '139.229.171.254',
        )
      end

      it do
        is_expected.to contain_dhcp__pool('CCS-Pathfinder').with(
          network: '139.229.174.0',
          mask: '255.255.255.0',
          range: ['139.229.174.200 139.229.174.249'],
          gateway: '139.229.174.254',
        )
      end

      it do
        is_expected.to contain_dhcp__pool('CCS-ComCam').with(
          network: '139.229.175.0',
          mask: '255.255.255.192',
          range: ['139.229.175.1 139.229.175.61'],
          gateway: '139.229.175.62',
        )
      end

      it do
        is_expected.to contain_dhcp__pool('CCS-LSSTCam').with(
          network: '139.229.175.64',
          mask: '255.255.255.192',
          range: ['139.229.175.101 139.229.175.120'],
          gateway: '139.229.175.126',
        )
      end

      it do
        is_expected.to contain_dhcp__pool('CCS-Test-APP').with(
          network: '139.229.175.128',
          mask: '255.255.255.128',
          range: ['139.229.175.241 139.229.175.249'],
          gateway: '139.229.175.254',
        )
      end

      it do
        is_expected.to contain_dhcp__pool('TCS-APP').with(
          network: '139.229.178.0',
          mask: '255.255.255.0',
          range: ['139.229.178.2 139.229.178.58'],
          gateway: '139.229.178.254',
        )
      end

      it do
        is_expected.to contain_dhcp__pool('yagan-lhn').with(
          network: '139.229.180.0',
          mask: '255.255.255.0',
          range: ['139.229.180.71 139.229.180.100'],
          gateway: '139.229.180.254',
          static_routes: [
            { 'network' => '134.79.20', 'mask' => '23', 'gateway' => '139.229.180.254' },
            { 'network' => '134.79.23', 'mask' => '24', 'gateway' => '139.229.180.254' },
            { 'network' => '134.79.235.224', 'mask' => '28', 'gateway' => '139.229.180.254' },
            { 'network' => '134.79.235.240', 'mask' => '28', 'gateway' => '139.229.180.254' },
          ],
        )
      end

      it do
        is_expected.to contain_dhcp__pool('IT-Contractors').with(
          network: '139.229.191.0',
          mask: '255.255.255.128',
          range: ['139.229.191.1 139.229.191.64', '139.229.191.66 139.229.191.100'],
          gateway: '139.229.191.126',
        )
      end

      it do
        is_expected.to contain_dhcp__pool('IT-Guess').with(
          network: '139.229.191.128',
          mask: '255.255.255.128',
          range: ['139.229.191.129 139.229.191.239'],
          gateway: '139.229.191.254',
          nameservers: ['1.1.1.1', '1.0.0.1', '8.8.8.8'],
        )
      end

      it do
        is_expected.to contain_dhcp__pool('IT-IPMI-BMC').with(
          network: '10.18.3.0',
          mask: '255.255.255.0',
          range: ['10.18.3.150 10.18.3.249'],
          gateway: '10.18.3.254',
        )
      end

      it do
        is_expected.to contain_dhcp__pool('Rubin-Power').with(
          network: '10.18.7.0',
          mask: '255.255.255.0',
          range: ['10.18.7.150 10.18.7.249'],
          gateway: '10.18.7.254',
        )
      end

      it do
        is_expected.to contain_dhcp__pool('IT-AP').with(
          network: '10.17.3.0',
          mask: '255.255.255.0',
          range: ['10.17.3.1 10.17.3.249'],
          gateway: '10.17.3.254',
          options: ['cisco.wlc 139.229.160.100'],
        )
      end

      it do
        is_expected.to contain_dhcp__pool('IT-VOIP').with(
          network: '10.17.1.0',
          mask: '255.255.255.0',
          range: ['10.17.1.1 10.17.1.249'],
          gateway: '10.17.1.254',
          options: ['voip-tftp-server 139.229.160.102'],
        )
      end

      it do
        is_expected.to contain_dhcp__pool('IT-IPMI-PDU').with(
          network: '10.18.1.0',
          mask: '255.255.255.0',
          range: ['10.18.1.200 10.18.1.249'],
          gateway: '10.18.1.254',
        )
      end

      it do
        is_expected.to contain_dhcp__pool('IT-CCTV').with(
          network: '10.17.7.0',
          mask: '255.255.255.0',
          range: ['10.17.7.1 10.17.7.249'],
          gateway: '10.17.7.254',
        )
      end

      it do
        is_expected.to contain_dhcp__pool('IT-MISC').with(
          network: '10.17.5.0',
          mask: '255.255.255.0',
          range: ['10.17.5.200 10.17.5.249'],
          gateway: '10.17.5.254',
        )
      end

      it do
        is_expected.to contain_dhcp__pool('IT-IPMI-PXE').with(
          network: '10.18.5.0',
          mask: '255.255.255.0',
          range: ['10.18.5.200 10.18.5.249'],
          gateway: '10.18.5.254',
        )
      end
    end # on os
  end # on_supported_os
end # role
