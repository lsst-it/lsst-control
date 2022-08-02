# frozen_string_literal: true

require 'spec_helper'

describe 'profile::core::docker' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      it { is_expected.to compile.with_all_deps }

      it do
        is_expected.to contain_class('docker').with(
          overlay2_override_kernel_check: true,
          socket_group: 70_014,
          socket_override: false,
          storage_driver: 'overlay2',
          version: '19.03.15',
        )
      end

      it { is_expected.to contain_class('yum::plugin::versionlock') }
      it { is_expected.to have_yum__versionlock_resource_count(2) }
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

      it do
        is_expected.to contain_file('/etc/docker').with(
          ensure: 'directory',
          mode: '0755',
        ).that_comes_before('File[/etc/docker/daemon.json]')
      end

      it do
        is_expected.to contain_file('/etc/docker/daemon.json').with(
          ensure: 'file',
          mode: '0644',
          content: %r{"live-restore": true},
        ).that_notifies('Service[docker]')
      end
    end
  end
end
