# frozen_string_literal: true

require 'spec_helper'

describe 'profile::core::puppet_master' do
  it { is_expected.to compile.with_all_deps }
  it { is_expected.to contain_cron('webhook') }
  it { is_expected.to contain_cron('smee') }

  it do
    is_expected.to contain_cron('webhook').with_command('/usr/bin/systemctl restart webhook > /dev/null 2>&1')
  end

  it do
    is_expected.to contain_cron('smee').with_command('/usr/bin/systemctl restart smee > /dev/null 2>&1')
  end
end
