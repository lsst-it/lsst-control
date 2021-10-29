# frozen_string_literal: true

require 'spec_helper'

describe 'profile::ccs::sysctl' do
  let(:node_params) { { org: 'lsst' } }

  it { is_expected.to compile.with_all_deps }
  it { is_expected.to have_sysctl__value_resource_count(2) }

  it do
    is_expected.to contain_sysctl__value('net.core.rmem_max')
      .with_value(18_874_368)
  end

  it do
    is_expected.to contain_sysctl__value('net.core.wmem_max')
      .with_value(18_874_368)
  end
end
