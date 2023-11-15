# frozen_string_literal: true

require 'spec_helper'

describe 'profile::core::kernel' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      context 'with no params' do
        it { is_expected.to compile.with_all_deps }
        it { is_expected.to have_yum__versionlock_resource_count(0) }
      end

      context 'with all params' do
        let(:params) do
          {
            version: '1.2.3',
            devel: true,
            debuginfo: true,
          }
        end

        it { is_expected.to compile.with_all_deps }

        %w[
          kernel
          kernel-tools
          kernel-tools-libs
          kernel-devel
          kernel-debuginfo
        ].each do |pkg|
          it do
            is_expected.to contain_yum__versionlock(pkg).with(
              ensure: 'present',
              version: '1.2.3',
            )
          end
        end
      end
    end
  end
end
