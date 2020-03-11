class tig::dashboard (
  String $grafana_password = $tig::grafana::params::grafana_password,
  String $grafana_user = $tig::grafana::params::grafana_user,
  String $grafana_url = $tig::grafana::params::grafana_url,
  String $influx_password = $tig::grafana::params::influxdb_password,
  String $influx_database = $tig::grafana::params::influxdb_database,
  String $influx_username = $tig::grafana::params::influxdb_user,
) inherits ::tig::grafana::params {
  class { 'grafana':
    cfg => {
      app_mode => 'production',
      server   => {
        http_port     => 8080,
      },
      security => {
        admin_user => $grafana_user,
        admin_password => $grafana_password,
      },
      database => {
        type          => 'sqlite3',
        host          => '127.0.0.1:3306',
        name          => 'grafananana',
      },
    },
  }
  class {'influxdb': }
  influx_database{$influx_database:
    superuser => $influx_username,
    superpass => $influx_password
  }

  grafana_datasource { 'influxdb':
    require           => Influx_database['influxdb'],
    grafana_url       => $grafana_url,
    grafana_user      => $grafana_user,
    grafana_password  => $grafana_password,
    type              => 'influxdb',
    url               => 'http://localhost:8086',
    user              => $influx_username,
    password          => $influx_password,
    database          => $influx_database,
    access_mode       => 'proxy',
    is_default        => true,
  }

  grafana_dashboard { 'telegraf':
    grafana_url       => $grafana_url,
    grafana_user      => $grafana_user,
    grafana_password  => $grafana_password,
    #content           => template('tig/dashboards/telegraf.json')
  }

  class grafana::telegraf (
    String $influx_host =$tig::grafana::params::grafana_url,
    String $password = $tig::params::influxdb_password,
    String $database = $tig::params::influxdb_database,
    String $username = $tig::params::influxdb_user,
  ) inherits ::grafana::params {

  $influx_url = "http://${influx_host}:8086"

  class { 'telegraf':
    hostname => $facts['hostname'],
    outputs  => {
        'influxdb' => [
            {
                'urls'     => [ $influx_url ],
                'database' => $database,
                'username' => $username,
                'password' => $password,
            }
        ]
    },
  }

  telegraf::input{ 'cpu':
    options => [{ 'percpu' => true, 'totalcpu' => true, }]
  }

  ['disk', 'io', 'net', 'swap', 'system', 'mem', 'processes', 'kernel' ].each |$plug| {
    telegraf::input{ $plug:
     options => [{}]}
  }
}
