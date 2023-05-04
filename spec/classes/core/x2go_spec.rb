# frozen_string_literal: true

require 'spec_helper'

describe 'profile::core::x2go' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end

      context 'with no parameters' do
        it { is_expected.to compile.with_all_deps }

        include_examples 'x2go packages'
      end
    end
  end
end
