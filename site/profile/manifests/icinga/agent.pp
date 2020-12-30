# @summary
#   Icinga agent creation for metric collections

class profile::icinga::agent(
  String $icinga_master_fqdn,
  String $icinga_master_ip,
  String $credentials_hash,
  String $host_template,
  String $ca_salt,
  String $ssh_port = '22',
){
  #<-----------------------Variables-Definition--------------------------->
  $packages = [
    'nagios-plugins-all',
  ]
  $nic = $facts['networking']['primary']
  $icinga_agent_fqdn = $facts['networking']['fqdn']
  $icinga_agent_ip = $facts['networking']['ip']
  $credentials = "Authorization:Basic ${credentials_hash}"
  $icinga_path = '/opt/icinga'
  $path = "${icinga_path}/${icinga_agent_fqdn}.json"
  $url = "https://${icinga_master_fqdn}/director/host"
  $cmd = "curl -s -k -H '${credentials}' -H 'Accept: application/json' -X POST '${url}' -d @${path}"
  $cond = "curl -s -k -H '${credentials}' -H 'Accept: application/json' -X GET '${url}/host?name=${icinga_agent_fqdn}' | grep Failed"
  #<-------------------End-Variables-Definition--------------------------->
  #
  #
  #<-------------------------Icinga-Configuration------------------------->
  class { '::icinga2':
    manage_repo => true,
    confd       => false,
    features    => ['mainlog'],
  }
  ##Icinga2 feature API config
  class { '::icinga2::feature::api':
    ensure          => 'present',
    ca_host         => $icinga_master_ip,
    ticket_salt     => $ca_salt,
    accept_config   => true,
    accept_commands => true,
    endpoints       => {
      $icinga_agent_fqdn  => {
        'host'  =>  $icinga_agent_ip
      },
      $icinga_master_fqdn => {
        'host'  =>  $icinga_master_ip,
      },
    },
    zones           => {
      $icinga_agent_fqdn => {
        'endpoints' => [$icinga_agent_fqdn],
        'parent'    => 'master',
      },
      'master'           => {
        'endpoints' => [$icinga_master_fqdn],
      },
    }
  }
  #<--------------------End-Icinga-Configuration-------------------------->
  #
  #
  #<-------------------------Additional-Plugins--------------------------->
  #Check disk
  file { '/usr/lib64/nagios/plugins/check_disk':
    owner   => 'root',
    group   => 'root',
    mode    => '4755',
    require => Package[$packages],
  }
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
    content => @("CONTENT")
      object CheckCommand "netio" {
        command = [ "/usr/lib64/nagios/plugins/check_netio" ]
        arguments = {
          "-i" = "${nic}"
        }
      }
      | CONTENT
  }
  if ($icinga_agent_fqdn =='comcam-fp01.ls.lsst.org' or $icinga_agent_fqdn =='comcam-mcm.ls.lsst.org') {
    archive {'/usr/lib64/nagios/plugins/check_netio2':
      ensure => present,
      source => 'https://www.claudiokuenzler.com/monitoring-plugins/check_netio.sh',
    }
    ->file { '/usr/lib64/nagios/plugins/check_netio2':
      owner => 'root',
      group => 'icinga',
      mode  => '4755',
    }
    ->file {'/etc/icinga2/features-enabled/netio2.conf':
      ensure  => 'present',
      owner   => 'icinga',
      group   => 'icinga',
      mode    => '0640',
      notify  => Service['icinga2'],
      content => @("CONTENT")
        object CheckCommand "netio2" {
          command = [ "/usr/lib64/nagios/plugins/check_netio2" ]
          arguments = {
            "-i" = "lsst-daq"
          }
        }
        | CONTENT
    }
  }
  if ($icinga_agent_fqdn =='net-dx.cp.lsst.org') {
    archive {'/usr/lib64/nagios/plugins/check_netio2':
      ensure => present,
      source => 'https://www.claudiokuenzler.com/monitoring-plugins/check_netio.sh',
    }
    ->file { '/usr/lib64/nagios/plugins/check_netio2':
      owner => 'root',
      group => 'icinga',
      mode  => '4755',
    }
    ->file {'/etc/icinga2/features-enabled/netio2.conf':
      ensure  => 'present',
      owner   => 'icinga',
      group   => 'icinga',
      mode    => '0640',
      notify  => Service['icinga2'],
      content => @("CONTENT")
        object CheckCommand "netio2" {
          command = [ "/usr/lib64/nagios/plugins/check_netio2" ]
          arguments = {
            "-i" = "ens224"
          }
        }
        | CONTENT
    }
  }
  #Memory Usage
  archive {'/usr/lib64/nagios/plugins/check_mem.pl':
    ensure => present,
    source => 'https://raw.githubusercontent.com/justintime/nagios-plugins/master/check_mem/check_mem.pl',
  }
  ->file { '/usr/lib64/nagios/plugins/check_mem.pl':
    owner => 'root',
    group => 'icinga',
    mode  => '4755',
  }
  #Logged Users
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

  ->file {'/etc/icinga2/features-enabled/cpu.conf':
    ensure  => 'present',
    owner   => 'icinga',
    group   => 'icinga',
    mode    => '0640',
    notify  => Service['icinga2'],
    content => @(CONTENT)
      object CheckCommand "cpu" {
        command = [ "/usr/lib64/nagios/plugins/check_cpu" ]
      }
      | CONTENT
  }
  #<---------------------END-Additional-Plugins--------------------------->
  #
  #
  #<----------------------Add-Host-to-Icinga-Master----------------------->
  ##Create a directory to allocate json files
  file { $icinga_path:
    ensure => 'directory',
  }
  ## Create host file
  file { $path:
    ensure  => 'present',
    content => @("CONTENT"/L)
      {
      "address": "${icinga_agent_ip}",
      "display_name": "${icinga_agent_fqdn}",
      "imports": [
        "${host_template}"
      ],
      "object_name":"${icinga_agent_fqdn}",
      "object_type": "object",
      "vars": {
          "safed_profile": "3",
          "ssh_port": "${ssh_port}"
      }
      }
      | CONTENT
  }
  -> exec { $cmd:
    cwd      => $icinga_path,
    path     => ['/sbin', '/usr/sbin', '/bin'],
    provider => shell,
    onlyif   => $cond,
    loglevel => debug,
  }
  ##Add require packages
  package { $packages:
    ensure => 'present',
  }
  #<------------------End-Add-Host-to-Icinga-Master----------------------->
}


