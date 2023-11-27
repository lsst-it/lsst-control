# frozen_string_literal: true

require 'spec_helper'

describe 'profile::core::foreman' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      let(:params) { { smee_url: 'https://foo.example.org' } }
      let(:pre_condition) do
        <<~PP
        class { 'puppet':
          environment => 'production',
        }
        PP
      end

      it { is_expected.to compile.with_all_deps }

      include_examples 'foreman'

      context 'with foreman_hostgroup param' do
        let(:params) do
          super().merge(
            foreman_hostgroup: {
              foo: {
                description: 'bar',
              },
            },
          )
        end

        it { is_expected.to contain_foreman_hostgroup('foo').with_description('bar') }
      end

      context 'with foreman_global_parameter param' do
        let(:params) do
          super().merge(
            foreman_global_parameter: {
              foo: {
                parameter_type: 'baz',
                value: 'bar',
              },
            },
          )
        end

        it do
          is_expected.to contain_foreman_global_parameter('foo').with(
            parameter_type: 'baz',
            value: 'bar',
          )
        end
      end
    end
  end
end
