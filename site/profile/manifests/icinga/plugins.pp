# @summary
#   Icinga additional plugins

class profile::icinga::plugins{
  #check_nwc_health plugin
  $icinga_path = '/opt/icinga'
  $base_dir    = '/usr/lib64/nagios/plugins'
  $nwc_dir     = "${icinga_path}/check_nwc_health"
  $conditions  = "--prefix=${nwc_dir} --with-nagios-user=root --with-nagios-group=icinga --with-perl=/bin/perl"

  vcsrepo { $nwc_dir:
    ensure   => present,
    provider => git,
    source   => 'https://github.com/lausser/check_nwc_health',
    revision => '1.4.9',
    require  => Class['::icingaweb2'],
  }
  ->exec {'git submodule update --init':
    cwd      => $nwc_dir,
    path     => ['/sbin', '/usr/sbin', '/bin'],
    onlyif   => "test ! -f ${$nwc_dir}/plugins-scripts/check_nwc_health",
    loglevel => debug,
  }
  ->exec {"autoreconf;./configure ${conditions};make;make install;":
    cwd      => $nwc_dir,
    path     => ['/sbin', '/usr/sbin', '/bin'],
    provider => shell,
    onlyif   => "test ! -f ${base_dir}/check_nwc_health",
    loglevel => debug,
  }
  ->file {"${base_dir}/check_nwc_health":
    ensure => 'present',
    source => "${$nwc_dir}/plugins-scripts/check_nwc_health",
    owner  => 'root',
    group  => 'icinga',
    mode   => '4755',
  }
  #Check memory plugin
  archive {'/usr/lib64/nagios/plugins/check_mem':
    ensure => present,
    source => 'https://raw.githubusercontent.com/justintime/nagios-plugins/master/check_mem/check_mem.pl',
  }
  ->file { '/usr/lib64/nagios/plugins/check_mem':
    owner => 'root',
    group => 'icinga',
    mode  => '4755',
  }
  #Check logged users
  archive {'/usr/lib64/nagios/plugins/check_users':
    ensure => present,
    source => 'https://exchange.nagios.org/components/com_mtree/attachment.php?link_id=1530&cf_id=24',
  }
  ->file { '/usr/lib64/nagios/plugins/check_users':
    owner => 'root',
    group => 'icinga',
    mode  => '4755',
  }
  #CPU usage
  archive {'/usr/lib64/nagios/plugins/check_cpu':
    ensure => present,
    source => 'https://exchange.nagios.org/components/com_mtree/attachment.php?link_id=580&cf_id=29',
  }
  ->file { '/usr/lib64/nagios/plugins/check_cpu':
    owner => 'root',
    group => 'icinga',
    mode  => '4755',
  }
  # ->file {'/etc/icinga2/features-enabled/cpu.conf':
  #   ensure  => 'present',
  #   owner   => 'icinga',
  #   group   => 'icinga',
  #   mode    => '0640',
  #   notify  => Service['icinga2'],
  #   content => @(CONTENT)
  #     object CheckCommand "cpu" {
  #       command = [ "/usr/lib64/nagios/plugins/check_cpu" ]
  #     }
  #     | CONTENT
  # }
  #Network Usage
  archive {'/usr/lib64/nagios/plugins/check_netio':
    ensure => present,
    source => 'https://www.claudiokuenzler.com/monitoring-plugins/check_netio.sh',
  }
  ->file { '/usr/lib64/nagios/plugins/check_netio':
    owner => 'root',
    group => 'icinga',
    mode  => '4755',
  }
  ->file {'/etc/icinga2/features-enabled/netio.conf':
    ensure  => 'present',
    owner   => 'icinga',
    group   => 'icinga',
    mode    => '0640',
    notify  => Service['icinga2'],
    content => @(CONTENT)
      object CheckCommand "netio" {
        import "plugin-check-command"
        command = [ "/usr/lib64/nagios/plugins/check_netio" ]
        timeout = 1m
      }
      | CONTENT
  }
  #Change permissions to dhcp plugin
  file { '/usr/lib64/nagios/plugins/check_dhcp':
    owner => 'root',
    group => 'nagios',
    mode  => '4755',
  }
  #Change permissions to disk plugin
  file { '/usr/lib64/nagios/plugins/check_disk':
    owner => 'root',
    group => 'nagios',
    mode  => '4755',
  }
}
