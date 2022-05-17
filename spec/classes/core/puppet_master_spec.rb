# frozen_string_literal: true

require 'spec_helper'

describe 'profile::core::puppet_master' do
  it { is_expected.to compile.with_all_deps }
  it { is_expected.to contain_cron('webhook') }
  it { is_expected.to contain_cron('smee') }
end
