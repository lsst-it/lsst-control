# frozen_string_literal: true

require 'spec_helper'

describe 'auxtel-archiver.tu.lsst.org', :sitepp do
  on_supported_os.each do |os, facts|
    # XXX networking needs to be updated to support EL8+
    next unless os =~ %r{centos-7-x86_64}

    context "on #{os}" do
      let(:facts) do
        facts.merge(
          fqdn: 'auxtel-archiver.tu.lsst.org',
        )
      end

      let(:node_params) do
        {
          role: 'auxtel-archiver',
          site: 'tu',
          cluster: 'auxtel-archiver',
        }
      end

      it do
        is_expected.to contain_network__interface('p3p1').with(
          bootproto: 'dhcp',
          defroute: 'yes',
          onboot: 'yes',
          type: 'Ethernet',
        )
      end

      it do
        is_expected.to contain_network__interface('p3p2').with(
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
          ipaddress: '140.252.147.133',
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

      it { is_expected.to compile.with_all_deps }

      it { is_expected.to contain_class('nfs::server').with_nfs_v4(true) }
      it { is_expected.to contain_nfs__server__export('/data/lsstdata') }
      it { is_expected.to contain_nfs__server__export('/data/repo') }
      it { is_expected.to contain_nfs__server__export('/data') }

      it do
        is_expected.to contain_nfs__client__mount('/net/self/data/lsstdata').with(
          share: 'lsstdata',
          server: 'auxtel-archiver.tu.lsst.org',
          atboot: true,
        )
      end

      it do
        is_expected.to contain_nfs__client__mount('/repo').with(
          share: 'repo',
          server: 'auxtel-archiver.tu.lsst.org',
          atboot: true,
        )
      end

      it do
        is_expected.to contain_nfs__client__mount('/net/self/data/root').with(
          share: 'data',
          server: 'auxtel-archiver.tu.lsst.org',
          atboot: true,
        )
      end
    end # on os
  end # on_supported_os
end # role
