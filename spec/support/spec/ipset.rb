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
end
