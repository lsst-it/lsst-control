# frozen_string_literal: true

require 'spec_helper'

describe 'foreman.ls.lsst.org', :sitepp do
  on_supported_os.each do |os, os_facts|
    # XXX networking needs to be updated to support EL8+
    next unless os =~ %r{centos-7-x86_64}

    context "on #{os}" do
      let(:facts) do
        override_facts(os_facts,
                       fqdn: 'foreman.ls.lsst.org',
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
          site: 'ls',
        }
      end
      let(:ntpservers) do
        %w[
          ntp.shoa.cl
          ntp.cp.lsst.org
          1.cl.pool.ntp.org
          1.south-america.pool.ntp.org
        ]
      end
      let(:nameservers) do
        %w[
          139.229.135.53
          139.229.135.54
          139.229.135.55
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
          ipaddress: '139.229.135.5',
        )
      end

      it do
        is_expected.to contain_dhcp__pool('IT-Services').with(
          network: '139.229.135.0',
          mask: '255.255.255.0',
          range: ['139.229.135.192 139.229.135.249'],
          gateway: '139.229.135.254',
        )
      end

      it do
        is_expected.to contain_dhcp__pool('RubinObs-LHN').with(
          network: '139.229.137.0',
          mask: '255.255.255.0',
          range: ['139.229.137.1 139.229.137.200'],
          gateway: '139.229.137.254',
        )
      end

      it do
        is_expected.to contain_dhcp__pool('Rubin-DMZ').with(
          network: '139.229.138.0',
          mask: '255.255.255.0',
          range: ['139.229.138.200 139.229.138.250'],
          gateway: '139.229.138.254',
          nameservers: ['1.0.0.1', '1.1.1.1', '8.8.8.8'],
        )
      end

      it do
        is_expected.to contain_dhcp__pool('Archive-LHN').with(
          network: '139.229.140.0',
          mask: '255.255.255.224',
          range: ['139.229.140.24 139.229.140.30'],
          gateway: '139.229.140.1',
        )
      end

      it do
        is_expected.to contain_dhcp__pool('IT-CORE-SERVICES').with(
          network: '139.229.141.0',
          mask: '255.255.255.224',
          gateway: '139.229.141.30',
          range: ['139.229.141.20 139.229.141.26'],
        )
      end

      it do
        is_expected.to contain_dhcp__pool('IT-HYPERVISOR').with(
          network: '139.229.141.32',
          mask: '255.255.255.240',
          gateway: '139.229.141.46',
          range: ['139.229.141.40 139.229.141.42'],
        )
      end

      it do
        is_expected.to contain_dhcp__pool('IT-BMC').with(
          network: '139.229.142.0',
          mask: '255.255.255.0',
          gateway: '139.229.142.254',
          range: ['139.229.142.230 139.229.142.250'],
        )
      end

      it do
        is_expected.to contain_dhcp__pool('BDC-Ayekan').with(
          network: '139.229.144.0',
          mask: '255.255.255.192',
          range: ['139.229.144.40 139.229.144.59'],
          gateway: '139.229.144.62',
        )
      end

      it do
        is_expected.to contain_dhcp__pool('BDC-Teststand-DDS').with(
          network: '139.229.145.0',
          mask: '255.255.255.0',
          range: ['139.229.145.225 139.229.145.249'],
          gateway: '139.229.145.254',
        )
      end

      it do
        is_expected.to contain_dhcp__pool('Commissioning-Cluster').with(
          network: '139.229.146.0',
          mask: '255.255.255.0',
          range: ['139.229.146.225 139.229.146.249'],
          gateway: '139.229.146.254',
        )
      end

      it do
        is_expected.to contain_dhcp__pool('DDS-Base').with(
          network: '139.229.147.0',
          mask: '255.255.255.0',
          range: ['139.229.147.225 139.229.147.249'],
          gateway: '139.229.147.254',
        )
      end

      it do
        is_expected.to contain_dhcp__pool('CDS-NAS').with(
          network: '139.229.148.0',
          mask: '255.255.255.0',
          range: ['139.229.148.225 139.229.148.249'],
          gateway: '139.229.148.254',
        )
      end

      it do
        is_expected.to contain_dhcp__pool('Base-Archive').with(
          network: '139.229.149.0',
          mask: '255.255.255.0',
          range: ['139.229.149.225 139.229.149.249'],
          gateway: '139.229.149.254',
        )
      end

      it do
        is_expected.to contain_dhcp__pool('Comcam-CCS').with(
          network: '139.229.150.0',
          mask: '255.255.255.128',
          range: ['139.229.150.112 139.229.150.125'],
          gateway: '139.229.150.126',
        )
      end

      it do
        is_expected.to contain_dhcp__pool('BTS_MANKE').with(
          network: '139.229.151.0',
          mask: '255.255.255.0',
          range: ['139.229.151.201 139.229.151.249'],
          gateway: '139.229.151.254',
        )
      end

      it do
        is_expected.to contain_dhcp__pool('DDS-BTS').with(
          network: '139.229.152.0',
          mask: '255.255.255.128',
          range: ['139.229.152.70 139.229.152.120'],
        )
      end

      it do
        is_expected.to contain_dhcp__pool('BTS_AUXTEL').with(
          network: '139.229.152.128',
          mask: '255.255.255.192',
          range: ['139.229.152.171 139.229.152.180'],
          gateway: '139.229.152.190',
        )
      end

      it do
        is_expected.to contain_dhcp__pool('BTS_MISC').with(
          network: '139.229.152.192',
          mask: '255.255.255.192',
          range: ['139.229.152.210 139.229.152.250'],
          gateway: '139.229.152.254',
        )
      end

      it do
        is_expected.to contain_dhcp__pool('BTS_LHN').with(
          network: '139.229.153.0',
          mask: '255.255.255.0',
          range: ['139.229.153.201 139.229.153.249'],
          gateway: '139.229.153.254',
          static_routes: [
            { 'network' => '134.79.20', 'mask' => '23', 'gateway' => '139.229.153.254' },
            { 'network' => '134.79.23', 'mask' => '24', 'gateway' => '139.229.153.254' },
            { 'network' => '134.79.235.224', 'mask' => '28', 'gateway' => '139.229.153.254' },
            { 'network' => '134.79.235.240', 'mask' => '28', 'gateway' => '139.229.153.254' },
          ],
        )
      end

      it do
        is_expected.to contain_dhcp__pool('BTS_LSSTCAM').with(
          network: '139.229.154.0',
          mask: '255.255.255.192',
          range: ['139.229.154.49 139.229.154.58'],
          gateway: '139.229.154.62',
        )
      end

      it do
        is_expected.to contain_dhcp__pool('RubinObs-WiFi-Guest').with(
          network: '139.229.159.128',
          mask: '255.255.255.128',
          range: ['139.229.159.129 139.229.159.230'],
          gateway: '139.229.159.254',
        )
      end

      it do
        is_expected.to contain_dhcp__pool('BDC-BMC').with(
          network: '10.50.3.0',
          mask: '255.255.255.0',
          range: ['10.50.3.1 10.50.3.249'],
          gateway: '10.50.3.254',
        )
      end

      it do
        is_expected.to contain_dhcp__pool('BDC-APS').with(
          network: '10.49.3.0',
          mask: '255.255.255.0',
          range: ['10.49.3.1 10.49.3.249'],
          gateway: '10.49.3.254',
          options: ['cisco.wlc 139.229.134.100'],
        )
      end

      it do
        is_expected.to contain_dhcp__pool('BDC-VoIP').with(
          network: '10.49.1.0',
          mask: '255.255.255.0',
          range: ['10.49.1.1 10.49.1.249'],
          gateway: '10.49.1.254',
          options: ['voip-tftp-server 139.229.134.102'],
        )
      end

      it do
        is_expected.to contain_dhcp__pool('BDC-PDU').with(
          network: '10.50.1.0',
          mask: '255.255.255.0',
          range: ['10.50.1.200 10.50.1.249'],
          gateway: '10.50.1.254',
        )
      end

      it do
        is_expected.to contain_dhcp__pool('BDC-CCTV').with(
          network: '10.49.7.0',
          mask: '255.255.255.0',
          range: ['10.49.7.1 10.49.7.249'],
          gateway: '10.49.7.254',
        )
      end

      it do
        is_expected.to contain_dhcp__pool('ANTU-FQDN').with(
          network: '139.229.154.96',
          mask: '255.255.255.240',
          range: ['139.229.154.102 139.229.154.107'],
          gateway: '139.229.154.110',
        )
      end

      it do
        is_expected.to contain_dhcp__pool('BDC-BMC-PUBLIC').with(
          network: '139.229.139.0',
          mask: '255.255.255.0',
          range: ['139.229.139.230 139.229.139.250'],
          gateway: '139.229.139.254',
        )
      end

      it do
        is_expected.to contain_dhcp__pool('ANTU-METALLB').with(
          network: '139.229.154.64',
          mask: '255.255.255.224',
          range: ['139.229.154.88 139.229.154.91'],
          gateway: '139.229.154.94',
        )
      end
    end # on os
  end # on_supported_os
end # role
