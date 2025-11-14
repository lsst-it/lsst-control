# frozen_string_literal: true

require 'spec_helper'

describe 'profile::core::restic' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      context 'with no params' do
        it { is_expected.to compile.with_all_deps }
        it { is_expected.not_to contain_class('restic') }
      end

      context 'with enable param' do
        let(:params) do
          {
            enable: true
          }
        end

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_class('restic') }
      end
    end
  end
end
