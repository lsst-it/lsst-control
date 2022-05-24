# frozen_string_literal: true

require 'spec_helper'

describe 'profile::archive::redis' do
  it { is_expected.to compile.with_all_deps }

  it do
    is_expected.to contain_class('redis').with(
      bind: '0.0.0.0',
      manage_repo: true,
      package_ensure: '5.0.5-1.el7.x86_64',
    )

    is_expected.to contain_class('redis::globals').with(
      scl: 'rh-redis5',
    )
  end

  it { is_expected.to contain_file('/etc/profile.d/rh-redis5.sh') }
end
