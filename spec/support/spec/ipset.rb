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
      ],
    )
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
      ],
    )
  end

  it do
    is_expected.to contain_ipset__set('ayekan').with_set(
      %w[
        139.229.144.0/26
      ],
    )
  end
end
