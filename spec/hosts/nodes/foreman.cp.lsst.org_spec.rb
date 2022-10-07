# frozen_string_literal: true

require 'spec_helper'

describe 'foreman.cp.lsst.org', :site do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts.merge(
          fqdn: 'foreman.cp.lsst.org',
        )
      end

      let(:node_params) do
        {
          role: 'foreman',
          site: 'cp',
          cluster: 'corecp',
        }
      end

      let(:manifest) do
        <<~SUMMARY
        dhcp::pool{ 'it_gss':
        network => '139.229.160.0',
        mask    => '255.255.255.0',
        range   => ['139.229.160.1 139.229.160.99'],
        gateway => '139.229.160.254',
        }
        dhcp::pool{ 'it_gs':
        network => '139.229.161.0',
        mask    => '255.255.255.0',
        range   => ['139.229.161.1 139.229.161.99'],
        gateway => '139.229.161.254',
        }
        dhcp::pool{ 'users':
        network => '139.229.162.0',
        mask    => '255.255.255.128',
        range   => ['139.229.162.28 139.229.162.37'],
        gateway => '139.229.162.126',
        }
        dhcp::pool{ 'users_163':
        network => '139.229.163.0',
        mask    => '255.255.255.0',
        range   => ['139.229.163.1 139.229.163.239'],
        gateway => '139.229.163.254',
        }
        dhcp::pool{ 'Rubin_LHN':
        network => '139.229.164.0',
        mask    => '255.255.255.0',
        range   => ['139.229.164.1 139.229.164.200'],
        gateway => '139.229.164.254',
        }
        dhcp::pool{ 'cds-arch':
        network => '139.229.165.0',
        mask    => '255.255.255.0',
        range   => ['139.229.165.200 139.229.165.253'],
        gateway => '139.229.165.254',
        }
        dhcp::pool{ 'cds-arch-dds':
        network => '139.229.166.0',
        mask    => '255.255.255.0',
        range   => ['139.229.166.200 139.229.166.253'],
        gateway => '139.229.166.254',
        }
        dhcp::pool{ 'ocs_app':
        network => '139.229.167.0',
        mask    => '255.255.255.0',
        range   => ['139.229.167.241 139.229.167.253'],
        gateway => '139.229.167.254',
        }
        dhcp::pool{ 'ess_sensors':
        network => '139.229.168.0',
        mask    => '255.255.255.128',
        range   => ['139.229.168.100 139.229.168.125'],
        gateway => '139.229.168.126',
        }
        dhcp::pool{ 'dome_calibration':
        network => '139.229.168.128',
        mask    => '255.255.255.192',
        range   => ['139.229.168.180 139.229.168.189'],
        gateway => '139.229.168.190',
        }
        dhcp::pool{ 'mtdome_hardware':
        network => '139.229.168.192',
        mask    => '255.255.255.192',
        range   => ['139.229.168.243 139.229.168.253'],
        gateway => '139.229.168.254',
        }
        dhcp::pool{ 'dds_auxtel':
        network => '139.229.170.0',
        mask    => '255.255.255.0',
        range   => ['139.229.170.64 139.229.170.191'],
        gateway => '139.229.170.254',
        }
        dhcp::pool{ 'ccs_pathfinder':
        network => '139.229.174.0',
        mask    => '255.255.255.0',
        range   => ['139.229.174.200 139.229.174.254'],
        gateway => '139.229.174.254',
        }
        dhcp::pool{ 'ccs_comcam':
        network => '139.229.175.0',
        mask    => '255.255.255.192',
        range   => ['139.229.175.1 139.229.175.61'],
        gateway => '139.229.175.62',
        }
        dhcp::pool{ 'ccs_lsstcam':
        network => '139.229.175.64',
        mask    => '255.255.255.192',
        range   => ['139.229.175.65 139.229.175.125'],
        gateway => '139.229.175.126',
        }
        dhcp::pool{ 'ccs_test_app':
        network => '139.229.175.128',
        mask    => '255.255.255.128',
        range   => ['139.229.175.241 139.229.175.253'],
        gateway => '139.229.175.254',
        }
        dhcp::pool{ 'tcs_app':
        network => '139.229.178.0',
        mask    => '255.255.255.0',
        range   => ['139.229.178.2 139.229.178.62'],
        gateway => '139.229.178.254',
        }
        dhcp::pool{ 'contractors_cp':
        network => '139.229.191.0',
        mask    => '255.255.255.128',
        range   => ['139.229.191.1 139.229.191.64','139.229.191.66 139.229.191.100'],
        gateway => '139.229.191.126',
        }
        dhcp::pool{ 'guests_cp':
        network => '139.229.191.128',
        mask    => '255.255.255.128',
        range   => ['139.229.191.129 139.229.191.239'],
        gateway => '139.229.191.254',
        }
        dhcp::pool{ 'it_cctv':
        network => '10.17.7.0',
        mask    => '255.255.255.0',
        range   => ['10.17.7.200 10.17.7.250'],
        gateway => '10.17.7.254',
        }
        dhcp::pool{ 'it_ipmi_srv':
        network => '10.18.3.0',
        mask    => '255.255.255.0',
        range   => ['10.18.3.150 10.18.3.253'],
        gateway => '10.18.3.254',
        }
        dhcp::pool{ 'rubin_power':
        network => '10.18.7.0',
        mask    => '255.255.255.0',
        range   => ['10.18.7.150 10.18.7.253'],
        gateway => '10.18.7.254',
        }
        SUMMARY
      end

      it { is_expected.to compile.with_all_deps }
    end # on os
  end # on_supported_os
end # role
