# frozen_string_literal: true

shared_examples 'docker' do |docker_version: nil|
  it do
    is_expected.to contain_class('docker').with(
      package_source: 'docker-ce',
      socket_group: 70_014,
      socket_override: false,
      storage_driver: 'overlay2',
    )
  end

  it { is_expected.to contain_class('docker::networks') }

  # the puppet resource to install the `docker-ce` package is named `docker`
  %w[
    docker
    docker-ce-cli
    docker-compose-plugin
  ].each do |pkg|
    it { is_expected.to contain_package(pkg) }
  end

  if docker_version
    it { is_expected.to contain_class('docker').with_version(docker_version) }

    %w[
      docker-ce
      docker-ce-cli
      docker-ce-rootless-extras
    ].each do |pkg|
      it { is_expected.to contain_yum__versionlock(pkg).with_version(docker_version) }
    end
  end

  it do
    is_expected.to contain_yum__versionlock('containerd.io').with(
      version: '1.6.21',
    )
  end

  it do
    is_expected.to contain_yum__versionlock('docker-scan-plugin').with(
      version: '0.23.0',
    )
  end

  it do
    is_expected.to contain_yum__versionlock('docker-compose-plugin').with(
      version: '2.17.3',
    )
  end

  it do
    # skip this example for class tests
    next unless defined?(node_params)

    to = node_params[:site] == 'cp' ? 'not_to' : 'to'

    is_expected.send(to, contain_class('docker').with(
                           log_driver: 'json-file',
                           log_opt: %w[
                             max-file=2
                             max-size=50m
                             mode=non-blocking
                           ],
                         ))
  end
end
