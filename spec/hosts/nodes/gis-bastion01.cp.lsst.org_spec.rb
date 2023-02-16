# frozen_string_literal: true

require 'spec_helper'

#
# note that this hosts has interfaces with an mtu of 9000
#
describe 'gis-bastion01.cp.lsst.org', :site do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts.merge(
          fqdn: 'gis-bastion01.cp.lsst.org',
        )
      end

      let(:node_params) do
        {
          role: 'bastion',
          site: 'cp',
        }
      end

      it { is_expected.to compile.with_all_deps }

      if facts[:os]['release']['major'] == '7'
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
