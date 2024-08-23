# frozen_string_literal: true

shared_examples 'ceph cluster' do
  it do
    is_expected.to contain_class('tuned').with(
      active_profile: 'latency-performance',
    )
  end
end
