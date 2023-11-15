# frozen_string_literal: true

require 'spec_helper'

describe 'profile::util::kernel_param' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      let(:title) { 'foo' }

      it { is_expected.to compile.with_all_deps }

      context 'with no params' do
        it do
          is_expected.to contain_kernel_parameter(title).with(
            ensure: 'present',
          )
        end

        it do
          is_expected.to contain_reboot(title).with(
            apply: 'finished',
            message: "set kernel parameter: #{title}",
            when: 'refreshed',
          )
        end

        it do
          is_expected.to contain_reboot(title).that_subscribes_to("Kernel_parameter[#{title}]")
        end
      end

      context 'with reboot => true' do
        let(:params) { { reboot: true } }

        it do
          is_expected.to contain_kernel_parameter(title).with(
            ensure: 'present',
          )
        end

        it do
          is_expected.to contain_reboot(title).with(
            apply: 'finished',
            message: "set kernel parameter: #{title}",
            when: 'refreshed',
          )
        end

        it do
          is_expected.to contain_reboot(title).that_subscribes_to("Kernel_parameter[#{title}]")
        end
      end

      context 'with reboot => false' do
        let(:params) { { reboot: false } }

        it do
          is_expected.to contain_kernel_parameter(title).with(
            ensure: 'present',
          )
        end

        it { is_expected.not_to contain_reboot(title) }
      end
    end
  end
end
