# @summary
#   Icinga agent creation for metric collections
#
# @param icinga_master_fqdn
#   Icinga master hostname.
#
# @param icinga_master_ip
#   IP address of icinga master. XXX We should only be using DNS records to resolve hosts.
#
# @param credentials_hash
#   HTTP auth
#
# @param host_template
#   Icinga template to import
#
# @param bmc_template
#   Icinga template for BMCs
#
# @param site
#   `summit` or not. XXX This does not conform to the standard two letter tu/ls/cp site codes.
#
# @param ca_salt
#   x509 CA salt string
#
# @param ssh_port
#   Port upon which sshd is listening.
#
class profile::icinga::agent (
  String $icinga_master_fqdn = 'null',
  String $icinga_master_ip = 'null',
  String $credentials_hash = 'null',
  String $site = 'null',
  String $host_template = 'null',
  String $bmc_template = 'null',
  String $ca_salt = 'null',
  String $ssh_port = '22',
) {
  #<-----------------------Variables-Definition--------------------------->
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
  class { 'icinga::repos':
    manage_epel         => false,
  }
  class { 'icinga2':
    confd           => false,
  }
  #  Icinga2 feature API config
  class { 'icinga2::feature::api':
    ensure          => 'present',
    ca_host         => $icinga_master_ip,
    ticket_salt     => $ca_salt,
    accept_config   => true,
    accept_commands => true,
    endpoints       => {
      $icinga_agent_fqdn  => {
        'host'  => $icinga_agent_ip,
      },
      $icinga_master_fqdn => {
        'host'  => $icinga_master_ip,
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
    },
  }
  #<--------------------End-Icinga-Configuration-------------------------->
  #
  #
  #<-------------------------Additional-Plugins--------------------------->
  #  Check disk
  file { '/usr/lib64/nagios/plugins/check_disk':
    owner   => 'root',
    group   => 'root',
    mode    => '4755',
    require => Package['nagios-plugins-all'],
  }
  #  Network Usage
  archive { '/usr/lib64/nagios/plugins/check_netio':
    ensure => present,
    source => 'https://www.claudiokuenzler.com/monitoring-plugins/check_netio.sh',
  }
  ->file { '/usr/lib64/nagios/plugins/check_netio':
    owner => 'root',
    group => 'icinga',
    mode  => '4755',
  }
  ->file { '/etc/icinga2/features-enabled/netio.conf':
    ensure  => 'file',
    owner   => 'icinga',
    group   => 'icinga',
    mode    => '0640',
    notify  => Service['icinga2'],
    # lint:ignore:strict_indent
    content => @("CONTENT"),
      object CheckCommand "netio" {
        command = [ "/usr/lib64/nagios/plugins/check_netio" ]
        arguments = {
          "-i" = "${nic}"
        }
      }
      | CONTENT
    # lint:endignore
  }
  if $site == 'summit' {
    if ($icinga_agent_fqdn =='comcam-fp01.cp.lsst.org' or $icinga_agent_fqdn =='comcam-mcm.cp.lsst.org') {
      archive { '/usr/lib64/nagios/plugins/check_netio2':
        ensure => present,
        source => 'https://www.claudiokuenzler.com/monitoring-plugins/check_netio.sh',
      }
      ->file { '/usr/lib64/nagios/plugins/check_netio2':
        owner => 'root',
        group => 'icinga',
        mode  => '4755',
      }
      ->file { '/etc/icinga2/features-enabled/netio2.conf':
        ensure  => 'file',
        owner   => 'icinga',
        group   => 'icinga',
        mode    => '0640',
        notify  => Service['icinga2'],
        # lint:ignore:strict_indent
        content => @("CONTENT"),
          object CheckCommand "netio2" {
            command = [ "/usr/lib64/nagios/plugins/check_netio2" ]
            arguments = {
              "-i" = "lsst-daq"
            }
          }
          | CONTENT
        # lint:endignore
      }
    }
    if ($icinga_agent_fqdn =='net-dx.cp.lsst.org') {
      archive { '/usr/lib64/nagios/plugins/check_netio2':
        ensure => present,
        source => 'https://www.claudiokuenzler.com/monitoring-plugins/check_netio.sh',
      }
      ->file { '/usr/lib64/nagios/plugins/check_netio2':
        owner => 'root',
        group => 'icinga',
        mode  => '4755',
      }
      ->file { '/etc/icinga2/features-enabled/netio2.conf':
        ensure  => 'file',
        owner   => 'icinga',
        group   => 'icinga',
        mode    => '0640',
        notify  => Service['icinga2'],
        # lint:ignore:strict_indent
        content => @("CONTENT"),
          object CheckCommand "netio2" {
            command = [ "/usr/lib64/nagios/plugins/check_netio2" ]
            arguments = {
              "-i" = "ens224"
            }
          }
          | CONTENT
        # lint:endignore
      }
    }
  }
  #  Memory Usage
  archive { '/usr/lib64/nagios/plugins/check_mem.pl':
    ensure => present,
    source => 'https://raw.githubusercontent.com/justintime/nagios-plugins/master/check_mem/check_mem.pl',
  }
  ->file { '/usr/lib64/nagios/plugins/check_mem.pl':
    owner => 'root',
    group => 'icinga',
    mode  => '4755',
  }
  #  Logged Users
  archive { '/usr/lib64/nagios/plugins/check_users':
    ensure => present,
    source => 'https://exchange.nagios.org/components/com_mtree/attachment.php?link_id=1530&cf_id=24',
  }
  ->file { '/usr/lib64/nagios/plugins/check_users':
    owner => 'root',
    group => 'icinga',
    mode  => '4755',
  }
  #  CPU usage
  archive { '/usr/lib64/nagios/plugins/check_cpu':
    ensure => present,
    source => 'https://exchange.nagios.org/components/com_mtree/attachment.php?link_id=580&cf_id=29',
  }
  ->file { '/usr/lib64/nagios/plugins/check_cpu':
    owner => 'root',
    group => 'icinga',
    mode  => '4755',
  }

  ->file { '/etc/icinga2/features-enabled/cpu.conf':
    ensure  => 'file',
    owner   => 'icinga',
    group   => 'icinga',
    mode    => '0640',
    notify  => Service['icinga2'],
    # lint:ignore:strict_indent
    content => @(CONTENT),
      object CheckCommand "cpu" {
        command = [ "/usr/lib64/nagios/plugins/check_cpu" ]
      }
      | CONTENT
    # lint:endignore
  }
  #<---------------------END-Additional-Plugins--------------------------->
  #
  #
  #<----------------------Add-Host-to-Icinga-Master----------------------->
  #  Create a directory to allocate json files
  file { $icinga_path:
    ensure => 'directory',
  }
  #  Create host file
  file { $path:
    ensure  => 'file',
    # lint:ignore:strict_indent
    content => @("CONTENT"/L),
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
    # lint:endignore
  }
  -> exec { $cmd:
    cwd      => $icinga_path,
    path     => ['/sbin', '/usr/sbin', '/bin'],
    provider => shell,
    onlyif   => $cond,
    loglevel => debug,
  }
  #  Install Nagios plugins
  package { 'nagios-plugins-all':
    ensure => 'present',
  }
  #<------------------End-Add-Host-to-Icinga-Master----------------------->
  #
  #
  #<-----------------------Add-BMC-to-Icinga-Master----------------------->
  unless $facts['is_virtual'] {
    if has_key($facts['ipmitool_mc_info'], 'Device Available') {
      $icinga_agent_bmc_fqdn = "${trusted['hostname']}-bmc.${trusted['domain']}"
      $icinga_agent_bmc_ip = "${icinga_path}/${icinga_agent_bmc_fqdn}.sh"
      $bmc_path = "${icinga_path}/${icinga_agent_bmc_fqdn}.json"
      $bmc_cmd = "curl -s -k -H '${credentials}' -H 'Accept: application/json' -X POST '${url}' -d @${bmc_path}"
      $bmc_cond = "curl -s -k -H '${credentials}' -H 'Accept: application/json' -X GET '${url}/host?name=${icinga_agent_bmc_fqdn}' | grep error"
      file { $icinga_agent_bmc_ip:
        ensure  => 'file',
        mode    => '0755',
        # lint:ignore:strict_indent
        content => @("CONTENT"/$),
          #/usr/bin/env bash
          cat > ${bmc_path} <<END
          {
          "address": "$(ipmitool lan print 1 | grep 'IP Address' | grep -v Source | awk '{print \$4}')",
          "display_name": "${icinga_agent_bmc_fqdn}",
          "imports": [
            "${bmc_template}"
          ],
          "object_name":"${icinga_agent_bmc_fqdn}",
          "object_type": "object",
          "vars": {
            "safed_profile": "3"
          }
          }
          END
          | CONTENT
        # lint:endignore
      }
      -> exec { $icinga_agent_bmc_ip:
        cwd      => $icinga_path,
        path     => ['/sbin', '/usr/sbin', '/bin'],
        provider => shell,
        unless   => "test -f ${bmc_path}",
        loglevel => debug,
      }
      -> exec { $bmc_cmd:
        cwd      => $icinga_path,
        path     => ['/sbin', '/usr/sbin', '/bin'],
        provider => shell,
        onlyif   => $bmc_cond,
        loglevel => debug,
      }
    }
  }
  #<---------------------END-Add-BMC-to-Icinga-Master--------------------->
}
