# frozen_string_literal: true

require 'spec_helper'

describe 'auxtel-daq-mgt.cp.lsst.org', :sitepp do
  on_supported_os.each do |os, os_facts|
    next unless os =~ %r{centos-7-x86_64}

    context "on #{os}" do
      let(:facts) do
        override_facts(os_facts,
                       fqdn: 'auxtel-daq-mgt.cp.lsst.org',
                       is_virtual: false,
                       virtual: 'physical',
                       dmi: {
                         'product' => {
                           'name' => 'PowerEdge R630',
                         },
                       })
      end
      let(:node_params) do
        {
          role: 'daq-mgt',
          site: 'cp',
        }
      end

      it { is_expected.to compile.with_all_deps }

      include_examples 'baremetal'
      include_examples 'lsst-daq dhcp-server'
      include_examples 'daq nfs exports'

      it { is_expected.to contain_class('daq::daqsdk') }
      it { is_expected.to contain_class('daq::rptsdk').with_version('V3.5.3') }
      it { is_expected.to contain_host('auxtel-sm').with_ip('192.168.101.2') }
      it { is_expected.to contain_network__interface('p3p1').with_ensure('absent') }

      it do
        is_expected.to contain_network__interface('em2').with(
          bootproto: 'none',
          # defroute: 'no',
          ipaddress: '192.168.101.1',
          # ipv6init: 'no',
          netmask: '255.255.255.0',
          onboot: 'yes',
          type: 'Ethernet',
        )
      end
    end # on os
  end # on_supported_os
end
