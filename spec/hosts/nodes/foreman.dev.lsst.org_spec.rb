# frozen_string_literal: true

require 'spec_helper'

describe 'foreman.dev.lsst.org', :sitepp do
  on_supported_os.each do |os, os_facts|
    # XXX networking needs to be updated to support EL8+
    next unless os =~ %r{centos-7-x86_64}

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
          site: 'dev',
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
          139.229.134.53
          139.229.134.54
          139.229.134.55
        ]
      end
      let(:dhcp_interfaces) do
        %w[
          ens192
        ]
      end

      it { is_expected.to compile.with_all_deps }

      include_examples 'vm'
      include_examples 'dhcp server'

      it do
        is_expected.to contain_network__interface('ens192').with(
          ipaddress: '139.229.134.5'
        )
      end

      it do
        is_expected.to contain_dhcp__pool('IT-Dev').with(
          network: '139.229.134.0',
          mask: '255.255.255.0',
          range: ['139.229.134.120 139.229.134.179'],
          gateway: '139.229.134.254'
        )
      end

      it do
        is_expected.to contain_dhcp__pool('BDC-Ayekan').with(
          network: '139.229.144.0',
          mask: '255.255.255.192',
          range: ['139.229.144.40 139.229.144.59'],
          gateway: '139.229.144.62'
        )
      end

      it do
        is_expected.to contain_dhcp__pool('DEV-MGT').with(
          network: '139.229.144.64',
          mask: '255.255.255.192',
          range: ['139.229.144.100 139.229.144.123'],
          gateway: '139.229.144.126'
        )
      end
    end # on os
  end # on_supported_os
end # role
