# frozen_string_literal: true

require 'spec_helper'

describe 'profile::core::ca' do
  it { is_expected.to compile.with_all_deps }
  it { is_expected.to contain_package('ca-certificates').with_ensure('latest') }
end
