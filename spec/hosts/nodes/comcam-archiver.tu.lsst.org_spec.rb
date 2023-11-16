# frozen_string_literal: true

require 'spec_helper'

describe 'comcam-archiver.tu.lsst.org', :sitepp do
  on_supported_os.each do |os, os_facts|
    # XXX networking needs to be updated to support EL8+
    next unless os =~ %r{centos-7-x86_64}

    context "on #{os}" do
      let(:facts) do
        override_facts(os_facts,
                       fqdn: 'comcam-archiver.tu.lsst.org',
                       is_virtual: false,
                       virtual: 'physical',
                       dmi: {
                         'product' => {
                           'name' => 'PowerEdge R440',
                         },
                       })
      end
      let(:node_params) do
        {
          role: 'comcam-archiver',
          site: 'tu',
          cluster: 'comcam-archiver',
        }
      end

      it { is_expected.to compile.with_all_deps }

      include_examples 'baremetal'

      it do
        is_expected.to contain_network__interface('p2p1').with(
          bootproto: 'dhcp',
          defroute: 'yes',
          onboot: 'yes',
          type: 'Ethernet',
        )
      end

      it do
        is_expected.to contain_network__interface('p2p2').with(
          bootproto: 'none',
          bridge: 'dds',
          defroute: 'no',
          nozeroconf: 'yes',
          onboot: 'yes',
          type: 'Ethernet',
        )
      end

      it do
        is_expected.to contain_network__interface('dds').with(
          bootproto: 'none',
          ipaddress: '140.252.147.136',
          netmask: '255.255.255.224',
          onboot: 'yes',
          type: 'bridge',
        )
      end

      it do
        is_expected.to contain_network__interface('em1').with(
          bootproto: 'none',
          onboot: 'no',
          type: 'Ethernet',
        )
      end

      it do
        is_expected.to contain_network__interface('em2').with(
          bootproto: 'none',
          onboot: 'no',
          type: 'Ethernet',
        )
      end

      it { is_expected.to contain_class('nfs::server').with_nfs_v4(true) }
      it { is_expected.to contain_nfs__server__export('/data/lsstdata') }
      it { is_expected.to contain_nfs__server__export('/data/repo') }
      it { is_expected.to contain_nfs__server__export('/data') }

      it do
        is_expected.to contain_nfs__client__mount('/net/self/data/lsstdata').with(
          share: 'lsstdata',
          server: 'comcam-archiver.tu.lsst.org',
          atboot: true,
        )
      end

      it do
        is_expected.to contain_nfs__client__mount('/repo').with(
          share: 'repo',
          server: 'comcam-archiver.tu.lsst.org',
          atboot: true,
        )
      end
    end # on os
  end # on_supported_os
end # role
