# frozen_string_literal: true

require 'spec_helper'

role = 'foreman'

describe "#{role} role" do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }
      let(:node_params) do
        {
          role: role,
          site: site,
        }
      end
      let(:smee_url) { 'https://smee.io/lpxrggGObEn5YTA' }

      describe 'foreman.dev.lsst.org', :sitepp do
        facts.merge!(fqdn: 'foreman.dev.lsst.org')
        let(:site) { 'dev' }
        let(:ntpservers) do
          %w[
            ntp.shoa.cl
            ntp.cp.lsst.org
            1.cl.pool.ntp.org
            1.south-america.pool.ntp.org
          ]
        end
        let(:ignore_branch_prefixes) do
          %w[
            master
            ncsa_production
            disable
            core
            cp
            dev
            ls
            tu
          ]
        end

        it do
          is_expected.to contain_dhcp__pool('IT-Dev').with(
            network: '139.229.134.0',
            mask: '255.255.255.0',
            range: ['139.229.134.120 139.229.134.149'],
            gateway: '139.229.134.254',
          )
        end

        it { is_expected.to compile.with_all_deps }

        include_examples 'common', facts: facts
        include_examples 'generic foreman'
      end # host

      describe 'foreman.tuc.lsst.cloud', :sitepp do
        facts.merge!(fqdn: 'foreman.tuc.lsst.cloud')
        let(:site) { 'tu' }
        let(:ntpservers) do
          %w[
            140.252.1.140
            140.252.1.141
            140.252.1.142
          ]
        end
        let(:ignore_branch_prefixes) do
          %w[
            master
            ncsa_production
            disable
            core
            cp
            dev
            ls
            tu
          ]
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

        it { is_expected.to compile.with_all_deps }

        include_examples 'common', facts: facts
        include_examples 'generic foreman'
      end # host

      describe 'foreman.ls.lsst.org', :sitepp do
        facts.merge!(fqdn: 'foreman.ls.lsst.org')
        let(:site) { 'ls' }
        let(:ntpservers) do
          %w[
            ntp.shoa.cl
            ntp.cp.lsst.org
            1.cl.pool.ntp.org
            1.south-america.pool.ntp.org
          ]
        end
        let(:ignore_branch_prefixes) do
          %w[
            master
            ncsa_production
            disable
            core
            cp
            dev
            ls
            tu
          ]
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

        it { is_expected.to compile.with_all_deps }

        include_examples 'common', facts: facts
        include_examples 'generic foreman'
      end # host

      describe 'foreman.cp.lsst.org', :sitepp do
        facts.merge!(fqdn: 'foreman.cp.lsst.org')
        let(:site) { 'cp' }
        let(:ntpservers) do
          %w[
            ntp.cp.lsst.org
            ntp.shoa.cl
            1.cl.pool.ntp.org
            1.south-america.pool.ntp.org
          ]
        end
        let(:ignore_branch_prefixes) do
          %w[
            master
            ncsa_production
            disable
            core
            dev
            ls
            tu
          ]
        end

        it do
          is_expected.to contain_dhcp__pool('IT-GSS').with(
            network: '139.229.160.0',
            mask: '255.255.255.0',
            range: ['139.229.160.1 139.229.160.99'],
            gateway: '139.229.160.254',
          )
        end

        it do
          is_expected.to contain_dhcp__pool('IT-GS').with(
            network: '139.229.161.0',
            mask: '255.255.255.0',
            range: ['139.229.161.200 139.229.161.249'],
            gateway: '139.229.161.254',
          )
        end

        it do
          is_expected.to contain_dhcp__pool('IT-Legacy').with(
            network: '139.229.162.0',
            mask: '255.255.255.128',
            range: ['139.229.162.28 139.229.162.37'],
            gateway: '139.229.162.126',
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
          is_expected.to contain_dhcp__pool('OCS-APP').with(
            network: '139.229.167.0',
            mask: '255.255.255.0',
            range: ['139.229.167.241 139.229.167.249'],
            gateway: '139.229.167.254',
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
            range: ['139.229.168.180 139.229.168.189'],
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
            range: ['139.229.175.65 139.229.175.125'],
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
            range: ['139.229.180.1 139.229.180.62'],
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

        it { is_expected.to compile.with_all_deps }

        include_examples 'common', facts: facts
        include_examples 'generic foreman'
      end # host
    end
  end
end
