# @summary
#   Send metrics from telegraf to grafana
#
# @param url_ls
#   URL of influxdb Base instance.
#
# @param url_cp
#   URL of influxdb Summit instance.
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
  String $url_ls,
  String $url_cp,
  String $database,
  String $username,
  String $password,
) {
  class { 'telegraf':
    hostname => $facts['networking']['fqdn'],
    outputs  => {
      'influxdb' => [{
          'urls'     => [$url_ls,$url_cp],
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
