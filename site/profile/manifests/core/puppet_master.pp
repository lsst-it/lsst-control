class profile::core::puppet_master(
  Stdlib::HTTPSUrl $smee_url
) {
  include cron
  include r10k
  include r10k::webhook
  include r10k::webhook::config
  include scl

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
}
