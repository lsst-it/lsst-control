# @summary
#   Send metrics from telegraf to grafana
#

class profile::core::monitoring(
  String $url,
  String $database,
  String $username,
  String $password,
) {

  class { 'telegraf':
    hostname => $facts['hostname'],
    outputs  => {
      'influxdb' => [{
        'urls'     => [ $url ],
        'database' => $database,
        'username' => $username,
        'password' => $password,
      }]
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
    }
  }

}
