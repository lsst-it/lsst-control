# @summary
#   Icinga additional plugins
#
# @param credentials_hash
#   HTTP auth
#
class profile::icinga::plugins (
  String $credentials_hash,
) {
  #<----------------------------------------------- Variables------------------------------------------------->
  #Implicit usage of facts
  $master_fqdn  = $facts['networking']['fqdn']

  #Commands abreviation
  $url_cmd     = "https://${master_fqdn}/director/command"
  $credentials   = "Authorization:Basic ${credentials_hash}"
  $format        = 'Accept: application/json'
  $curl          = 'curl -s -k -H'
  $icinga_path   = '/opt/icinga'
  $lt            = '| grep error'

  #Command Names
  $cpu_command_name = 'cpu'
  $netio_command_name = 'netio'
  $netio2_command_name = 'netio2'

  #Commands Array
  $commands = [
    $cpu_command_name,
    $netio_command_name,
    $netio2_command_name,
  ]
  #check_nwc_health variables
  $base_dir    = '/usr/lib64/nagios/plugins'
  $nwc_dir     = "${icinga_path}/check_nwc_health"
  $conditions  = "--prefix=${nwc_dir} --with-nagios-user=root --with-nagios-group=icinga --with-perl=/bin/perl"

  #<--------------------------------------------END Variables------------------------------------------------->
  #
  #
  #<---------------------------Plugins Creation and permissions adjustment------------------------------------>

  # XXX we should not be compiling software on production systems. If a 3rd
  # party package is not avaiable an rpm should be created and uploaded to nexus.
  $nwc_build_packages = [
    'autoconf',
    'automake',
  ]
  ensure_packages($nwc_build_packages)

  vcsrepo { $nwc_dir:
    ensure   => present,
    provider => git,
    source   => 'https://github.com/lausser/check_nwc_health',
    revision => '1.4.9',
    require  => Class['icingaweb2'],
  }
  ->exec { 'git submodule update --init':
    cwd      => $nwc_dir,
    path     => ['/sbin', '/usr/sbin', '/bin'],
    onlyif   => "test ! -f ${$nwc_dir}/plugins-scripts/check_nwc_health",
    loglevel => debug,
  }
  ->exec { 'autoreconf':
    command  => "autoreconf;./configure ${conditions};make;make install;",
    cwd      => $nwc_dir,
    path     => ['/sbin', '/usr/sbin', '/bin'],
    provider => shell,
    onlyif   => "test ! -f ${base_dir}/check_nwc_health",
    loglevel => debug,
    require  => Package[$nwc_build_packages],
  }
  ->file { "${base_dir}/check_nwc_health":
    ensure => 'file',
    source => "${$nwc_dir}/plugins-scripts/check_nwc_health",
    owner  => 'root',
    group  => 'icinga',
    mode   => '4755',
  }
  #Check memory plugin
  archive { '/usr/lib64/nagios/plugins/check_mem':
    ensure => present,
    source => 'https://raw.githubusercontent.com/justintime/nagios-plugins/master/check_mem/check_mem.pl',
  }
  ->file { '/usr/lib64/nagios/plugins/check_mem':
    owner => 'root',
    group => 'icinga',
    mode  => '4755',
  }
  #Check logged users
  archive { '/usr/lib64/nagios/plugins/check_users':
    ensure => present,
    source => 'https://exchange.nagios.org/components/com_mtree/attachment.php?link_id=1530&cf_id=24',
  }
  ->file { '/usr/lib64/nagios/plugins/check_users':
    owner => 'root',
    group => 'icinga',
    mode  => '4755',
  }
  #Check CPU usage
  archive { '/usr/lib64/nagios/plugins/check_cpu':
    ensure => present,
    source => 'https://exchange.nagios.org/components/com_mtree/attachment.php?link_id=580&cf_id=29',
  }
  ->file { '/usr/lib64/nagios/plugins/check_cpu':
    owner => 'root',
    group => 'icinga',
    mode  => '4755',
  }
  #Check network traffic
  archive { '/usr/lib64/nagios/plugins/check_netio':
    ensure => present,
    source => 'https://www.claudiokuenzler.com/monitoring-plugins/check_netio.sh',
  }
  ->file { '/usr/lib64/nagios/plugins/check_netio':
    owner => 'root',
    group => 'icinga',
    mode  => '4755',
  }
  #Check network traffic for devices with 2 NICS
  archive { '/usr/lib64/nagios/plugins/check_netio2':
    ensure => present,
    source => 'https://www.claudiokuenzler.com/monitoring-plugins/check_netio.sh',
  }
  ->file { '/usr/lib64/nagios/plugins/check_netio2':
    owner => 'root',
    group => 'icinga',
    mode  => '4755',
  }
  #Add commands to Icinga Director
  $commands.each |$name| {
    $path = "${$icinga_path}/${$name}.json"
    $cond = "${curl} '${credentials}' -H '${format}' -X GET '${url_cmd}?name=${name}' ${lt}"
    $cmd  = "${curl} '${credentials}' -H '${format}' -X POST '${url_cmd}' -d @${path}"

    file { $path:
      ensure  => 'file',
      # lint:ignore:strict_indent
      content => @("COMMAND_HOST"/$),
        {
        "command": "\/usr\/lib64\/nagios\/plugins\/check_${name}",
        "methods_execute": "PluginCheck",
        "object_name": "${name}",
        "object_type": "object",
        "timeout": "1m",
        "zone": "master"
        }
        | COMMAND_HOST
      # lint:endignore
    }
    ->exec { $cmd:
      cwd      => $icinga_path,
      path     => ['/sbin', '/usr/sbin', '/bin'],
      provider => shell,
      onlyif   => $cond,
      loglevel => debug,
    }
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
