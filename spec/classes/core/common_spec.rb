# frozen_string_literal: true

require 'spec_helper'

describe 'profile::core::common' do
  let(:node_params) do
    {
      org: 'lsst',
      site: 'dev',
      ipa_force_join: false,  # XXX fix easy_ipa mod
    }
  end

  it { is_expected.to compile.with_all_deps }
  it { is_expected.to contain_class('hosts') }
  it { is_expected.to contain_class('network') }
  it { is_expected.to contain_class('profile::core::nm_dispatch') }
  it { is_expected.to contain_package('ca-certificates').with_ensure('latest') }
end
