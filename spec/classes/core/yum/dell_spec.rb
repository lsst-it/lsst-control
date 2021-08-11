# frozen_string_literal: true

require 'spec_helper'

describe 'profile::core::yum::dell' do
  let(:node_params) do
    {
      org: 'lsst',
    }
  end

  it { is_expected.to compile.with_all_deps }

  it do
    is_expected.to contain_yumrepo('dell').with(
      descr: 'Dell',
      ensure: 'present',
      enabled: true,
    )
  end
end
