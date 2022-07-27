# frozen_string_literal: true

require 'spec_helper'

describe 'profile::core::puppet_master' do
  it { is_expected.to compile.with_all_deps }

  it do
    is_expected.to contain_cron('webhook').with_command('/usr/bin/systemctl restart webhook > /dev/null 2>&1')
  end

  it do
    is_expected.to contain_cron('smee').with_command('/usr/bin/systemctl restart smee > /dev/null 2>&1')
  end

  it { is_expected.to contain_foreman__plugin('puppet') }
  it { is_expected.to contain_foreman__cli__plugin('foreman_puppet') }
  it { is_expected.to contain_foreman__plugin('tasks') }
  it { is_expected.to contain_foreman__cli__plugin('foreman_tasks') }
  it { is_expected.to contain_foreman__plugin('remote_execution') }
  it { is_expected.to contain_foreman__cli__plugin('foreman_remote_execution') }
  it { is_expected.to contain_foreman__plugin('templates') }
  it { is_expected.to contain_foreman__cli__plugin('foreman_templates') }
  it { is_expected.to contain_foreman__plugin('column_view') }

  context 'with foreman_hostgroup param' do
    let(:params) do
      {
        foreman_hostgroup: {
          foo: {
            description: 'bar',
          },
        },
      }
    end

    it { is_expected.to contain_foreman_hostgroup('foo').with_description('bar') }
  end

  context 'with foreman_global_parameter param' do
    let(:params) do
      {
        foreman_global_parameter: {
          foo: {
            parameter_type: 'baz',
            value: 'bar',
          },
        },
      }
    end

    it do
      is_expected.to contain_foreman_global_parameter('foo').with(
        parameter_type: 'baz',
        value: 'bar',
      )
    end
  end
end
