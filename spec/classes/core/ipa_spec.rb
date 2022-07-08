# frozen_string_literal: true

require 'spec_helper'

describe 'profile::core::ipa' do
  let(:pre_condition) do
    <<~PP
      include easy_ipa
      include sssd
    PP
  end
  let(:params) do
    {
      default: {
        foo: {
          bar: 'baz',
        },
      },
    }
  end

  it { is_expected.to compile.with_all_deps }

  it do
    is_expected.to contain_ini_setting('/etc/ipa/default.conf [foo] bar').with(
      section: 'foo',
      setting: 'bar',
      value: 'baz',
    )
  end
end
