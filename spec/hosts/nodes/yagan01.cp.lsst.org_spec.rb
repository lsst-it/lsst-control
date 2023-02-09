# frozen_string_literal: true

require 'spec_helper'

#
# Testing network interfaces from the yagan cluster hiera layer. One node in
# the cluster should be sufficient.
#
describe 'yagan01.cp.lsst.org', :site do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        override_facts(facts, fqdn: 'yagan01.cp.lsst.org')
      end

      let(:node_params) do
        {
          role: 'rke',
          site: 'cp',
          cluster: 'yagan',
        }
      end

      let(:gw) { '139.229.180.254' }

      it { is_expected.to compile.with_all_deps }

      it do
        is_expected.to contain_network__interface('enp1s0f1.1800').with(
          bootproto: 'none',
          defroute: 'no',
          nozeroconf: 'yes',
          onboot: 'yes',
          type: 'none',
          vlan: 'yes',
        )
      end

      it do
        is_expected.to contain_network__rule('enp1s0f1.1800').with(
          iprule: ['priority 100 from 139.229.180.0/25 lookup 1800'],
        )
      end

      it do
        is_expected.to contain_network__routing_table('lhn').with(
          table_id: 1800,
        )
      end

      it do
        is_expected.to contain_network__mroute('enp1s0f1.1800').with(
          table: 1800,
          routes: [
            '139.229.180.0/24' => 'enp1s0f1.1800',
            'default' => '139.229.180.251',
          ],
        )
      end

      it do
        is_expected.to contain_class('cni::plugins').with(
          version: '1.2.0',
          checksum: 'f3a841324845ca6bf0d4091b4fc7f97e18a623172158b72fc3fdcdb9d42d2d37',
          enable: ['macvlan'],
        )
      end
    end # on os
  end # on_supported_os
end
