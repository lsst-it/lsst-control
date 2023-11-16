# frozen_string_literal: true

require 'spec_helper'

describe 'profile::ccs::common' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { override_facts(os_facts, site: 'ls') }
      let(:pre_condition) do
        <<~PP
          include ssh
        PP
      end

      it { is_expected.to compile.with_all_deps }

      context 'with out params' do
        it { is_expected.not_to contain_package('foo') }
      end

      context 'with packages params' do
        let(:params) do
          {
            packages: ['foo'],
          }
        end

        it { is_expected.to contain_package('foo') }
      end
    end
  end
end
