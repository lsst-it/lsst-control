# @summary
#   Send metrics from telegraf to grafana
#
# @param url
#   URL of influxdb instance.
#
# @param database
#   Name of influxdb instance.
#
# @param username
#   Influxdb username.
#
# @param password
#   Influxdb password.
#
class profile::core::monitoring (
  String $url,
  String $database,
  String $username,
  String $password,
) {
  class { 'telegraf':
    hostname => $facts['networking']['fqdn'],
    outputs  => {
      'influxdb' => [{
          'urls'     => [$url],
          'database' => $database,
          'username' => $username,
          'password' => $password,
      }],
    },
    inputs   => {
      'cpu'    => [{
          'percpu'   => true,
          'totalcpu' => true,
      }],
      'mem'    => [{}],
      'io'     => [{}],
      'net'    => [{}],
      'disk'   => [{}],
      'swap'   => [{}],
      'system' => [{}],
    },
  }
}
