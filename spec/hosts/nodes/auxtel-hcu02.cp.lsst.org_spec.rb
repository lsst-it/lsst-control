# frozen_string_literal: true

require 'spec_helper'

describe 'auxtel-hcu02.cp.lsst.org', :sitepp do
  on_supported_os.each do |os, os_facts|
    next unless os =~ %r{centos-7-x86_64}

    context "on #{os}" do
      let(:facts) do
        lsst_override_facts(os_facts,
                            is_virtual: false,
                            virtual: 'physical',
                            dmi: {
                              'manufacturer' => 'Advantech',
                              'product' => {
                                'name' => 'UNO-1483G-434AE',
                              },
                            })
      end
      let(:node_params) do
        {
          role: 'atshcu',
          site: 'cp',
        }
      end

      it { is_expected.to compile.with_all_deps }

      include_examples 'baremetal no bmc'
      include_examples 'powertop'
      it { is_expected.to have_network__interface_resource_count(4) }

      it do
        is_expected.to contain_network__interface('eno1').with(
          bootproto: 'dhcp',
          defroute: 'yes',
          onboot: 'yes',
          type: 'Ethernet'
        )
      end

      it do
        is_expected.to contain_network__interface('enp6s0').with(
          bootproto: 'none',
          ipaddress: '192.168.1.1',
          netmask: '255.255.255.0',
          onboot: 'yes',
          type: 'Ethernet'
        )
      end

      it do
        is_expected.to contain_network__interface('enp7s0').with(
          bootproto: 'none',
          onboot: 'no',
          type: 'Ethernet'
        )
      end

      it do
        is_expected.to contain_network__interface('enp8s0').with(
          bootproto: 'none',
          onboot: 'no',
          type: 'Ethernet'
        )
      end
    end # on os
  end # on_supported_os
end # role
