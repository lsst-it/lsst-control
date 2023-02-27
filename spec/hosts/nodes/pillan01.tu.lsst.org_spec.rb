# frozen_string_literal: true

require 'spec_helper'

#
# Testing network interfaces from the pillan cluster hiera layer. One node in
# the pillan cluster should be sufficient.
#
describe 'pillan01.tu.lsst.org', :site do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:int1) do
        if (facts[:os]['family'] == 'RedHat') && (facts[:os]['release']['major'] == '7')
          'eno1'
        else
          'eno1np0'
        end
      end

      let(:int2) do
        if (facts[:os]['family'] == 'RedHat') && (facts[:os]['release']['major'] == '7')
          'eno2d1'
        else
          'eno2np1'
        end
      end

      let(:facts) do
        override_facts(facts,
                       networking: { interfaces: { int1 => { mac: '11:22:33:44:55:66' } } },
                       fqdn: 'pillan01.tu.lsst.org')
      end

      let(:node_params) do
        {
          role: 'rke',
          site: 'tu',
          cluster: 'pillan',
        }
      end

      it { is_expected.to compile.with_all_deps }

      it do
        is_expected.to contain_class('cni::plugins').with(
          version: '1.2.0',
          checksum: 'f3a841324845ca6bf0d4091b4fc7f97e18a623172158b72fc3fdcdb9d42d2d37',
          enable: ['macvlan'],
        )
      end

      if facts[:os]['release']['major'] == '7'
        it do
          is_expected.to contain_network__interface('bond0').with(
            bonding_master: 'yes',
            bonding_opts: 'mode=4 miimon=100',
            bootproto: 'dhcp',
            defroute: 'yes',
            nozeroconf: 'yes',
            onboot: 'yes',
            type: 'Bond',
          )
        end

        if (facts[:os]['family'] == 'RedHat') && (facts[:os]['release']['major'] == '7')
          # explicitly setting the bond mac address on EL7 might have no effect?
          # We aren't changing the behavior for EL7 to avoid a network restart
          # for legacy nodes.
          it { is_expected.to contain_network__interface('bond0').without_macaddr }
        else
          it do
            is_expected.to contain_network__interface('bond0').with(
              macaddr: '11:22:33:44:55:66',
            )
          end
        end

        it do
          is_expected.to contain_network__interface(int1).with(
            bootproto: 'none',
            master: 'bond0',
            onboot: 'yes',
            slave: 'yes',
            type: 'Ethernet',
          )
        end

        it do
          is_expected.to contain_network__interface(int2).with(
            bootproto: 'none',
            master: 'bond0',
            onboot: 'yes',
            slave: 'yes',
            type: 'Ethernet',
          )
        end

        # common between EL7 & EL8
        %w[
          enp129s0f0
          enp129s0f1
        ].each do |int|
          it do
            is_expected.to contain_network__interface(int).with(
              bootproto: 'none',
              master: 'bond0',
              onboot: 'yes',
              slave: 'yes',
              type: 'Ethernet',
            )
          end
        end
      end
    end # on os
  end # on_supported_os
end
