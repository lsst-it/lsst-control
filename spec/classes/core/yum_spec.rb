# frozen_string_literal: true

require 'spec_helper'

describe 'profile::core::yum' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      context 'with no parameters' do
        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_class('yum') }
        it { is_expected.to contain_class('yum::plugin::versionlock') }
      end

      context 'with versionlock param' do
        let(:params) do
          {
            versionlock: {
              foo: {
                ensure: 'present',
                version: '1',
                epoch: 1,
                arch: 'noarch',
              },
            },
          }
        end

        it { is_expected.to contain_class('yum') }
        it { is_expected.to contain_class('yum::plugin::versionlock') }

        it do
          is_expected.to contain_yum__versionlock('foo').with(
            ensure: 'present',
            version: '1',
            epoch: 1,
            arch: 'noarch'
          )
        end
      end
    end
  end
end
