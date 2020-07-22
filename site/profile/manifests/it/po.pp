
class profile::it::po {
# Remove these packages for now
# Package { ensure => 'purged' }

#   $enhancers = [ 'sssd', 'realmd', ]

# package { $enhancers: }
# Install for now
Package { ensure => 'installed' }

  $enhancers = [ 'tree', 'oddjob', 'oddjob-mkhomedir', 'adcli', 'wget', 'nmap',
  'openldap-clients', 'policycoreutils-python', 'tcpdump', 'openssl', 'nc',
  'git', 'openssl-devel', 'telnet', 'acpid', 'lvm2', 'bash-completion', 'sudo' ]

package { $enhancers: }
# Firewall rules
################################################################################

$lsst_firewall_default_zone = lookup("lsst_firewall_default_zone")

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
#####################################################
file_line { 'SELINUX=permissive':
  path  => '/etc/selinux/config',
  line  => 'SELINUX=enforce',
  match => '^SELINUX=+',
  }
}
