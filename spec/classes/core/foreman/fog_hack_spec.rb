# frozen_string_literal: true

require 'spec_helper'

describe 'profile::core::foreman::fog_hack' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile.with_all_deps }

      include_examples 'fog_hack'
    end
  end
end
