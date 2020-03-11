class profile::core::telegraf(
  String $password,
  String $username = 'telegraf-nodes',
  String $database = 'nodes',
  String $host     = 'metrics-ingress.ls.lsst.org',
  String $port     = '8086'
) {
  class { '::telegraf':
    hostname    => $::facts['fqdn'],
    global_tags => {"site" => $::site},
  }

  $default_inputs = {
    'cpu'        => [{}],
    'chrony'     => [{}],
    'conntrack'  => [{}],
    'disk'       => [{"ignore_fs" => ["tmpfs", "devtmpfs", "overlay"]}],
    'diskio'     => [{}],
    'interrupts' => [{}],
    'mem'        => [{}],
    'net'        => [{}],
    'netstat'    => [{}],
    'processes'  => [{}],
    'system'     => [{}],
    'swap'       => [{}],
  }

  $default_inputs.each |$type, $options| {
    telegraf::input { $type:
      plugin_type => $type,
      options     => $options
    }
  }

  $influxdb_url = "http://${host}:${port}"
  telegraf::output { 'chile-influxdb':
    plugin_type => 'influxdb',
    options     => [
      {
        'urls'     => [$influxdb_url],
        'database' => $database,
        'username' => $username,
        'password' => $password
      }
    ]
  }
}
