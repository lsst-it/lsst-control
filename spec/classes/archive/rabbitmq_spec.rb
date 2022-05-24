# frozen_string_literal: true

require 'spec_helper'

describe 'profile::archive::rabbitmq' do
  it { is_expected.to compile.with_all_deps }

  it { is_expected.to contain_class('rabbitmq').with_package_ensure('3.8.3-1.el7.noarch') }
  it { is_expected.to contain_yum__versionlock('0:rabbitmq-server-3.8.3-1.el7.noarch') }

  it do
    is_expected.to contain_yum__install('erlang').with_source(%r{erlang-22.3.4-1.el7.x86_64.rpm})
  end

  it { is_expected.to contain_yum__versionlock('0:erlang-22.3.4-1.el7.x86_64') }
end
