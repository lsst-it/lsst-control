# frozen_string_literal: true

require 'spec_helper'

describe 'profile::daq::sysctl' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile.with_all_deps }
      it { is_expected.to have_sysctl__value_resource_count(2) }

      include_examples 'lsst-daq sysctls'

      it do
        is_expected.to contain_file('/etc/sysctl.d/99-lsst-daq-ccs.conf').with(
          ensure: :absent
        )
      end
    end
  end
end
