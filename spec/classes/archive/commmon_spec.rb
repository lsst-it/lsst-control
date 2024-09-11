# frozen_string_literal: true

require 'spec_helper'

describe 'profile::archive::common' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      let(:pre_condition) do
        <<~PP
          # change service unit name from sssd.service to sssd
          class { 'sssd': service_names => ['sssd'] }
        PP
      end

      it { is_expected.to compile.with_all_deps }

      include_examples 'archiver'
    end
  end
end
