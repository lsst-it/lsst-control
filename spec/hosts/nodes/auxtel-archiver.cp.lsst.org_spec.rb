# frozen_string_literal: true

require 'spec_helper'

describe 'auxtel-archiver.cp.lsst.org', :sitepp do
  on_supported_os.each do |os, os_facts|
    # XXX networking needs to be updated to support EL8+
    next unless os =~ %r{centos-7-x86_64}

    context "on #{os}" do
      let(:facts) do
        override_facts(os_facts,
                       fqdn: 'auxtel-archiver.cp.lsst.org',
                       is_virtual: false,
                       virtual: 'physical',
                       dmi: {
                         'product' => {
                           'name' => 'PowerEdge R640',
                         },
                       })
      end
      let(:node_params) do
        {
          role: 'auxtel-archiver',
          site: 'cp',
          cluster: 'auxtel-archiver',
        }
      end

      it { is_expected.to compile.with_all_deps }

      include_examples 'baremetal'

      it do
        is_expected.to contain_network__interface('em1').with(
          bootproto: 'dhcp',
          defroute: 'yes',
          nozeroconf: 'yes',
          onboot: 'yes',
          type: 'Ethernet',
        )
      end

      it do
        is_expected.to contain_network__interface('em2').with(
          bootproto: 'none',
          nozeroconf: 'yes',
          onboot: 'yes',
          type: 'Ethernet',
        )
      end

      it do
        is_expected.to contain_network__interface('em3').with(
          bootproto: 'none',
          onboot: 'no',
          type: 'Ethernet',
        )
      end

      it do
        is_expected.to contain_network__interface('em4').with(
          bootproto: 'none',
          onboot: 'no',
          type: 'Ethernet',
        )
      end

      it do
        is_expected.to contain_network__interface('p2p1').with(
          bootproto: 'none',
          onboot: 'no',
          type: 'Ethernet',
        )
      end

      it do
        is_expected.to contain_network__interface('p2p2').with(
          bootproto: 'none',
          nozeroconf: 'yes',
          onboot: 'no',
          type: 'Ethernet',
        )
      end

      it do
        is_expected.to contain_network__interface('em2.1201').with(
          bootproto: 'none',
          ipaddress: '139.229.166.10',
          netmask: '255.255.255.0',
          nozeroconf: 'yes',
          onboot: 'yes',
          type: 'none',
          vlan: 'yes',
        )
      end

      it { is_expected.to contain_class('nfs').with_server_enabled(false) }
      it { is_expected.to contain_class('nfs').with_client_enabled(true) }

      it do
        is_expected.to contain_nfs__client__mount('/data').with(
          share: 'auxtel',
          server: 'nfs-auxtel.cp.lsst.org',
          atboot: true,
        )
      end
    end # on os
  end # on_supported_os
end # role
