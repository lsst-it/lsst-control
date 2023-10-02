# frozen_string_literal: true

require 'spec_helper'

describe 'profile::core::sssd' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }
      let(:pre_condition) do
        <<~PP
          # easy_ipa has a hardwired dep on the sssd service
          class { 'sssd': service_names => ['sssd'] }
        PP
      end

      it { is_expected.to compile.with_all_deps }

      include_examples 'sssd services'
    end
  end
end
