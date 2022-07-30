# frozen_string_literal: true

require 'spec_helper'

describe 'profile::core::ipa' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }
      let(:pre_condition) do
        <<~PP
          include easy_ipa
          include sssd
        PP
      end

      context 'with no params' do
        it { is_expected.to compile.with_all_deps }
      end

      context 'with default param' do
        let(:params) do
          {
            default: {
              foo: {
                bar: 'baz',
              },
            },
          }
        end

        it do
          is_expected.to contain_ini_setting('/etc/ipa/default.conf [foo] bar').with(
            section: 'foo',
            setting: 'bar',
            value: 'baz',
          ).that_requires('Class[easy_ipa]')
        end
      end
    end
  end
end
