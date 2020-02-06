#This base installation is based on the procedure
# https://confluence.lsstcorp.org/display/IT/Linux+CentOS+Setup
class profile::default {
  include ssh
  include profile::it::monitoring
  # All telegraf configuration came from Hiera

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

  $motd_msg = lookup('motd')
  file { '/etc/motd' :
    ensure  => file,
    content => $motd_msg,
  }

################################################################################

}
