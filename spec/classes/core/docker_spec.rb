# frozen_string_literal: true

require 'spec_helper'

describe 'profile::core::docker' do
  let(:node_params) { { org: 'lsst' } }

  it { is_expected.to compile.with_all_deps }

  it do
    is_expected.to contain_class('docker').with(
      overlay2_override_kernel_check: true,
      socket_group: 70_014,
      socket_override: false,
      storage_driver: 'overlay2',
      version: '20.10.12',
    )
  end

  it { is_expected.to contain_class('yum::plugin::versionlock') }
  it { is_expected.to have_yum__versionlock_resource_count(5) }
  it { is_expected.to contain_class('docker::networks') }

  it do
    is_expected.to contain_systemd__dropin_file('wait-for-docker-group.conf').with(
      unit: 'docker.socket',
      content: %r{SocketGroup=root},
    )
  end

  it do
    is_expected.to contain_file('/etc/systemd/system/docker.service.d/wait-for-docker-group.conf').with_content(%r{Requires=docker.socket containerd.service sssd.service})
  end
end
