# frozen_string_literal: true

require 'spec_helper'

describe 'profile::core::ipa' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

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
          ).that_requires('Class[ipa]')
        end
      end
    end
  end
end
