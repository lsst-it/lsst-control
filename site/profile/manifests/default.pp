#This base installation is based on the procedure
# https://confluence.lsstcorp.org/display/IT/Linux+CentOS+Setup
class profile::default {
  include ssh
  include profile::it::monitoring
  include profile::it::lsst_users
  # All telegraf configuration came from Hiera

  package { 'nmap':
    ensure => installed,
  }

  package { 'vim':
    ensure => installed,
  }

  package { 'wget':
    ensure => installed,
  }

  # I would like to confirm if there is any particular version of gcc to be installed
  package { 'gcc':
    ensure => installed,
  }

  package { 'xinetd':
    ensure => installed,
  }

  package { 'tcpdump':
    ensure => installed,
  }

  package { 'openssl':
    ensure => installed,
  }

  package { 'openssl-devel':
    ensure => installed,
  }

  package { 'telnet':
    ensure => installed,
  }

  package { 'acpid':
    ensure => installed,
  }

  package { 'lvm2':
    ensure => installed,
  }

  package { 'bash-completion':
    ensure => installed,
  }

  package { 'tree':
    ensure => installed,
  }

  package { 'sudo':
    ensure => installed,
  }

# Firewall and security measurements
################################################################################

  $lsst_firewall_default_zone = lookup('lsst_firewall_default_zone')

  class { 'firewalld':
    service_ensure => lookup('firewalld_status'),
    default_zone   => $lsst_firewall_default_zone,
  }

  firewalld_zone { $lsst_firewall_default_zone:
    ensure  => present,
    target  => lookup('lsst_firewall_default_target'),
    sources => lookup('lsst_firewall_default_sources')
  }

  firewalld_service { 'Enable SSH':
    ensure  => 'present',
    service => 'ssh',
  }

  firewalld_service { 'Enable DHCP':
    ensure  => 'present',
    service => 'dhcpv6-client',
  }

  exec{'enable_icmp':
    provider => 'shell',
    command  => '/usr/bin/firewall-cmd --add-protocol=icmp --permanent && /usr/bin/firewall-cmd --reload',
    require  => Class['firewalld'],
    onlyif   => "[[ \"\$(firewall-cmd --list-protocols)\" != *\"icmp\"* ]]"
  }

################################################################################
  $ntp = lookup('ntp')
  class { '::chrony':
    servers => {
      "${$ntp[ntp_server_1]}" => ['iburst'],
      "${$ntp[ntp_server_2]}" => ['iburst'],
      "${$ntp[ntp_server_3]}" => ['iburst'],
    },
  }

  $motd_msg = lookup('motd')
  file { '/etc/motd' :
    ensure  => file,
    content => $motd_msg,
  }

  $puppet_agent_run_interval = lookup('puppet_agent_run_interval')

  ini_setting { 'Puppet agent runinterval':
    ensure  => present,
    path    => '/etc/puppetlabs/puppet/puppet.conf',
    section => 'agent',
    setting => 'runinterval',
    value   => $puppet_agent_run_interval,
  }

  ini_setting { 'Puppet agent server':
    ensure  => present,
    path    => '/etc/puppetlabs/puppet/puppet.conf',
    section => 'agent',
    setting => 'server',
    value   => lookup('puppet_master_server'),
  }

  file{'/opt/puppetlabs/puppet/cache':
    ensure => 'directory',
    mode   => '0755',
  }

  service{ 'puppet':
    ensure => lookup('puppet_agent_service_state'),
    enable => true,
  }

################################################################################

  file_line { 'SELINUX=permissive':
    path  => '/etc/selinux/config',
    line  => 'SELINUX=enforce',
    match => '^SELINUX=+',
  }

  # Set timezone as default to UTC
  exec { 'set-timezone':
    provider => 'shell',
    command  => '/bin/timedatectl set-timezone UTC',
    returns  => [0],
    onlyif   => "test -z \"$(ls -l /etc/localtime | grep -o UTC)\""
  }

# Shared resources from all the teams

  package { 'git':
    ensure => present,
  }

}
