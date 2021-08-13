# frozen_string_literal: true

require 'spec_helper'

describe 'profile::core::ifdown' do
  context 'with no params' do
    it { is_expected.to compile.with_all_deps }
    it { is_expected.to have_exec_resource_count(0) }
  end

  context 'with interface param' do
    let(:params) { { interface: 'eth0' } }

    it { is_expected.to have_exec_resource_count(1) }
    it { is_expected.to contain_exec('ip link set eth0 down') }
  end
end
