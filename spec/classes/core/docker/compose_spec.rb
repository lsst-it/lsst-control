# frozen_string_literal: true

require 'spec_helper'

describe 'profile::core::docker::compose' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end

      context 'with no parameters' do
        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_package('docker-compose-plugin') }
      end
    end
  end
end
