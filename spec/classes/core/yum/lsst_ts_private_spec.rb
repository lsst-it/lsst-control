# frozen_string_literal: true

require 'spec_helper'

describe 'profile::core::yum::lsst_ts_private' do
  let(:node_params) { { org: 'lsst' } }

  context 'without params' do
    it { is_expected.to compile.with_all_deps }

    it do
      is_expected.to contain_yumrepo('lsst-ts-private').with(
        descr: 'LSST Telescope and Site Private Packages',
        ensure: 'present',
        enabled: true,
        username: nil,
        password: nil,
      )
    end
  end

  context 'with username & password param' do
    let(:params) do
      {
        username: 'foo',
        password: 'bar',
      }
    end

    it { is_expected.to compile.with_all_deps }

    it do
      is_expected.to contain_yumrepo('lsst-ts-private').with(
        descr: 'LSST Telescope and Site Private Packages',
        ensure: 'present',
        enabled: true,
        username: 'foo',
        password: 'bar',
      )
    end
  end
end
