# frozen_string_literal: true

shared_examples 'firewall default' do |os_facts:|
  it { is_expected.to contain_service('nftables').with_enable(true) } if (os_facts[:os]['family'] == 'RedHat') && (os_facts[:os]['release']['major'] == '9')

  it { is_expected.to contain_service('iptables').with_enable(true) }
  it { is_expected.to contain_resources('firewall').with_purge(true) }

  it do
    is_expected.to contain_firewall('000 accept established').with(
      proto: 'all',
      state: %w[RELATED ESTABLISHED],
      jump: 'accept'
    )
  end

  it do
    is_expected.to contain_firewall('001 accept all icmp').with(
      proto: 'icmp',
      jump: 'accept'
    )
  end

  it do
    is_expected.to contain_firewall('002 accept all loopback').with(
      proto: 'all',
      iniface: 'lo',
      jump: 'accept'
    )
  end

  it do
    is_expected.to contain_firewall('020 accept dhcp').with(
      proto: 'udp',
      sport: %w[67 68],
      dport: %w[67 68],
      jump: 'accept'
    )
  end

  it do
    is_expected.to contain_firewall('990 reject all').with(
      proto: 'all',
      jump: 'reject'
    )
  end

  it do
    is_expected.to contain_firewall('991 reject forward all').with(
      chain: 'FORWARD',
      proto: 'all',
      jump: 'reject'
    )
  end
end

shared_examples 'firewall node_exporter scraping' do |site:|
  case site
  when 'dev'
    it do
      is_expected.to contain_firewall('100 accept node_exporter').with(
        proto: 'tcp',
        state: 'NEW',
        ipset: 'ayekan src',
        dport: '9100',
        jump: 'accept'
      )
    end

    it do
      is_expected.to contain_firewall('101 accept node_exporter').with(
        proto: 'tcp',
        state: 'NEW',
        ipset: 'dev src',
        dport: '9100',
        jump: 'accept'
      )
    end
  when 'ls'
    it do
      is_expected.to contain_firewall('100 accept node_exporter').with(
        proto: 'tcp',
        state: 'NEW',
        ipset: 'ayekan src',
        dport: '9100',
        jump: 'accept'
      )
    end
  end
end
