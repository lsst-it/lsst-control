# @summary
#   Monitor system metrics.
#
# @param password
#   The InfluxDB password for the telegraf user
#
# @param username
#   The InfluxDB username for node metrics (as opposed to summit power metrics).
#
# @param database
#   The InfluxDB database for node metrics (as opposed to summit power metrics).
#
# @param host
#   The backing InfluxDB instance. At present the default DNS record is a CNAME.
class profile::core::telegraf(
  String $password,
  String $username = 'telegraf',
  String $database = 'telegraf',
  String $host     = 'metrics-ingress.ls.lsst.org',
) {
  $influxdb_url = "http://${host}:8086"
  class { '::telegraf':
    hostname               => $::facts['fqdn'],
    global_tags            => {'site' => $::site},
    purge_config_fragments => true,
    outputs                => {
      'influxdb' => [
        {
          'urls'                   => [$influxdb_url],
          'database'               => $database,
          'username'               => $username,
          'password'               => $password,
          'skip_database_creation' => true
        }
      ]
    }
  }

  $default_inputs = {
    'cpu'        => [{}],
    'chrony'     => [{}],
    'conntrack'  => [{}],
    'disk'       => [{'ignore_fs' => ['tmpfs', 'devtmpfs', 'overlay']}],
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
}
