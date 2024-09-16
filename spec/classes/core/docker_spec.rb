# frozen_string_literal: true

require 'spec_helper'

describe 'profile::core::docker' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile.with_all_deps }

      include_examples 'docker', docker_version: '23.0.6'

      it do
        is_expected.to contain_systemd__dropin_file('wait-for-docker-group.conf').with(
          unit: 'docker.socket',
          content: %r{SocketGroup=root}
        )
      end

      it do
        is_expected.to contain_file('/etc/systemd/system/docker.service.d/wait-for-docker-group.conf')
          .with_content(%r{Requires=docker.socket containerd.service sssd.service})
          .that_notifies('Service[docker]')
      end

      if os_facts[:os]['release']['major'] == '9'
        it do
          is_expected.to contain_systemd__dropin_file('ceph.conf').with(
            unit: 'containerd.service',
            content: <<~CONTENT
              # fix for ceph mons crashing
              # See: https://github.com/rook/rook/issues/10110#issuecomment-1464898937
              [Service]
              LimitNOFILE=1048576
              LimitNPROC=1048576
              LimitCORE=1048576
            CONTENT
          )
        end
      end

      it do
        is_expected.to contain_file('/etc/docker').with(
          ensure: 'directory',
          mode: '0755'
        ).that_comes_before('File[/etc/docker/daemon.json]')
      end

      it do
        is_expected.to contain_file('/etc/docker/daemon.json').with(
          ensure: 'file',
          mode: '0644',
          content: %r{"live-restore": true}
        ).that_notifies('Service[docker]')
      end
    end
  end
end
