# frozen_string_literal: true

shared_examples 'firewall default' do |facts:|
  if (facts[:os]['family'] == 'RedHat') && (facts[:os]['release']['major'] == '9')
    it { is_expected.to contain_service('nftables').with_enable(true) }
  end

  it { is_expected.to contain_service('iptables').with_enable(true) }
  it { is_expected.to contain_resources('firewall').with_purge(true) }

  it do
    is_expected.to contain_firewall('000 accept established').with(
      proto: 'all',
      state: %w[RELATED ESTABLISHED],
      action: 'accept',
    )
  end

  it do
    is_expected.to contain_firewall('001 accept all icmp').with(
      proto: 'icmp',
      action: 'accept',
    )
  end

  it do
    is_expected.to contain_firewall('002 accept all loopback').with(
      proto: 'all',
      iniface: 'lo',
      action: 'accept',
    )
  end

  it do
    is_expected.to contain_firewall('020 accept dhcp').with(
      proto: 'udp',
      sport: %w[67 68],
      dport: %w[67 68],
      action: 'accept',
    )
  end

  it do
    is_expected.to contain_firewall('990 reject all').with(
      proto: 'all',
      action: 'reject',
    )
  end

  it do
    is_expected.to contain_firewall('991 reject forward all').with(
      chain: 'FORWARD',
      proto: 'all',
      action: 'reject',
    )
  end
end
