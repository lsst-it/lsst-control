# frozen_string_literal: true

shared_examples 'ipset' do
  it { is_expected.to contain_class('ipset') }

  it do
    is_expected.to contain_ipset__set('aura').with_set(
      %w[
        140.252.0.0/16
        139.229.0.0/16
        198.19.0.0/16
        10.0.0.0/8
      ]
    ).that_comes_before('Class[firewall]')
  end

  it do
    is_expected.to contain_ipset__set('rubin').with_set(
      %w[
        139.229.134.0/23
        139.229.136.0/21
        139.229.144.0/20
        139.229.160.0/19
        139.229.192.0/18
        140.252.146.0/23
        198.19.0.0/16
        10.0.0.0/8
      ]
    ).that_comes_before('Class[firewall]')
  end

  it do
    is_expected.to contain_ipset__set('ayekan').with_set(
      %w[
        139.229.144.0/26
      ]
    ).that_comes_before('Class[firewall]')
  end

  it do
    is_expected.to contain_ipset__set('dev').with_set(
      %w[
        139.229.134.0/24
      ]
    ).that_comes_before('Class[firewall]')
  end

  it do
    is_expected.to contain_ipset__set('tufde').with_set(
      %w[
        140.252.146.32/27
        140.252.146.64/27
        140.252.147.0/28
        140.252.147.32/28
        140.252.147.64/27
      ]
    ).that_comes_before('Class[firewall]')
  end

  it do
    is_expected.to contain_ipset__set('lsfde').with_set(
      %w[
        139.229.135.0/24
        139.229.141.0/27
        139.229.141.32/28
        139.229.144.0/26
        139.229.147.0/24
        139.229.151.0/24
        139.229.152.128/26
        139.229.152.192/26
        139.229.154.0/26
      ]
    ).that_comes_before('Class[firewall]')
  end

  it do
    is_expected.to contain_ipset__set('cpfde').with_set(
      %w[
        139.229.160.0/24
        139.229.161.0/27
        139.229.175.128/25
        139.229.175.0/26
        139.229.175.64/26
        139.229.181.0/27
      ]
    ).that_comes_before('Class[firewall]')
  end
end
