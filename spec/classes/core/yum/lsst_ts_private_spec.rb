# frozen_string_literal: true

require 'spec_helper'

describe 'profile::core::yum::lsst_ts_private' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      context 'without params' do
        it { is_expected.to compile.with_all_deps }

        it do
          is_expected.to contain_yumrepo('lsst-ts-private').with(
            descr: 'LSST Telescope and Site Private Packages',
            ensure: 'present',
            enabled: true,
            username: nil,
            password: nil
          )
        end
      end

      context 'with username & password param (Sensitive)' do
        let(:params) do
          {
            username: 'foo',
            password: sensitive('bar'),
          }
        end

        it { is_expected.to compile.with_all_deps }

        it do
          is_expected.to contain_yumrepo('lsst-ts-private').with(
            descr: 'LSST Telescope and Site Private Packages',
            ensure: 'present',
            enabled: true,
            username: 'foo',
            password: sensitive('bar')
          )
        end
      end

      context 'with username (Sensitive) & password param (Sensitive)' do
        let(:params) do
          {
            username: sensitive('foo'),
            password: sensitive('bar'),
          }
        end

        it { is_expected.to compile.with_all_deps }

        it do
          is_expected.to contain_yumrepo('lsst-ts-private').with(
            descr: 'LSST Telescope and Site Private Packages',
            ensure: 'present',
            enabled: true,
            username: 'foo',
            password: sensitive('bar')
          )
        end
      end
    end
  end
end
