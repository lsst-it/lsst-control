# frozen_string_literal: true

require 'spec_helper'

describe 'profile::archive::common', :archiver do
  let(:node_params) do
    {
      site: 'dev',
    }
  end

  let(:facts) { { hostname: 'foo' } }

  it { is_expected.to compile.with_all_deps }

  %w[
    git
    cmake
    gcc-c++
  ].each do |p|
    it { is_expected.to contain_package(p) }
  end

  %w[
    docker-compose
    cryptography
    redis
  ].each do |p|
    it { is_expected.to contain_python__pip(p) }
  end

  it { is_expected.to contain_accounts__user('arc').with_uid('61000') }
  it { is_expected.to contain_accounts__user('atadbot').with_uid('61002') }
  it { is_expected.to contain_group('docker-foo').with_gid('70014') }

  it do
    is_expected.to contain_sudo__conf('comcam_archive_cmd')
      .with_content('%comcam-archive-sudo ALL=(arc,atadbot) NOPASSWD: ALL')
  end
end
