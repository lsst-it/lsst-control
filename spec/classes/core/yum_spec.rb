# frozen_string_literal: true

require 'spec_helper'

describe 'profile::core::yum' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end

      context 'with no parameters' do
        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_class('yum') }
        it { is_expected.to contain_class('yum::plugin::versionlock') }
      end

      context 'with versionlock param' do
        let(:params) do
          {
            versionlock: {
              '0:foo-1-1.noarch': {
                ensure: 'present',
              },
            },
          }
        end

        it { is_expected.to contain_class('yum') }
        it { is_expected.to contain_class('yum::plugin::versionlock') }

        it do
          is_expected.to contain_yum__versionlock('0:foo-1-1.noarch').with_ensure('present')
        end
      end
    end
  end
end
