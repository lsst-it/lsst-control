# frozen_string_literal: true

require 'spec_helper'

describe 'love01.ls.lsst.org', :site do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts.merge(
          fqdn: 'love01.ls.lsst.org',
        )
      end

      let(:node_params) do
        {
          role: 'amor',
          site: 'ls',
          cluster: 'amor',
        }
      end

      it do
        is_expected.to contain_network__interface('enp129s0f0').with(
          bootproto: 'dhcp',
          defroute: 'yes',
          nozeroconf: 'yes',
          onboot: 'yes',
          type: 'Ethernet',
        )
      end

      it do
        is_expected.to contain_network__interface('enp129s0f1').with(
          bootproto: 'none',
          nozeroconf: 'yes',
          onboot: 'yes',
          type: 'Ethernet',
        )
      end

      it do
        is_expected.to contain_network__interface('enp129s0f1.2502').with(
          bootproto: 'none',
          bridge: 'dds',
          nozeroconf: 'yes',
          onboot: 'yes',
          type: 'none',
          vlan: 'yes',
        )
      end

      it do
        is_expected.to contain_network__interface('dds').with(
          bootproto: 'dhcp',
          onboot: 'yes',
          type: 'bridge',
        )
      end

      it { is_expected.to compile.with_all_deps }

    end # on os
  end # on_supported_os
end # role
