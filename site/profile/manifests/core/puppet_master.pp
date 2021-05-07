# @summary
#   Install foreman/puppetserver
#
# @param enable_puppetdb
#   Whether or not to enable puppetserver's puppetdb support
class profile::core::puppet_master(
  Stdlib::HTTPSUrl $smee_url,
  Boolean $enable_puppetdb = false,
) {
  include cron
  include foreman
  include foreman::cli
  include foreman::compute::libvirt
  include foreman::plugin::remote_execution
  include foreman::plugin::tasks
  include foreman_proxy
  include foreman_proxy::plugin::dns::route53
  include foreman_proxy::plugin::dynflow
  include foreman_proxy::plugin::remote_execution::ssh
  include foreman::repo
  include puppet
  include r10k
  include r10k::webhook
  include r10k::webhook::config
  include scl

  if $enable_puppetdb {
    include puppet::server::puppetdb
  }

  Class['r10k::webhook::config'] -> Class['r10k::webhook']

  $node_pkgs = [
    'rh-nodejs10',
    'rh-nodejs10-npm',
  ]

  package { $node_pkgs:
    require => Class['scl']
  }

  exec { 'install-smee':
    creates   => '/opt/rh/rh-nodejs10/root/usr/bin/smee',
    command   => 'npm install --global smee-client',
    subscribe => Package['rh-nodejs10-npm'],
    path      => [
      '/opt/rh/rh-nodejs10/root/usr/bin',
      '/usr/sbin',
      '/usr/bin',
    ],
  }

  $service_unit = @("EOT")
    [Unit]
    Description=smee.io webhook daemon

    [Service]
    Type=simple
    ExecStart=/usr/bin/scl enable rh-nodejs10 -- \
      /opt/rh/rh-nodejs10/root/usr/bin/smee \
      --url ${smee_url} \
      -P /payload \
      -p 8088
    Restart=on-failure
    RestartSec=10

    [Install]
    WantedBy=default.target
    | EOT

  systemd::unit_file { 'smee.service':
    content => $service_unit,
  }
  ~> service { 'smee':
    ensure    => 'running',
    enable    => true,
    subscribe => Exec['install-smee'],
  }

  # The toml-rb gem is required for the telegraf module.
  #
  # Note that if the telegraf module is used then Puppet will fail during a catalog
  # compilation, so we might need to manually install this gem in that scenario.
  package { 'toml-rb':
    provider => 'puppetserver_gem',
  }
}
