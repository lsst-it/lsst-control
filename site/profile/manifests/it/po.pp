
class profile::it::po {
# Remove these packages for now
Package { ensure => 'purged' }

  $enhancers = [ 'sssd', 'realmd', ]

package { $enhancers: }
# Install for now
Package { ensure => 'installed' }

  $enhancers = [ 'tree', 'oddjob', 'oddjob-mkhomedir', 'adcli',
  'openldap-clients', 'policycoreutils-python', 'tcpdump', 'openssl', 
  'openssl-devel', 'telnet', 'acpid', 'lvm2', 'bash-completion', 'sudo' ]

package { $enhancers: }
}
