# frozen_string_literal: true

require 'spec_helper'

describe 'profile::ccs::el9' do
  on_supported_os.each do |os, os_facts|
    next unless os =~ %r{almalinux-9-x86_64}

    context "on #{os}" do
      let(:facts) { os_facts }
      let(:node_params) { { site: 'ls' } }
      let(:pre_condition) do
        <<~PP
          include ssh
          include profile::ccs::common
        PP
      end

      it { is_expected.to compile.with_all_deps }

      it { is_expected.to contain_package('compat-bin') }
    end # on os
  end # on_supported_os
end
