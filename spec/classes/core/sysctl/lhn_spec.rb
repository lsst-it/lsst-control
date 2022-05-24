# frozen_string_literal: true

require 'spec_helper'

describe 'profile::core::sysctl::lhn', :lhn_node do
  it { is_expected.to compile.with_all_deps }
  it { is_expected.to have_sysctl__value_resource_count(7) }
end
