# frozen_string_literal: true

require 'spec_helper'

describe 'profile::daq::sysctl' do
  it { is_expected.to compile.with_all_deps }
  it { is_expected.to have_sysctl__value_resource_count(2) }

  include_examples 'lsst-daq sysctls'

  it do
    is_expected.to contain_file('/etc/sysctl.d/99-lsst-daq-ccs.conf').with(
      ensure: :absent,
    )
  end
end
