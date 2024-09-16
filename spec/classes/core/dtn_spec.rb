# frozen_string_literal: true

require 'spec_helper'

describe 'profile::core::dtn' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile.with_all_deps }

      sysctls = {
        'net.core.rmem_max': 2_147_483_647,
        'net.core.wmem_max': 2_147_483_647,
        'net.ipv4.tcp_rmem': "4096\t87380\t2147483647",
        'net.ipv4.tcp_wmem': "4096\t65536\t2147483647",
        'net.core.netdev_max_backlog': 250_000,
        'net.ipv4.tcp_no_metrics_save': 1,
        'net.ipv4.tcp_congestion_control': 'htcp',
        'net.ipv4.tcp_mtu_probing': 1,
        'net.core.default_qdisc': 'fq',
      }

      sysctls.each do |s, v|
        it do
          is_expected.to contain_sysctl__value(s)
            .with(
              value: v,
              target: '/etc/sysctl.d/93-tcp_ip.conf'
            )
        end
      end

      it { is_expected.to have_sysctl__value_resource_count(sysctls.size) }

      it { is_expected.to contain_package('hwloc') }
      it { is_expected.to contain_package('hwloc-gui') }
    end
  end
end
