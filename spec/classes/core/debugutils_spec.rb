# frozen_string_literal: true

require 'spec_helper'

describe 'profile::core::debugutils' do
  it { is_expected.to compile.with_all_deps }

  include_examples 'debugutils'
end
