# frozen_string_literal: true

require 'spec_helper'

describe 'profile::core::k8snode' do
  on_supported_os.each do |os, os_facts|
    next unless os =~ %r{almalinux-9-x86_64}

    context "on #{os}" do
      let(:facts) { os_facts }

      context 'with no params' do
        it { is_expected.to compile.with_all_deps }

        include_examples 'k8snode profile'

        it { is_expected.not_to contain_class('cni::plugins') }
        it { is_expected.not_to contain_class('cni::plugins::dhcp') }
      end

      context 'with enable_dhcp param' do
        context 'when false' do
          let(:params) do
            {
              enable_dhcp: false,
            }
          end

          it { is_expected.to compile.with_all_deps }

          include_examples 'k8snode profile'

          it { is_expected.not_to contain_class('cni::plugins') }
          it { is_expected.not_to contain_class('cni::plugins::dhcp') }
        end

        context 'when true' do
          let(:params) do
            {
              enable_dhcp: true,
            }
          end

          it { is_expected.to compile.with_all_deps }

          include_examples 'k8snode profile'

          it { is_expected.to contain_class('cni::plugins') }
          it { is_expected.to contain_class('cni::plugins::dhcp') }
        end

        context 'when service_only' do
          let(:params) do
            {
              enable_dhcp: 'service_only',
            }
          end

          it { is_expected.to compile.with_all_deps }

          include_examples 'k8snode profile'

          it { is_expected.not_to contain_class('cni::plugins') }
          it { is_expected.not_to contain_class('cni::plugins::dhcp') }
          it { is_expected.to contain_class('cni::plugins::dhcp::service') }
        end
      end
    end
  end
end
