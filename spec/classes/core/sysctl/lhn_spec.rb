# frozen_string_literal: true

require 'spec_helper'

describe 'profile::core::sysctl::lhn' do
  let(:node_params) { { org: 'lsst' } }

  it { is_expected.to compile.with_all_deps }
  it { is_expected.to have_sysctl__value_resource_count(7) }

  it do
    is_expected.to contain_sysctl__value('net.core.rmem_max')
      .with_value(536_870_912)
  end

  it do
    is_expected.to contain_sysctl__value('net.core.wmem_max')
      .with_value(536_870_912)
  end

  it do
    is_expected.to contain_sysctl__value('net.ipv4.tcp_rmem')
      .with_value('4096 87380 536870912')
  end

  it do
    is_expected.to contain_sysctl__value('net.ipv4.tcp_wmem')
      .with_value('4096 65536 536870912')
  end

  it do
    is_expected.to contain_sysctl__value('net.ipv4.tcp_congestion_control')
      .with_value('htcp')
  end

  it do
    is_expected.to contain_sysctl__value('net.ipv4.tcp_mtu_probing')
      .with_value(1)
  end

  it do
    is_expected.to contain_sysctl__value('net.core.default_qdisc')
      .with_value('fq')
  end
end
