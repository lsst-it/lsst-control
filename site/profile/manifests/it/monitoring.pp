# Class responsible for the monitoring of servers.
class profile::it::monitoring {
  if lookup('monitoring_enabled'){
    include telegraf
    $backup_outputs = lookup('backup_outputs', {default_value => undef})
    if $backup_outputs {
      $backup_outputs.each | $output | {
        telegraf::output{ $output["name"]:
          plugin_type => $output["plugintype"],
          options     => $output["options"]
        }
      }
    }
    # TODO Until telegraf's puppet module doesn't allow multiple procstat definitions from hiera,
    # a fixed script/variable is defined to configure the required services to be monitored. 
    $monitored_services = lookup('monitored_services')
    $monitored_services.each | $service | {
      telegraf::input { $service:
        plugin_type => 'procstat',
        options     =>
          {
            'systemd_unit' => "${service}.service",
          },
      }
    }
    #Remote Logging
    #All definitions come from hiera.
    class{'rsyslog::client':}
  }else{
    service{'telegraf':
      ensure => stopped,
    }
  }

  if ! $is_virtual {
    package { 'smartmontools':
      ensure => installed,
    }
    package { 'lm_sensors':
      ensure => installed,
    }
    file_line { 'Adding smartcl permissions to sudoers':
      ensure  => present,
      path    => '/etc/sudoers',
      line    => 'telegraf  ALL= NOPASSWD: /usr/sbin/smartctl',
      match   => '^telegraf',
      require => Package['sudo']
    }
  }
}
