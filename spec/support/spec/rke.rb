# frozen_string_literal: true

shared_examples 'rke profile' do
  it { is_expected.to contain_vcsrepo('/home/rke/k8s-cookbook') }

  it { is_expected.to contain_kmod__load('br_netfilter') }

  it do
    is_expected.to contain_sysctl__value('net.bridge.bridge-nf-call-iptables').with(
      value: 1,
      target: '/etc/sysctl.d/80-rke.conf'
    ).that_requires('Kmod::Load[br_netfilter]').that_comes_before('Class[docker]')
  end

  it do
    is_expected.to contain_vcsrepo('/home/rke/k8s-cookbook').that_requires('Class[ipa]')
  end
end
