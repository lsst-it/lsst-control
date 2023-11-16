# frozen_string_literal: true

require 'spec_helper'

describe 'profile::core::bash_completion' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile.with_all_deps }

      include_examples 'bash_completion', os_facts: os_facts
    end
  end
end
