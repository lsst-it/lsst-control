# frozen_string_literal: true

require 'spec_helper'

describe 'comcam-archiver.cp.lsst.org', :sitepp do
  on_supported_os.each do |os, os_facts|
    # XXX networking needs to be updated to support EL8+
    next unless os =~ %r{centos-7-x86_64}

    context "on #{os}" do
      let(:facts) do
        lsst_override_facts(os_facts,
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
          role: 'comcam-archiver',
          site: 'cp',
          cluster: 'comcam-archiver',
        }
      end

      it { is_expected.to compile.with_all_deps }

      include_examples 'baremetal'

      it do
        is_expected.to contain_network__interface('em1').with(
          bootproto: 'dhcp',
          defroute: 'yes',
          onboot: 'yes',
          type: 'Ethernet'
        )
      end

      it do
        is_expected.to contain_network__interface('em2').with(
          bootproto: 'none',
          defroute: 'no',
          ipaddress: '139.229.166.1',
          netmask: '255.255.255.0',
          nozeroconf: 'yes',
          onboot: 'yes',
          type: 'Ethernet'
        )
      end

      it do
        is_expected.to contain_network__interface('em3').with(
          bootproto: 'none',
          onboot: 'no',
          type: 'Ethernet'
        )
      end

      it do
        is_expected.to contain_network__interface('em4').with(
          bootproto: 'none',
          onboot: 'no',
          type: 'Ethernet'
        )
      end

      it do
        is_expected.to contain_network__interface('p2p1').with(
          bootproto: 'none',
          onboot: 'no',
          type: 'Ethernet'
        )
      end

      it do
        is_expected.to contain_network__interface('p2p2').with(
          bootproto: 'none',
          onboot: 'no',
          type: 'Ethernet'
        )
      end

      it { is_expected.to contain_class('nfs::server').with_nfs_v4(true) }
      it { is_expected.to contain_nfs__server__export('/data/lsstdata') }
      it { is_expected.to contain_nfs__server__export('/data/repo') }
      it { is_expected.to contain_nfs__server__export('/data') }

      it do
        is_expected.to contain_nfs__client__mount('/net/self/data/lsstdata').with(
          share: 'lsstdata',
          server: 'comcam-archiver.cp.lsst.org',
          atboot: true
        )
      end

      it do
        is_expected.to contain_nfs__client__mount('/repo').with(
          share: 'repo',
          server: 'comcam-archiver.cp.lsst.org',
          atboot: true
        )
      end
    end # on os
  end # on_supported_os
end # role
