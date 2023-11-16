# frozen_string_literal: true

require 'spec_helper'

describe 'profile::core::ca' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile.with_all_deps }
      it { is_expected.to contain_package('ca-certificates').with_ensure('latest') }
    end
  end
end
