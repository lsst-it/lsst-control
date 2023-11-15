# frozen_string_literal: true

require 'spec_helper'

describe 'gis-bastion01.cp.lsst.org', :sitepp do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) do
        override_facts(os_facts,
                       fqdn: 'gis-bastion01.cp.lsst.org',
                       is_virtual: false,
                       virtual: 'physical',
                       dmi: {
                         'product' => {
                           'name' => 'AS -1114S-WN10RT',
                         },
                       })
      end
      let(:node_params) do
        {
          role: 'bastion',
          site: 'cp',
        }
      end

      it { is_expected.to compile.with_all_deps }

      include_examples 'baremetal'

      if os_facts[:os]['release']['major'] == '7'
        it do
          is_expected.to contain_network__interface('enp1s0f0').with(
            bootproto: 'dhcp',
            defroute: 'yes',
            nozeroconf: 'yes',
            onboot: 'yes',
            type: 'Ethernet',
          )
        end

        it do
          is_expected.to contain_network__interface('enp1s0f1').with(
            bootproto: 'none',
            ipaddress: '192.168.180.230',
            netmask: '255.255.255.0',
            nozeroconf: 'yes',
            onboot: 'yes',
            type: 'Ethernet',
          )
        end
      end
    end # on os
  end # on_supported_os
end
